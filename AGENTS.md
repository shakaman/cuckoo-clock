# AGENTS.md

Context for coding agents (Claude Code & co.) working on this repo.

## Project
3D-printed cuckoo alarm clock for the owner's nephew (French-speaking kid). ESP32-S3 brain, swappable LEGO minifigure that comes out of a guillotine door, two round displays as eyes, quartz hands driven by the ESP32.
Status: **enclosure & mechanism v0.2 done (not printed yet); firmware not started.**

- The owner writes in French and likes short, to-the-point answers. Repo content (code, comments, docs, commits) is in **English**.
- Exception on purpose: the engraved day labels on the front stay French (`L M M J V` = Mon–Fri). Any kid-facing text (web UI, sounds) should be French.

## Layout
```
hardware/coucou.scad      parametric OpenSCAD model (single file, all parts)
hardware/stl/*.stl        print-ready STLs, already in print orientation
hardware/README.md        enclosure/mechanism notes, print settings, servo ranges
docs/                     render_3d.png, front_view.{svg,png}, front_template_1-1.pdf
tools/                    check_interference.py, front_view.py, front_template.py
firmware/                 (to create) PlatformIO project
```

## Hardware model (hardware/coucou.scad)
- Units mm. Axes: X width, Y depth (front face at y=0, +Y to the back), Z up (case bottom z=0).
- `part` selects what is rendered (`assembly` or one part name); `open_pos` 0/1 = figure in/out; `style` = `modern` (validated design) or `classic`.
- Parameter sections: Case, Components (measured/typical part sizes), Mechanism, then derived values. Change parameters, never hard-code numbers in modules.
- Key dimensions: body 200 × 115 × 190, total height 290, roof pitch 45°, door opening 40 × 62 at sill z≈117.4, dial Ø80 at z=60, eyes Ø33 window at x=±62 z=148, switches at z=12 pitch 26.
- **Invariants**
  - `roof_pitch` ≥ 45 — below that the door arm hits the roof.
  - After any geometry change: re-export the affected STLs, check each is watertight and single-body, and run `python3 tools/check_interference.py` (must print `OK`).
  - `tools/front_view.py` and `tools/front_template.py` duplicate a few front-face dimensions: keep them in sync when the front changes.
- Export one part: `openscad -D 'part="body"' -o hardware/stl/body.stl hardware/coucou.scad`
  Export all: loop over the names listed in the `part` Customizer comment (20 parts, `assembly` excluded).
- `docs/img/render_3d.png` was made with pyrender (OSMesa) from coloured STL groups; not scripted yet.
- Component sizes are typical values; the owner must measure his parts (MG90S, GC9A01 PCB, LD2410C, quartz movement) before printing.

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

MCP23017 port A: GPA0–GPA4 Mon–Fri switches, GPA5 pull-weight micro-switch, GPA6 chimney button, GPA7 DRV5032 Hall sensor. All inputs with internal pull-ups, active low.

Decisions already made (don't reopen without asking):
- NFC (PN532) was **dropped**; figure sound/animation is chosen on the web page.
- Presence = LD2410C mmWave radar hidden behind the front face (no hole). Use the *moving target* + distance so eyes wake only within ~1.5 m.
- Hands = stock **stepping** quartz movement with its coil driven by the ESP32 (no stepper motor, no third display).

## Firmware plan (not started)
Suggested stack: PlatformIO + Arduino framework, LovyanGFX (2 × GC9A01 on one SPI bus), DFRobotDFPlayerMini, RTClib (DS3231), Adafruit MCP23017, ESP32Servo or LEDC, a small LD2410 UART parser, AsyncWebServer + LittleFS for the web page, NVS (Preferences) for settings.

Behaviour spec:
- **Alarm**: time set on the web page; armed day = matching Mon–Fri switch ON; never on weekends. Sequence: sunrise on LEDs/eyes → cuckoo sequence → sound; encoder press = snooze, long press = settings.
- **Hourly cuckoo**: muted 20:00–07:00 (night mode, also disables the radar wake-up).
- **Cuckoo sequence**: door open → carriage out → rotation / sound / eye animation → rotation back to 0° → carriage in → door closed. Never move the carriage while the door is closed.
- **Servo ranges**: door arm 90° = closed, -90° = open (180° travel); rack 0° = in, 180° = out (39.3 mm); rotation 1:1, ±90° around front-facing. Ramp moves, detach or hold low when idle (kid's bedroom → noise).
- **Timekeeping**: NTP (Europe/Paris TZ, automatic DST) with DS3231 fallback. Coil: one ~30 ms pulse per second, alternating polarity (47 H / 48 L, then reverse), 150 Ω in series on each pin. Fast-forward ≈ 8 steps/s; for DST back, pause 1 h. Hall sensor triggers when the minute hand (magnet at r = 28 mm) passes 12 → re-sync minutes hourly; persist step count / hour position in NVS (limit flash writes). First setup: user enters the time shown by the hands on the web page.
- **Volume**: encoder, stored in NVS; web page shows the same value.
- Power: 5 V 3 A USB-C; servos straight from 5 V with 1000 µF; brownout-safe startup (don't sweep servos at boot).

## Git
- Local checkout uses a bare repo + worktrees: `cuckoo-clock/.bare` and `cuckoo-clock/main` (worktree). Work in `main/` or add a worktree per branch.
- Remote: `git@github.com:shakaman/cuckoo-clock.git`. Branch for non-trivial work and merge into `main`.
- Commit messages in English, imperative subject line.
