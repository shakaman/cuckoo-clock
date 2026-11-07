#!/usr/bin/env python3
"""Collision check between fixed and moving parts of hardware/coucou.scad.

Exports world-placed groups and reports every pairwise intersection larger
than 0.5 mm³, for these states:
  - figure in  (open_pos=0) with the door swept from closed to open,
  - figure out (open_pos=1) with the door fully open.
Skipped pairs: pinion/carriage (gears mesh) and door servo/crank (horn seated in the crank).

Requires: openscad on PATH, pip install trimesh manifold3d numpy
Usage:    python3 tools/check_interference.py      (~3-6 min)
"""
import itertools, pathlib, subprocess, sys, tempfile
import numpy as np, trimesh, manifold3d as m

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCAD = ROOT / "hardware" / "coucou.scad"
DOOR_SWEEP = [0, 20, 40, 60, 80, 100]

STATIC = {
    "case": "body(); back_panel(); face_mask(); beak();"
            " translate([0, -2, dial_z]) rotate([90, 0, 0]) dial();"
            " translate([-mov_sq/2, fw, dial_z - mov_sq/2]) cube([mov_sq, mov_depth, mov_sq]);"
            " for (s = [-1, 1]) translate([s * eye_x, fw + 0.5, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_pcb_d - 0.5, h = 4);"
            " translate([rad_x - rad_w/2, fw + 0.2, rad_z - rad_h/2]) cube([rad_w, rad_t, rad_h]);"
            " translate([btn_x, btn_y, btn_top]) button_cap();",
    "deck": "deck();",
    "dservo": "door_servo_placed();",
}
MOVING = {
    "pinion": "translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) servo_model();"
              " translate([pin_x, pin_y, pin_bot]) cylinder(r = gear_m * pin_teeth / 2 + gear_m, h = gear_t);",
    "carr": "translate([0, y_shaft, c_O]) carriage(); translate([0, y_shaft, c_O]) rotate([0, 0, 90]) servo_model();"
            " translate([0, y_shaft, c_O + gear_bot_l]) cylinder(r = gear_m * gear_teeth / 2 + gear_m, h = gear_t);"
            " translate([0, y_shaft - cd, c_O + gear_bot_l]) cylinder(r = gear_m * gear_teeth / 2 + gear_m, h = gear_t);"
            " translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t - 1.2]) minifig_ghost();",
}
# rack/pinion mesh on purpose; the servo horn sits in the crank recess on purpose
SKIP = {frozenset({"pinion", "carr"}), frozenset({"dservo", "crank"})}


def library_source():
    s = SCAD.read_text()
    i = s.index("// ================================================================ SELECTION")
    return s[:i].replace('part = "assembly";', 'part = "none";')


def load(path):
    t = trimesh.load(path)
    return m.Manifold(m.Mesh(vert_properties=np.asarray(t.vertices, dtype=np.float32),
                             tri_verts=np.asarray(t.faces, dtype=np.uint32)))


def main():
    lib = library_source()
    found = 0
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)

        def build(name, code, pos):
            src = tmp / f"{name}.scad"
            src.write_text(lib + "\n" + code + "\n")
            out = tmp / f"{name}_{pos}.stl"
            subprocess.run(["openscad", "-D", f"open_pos={pos}", "-o", str(out), str(src)],
                           check=True, capture_output=True)
            return load(out)

        static = {k: build(k, v, 0) for k, v in STATIC.items()}
        states = [(0, a) for a in DOOR_SWEEP] + [(1, 100)]
        moving_cache = {}
        for pos, ang in states:
            if pos not in moving_cache:
                moving_cache[pos] = {k: build(k, v, pos) for k, v in MOVING.items()}
            groups = dict(static, **moving_cache[pos])
            # door, crank and link, each on its own so their pin joints don't count
            groups["door"] = build(f"door{ang}", f"door_placed({ang});", pos)
            groups["crank"] = build(f"crank{ang}",
                f"translate([ds_S[0], ds_S[1], crank_z]) rotate([0, 0, crank_a0 + {ang}]) door_crank();", pos)
            groups["link"] = build(f"link{ang}",
                f"tp = hinge + [crank_r * cos(crank_a0 + {ang}), crank_r * sin(crank_a0 + {ang})];"
                f" translate([tp[0], tp[1], link_z]) rotate([0, 0, atan2(link_d[1], link_d[0])]) door_link();", pos)
            for a, b in itertools.combinations(groups, 2):
                if frozenset({a, b}) in SKIP:
                    continue
                for piece in (groups[a] ^ groups[b]).decompose():
                    if piece.volume() > 0.5:
                        found += 1
                        print(f"open_pos={pos} door={ang}°  {a} × {b}  {piece.volume():.1f} mm³"
                              f"  bbox={[round(v, 1) for v in piece.bounding_box()]}")
    print("OK: no interference" if not found else f"{found} interference(s)")
    sys.exit(1 if found else 0)


if __name__ == "__main__":
    main()
