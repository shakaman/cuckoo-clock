#!/usr/bin/env python3
"""1:1 printable owl front template (A3 + 2 × A4) -> docs/front_template_1-1.pdf.

Line art comes from front_view.panel(); dimensions mirror hardware/coucou.scad.
Requires: pip install cairosvg pypdf
"""
import io, pathlib, sys
import cairosvg
from pypdf import PdfReader, PdfWriter

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from front_view import (ROOT, HW, TUFT, DIP, SILL, DOOR_OPEN_W, DOOR_OPEN_H, EYE_X, EYE_Z, EYE_D,
                        DIAL_Z, DIAL_D, panel)

L, DIM = "#333", "#C0392B"


def Y(z):
    return -z


def hdim(x1, x2, z, label, above=True):
    o = 3.2 if above else -5.5
    return (f'<line x1="{x1}" y1="{Y(z)}" x2="{x2}" y2="{Y(z)}" stroke="{DIM}" stroke-width="0.25" marker-start="url(#a)" marker-end="url(#a)"/>'
            f'<text x="{(x1 + x2) / 2}" y="{Y(z + o)}" font-family="DejaVu Sans" font-size="3.6" fill="{DIM}" text-anchor="middle">{label}</text>')


def vdim(x, z1, z2, label, left=True):
    tx = x - 2 if left else x + 2
    zm = (z1 + z2) / 2
    return (f'<line x1="{x}" y1="{Y(z1)}" x2="{x}" y2="{Y(z2)}" stroke="{DIM}" stroke-width="0.25" marker-start="url(#a)" marker-end="url(#a)"/>'
            f'<text x="{tx}" y="{Y(zm)}" font-family="DejaVu Sans" font-size="3.6" fill="{DIM}" text-anchor="middle" transform="rotate(-90 {tx} {Y(zm)})">{label}</text>')


def ext(x1, z1, x2, z2):
    return f'<line x1="{x1}" y1="{Y(z1)}" x2="{x2}" y2="{Y(z2)}" stroke="{DIM}" stroke-width="0.15" stroke-dasharray="1 1"/>'


def drawing():
    S = [panel(open_=False, line=L)]
    top = TUFT[1]
    S += [ext(-HW, 0, -HW, -14), ext(HW, 0, HW, -14), hdim(-HW, HW, -12, f"{2 * HW}", above=False)]
    S += [ext(HW, 0, HW + 32, 0), ext(TUFT[0], top, HW + 32, top), vdim(HW + 29, 0, top, f"{top}", left=False)]
    S += [ext(0, DIP, HW + 18, DIP), vdim(HW + 15, 0, DIP, f"{DIP}", left=False)]
    S += [vdim(-HW - 10, 0, DIAL_Z, f"{DIAL_Z}"), ext(-DIAL_D / 2, DIAL_Z, -HW - 13, DIAL_Z)]
    S += [hdim(-DIAL_D / 2, DIAL_D / 2, DIAL_Z - 24, f"Ø{DIAL_D}")]
    S += [hdim(-EYE_X, EYE_X, EYE_Z + 47, f"{2 * EYE_X} (eye spacing)"),
          hdim(EYE_X - EYE_D / 2, EYE_X + EYE_D / 2, EYE_Z - 25, f"Ø{EYE_D}", above=False)]
    S += [vdim(-HW - 10, 0, EYE_Z, f"{EYE_Z}"), ext(-EYE_X - EYE_D / 2, EYE_Z, -HW - 13, EYE_Z)]
    S += [vdim(-HW - 20, 0, SILL, f"{SILL:.0f} (door sill)"), ext(-DOOR_OPEN_W / 2, SILL, -HW - 23, SILL)]
    S += [vdim(-DOOR_OPEN_W / 2 + 4, SILL, SILL + DOOR_OPEN_H, f"{DOOR_OPEN_H}", left=False)]
    return "\n".join(S), top


def page(w_mm, h_mm, tx, ty, extra=""):
    body, _ = drawing()
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w_mm}mm" height="{h_mm}mm" viewBox="0 0 {w_mm} {h_mm}">'
            f'<defs><marker id="a" viewBox="0 0 6 6" refX="3" refY="3" markerWidth="4" markerHeight="4" orient="auto-start-reverse"><path d="M0,0 L6,3 L0,6 Z" fill="{DIM}"/></marker></defs>'
            f'<rect width="100%" height="100%" fill="#fff"/>'
            f'<g transform="translate({tx},{ty})">{body}</g>{extra}</svg>')


def scalebar(x, y):
    t = [f'<rect x="{x}" y="{y}" width="100" height="3" fill="none" stroke="#000" stroke-width="0.3"/>']
    t += [f'<rect x="{x + i * 10}" y="{y}" width="10" height="3" fill="#000"/>' for i in range(0, 10, 2)]
    t.append(f'<text x="{x}" y="{y + 8}" font-family="DejaVu Sans" font-size="3.5">0</text>'
             f'<text x="{x + 100}" y="{y + 8}" font-family="DejaVu Sans" font-size="3.5" text-anchor="end">100 mm — check with a ruler</text>')
    return "".join(t)


def title(x, y, sub):
    return (f'<text x="{x}" y="{y}" font-family="DejaVu Sans" font-weight="bold" font-size="6">LEGO Cuckoo (owl) — front face 1:1</text>'
            f'<text x="{x}" y="{y + 5.5}" font-family="DejaVu Sans" font-size="3.6" fill="#555">{sub}</text>')


def main():
    _, top = drawing()
    pdfs = []
    # A3 portrait, single sheet
    pw, ph = 297, 420
    ex = title(15, 15, "Print at 100 % (actual size, no “fit to page”). Dimensions in mm.") + scalebar(15, 400)
    pdfs.append(cairosvg.svg2pdf(bytestring=page(pw, ph, 145, 40 + top, ex).encode()))
    # 2 × A4 landscape with a 20 mm overlap
    pw, ph = 297, 210
    total_top, total_bot = top + 10, -45
    mid = total_bot + (total_top - total_bot) / 2
    zc = mid - 10
    for k, zmax in enumerate((total_top, mid + 10)):
        ty = 14 + zmax
        marks = f'<line x1="0" y1="{ty - zc}" x2="{pw}" y2="{ty - zc}" stroke="#2980B9" stroke-width="0.3" stroke-dasharray="3 2"/>'
        if k == 0:
            marks += f'<text x="8" y="{ty - zc - 1.5}" font-family="DejaVu Sans" font-size="3.4" fill="#2980B9">Sheet 1 — cut here and overlay on the line of sheet 2</text>'
        else:
            marks += f'<text x="8" y="{ty - zc + 4.5}" font-family="DejaVu Sans" font-size="3.4" fill="#2980B9">Sheet 2 — align the top of sheet 1 on this line</text>'
            marks += scalebar(185, 197)
        marks += f'<rect width="{pw}" height="13" fill="#fff"/>' + title(8, 7, f"2 × A4 landscape — sheet {k + 1}/2 — print at 100 %")
        pdfs.append(cairosvg.svg2pdf(bytestring=page(pw, ph, 140, ty, marks).encode()))
    w = PdfWriter()
    for p in pdfs:
        for pg in PdfReader(io.BytesIO(p)).pages:
            w.add_page(pg)
    with open(ROOT / "docs" / "front_template_1-1.pdf", "wb") as f:
        w.write(f)


if __name__ == "__main__":
    main()
