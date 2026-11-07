# LEGO Cuckoo — enclosure & mechanism v0.2 (modern style)

Parametric source: `coucou.scad` (OpenSCAD). STLs in `stl/`, already oriented for printing.
Footprint: **200 × 115 × 290 mm** (210 mm at the roof, plus chimney and weight). Every part fits a 250 mm bed.
Setting `style = "classic"` in the .scad brings back the chalet version (tiles, numerals, heart, planks).

Visuals: `../docs/img/render_3d.png` (view + cutaway), `../docs/img/front_view.png`, `../docs/front_template_1-1.pdf` (1:1 template).

## Design
- Cream front with rounded front edges (R8), thick walnut roof (6 mm) without tiles, 45° pitch.
- Anthracite Ø80 dial with white indices and no numerals (two-colour print), orange accent colour (chimney button, second hand, capsule weight).
- 2 round displays as eyes, 124 mm apart.
- 5 Mon–Fri switches at the bottom, each with its day LED on the right. Labels are engraved in French (L M M J V) on purpose.

## Mechanism
- **Guillotine door** lifted by a servo housed in the gable (arm + link). Minimum 45° roof pitch for the arm to clear.
- **Carriage on a slide**, driven by a rack + 25-tooth pinion: 180° of servo = **39.3 mm** of stroke.
- **Turntable** at the end of an arm that goes through the door: onboard servo + two 30-tooth gears (1:1). The LEGO 2×2 plate is glued on the gear.
- **LD2410C presence radar** hidden behind the front face, left of the dial (moulded slot, the board slides in from the top, antenna against the front). No hole: 24 GHz goes through 4 mm of PLA/PETG.
- **Hands driven by the ESP32** (see the main README): Hall sensor pocket in the back of the dial at 12 o'clock (r = 28 mm), wire groove to a Ø3 hole in the front face.

## Printing (PETG recommended for the mechanism)
| Part | Notes |
|---|---|
| body | front face on the bed; L–V letters engraved |
| carriage | supports under the arm |
| roof_right / roof_left | flat, inner face down |
| dial | filament change at 2 mm for the indices; Hall sensor pocket on the back |
| gears, door, rails | 0.12–0.16 mm layers, 100 % infill for the gears |

## Hardware
- M3 brass inserts (~30) + M3×8/10 screws; low-head M3 screw + nyloc nut for the turntable axle
- M2 screws + nuts (servos, door link)
- **Stepping** quartz movement with a long shaft (4 mm front + 2 mm dial), modified to be driven by the ESP32
- Ø3×2 neodymium magnet (under the minute hand) + DRV5032 SOT-23 Hall sensor

## Firmware impact
| Servo | Role | Range |
|---|---|---|
| door | arm down (90°) = closed → arm up (-90°) = open | 180° |
| rack | 0° = retracted, 180° = out | 39.3 mm |
| rotation | figure, 1:1 | ±90° around "facing front" |

- Cuckoo sequence: door opens → carriage out → rotation / sound / eyes → rotation back to 0° → carriage in → door closes.
- Radar: use the **moving target** and its distance (UART) so the eyes only wake when someone passes within ~1.5 m. Disabled in night mode, with a timeout before switching off.

## Measure before printing
"Components" section of the .scad: MG90S servos (heights), GC9A01 PCB Ø, LD2410C (16 × 22 mm), quartz movement.
