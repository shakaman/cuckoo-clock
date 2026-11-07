# LEGO Cuckoo — owl head, enclosure & mechanism v0.3

Parametric source: `coucou.scad` (OpenSCAD). STLs in `stl/`, already oriented for printing.
Footprint: **210 × 115 × 246 mm** (plus top button and pull-weight). Every part fits a 250 × 210 mm bed.
The previous chalet / modern-box design (v0.2) is in git history.

Visuals: `../docs/img/render_3d.png` (view + cutaway), `../docs/img/front_view.png`, `../docs/front_template_1-1.pdf` (1:1 template).

## Design
- Owl head: brown shell with ear tufts, cream facial mask (two discs + centre band) inlaid flush in the front, orange beak.
- The two round displays are the owl's eyes (amber iris drawn on screen; sleepy at rest, wide open on wake-up).
- Engraved brows, forehead chevrons and chest feathers (0.6 mm deep).
- Anthracite Ø80 dial with white indices as the belly; 5 Mon–Fri switches at the bottom, each with its day LED on the right. Labels are engraved in French (L M M J V) on purpose.
- Orange accents: beak, top button, second hand, capsule pull-weight.

## Mechanism
- **Side-hinged door** (like a real cuckoo door): overlay door hinged on the right, opening outwards by 100°. The hinge lugs are part of the face mask; the pin is a Ø2 brass rod (~80 mm).
- **Door drive**: parallelogram linkage — servo upside down on a shelf above the opening, crank on its horn, link to a tab behind the door. The link passes through the top-right corner of the opening; crank and link sit above the figure (≥ 4.7 mm clearance).
- **Carriage on a slide**, driven by a rack + 25-tooth pinion: 180° of servo = **39.3 mm** of stroke.
- **Turntable** at the end of an arm that goes through the door: onboard servo + two 30-tooth gears (1:1). The LEGO 2×2 plate is glued on the gear.
- **LD2410C presence radar** hidden behind the front face, left of the dial (moulded slot, board slides in from the top). No hole: 24 GHz goes through 4 mm of PLA/PETG.
- **Hands driven by the ESP32** (see the main README): Hall sensor pocket in the back of the dial at 12 o'clock (r = 28 mm), wire groove to a Ø3 hole in the front.
- **Top button**: 12×12 tactile switch on a shelf under the head, printed cap through the top.

## Parts & printing (PETG recommended for the mechanism)
| Part | Colour | Notes |
|---|---|---|
| body | brown | front face on the bed (210 × 246 footprint, 115 tall); engravings and mask pocket face the bed |
| back_panel | brown | flat |
| face_mask | cream | back on the bed, hinge lugs up; glue into the front pocket |
| beak | orange | base on the bed; glue on the mask |
| door | brown | outside face on the bed |
| door_crank, door_link | any | flat |
| deck, carriage, gears, pinion | any | carriage with supports under the arm; 100 % infill for the gears |
| dial | anthracite / white | filament change at 2 mm for the indices; Hall sensor pocket on the back |
| button_cap, weight | orange | stem / flat end on the bed |

## Hardware
- M3 brass inserts (12) + M3×8 screws (back panel, deck); low-head M3 screw + nyloc nut for the turntable axle
- M2 screws + nuts (servos, link pins)
- Ø2 × 80 mm brass rod (door hinge pin)
- **Stepping** quartz movement with a long shaft (4 mm front + 2 mm dial), modified to be driven by the ESP32
- Ø3×2 neodymium magnet (under the minute hand) + DRV5032 SOT-23 Hall sensor
- 12×12 tactile switch (7.3 mm tall)

## Firmware impact
| Servo | Role | Range |
|---|---|---|
| door | crank turns 100° (closed → open); servo mounted upside down, so calibrate the direction | 100° |
| rack | 0° = retracted, 180° = out | 39.3 mm |
| rotation | figure, 1:1 | ±90° around "facing front" |

- Cuckoo sequence: door opens → carriage out → rotation / sound / eyes → rotation back to 0° → carriage in → door closes.
- Never move the carriage unless the door is fully open (the figure would hit the door / link).
- Radar: use the **moving target** and its distance (UART) so the eyes only wake when someone passes within ~1.5 m. Disabled in night mode, with a timeout before switching off.

## Measure before printing
"Components" section of the .scad: MG90S servos (heights), GC9A01 PCB Ø, LD2410C (16 × 22 mm), quartz movement, tactile switch height.
