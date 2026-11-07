#!/usr/bin/env python3
"""3D render of the assembly (3/4 front view + cutaway) -> docs/img/render_3d.png.

Exports coloured groups of hardware/coucou.scad with OpenSCAD (open_pos=1, door open),
then renders them offscreen with pyrender (OSMesa).
Requires: openscad, pip install trimesh manifold3d pyrender PyOpenGL==3.1.7 pillow,
          libosmesa6 (apt).   Usage: python3 tools/render_3d.py   (~2-4 min)
"""
import os, pathlib, subprocess, tempfile
os.environ["PYOPENGL_PLATFORM"] = "osmesa"
import numpy
numpy.infty = numpy.inf   # pyrender still uses the removed alias
import numpy as np, trimesh, pyrender, manifold3d as m
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCAD = ROOT / "hardware" / "coucou.scad"

GROUPS = {
 "accent": "beak(); translate([btn_x, btn_y, btn_top]) button_cap(); translate([45, 30, -64]) weight(); translate([0, -8.4, dial_z]) rotate([90, 0, 0]) rotate(160) linear_extrude(1.2) hull() { circle(d = 1); translate([0, 35]) circle(d = 0.8); } translate([0, -8.6, dial_z]) rotate([90,0,0]) cylinder(d = 5, h = 1);",
 "back": "back_panel();",
 "body": "body();",
 "cord": "translate([45, 30, -30]) cylinder(d = 1.2, h = 30, $fn=12);",
 "dialbase": "translate([0, -2, dial_z]) rotate([90, 0, 0]) cylinder(d = dial_d, h = 2);",
 "door": "door_placed(door_ang);",
 "eyeamber": "for (s=[-1,1]) translate([s*eye_x, fw-0.2, eye_z]) rotate([90,0,0]) cylinder(d=28,h=0.3);",
 "eyeblack": "for (s=[-1,1]) translate([s*eye_x, fw+0.3, eye_z]) rotate([90,0,0]) cylinder(d=eye_view_d+1,h=0.3);",
 "eyeglint": "for (s=[-1,1]) translate([s*eye_x+5, fw-0.95, eye_z+3]) rotate([90,0,0]) cylinder(d=4.4,h=0.3);",
 "eyepupil": "for (s=[-1,1]) translate([s*eye_x+2, fw-0.6, eye_z]) rotate([90,0,0]) cylinder(d=16,h=0.3);",
 "fig_blue": "translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t + 2]) translate([-7.8, -4, 0]) cube([15.6, 8, 12.8]);",
 "fig_green": "translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t - 1.2]) { translate([-8, -8, 0]) cube([16, 16, 3.2]); for(x=[-4,4],y=[-4,4]) translate([x,y,3.2]) cylinder(d=4.8,h=1.7); }",
 "fig_hair": "translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t + 36.6]) { scale([1,1,0.5]) sphere(d=11); cylinder(d=11,h=1.5);}",
 "fig_red": "translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t + 14.8]) { hull(){ translate([-6.5,-4,12.8]) cube([13,8,0.1]); translate([-7.8,-4,0]) cube([15.6,8,0.1]);} for(s=[-1,1]) translate([s*8.5,-1,2]) rotate([0,s*15,0]) cylinder(d=3.5,h=10,$fn=16);}",
 "fig_yellow": "translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t + 27.6]) cylinder(d = 9.6, h = 10);",
 "hands": "module hand(len, w, a, y) translate([0, y, dial_z]) rotate([90, 0, 0]) rotate(a) linear_extrude(1.2) hull() { circle(d = w); translate([0, len]) circle(d = w * 0.8); }\nhand(22, 3.6, 150, -5.6); hand(33, 2.4, 0, -7.0);",
 "mask": "face_mask();",
 "mech": "deck(); translate([0, y_shaft, c_O]) carriage(); translate([0, y_shaft, c_O + gear_bot_l]) horn_gear(gear_teeth); translate([0, y_shaft - cd, c_O + gear_bot_l]) gear_turntable(); translate([pin_x, pin_y, pin_bot]) horn_gear(pin_teeth); tp = hinge + [crank_r * cos(crank_a0 + door_ang), crank_r * sin(crank_a0 + door_ang)]; translate([ds_S[0], ds_S[1], crank_z]) rotate([0, 0, crank_a0 + door_ang]) door_crank(); translate([tp[0], tp[1], link_z]) rotate([0, 0, atan2(link_d[1], link_d[0])]) door_link();",
 "movement": "translate([-mov_sq/2, fw, dial_z - mov_sq/2]) cube([mov_sq, mov_depth, mov_sq]);",
 "pcb": "translate([rad_x - rad_w/2, fw + 0.2, rad_z - rad_h/2]) cube([rad_w, rad_t, rad_h]); for (s = [-1, 1]) translate([s * eye_x, fw + 0.5, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_pcb_d - 0.5, h = 1.6);",
 "servos": "translate([0, y_shaft, c_O]) rotate([0, 0, 90]) servo_model(); translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) servo_model(); door_servo_placed();",
 "ticks": "translate([0, -2, dial_z]) rotate([90, 0, 0]) intersection() { dial(); translate([0, 0, 2.05]) cylinder(d = dial_d + 1, h = 2); }"
}

C = {
 'body': "#6B4F3A", 'back': "#57402F", 'mask': "#EFE9DF", 'accent': "#E07A3F", 'dialbase': "#2B2B2B", 'ticks': "#F4F1EA",
 'hands': "#F4F1EA", 'cord': "#333333", 'eyeblack': "#111111", 'eyeamber': "#F2B33D", 'eyepupil': "#111111", 'eyeglint': "#FFFFFF",
 'door': "#57402F", 'mech': "#A9ADB3", 'servos': "#3A6EA5", 'pcb': "#2E7D4F", 'movement': "#555555",
 'fig_green': "#3C8D2F", 'fig_blue': "#1F4E9C", 'fig_red': "#C8312D", 'fig_yellow': "#F2C318", 'fig_hair': "#5A3A1E",
}

CUT = {'body', 'back', 'mask', 'dialbase', 'ticks', 'movement', 'pcb', 'mech', 'door',
       'eyeblack', 'eyeamber', 'eyepupil', 'eyeglint', 'hands', 'accent'}


def rgb(h):
    return [(int(h[i:i + 2], 16) / 255) ** 2.2 for i in (1, 3, 5)] + [1]


def look_at(eye, target, up=(0, 0, 1)):
    eye, target, up = (np.array(v, dtype=float) for v in (eye, target, up))
    f = target - eye; f /= np.linalg.norm(f)
    r = np.cross(f, up); r /= np.linalg.norm(r)
    u = np.cross(r, f)
    M = np.eye(4); M[:3, 0] = r; M[:3, 1] = u; M[:3, 2] = -f; M[:3, 3] = eye
    return M


def cut_half(t):
    mm = m.Manifold(m.Mesh(vert_properties=np.asarray(t.vertices, dtype=np.float32),
                           tri_verts=np.asarray(t.faces, dtype=np.uint32)))
    o = (mm ^ m.Manifold.cube([300, 400, 600]).translate([0, -100, -150])).to_mesh()
    return trimesh.Trimesh(np.array(o.vert_properties)[:, :3], np.array(o.tri_verts))


def render(meshes, eye, target, cut, size=(1300, 1300), fov=28):
    sc = pyrender.Scene(bg_color=[0.97, 0.96, 0.945, 1], ambient_light=[0.55, 0.55, 0.55])
    for k, t in meshes.items():
        if cut and k in CUT:
            t = cut_half(t)
        if len(t.faces) == 0:
            continue
        mat = pyrender.MetallicRoughnessMaterial(baseColorFactor=rgb(C[k]), metallicFactor=0.0, roughnessFactor=0.75)
        sc.add(pyrender.Mesh.from_trimesh(t, material=mat, smooth=False))
    sc.add(pyrender.PerspectiveCamera(yfov=np.radians(fov), aspectRatio=size[0] / size[1], znear=200, zfar=2000),
           pose=look_at(eye, target))
    for d, inten in (((0.5, -1.0, 0.8), 4.5), ((-0.9, -0.5, 0.4), 2.2), ((0.2, 0.8, 1.0), 1.5)):
        sc.add(pyrender.DirectionalLight(color=[1, 1, 1], intensity=inten), pose=look_at(np.array(target) + np.array(d) * 500, target))
    r = pyrender.OffscreenRenderer(size[0] * 2, size[1] * 2)
    img, _ = r.render(sc)
    r.delete()
    return Image.fromarray(img).resize(size, Image.LANCZOS)


def main():
    meshes = {}
    with tempfile.TemporaryDirectory() as tmp:
        for k, code in GROUPS.items():
            src = pathlib.Path(tmp) / f"{k}.scad"
            src.write_text(f"include <{SCAD}>\n{code}\n")
            out = pathlib.Path(tmp) / f"{k}.stl"
            subprocess.run(["openscad", "-D", "open_pos=1", "-D", 'part="none"', "-o", str(out), str(src)],
                           check=True, capture_output=True)
            meshes[k] = trimesh.load(out)
    a = render(meshes, (260, -600, 210), (0, 30, 118), cut=False)
    b = render(meshes, (-600, -230, 270), (0, 55, 135), cut=True)
    c = Image.new("RGB", (a.width + b.width, a.height), (247, 245, 241))
    c.paste(a, (0, 0)); c.paste(b, (a.width, 0))
    c.save(ROOT / "docs" / "img" / "render_3d.png")


if __name__ == "__main__":
    main()
