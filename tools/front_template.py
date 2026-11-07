"""1:1 printable front-face template (A3 + 2×A4) -> docs/front_template_1-1.pdf.
Dimensions mirror hardware/coucou.scad (update both). Requires: pip install cairosvg pypdf"""
import pathlib
ROOT = pathlib.Path(__file__).resolve().parent.parent
import math, cairosvg, io
from pypdf import PdfWriter, PdfReader

W, H, pitch = 200, 190, 45
gh = W/2*math.tan(math.radians(pitch)); ovh = 5; rt = 6
sill = 117.4; dw, dh = 40, 62
eye_x, eye_z, eye_d = 62, 148, 33
dial_z, dial_d = 60, 80
L = "#333"; LW = 0.35
DIM = "#C0392B"

def Y(z): return -z

def drawing():
    S = []
    st = f'stroke="{L}" stroke-width="{LW}"'
    # cordon + contrepoids
    S.append(f'<line x1="45" y1="0" x2="45" y2="{Y(-30)}" {st} stroke-dasharray="2 1"/>')
    S.append(f'<rect x="36" y="{Y(-30)}" width="18" height="34" rx="9" fill="#F6D9C6" {st}/>')
    # cheminée
    s = 51; cx = s*math.cos(math.radians(pitch)); cz = H+gh-s*math.sin(math.radians(pitch))
    xl, xr = cx-6, cx+14
    S.append(f'<path d="M{xl},{Y(cz+30)} L{xr},{Y(cz+30)} L{xr},{Y(H+gh-xr)} L{xl},{Y(H+gh-xl)} Z" fill="#F6D9C6" {st}/>')
    # corps + pignon
    S.append(f'<path d="M{-W/2},0 L{-W/2},{Y(H)} L0,{Y(H+gh)} L{W/2},{Y(H)} L{W/2},0 Z" fill="#FBFAF7" {st}/>')
    # toit
    n = rt/math.cos(math.radians(pitch))
    for sg in (-1, 1):
        x0 = sg*(W/2+ovh); z0 = H-ovh*math.tan(math.radians(pitch))
        S.append(f'<path d="M0,{Y(H+gh)} L{x0},{Y(z0)} L{x0},{Y(z0+n)} L0,{Y(H+gh+n)} Z" fill="#D9CFC5" {st}/>')
    # yeux
    for sg in (-1, 1):
        ex = sg*eye_x
        S.append(f'<circle cx="{ex}" cy="{Y(eye_z)}" r="{eye_d/2}" fill="#E4E4E4" {st}/>')
        S.append(f'<rect x="{ex-7.5}" y="{Y(eye_z+10)}" width="15" height="20" rx="7.5" fill="#fff" {st}/>')
        S.append(f'<line x1="{ex-3}" y1="{Y(eye_z)}" x2="{ex+3}" y2="{Y(eye_z)}" {st}/><line x1="{ex}" y1="{Y(eye_z-3)}" x2="{ex}" y2="{Y(eye_z+3)}" {st}/>')
    # porte
    S.append(f'<rect x="{-dw/2}" y="{Y(sill+dh)}" width="{dw}" height="{dh}" fill="#E9E2DA" {st}/>')
    # cadran
    S.append(f'<circle cx="0" cy="{Y(dial_z)}" r="{dial_d/2}" fill="#EDEDED" {st}/>')
    for h in range(12):
        a = math.radians(90-h*30); big = h % 3 == 0
        r1 = dial_d/2-(12 if big else 7); r2 = dial_d/2-4
        S.append(f'<line x1="{r1*math.cos(a)}" y1="{Y(dial_z+r1*math.sin(a))}" x2="{r2*math.cos(a)}" y2="{Y(dial_z+r2*math.sin(a))}" stroke="{L}" stroke-width="{1.4 if big else 0.7}" stroke-linecap="round"/>')
    for ang, l, w in ((305, 22, 2.2), (60, 33, 1.4)):
        a = math.radians(90-ang)
        S.append(f'<line x1="0" y1="{Y(dial_z)}" x2="{l*math.cos(a)}" y2="{Y(dial_z+l*math.sin(a))}" stroke="{L}" stroke-width="{w}" stroke-linecap="round"/>')
    S.append(f'<circle cx="0" cy="{Y(dial_z)}" r="1.6" fill="{L}"/>')
    # interrupteurs, LED, lettres
    for i, d in enumerate("LMMJV"):
        x = (i-2)*26
        S.append(f'<circle cx="{x}" cy="{Y(12)}" r="5" fill="#fff" {st}/><circle cx="{x}" cy="{Y(12)}" r="3.15" fill="none" {st}/>')
        S.append(f'<circle cx="{x+9}" cy="{Y(12)}" r="1.6" fill="#fff" {st}/>')
        S.append(f'<text x="{x}" y="{Y(1.8)}" font-family="DejaVu Sans" font-weight="bold" font-size="4.5" fill="{L}" text-anchor="middle">{d}</text>')
    # ---- cotes
    def hdim(x1, x2, z, label, above=True):
        o = 3.2 if above else -5.5
        return (f'<line x1="{x1}" y1="{Y(z)}" x2="{x2}" y2="{Y(z)}" stroke="{DIM}" stroke-width="0.25" marker-start="url(#a)" marker-end="url(#a)"/>'
                f'<text x="{(x1+x2)/2}" y="{Y(z+o)}" font-family="DejaVu Sans" font-size="3.6" fill="{DIM}" text-anchor="middle">{label}</text>')
    def vdim(x, z1, z2, label, left=True):
        tx = x-2 if left else x+2
        return (f'<line x1="{x}" y1="{Y(z1)}" x2="{x}" y2="{Y(z2)}" stroke="{DIM}" stroke-width="0.25" marker-start="url(#a)" marker-end="url(#a)"/>'
                f'<text x="{tx}" y="{Y((z1+z2)/2)}" font-family="DejaVu Sans" font-size="3.6" fill="{DIM}" text-anchor="middle" transform="rotate(-90 {tx} {Y((z1+z2)/2)})">{label}</text>')
    def ext(x1, z1, x2, z2):
        return f'<line x1="{x1}" y1="{Y(z1)}" x2="{x2}" y2="{Y(z2)}" stroke="{DIM}" stroke-width="0.15" stroke-dasharray="1 1"/>'
    top = H+gh+n
    S += [ext(-W/2, 0, -W/2, -14), ext(W/2, 0, W/2, -14), hdim(-W/2, W/2, -12, "200 (body)", above=False)]
    S += [ext(-W/2-ovh, H-ovh, -W/2-ovh, H+20), ext(W/2+ovh, H-ovh, W/2+ovh, H+20), hdim(-W/2-ovh, W/2+ovh, H+18, "210 (roof)")]
    S += [ext(W/2, H, W/2+18, H), vdim(W/2+15, 0, H, "190", left=False)]
    S += [ext(0, top, W/2+32, top), ext(W/2, 0, W/2+32, 0), vdim(W/2+29, 0, top, f"{top:.0f} (without chimney)", left=False)]
    S += [vdim(-W/2-10, 0, dial_z, "60"), ext(-dial_d/2, dial_z, -W/2-13, dial_z)]
    S += [hdim(-dial_d/2, dial_d/2, dial_z+dial_d/2+5, "Ø80")]
    S += [hdim(-eye_x, eye_x, eye_z+eye_d/2+5, "124 (eye spacing)"), hdim(eye_x-eye_d/2, eye_x+eye_d/2, eye_z-eye_d/2-4, "Ø33", above=False)]
    S += [vdim(-W/2-10, 0, eye_z, "148"), ext(-eye_x-eye_d/2, eye_z, -W/2-13, eye_z)]
    S += [hdim(-dw/2, dw/2, sill+dh+3, "40"), vdim(dw/2+5, sill, sill+dh, "62", left=False)]
    S += [vdim(-W/2-20, 0, sill, "117"), ext(-dw/2, sill, -W/2-23, sill)]
    return "\n".join(S), top

def page(w_mm, h_mm, tx, ty, extra=""):
    body, top = drawing()
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w_mm}mm" height="{h_mm}mm" viewBox="0 0 {w_mm} {h_mm}">'
            f'<defs><marker id="a" viewBox="0 0 6 6" refX="3" refY="3" markerWidth="4" markerHeight="4" orient="auto-start-reverse"><path d="M0,0 L6,3 L0,6 Z" fill="{DIM}"/></marker></defs>'
            f'<rect width="100%" height="100%" fill="#fff"/>'
            f'<g transform="translate({tx},{ty})">{body}</g>{extra}</svg>')

def scalebar(x, y):
    t = [f'<rect x="{x}" y="{y}" width="100" height="3" fill="none" stroke="#000" stroke-width="0.3"/>']
    for i in range(10):
        if i % 2 == 0: t.append(f'<rect x="{x+i*10}" y="{y}" width="10" height="3" fill="#000"/>')
    t.append(f'<text x="{x}" y="{y+8}" font-family="DejaVu Sans" font-size="3.5">0</text><text x="{x+100}" y="{y+8}" font-family="DejaVu Sans" font-size="3.5" text-anchor="end">100 mm — check with a ruler</text>')
    return "".join(t)

def title(x, y, sub):
    return (f'<text x="{x}" y="{y}" font-family="DejaVu Sans" font-weight="bold" font-size="6">LEGO Cuckoo — front face 1:1</text>'
            f'<text x="{x}" y="{y+5.5}" font-family="DejaVu Sans" font-size="3.6" fill="#555">{sub}</text>')

_, top = drawing()
pdfs = []
# --- page A3 portrait, une seule feuille
pw, ph = 297, 420
tx = 140; ty = 25 + top
ex = title(15, 15, "Print at 100 % (actual size, no “fit to page”). Dimensions in mm.") + scalebar(15, 400)
pdfs.append(cairosvg.svg2pdf(bytestring=page(pw, ph, tx, ty, ex).encode()))
# --- 2 feuilles A4 paysage à assembler (recouvrement 20 mm)
pw, ph = 297, 210
total_top, total_bot = top + 10, -70      # étendue en z
span = total_top - total_bot
mid = total_bot + span/2
cuts = [(mid - 10, total_top), (total_bot, mid + 10)]   # (zmin, zmax) par feuille
for k, (zmin, zmax) in enumerate(cuts):
    ty = 12 + zmax
    marks = ""
    if k == 0:
        zc = mid - 10
        marks += f'<line x1="0" y1="{ty - zc}" x2="{pw}" y2="{ty - zc}" stroke="#2980B9" stroke-width="0.3" stroke-dasharray="3 2"/>'
        marks += f'<text x="8" y="{ty - zc - 1.5}" font-family="DejaVu Sans" font-size="3.4" fill="#2980B9">Sheet 1 — cut here and overlay on the line of sheet 2</text>'
    else:
        zc = mid - 10
        marks += f'<line x1="0" y1="{ty - zc}" x2="{pw}" y2="{ty - zc}" stroke="#2980B9" stroke-width="0.3" stroke-dasharray="3 2"/>'
        marks += f'<text x="8" y="{ty - zc + 4.5}" font-family="DejaVu Sans" font-size="3.4" fill="#2980B9">Sheet 2 — align the top of sheet 1 on this line</text>'
        marks += scalebar(180, 195)
    marks += f'<rect width="{pw}" height="12" fill="#fff"/>' + title(8, 7, f"2 × A4 landscape version — sheet {k+1}/2 — print at 100 %")
    pdfs.append(cairosvg.svg2pdf(bytestring=page(pw, ph, 140, ty, marks).encode()))

w = PdfWriter()
for p in pdfs:
    for pg in PdfReader(io.BytesIO(p)).pages: w.add_page(pg)
with open(ROOT / "docs/front_template_1-1.pdf", "wb") as f: w.write(f)
print("ok", top)
