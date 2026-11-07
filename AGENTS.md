# AGENTS.md

Context for coding agents (Claude Code & co.) working on this repo.

## Project
3D-printed owl-head cuckoo alarm clock for the owner's nephew (French-speaking kid). ESP32-S3 brain, swappable LEGO minifigure that comes out of a side-hinged door, two round displays as the owl's eyes, quartz hands driven by the ESP32.
Status: **owl enclosure & mechanism v0.3 done (not printed yet); firmware not started.** The earlier chalet / modern-box design (v0.2) is in git history.

- The owner writes in French and likes short, to-the-point answers. Repo content (code, comments, docs, commits) is in **English**.
- Exception on purpose: the engraved day labels on the front stay French (`L M M J V` = Mon–Fri). Any kid-facing text (web UI, sounds) should be French.

## Layout
```
hardware/coucou.scad      parametric OpenSCAD model (single file, all parts)
hardware/stl/*.stl        print-ready STLs, already in print orientation
hardware/README.md        enclosure/mechanism notes, print settings, servo ranges
docs/                     render_3d.png, front_view.{svg,png}, front_template_1-1.pdf
tools/                    check_interference.py, front_view.py, front_template.py, render_3d.py
firmware/                 (to create) PlatformIO project
```

## Hardware model (hardware/coucou.scad)
- Units mm. Axes: X width, Y depth (front face at y=0, +Y to the back), Z up (case bottom z=0).
- `part` selects what is rendered (`assembly` or one part name); `open_pos` 0/1 = figure in/out; `door_a` forces a door angle (-1 = follow `open_pos`).
- Parameter sections: Case, Owl outline, Components (measured/typical part sizes), Mechanism, then derived values. Change parameters, never hard-code numbers in modules.
- The owl outline is a 2D polygon (`outline_pts`: rounded bottom corners + Bézier sides/ear tufts/top). Most shapes are 2D in the X/Z plane extruded along Y with `slab(y0, t)`.
- Body = one-piece shell (front + walls + top + floor), printed front face down; back panel is an inset plate screwed into 8 bosses.
- Face mask (cream) is a separate 2 mm inlay in a front pocket and carries the door hinge lugs; beak glued on top.
- Key dimensions: head 210 × 115 × 246 (tuft tips), top of head between tufts z=220, door opening 40 × 64 at sill z≈117.4, door 115.4–183.4, hinge axis (25.5, -3.1), eyes Ø33 window at x=±62 z=148, dial Ø80 at z=60, switches at z=12 pitch 26.
- Door drive: parallelogram linkage. Door tab pin `tab0`, `link_d` = tab→crank-pin vector = hinge→servo-shaft vector, so the servo crank turns exactly like the door (100°). Door servo is upside down on a shelf (tab plane z=190.5), crank z 178.5–181.5, link z 175.7–178.2 (passes through the top-right corner of the opening), door tab below the link. Figure top ≈ z 171.
- **Invariants**
  - The link must stay inside the opening (x < 20) where it crosses the front wall, for the whole 0–100° sweep — check after moving `hinge`, `tab0` or `link_d`.
  - Door top + lug must stay below the mask top band; the door servo case must clear the head top (inner top ≈ 217 at x=0).
  - After any geometry change: re-export the affected STLs, check each is watertight and single-body, and run `python3 tools/check_interference.py` (sweeps the door 0→100°; must print `OK`).
  - `tools/front_view.py` duplicates the front dimensions (outline, mask, door, beak, engravings) and `front_template.py` reuses it: keep them in sync when the front changes.
- Export one part: `openscad -D 'part="body"' -o hardware/stl/body.stl hardware/coucou.scad`
  Export all: loop over the names listed in the `part` Customizer comment (15 parts, `assembly` excluded).
- Docs regeneration: `python3 tools/front_view.py`, `python3 tools/front_template.py`, `python3 tools/render_3d.py` (needs pyrender + OSMesa).
- Component sizes are typical values; the owner must measure his parts (MG90S, GC9A01 PCB, LD2410C, quartz movement, tactile switch) before printing.

## Electronics (source of truth: README.md → BOM & pinout)
ESP32-S3-DevKitC-1 N16R8 (octal PSRAM → GPIO 26–37 unavailable).

| Function | GPIO |
|---|---|
| Display SPI SCK / MOSI / DC / RST | 12 / 11 / 9 / 10 |
| CS left / right eye (GC9A01) | 13 / 14 |
| Backlight PWM | 21 |
| I²C SDA / SCL (MCP23017 @0x20, DS3231 @0x68) | 8 / 18 |
| MCP23017 INT | 7 |
| DFPlayer TX / RX / BUSY | 17 / 16 / 15 |
| Servos door / carriage / rotation | 4 / 5 / 6 |
| Encoder A / B / SW | 1 / 2 / 42 |
| WS2812 / LEDs | 38 |
| LD2410C TX / RX / OUT (256000 baud) | 39 / 40 / 41 |
| Quartz coil A / B | 47 / 48 |

MCP23017 port A: GPA0–GPA4 Mon–Fri switches, GPA5 pull-weight micro-switch, GPA6 top button, GPA7 DRV5032 Hall sensor. All inputs with internal pull-ups, active low.

Decisions already made (don't reopen without asking):
- Owl-head shape with a side-hinged door (chosen to keep the head compact: 21 × 25 cm).
- NFC (PN532) was **dropped**; figure sound/animation is chosen on the web page.
- Presence = LD2410C mmWave radar hidden behind the front face (no hole). Use the *moving target* + distance so eyes wake only within ~1.5 m.
- Hands = stock **stepping** quartz movement with its coil driven by the ESP32 (no stepper motor, no third display).

## Firmware plan (not started)
Suggested stack: PlatformIO + Arduino framework, LovyanGFX (2 × GC9A01 on one SPI bus), DFRobotDFPlayerMini, RTClib (DS3231), Adafruit MCP23017, ESP32Servo or LEDC, a small LD2410 UART parser, AsyncWebServer + LittleFS for the web page, NVS (Preferences) for settings.

Behaviour spec:
- **Alarm**: time set on the web page; armed day = matching Mon–Fri switch ON; never on weekends. Sequence: sunrise on LEDs/eyes → cuckoo sequence → sound; encoder press = snooze, long press = settings.
- **Hourly cuckoo**: muted 20:00–07:00 (night mode, also disables the radar wake-up).
- **Eyes**: owl eyes drawn on the two GC9A01 (amber iris, black pupil); sleepy half-closed lids at rest, wide open on wake-up / presence, blink now and then.
- **Cuckoo sequence**: door open → carriage out → rotation / sound / eye animation → rotation back to 0° → carriage in → door closed. Never move the carriage while the door is closed.
- **Servo ranges**: door crank 100° from closed to open (servo upside down → calibrate direction and end points, store them in NVS); rack 0° = in, 180° = out (39.3 mm); rotation 1:1, ±90° around front-facing. Only move the carriage when the door is fully open. Ramp moves, detach or hold low when idle (kid's bedroom → noise).
- **Timekeeping**: NTP (Europe/Paris TZ, automatic DST) with DS3231 fallback. Coil: one ~30 ms pulse per second, alternating polarity (47 H / 48 L, then reverse), 150 Ω in series on each pin. Fast-forward ≈ 8 steps/s; for DST back, pause 1 h. Hall sensor triggers when the minute hand (magnet at r = 28 mm) passes 12 → re-sync minutes hourly; persist step count / hour position in NVS (limit flash writes). First setup: user enters the time shown by the hands on the web page.
- **Volume**: encoder, stored in NVS; web page shows the same value.
- Power: 5 V 3 A USB-C; servos straight from 5 V with 1000 µF; brownout-safe startup (don't sweep servos at boot).

## Git
- Local checkout uses a bare repo + worktrees: `cuckoo-clock/.bare` and `cuckoo-clock/main` (worktree). Work in `main/` or add a worktree per branch.
- Remote: `git@github.com:shakaman/cuckoo-clock.git`. Branch for non-trivial work and merge into `main`.
- Commit messages in English, imperative subject line.
