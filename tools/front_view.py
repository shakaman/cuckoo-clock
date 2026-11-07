"""Front elevation (at rest / wake-up) of the modern design -> docs/img/front_view.{svg,png}.
Dimensions mirror hardware/coucou.scad (update both). Requires: pip install cairosvg"""
import pathlib
ROOT = pathlib.Path(__file__).resolve().parent.parent
import math, cairosvg
W,H,pitch=200,190,45; gh=W/2*math.tan(math.radians(pitch)); ovh=5; rt=6
sill=117.4; dw,dh=40,62; eye_x,eye_z,eye_d=62,148,33; dial_z,dial_d=60,80
FACE="#EEEAE3"; ROOF="#5B4636"; DIAL="#2B2B2B"; ACC="#E07A3F"; DOOR="#6A5140"; INK="#F6F3EC"
def panel(open_):
    S=[]; Y=lambda z: -z   # svg y
    # ombre portée douce
    S.append(f'<ellipse cx="0" cy="{Y(-6)}" rx="{W/2+10}" ry="5" fill="#000" opacity="0.06"/>')
    # cordon + contrepoids
    S.append(f'<line x1="45" y1="0" x2="45" y2="{Y(-30)}" stroke="#444" stroke-width="0.9"/>')
    S.append(f'<rect x="36" y="{Y(-30)}" width="18" height="34" rx="9" fill="{ACC}"/>')
    # cheminée (sur le rampant droit)
    s=51; cx=s*math.cos(math.radians(pitch)); cz=H+gh-s*math.sin(math.radians(pitch))
    xl,xr=cx-6,cx+14; zl=H+gh-xl; zr=H+gh-xr
    S.append(f'<path d="M{xl},{Y(cz+30)} L{xr},{Y(cz+30)} L{xr},{Y(zr)} L{xl},{Y(zl)} Z" fill="{ACC}"/>')
    S.append(f'<rect x="{cx-9+4}" y="{Y(cz+33)}" width="18" height="3" rx="1" fill="{ACC}" stroke="#c4612b" stroke-width="0.5"/>')
    # corps + pignon
    S.append(f'<path d="M{-W/2},0 L{-W/2},{Y(H)} L0,{Y(H+gh)} L{W/2},{Y(H)} L{W/2},0 Z" fill="{FACE}"/>')
    # toit : deux pans épais
    n=rt/math.cos(math.radians(pitch))
    for sgn in (-1,1):
        x0=sgn*(W/2+ovh); z0=H-ovh*math.tan(math.radians(pitch))
        S.append(f'<path d="M0,{Y(H+gh)} L{x0},{Y(z0)} L{x0},{Y(z0+n)} L0,{Y(H+gh+n)} Z" fill="{ROOF}"/>')
    # yeux
    for sgn in (-1,1):
        ex=sgn*eye_x
        S.append(f'<circle cx="{ex}" cy="{Y(eye_z)}" r="{eye_d/2+1.2}" fill="#d9d4cb"/>')
        S.append(f'<circle cx="{ex}" cy="{Y(eye_z)}" r="{eye_d/2}" fill="#111"/>')
        px=ex+(2 if open_ else 0); pz=eye_z+(1 if open_ else -1)
        h=22 if open_ else 20
        S.append(f'<rect x="{px-7.5}" y="{Y(pz+h/2)}" width="15" height="{h}" rx="7.5" fill="{INK}"/>')
        if open_:  # sourcils joyeux dessinés à l'écran
            S.append(f'<path d="M{ex-9},{Y(eye_z+14)} Q{ex},{Y(eye_z+18)} {ex+9},{Y(eye_z+14)}" stroke="{INK}" stroke-width="2" fill="none" stroke-linecap="round"/>')
    # porte
    S.append(f'<rect x="{-dw/2-0.8}" y="{Y(sill+dh+0.8)}" width="{dw+1.6}" height="{dh+1.6}" fill="#cfc9bf"/>')
    if not open_:
        S.append(f'<rect x="{-dw/2}" y="{Y(sill+dh)}" width="{dw}" height="{dh}" fill="{DOOR}"/>')
        S.append(f'<circle cx="0" cy="{Y(sill+dh-12)}" r="5" fill="none" stroke="#8a6d57" stroke-width="1.2"/>')
    else:
        S.append(f'<rect x="{-dw/2}" y="{Y(sill+dh)}" width="{dw}" height="{dh}" fill="#2a221d"/>')
        # plateau + figurine
        S.append(f'<rect x="-16" y="{Y(sill+12)}" width="32" height="6" rx="1.5" fill="#9a9a9a"/>')
        b=sill+12; Yl="#F2C318"
        S.append(f'<rect x="-8" y="{Y(b+3.2)}" width="16" height="3.2" fill="#3C8D2F"/>')
        S.append(f'<rect x="-7" y="{Y(b+16)}" width="14" height="12.8" fill="#1f4e9c"/>')
        S.append(f'<path d="M-7.8,{Y(b+28.8)} L7.8,{Y(b+28.8)} L7,{Y(b+16)} L-7,{Y(b+16)} Z" fill="#c8312d"/>')
        S.append(f'<rect x="-11" y="{Y(b+27)}" width="3.5" height="10" rx="1.5" fill="#c8312d" transform="rotate(-25 -9 {Y(b+26)})"/>')
        S.append(f'<rect x="-4.8" y="{Y(b+38.8)}" width="9.6" height="10" rx="2.5" fill="{Yl}"/>')
        S.append(f'<rect x="-5.5" y="{Y(b+42.5)}" width="11" height="4.5" rx="2" fill="#5a3a1e"/>')
        S.append(f'<circle cx="-1.8" cy="{Y(b+33.8)}" r="0.7" fill="#222"/><circle cx="1.8" cy="{Y(b+33.8)}" r="0.7" fill="#222"/>')
    # cadran
    S.append(f'<circle cx="0" cy="{Y(dial_z)}" r="{dial_d/2}" fill="{DIAL}"/>')
    for h in range(12):
        a=math.radians(90-h*30); big=h%3==0
        r1=dial_d/2-(12 if big else 7); r2=dial_d/2-4
        S.append(f'<line x1="{r1*math.cos(a)}" y1="{Y(dial_z+r1*math.sin(a))}" x2="{r2*math.cos(a)}" y2="{Y(dial_z+r2*math.sin(a))}" stroke="{INK}" stroke-width="{2.6 if big else 1.3}" stroke-linecap="round"/>')
    def hand(ang,l,w,col):
        a=math.radians(90-ang); return f'<line x1="0" y1="{Y(dial_z)}" x2="{l*math.cos(a)}" y2="{Y(dial_z+l*math.sin(a))}" stroke="{col}" stroke-width="{w}" stroke-linecap="round"/>'
    hh,mm=(7,0) if open_ else (10,10)
    S.append(hand(hh*30+mm/2,22,3.6,INK)); S.append(hand(mm*6,33,2.4,INK)); S.append(hand(200,35,0.9,ACC))
    S.append(f'<circle cx="0" cy="{Y(dial_z)}" r="2.6" fill="{ACC}"/>')
    # interrupteurs + LED + lettres
    for i,d in enumerate("LMMJV"):
        x=(i-2)*26; on = i in (0,1,2,3,4) and (not open_ or i!=4)
        S.append(f'<circle cx="{x}" cy="{Y(12)}" r="5" fill="#c9c4bb"/><circle cx="{x}" cy="{Y(12)}" r="2.2" fill="#8d8a84"/>')
        S.append(f'<rect x="{x-1.1}" y="{Y(19)}" width="2.2" height="7" rx="1.1" fill="#b5b1aa"/>')
        led = ACC if (open_ and i==4) else ("#7cc576" if True else "#ccc")
        S.append(f'<circle cx="{x+9}" cy="{Y(12)}" r="1.6" fill="{led}"/>')
        S.append(f'<text x="{x}" y="{Y(1.8)}" font-family="DejaVu Sans" font-weight="bold" font-size="4.5" fill="#8d877d" text-anchor="middle">{d}</text>')
    return "\n".join(S)
pad=20; vw=W+2*ovh+2*pad; top=H+gh+12; vh=top+80
svg=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {2*vw+10} {vh}" width="{(2*vw+10)*6}" height="{vh*6}"><rect width="100%" height="100%" fill="#F7F5F1"/>'
for k,o in enumerate((False,True)):
    svg+=f'<g transform="translate({k*(vw+10)+vw/2},{top+pad/2})">{panel(o)}</g>'
    svg+=f'<text x="{k*(vw+10)+vw/2}" y="{vh-4}" font-family="DejaVu Sans" font-size="6" fill="#777" text-anchor="middle">{"At rest" if not o else "Wake-up: door open, figure out"}</text>'
svg+='</svg>'
open(ROOT / 'docs/img/front_view.svg', 'w').write(svg)
cairosvg.svg2png(bytestring=svg.encode(), write_to=str(ROOT / 'docs/img/front_view.png'))
