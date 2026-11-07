#!/usr/bin/env python3
"""Owl front elevation (at rest / wake-up) -> docs/img/front_view.{svg,png}.

Shapes mirror hardware/coucou.scad (outline, mask, door, beak, engravings):
update both when the front changes. `panel()` is reused by front_template.py.
Requires: pip install cairosvg
"""
import math, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent

# ---- dimensions (keep in sync with coucou.scad)
HW, SIDE_TOP, TUFT, DIP, CORNER_R = 105, 165, (98, 246), 220, 20
SILL, DOOR_OPEN_W, DOOR_OPEN_H = 117.4, 40, 64
DOOR_BOT, DOOR_TOP, HINGE_X = 115.4, 183.4, 25.5
EYE_X, EYE_Z, EYE_D = 62, 148, 33
DIAL_Z, DIAL_D = 60, 80
BTN_X = -25

BROWN, BROWN_D, BROWN_L = "#6B4F3A", "#57402F", "#8A6A50"
CREAM, DIAL, ACC, INK, AMBER = "#EFE9DF", "#2B2B2B", "#E07A3F", "#F6F3EC", "#F2B33D"


def Y(z):
    return -z


def bez(p0, p1, p2, p3, n=24):
    return [tuple((1 - t) ** 3 * a + 3 * (1 - t) ** 2 * t * b + 3 * (1 - t) * t * t * c + t ** 3 * d
                  for a, b, c, d in zip(p0, p1, p2, p3)) for t in (i / n for i in range(n + 1))]


def qbez(p0, p1, p2, n=20):
    return [tuple((1 - t) ** 2 * a + 2 * (1 - t) * t * b + t * t * c for a, b, c in zip(p0, p1, p2))
            for t in (i / n for i in range(n + 1))]


def outline_path():
    side = bez((HW, SIDE_TOP), (HW, SIDE_TOP + 38), (HW - 1, SIDE_TOP + 61), TUFT, 16)
    top = bez(TUFT, (TUFT[0] - 23, TUFT[1] - 16), (35, DIP), (0, DIP))
    pts = side + top[1:] + [(-x, z) for x, z in reversed(top[:-1])] + [(-x, z) for x, z in reversed(side)]
    d = f"M{-HW + CORNER_R},0 L{HW - CORNER_R},0 A{CORNER_R},{CORNER_R} 0 0 0 {HW},{Y(CORNER_R)} "
    d += " ".join(f"L{x:.2f},{Y(z):.2f}" for x, z in pts)
    d += f" L{-HW},{Y(CORNER_R)} A{CORNER_R},{CORNER_R} 0 0 0 {-HW + CORNER_R},0 Z"
    return d


def polyline(pts, color, w):
    return (f'<polyline points="{" ".join(f"{x:.2f},{Y(z):.2f}" for x, z in pts)}" fill="none" '
            f'stroke="{color}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"/>')


def mask_path():
    return f"M-31,{Y(104)} L31,{Y(104)} L31,{Y(194)} L0,{Y(186)} L-31,{Y(194)} Z"


def minifig(S, b):
    S.append(f'<rect x="-16" y="{Y(b)}" width="32" height="6" rx="1.5" fill="#9a9a9a"/>')
    b += 0.5
    S.append(f'<rect x="-8" y="{Y(b + 3.2)}" width="16" height="3.2" fill="#3C8D2F"/>')
    S.append(f'<rect x="-7" y="{Y(b + 16)}" width="14" height="12.8" fill="#1f4e9c"/>')
    S.append(f'<path d="M-7.8,{Y(b + 28.8)} L7.8,{Y(b + 28.8)} L7,{Y(b + 16)} L-7,{Y(b + 16)} Z" fill="#c8312d"/>')
    S.append(f'<rect x="-11" y="{Y(b + 27)}" width="3.5" height="10" rx="1.5" fill="#c8312d" transform="rotate(-25 -9 {Y(b + 26)})"/>')
    S.append(f'<rect x="-4.8" y="{Y(b + 38.8)}" width="9.6" height="10" rx="2.5" fill="#F2C318"/>')
    S.append(f'<rect x="-5.5" y="{Y(b + 42.5)}" width="11" height="4.5" rx="2" fill="#5a3a1e"/>')
    S.append(f'<circle cx="-1.8" cy="{Y(b + 33.8)}" r="0.7" fill="#222"/><circle cx="1.8" cy="{Y(b + 33.8)}" r="0.7" fill="#222"/>')


def panel(open_=False, line=None):
    """SVG group content. line=None -> colour illustration; line='#333' -> line art for the template."""
    S = []
    fill = (lambda c: "#fff") if line else (lambda c: c)
    st = f' stroke="{line}" stroke-width="0.35"' if line else ""
    if not line:
        S.append(f'<ellipse cx="0" cy="{Y(-6)}" rx="115" ry="5" fill="#000" opacity="0.06"/>')
    # cord + weight
    S.append(f'<line x1="45" y1="0" x2="45" y2="{Y(-30)}" stroke="#444" stroke-width="0.9"/>')
    S.append(f'<rect x="36" y="{Y(-30)}" width="18" height="34" rx="9" fill="{fill(ACC)}"{st}/>')
    # top button
    S.append(f'<ellipse cx="{BTN_X}" cy="{Y(221.6)}" rx="7" ry="3.2" fill="{fill(ACC)}"{st}/>')
    S.append(f'<path d="{outline_path()}" fill="{fill(BROWN)}"{st}/>')
    # engravings: forehead chevrons, brows, chest scallops
    ec = line or BROWN_L
    for x in (-22, 0, 22):
        S.append(polyline([(x - 7, 213), (x, 208), (x + 7, 213)], ec, 1.6 if not line else 0.5))
    for s in (-1, 1):
        S.append(polyline(qbez((s * 6, 197), (s * 40, 212), (s * 97, 190)), BROWN_D if not line else line, 3 if not line else 0.5))
    for row in range(4):
        for s in (-1, 1):
            for k in range(3):
                z = 34 + row * 18
                x = s * (55 + k * 16 + (8 if row % 2 else 0))
                if abs(x) + 8 < HW - 4 and not (z > 80 and k == 2):
                    S.append(polyline([(x + 8 * math.cos(math.radians(a)), z + 8 * math.sin(math.radians(a)))
                                       for a in range(180, 361, 15)], ec, 1.6 if not line else 0.5))
    # facial mask (clipped to the outline)
    S.append(f'<clipPath id="head{int(open_)}"><path d="{outline_path()}"/></clipPath>')
    S.append(f'<g clip-path="url(#head{int(open_)})">')
    S.append(f'<path d="{mask_path()}" fill="{fill(CREAM)}"{st}/>')
    for s in (-1, 1):
        S.append(f'<circle cx="{s * EYE_X}" cy="{Y(EYE_Z)}" r="44" fill="{fill(CREAM)}"{st}/>')
    if not line:
        S.append(f'<path d="{mask_path()}" fill="{CREAM}"/>')
    S.append('</g>')
    # eyes (displays)
    for s in (-1, 1):
        ex = s * EYE_X
        S.append(f'<circle cx="{ex}" cy="{Y(EYE_Z)}" r="20" fill="{fill(BROWN)}"{st}/>')
        S.append(f'<circle cx="{ex}" cy="{Y(EYE_Z)}" r="{EYE_D / 2}" fill="{fill("#111")}"{st}/>')
        if line:
            S.append(f'<path d="M{ex - 3},{Y(EYE_Z)} h6 M{ex},{Y(EYE_Z - 3)} v6" stroke="{line}" stroke-width="0.35"/>')
            continue
        S.append(f'<circle cx="{ex}" cy="{Y(EYE_Z)}" r="14" fill="{AMBER}"/>')
        dx = 2 if open_ else 0
        S.append(f'<circle cx="{ex + dx}" cy="{Y(EYE_Z)}" r="{8 if open_ else 6.5}" fill="#111"/>')
        S.append(f'<circle cx="{ex + dx + 3}" cy="{Y(EYE_Z + 3)}" r="2.2" fill="#fff"/>')
        if not open_:  # sleepy eyelids
            S.append(f'<path d="M{ex - 15},{Y(EYE_Z + 1)} A15,15 0 0 1 {ex + 15},{Y(EYE_Z + 1)} Z" fill="#3a2b20"/>')
    # door: hinge lugs, overlay door (closed) or opening + open door
    for z0, z1 in ((DOOR_BOT - 6.4, DOOR_BOT - 0.4), (DOOR_TOP + 0.4, DOOR_TOP + 6.4)):
        S.append(f'<rect x="{HINGE_X - 2.8}" y="{Y(z1)}" width="5.6" height="{z1 - z0}" rx="1" fill="{fill(CREAM)}"{st if line else f" stroke=\"#cfc6b8\" stroke-width=\"0.5\""}/>')
    w = DOOR_OPEN_W
    if not open_:
        S.append(f'<rect x="{-w / 2 - 3}" y="{Y(DOOR_TOP)}" width="{HINGE_X + w / 2 + 3}" height="{DOOR_TOP - DOOR_BOT}" rx="1.5" fill="{fill(BROWN_D)}"{st}/>')
        S.append(f'<rect x="{-w / 2}" y="{Y(SILL + DOOR_OPEN_H)}" width="{w}" height="{DOOR_OPEN_H}" fill="none" stroke="{line or BROWN}" stroke-width="0.4" stroke-dasharray="{"2 1" if line else "0"}"/>')
        for i in range(4):
            z = DOOR_BOT + 14 + i * 13
            S.append(polyline(qbez((-10, z), (0, z - 6), (10, z), 8), ec, 1.4 if not line else 0.5))
    else:
        S.append(f'<rect x="{-w / 2}" y="{Y(SILL + DOOR_OPEN_H)}" width="{w}" height="{DOOR_OPEN_H}" fill="{fill("#2a221d")}"{st}/>')
        if not line:
            minifig(S, SILL + 6)
        S.append(f'<path d="M{HINGE_X},{Y(DOOR_BOT)} L{HINGE_X + 9},{Y(DOOR_BOT - 6)} L{HINGE_X + 9},{Y(DOOR_TOP + 6)} L{HINGE_X},{Y(DOOR_TOP)} Z" fill="{fill(BROWN_D)}"{st}/>')
    # beak
    S.append(f'<path d="M-8,{Y(114)} L8,{Y(114)} L0,{Y(101.5)} Z" fill="{fill(ACC)}" stroke="{line or "#c4612b"}" stroke-width="{0.35 if line else 0.6}" stroke-linejoin="round"/>')
    # dial
    S.append(f'<circle cx="0" cy="{Y(DIAL_Z)}" r="{DIAL_D / 2}" fill="{fill(DIAL)}"{st}/>')
    for h in range(12):
        a = math.radians(90 - h * 30); big = h % 3 == 0
        r1 = DIAL_D / 2 - (14 if big else 8); r2 = DIAL_D / 2 - 4
        S.append(f'<line x1="{r1 * math.cos(a):.2f}" y1="{Y(DIAL_Z + r1 * math.sin(a)):.2f}" x2="{r2 * math.cos(a):.2f}" y2="{Y(DIAL_Z + r2 * math.sin(a)):.2f}" stroke="{line or INK}" stroke-width="{(2.6 if big else 1.3) if not line else (1.2 if big else 0.6)}" stroke-linecap="round"/>')

    def hand(ang, l, w, col):
        a = math.radians(90 - ang)
        return f'<line x1="0" y1="{Y(DIAL_Z)}" x2="{l * math.cos(a):.2f}" y2="{Y(DIAL_Z + l * math.sin(a)):.2f}" stroke="{col}" stroke-width="{w}" stroke-linecap="round"/>'
    hh, mm = (7, 0) if open_ else (10, 10)
    S.append(hand(hh * 30 + mm / 2, 22, 3.6 if not line else 2.2, line or INK))
    S.append(hand(mm * 6, 33, 2.4 if not line else 1.4, line or INK))
    if not line:
        S.append(hand(200, 35, 0.9, ACC))
    S.append(f'<circle cx="0" cy="{Y(DIAL_Z)}" r="2.2" fill="{line or ACC}"/>')
    # day switches + LEDs + labels
    for i, d in enumerate("LMMJV"):
        x = (i - 2) * 26
        S.append(f'<circle cx="{x}" cy="{Y(12)}" r="5" fill="{fill(BROWN_D)}"{st}/><circle cx="{x}" cy="{Y(12)}" r="3.15" fill="{fill("#c9c4bb")}"{st}/>')
        if not line:
            S.append(f'<rect x="{x - 1.1}" y="{Y(19)}" width="2.2" height="7" rx="1.1" fill="#e2ddd5"/>')
        led = ACC if (open_ and i == 4) else "#7cc576"
        S.append(f'<circle cx="{x + 9}" cy="{Y(12)}" r="1.6" fill="{fill(led)}"{st}/>')
        S.append(f'<text x="{x}" y="{Y(1.8)}" font-family="DejaVu Sans" font-weight="bold" font-size="4.5" fill="{line or CREAM}" text-anchor="middle">{d}</text>')
    return "\n".join(S)


def main():
    import cairosvg
    W, pad = 2 * HW, 22
    vw = W + 2 * pad; top = TUFT[1] + 14; vh = top + 80
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {2 * vw + 10} {vh}" '
           f'width="{(2 * vw + 10) * 6}" height="{vh * 6}"><rect width="100%" height="100%" fill="#F7F5F1"/>')
    for k, o in enumerate((False, True)):
        cx = k * (vw + 10) + vw / 2
        svg += f'<g transform="translate({cx},{top})">{panel(o)}</g>'
        label = "At rest (sleepy eyes)" if not o else "Wake-up: eyes wide open, figure out"
        svg += f'<text x="{cx}" y="{vh - 6}" font-family="DejaVu Sans" font-size="6" fill="#777" text-anchor="middle">{label}</text>'
    svg += '</svg>'
    out = ROOT / "docs" / "img"
    (out / "front_view.svg").write_text(svg)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=str(out / "front_view.png"))


if __name__ == "__main__":
    main()
