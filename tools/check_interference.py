#!/usr/bin/env python3
"""Collision check between fixed and moving parts of hardware/coucou.scad.

Exports world-placed groups for both mechanism states (open_pos = 0 and 1),
then reports every pairwise intersection larger than 0.5 mm³.
The pinion/carriage pair is skipped (rack and pinion mesh on purpose).

Requires: openscad on PATH, pip install trimesh manifold3d numpy
Usage:    python3 tools/check_interference.py      (~2-4 min)
"""
import itertools, pathlib, subprocess, sys, tempfile
import numpy as np, trimesh, manifold3d as m

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCAD = ROOT / "hardware" / "coucou.scad"

GROUPS = {
    "static": "body(); back_panel(); gable(true); gable(false); roof(1); roof(-1);"
              " translate([-mov_sq/2, fw, dial_z - mov_sq/2]) cube([mov_sq, mov_depth, mov_sq]);"
              " for (s = [-1, 1]) translate([s * eye_x, fw + 0.5, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_pcb_d - 0.5, h = 4);",
    "deck": "deck();",
    "rails": "translate([0, fw, 0]) door_rails();",
    "dmount": "door_servo_mount(); translate([0, ds_O_y, z_ds]) rotate([90, 0, 0]) servo_model();",
    "pinion": "translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) servo_model();"
              " translate([pin_x, pin_y, pin_bot]) cylinder(r = gear_m * pin_teeth / 2 + gear_m, h = gear_t);",
    "carr": "translate([0, y_shaft, c_O]) carriage(); translate([0, y_shaft, c_O]) rotate([0, 0, 90]) servo_model();"
            " translate([0, y_shaft, c_O + gear_bot_l]) cylinder(r = gear_m * gear_teeth / 2 + gear_m, h = gear_t);"
            " translate([0, y_shaft - cd, c_O + gear_bot_l]) cylinder(r = gear_m * gear_teeth / 2 + gear_m, h = gear_t);"
            " translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t - 1.2]) minifig_ghost();",
    "door": "translate([0, fw + 0.2, door_z]) door();",
    # full sweep of the door arm, whatever open_pos is
    "darm": "for (da = [-90:15:90]) translate([0, ds_arm_y, z_ds]) rotate([-90, 0, 0]) rotate([0, 0, da]) door_arm();",
}
SKIP = {frozenset({"pinion", "carr"})}


def library_source():
    s = SCAD.read_text()
    i = s.index("// ================================================================ SELECTION")
    j = s.index("module roof_flat")
    return (s[:i] + s[j:]).replace('part = "assembly";', 'part = "none";')


def load(path):
    t = trimesh.load(path)
    return m.Manifold(m.Mesh(vert_properties=np.asarray(t.vertices, dtype=np.float32),
                             tri_verts=np.asarray(t.faces, dtype=np.uint32)))


def main():
    lib = library_source()
    found = 0
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        for pos in (0, 1):
            meshes = {}
            for name, code in GROUPS.items():
                src = tmp / f"{name}.scad"
                src.write_text(lib + "\n" + code + "\n")
                out = tmp / f"{name}_{pos}.stl"
                subprocess.run(["openscad", "-D", f"open_pos={pos}", "-o", str(out), str(src)],
                               check=True, capture_output=True)
                meshes[name] = load(out)
            for a, b in itertools.combinations(GROUPS, 2):
                if frozenset({a, b}) in SKIP:
                    continue
                for piece in (meshes[a] ^ meshes[b]).decompose():
                    if piece.volume() > 0.5:
                        found += 1
                        print(f"open_pos={pos}  {a} × {b}  {piece.volume():.1f} mm³  bbox={[round(v, 1) for v in piece.bounding_box()]}")
    print("OK: no interference" if not found else f"{found} interference(s)")
    sys.exit(1 if found else 0)


if __name__ == "__main__":
    main()
