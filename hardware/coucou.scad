// =====================================================================
//  COUCOU LEGO — horloge-réveil coucou ESP32 imprimée en 3D      v0.1
//  OpenSCAD paramétrique (testé 2021.01). Unités : mm.
//
//  Repère : X = largeur, Y = profondeur (face avant en y=0, +Y vers
//  l'arrière), Z = hauteur (dessous du boîtier en z=0).
//  Choisir la pièce avec `part` (Customizer) ou en ligne de commande :
//    openscad -D 'part="body"' -o body.stl coucou.scad
//
//  ⚠ Les cotes des composants (servo MG90S, écrans, radar LD2410C, mouvement)
//    sont des valeurs typiques : mesure les tiens et ajuste la section
//    « Composants » avant d'imprimer.
// =====================================================================

/* [Rendu] */
part = "assembly"; // [assembly, body, back_panel, gable_front, gable_back, roof_right, roof_left, deck, carriage, gear_drive, gear_turntable, pinion, door, door_rails, door_arm, door_link, door_servo_mount, dial, chimney, chimney_cap, pinecone]
// Vue assemblage : 0 = personnage rentré, porte fermée ; 1 = sorti, porte ouverte
open_pos = 1; // [0:1]
// Style : chalet classique ou moderne épuré
style = "modern"; // [classic, modern]
modern = style == "modern";
corner_r = 8;     // rayon des arêtes avant (style moderne)
$fn = 64;

/* [Boîtier] */
W = 200;          // largeur
D = 115;          // profondeur
H = 190;          // hauteur du corps (sans le toit)
wall = 3;         // parois latérales / fond
fw = 4;           // paroi avant
bp = 3;           // panneau arrière
roof_pitch = 45;  // pente du toit (°) — mini 45 pour le débattement du bras de porte
roof_ovh = modern ? 5 : 12;   // débord du toit
roof_t = modern ? 6 : 3;
ins_d = 4.2;      // trou pour insert laiton M3
ins_l = 6;

/* [Composants] */
// Écrans GC9A01 (yeux)
eye_pcb_d = 40.5; eye_view_d = 33; eye_x = 62; eye_z = 148;
// Cadran + mouvement quartz (axe long conseillé, ≥ 8 mm de filetage utile)
dial_z = 60; dial_d = 80; mov_sq = 56; mov_depth = 16; mov_hole = 8.2;
// Interrupteurs des jours (MTS-102, filetage M6) + LED
days = ["L","M","M","J","V"];
sw_hole = 6.3; sw_pitch = 26; sw_z = 12; led_d = 3.2; led_dx = 9; // LED à droite de chaque interrupteur
// Encodeur (paroi droite) et haut-parleur Ø40 (paroi gauche)
enc_hole = 7.4; enc_y = 70; enc_z = 70;
spk_d = 40; spk_y = 65; spk_z = 60;
// Servo MG90S : origine = axe de sortie, plan supérieur des pattes en z=0,
// corps orienté selon +X
sv_L = 22.8; sv_W = 12.2; sv_off = 6.1; sv_tab = 4.7; sv_tab_t = 2.5;
sv_below = 18.4;  // plan pattes -> dessous du corps
sv_above = 4.3;   // plan pattes -> dessus du boîtier
horn_top = 11;    // plan pattes -> dessus du palonnier rond
horn_d = 21.2;    // Ø palonnier rond
sv_hole_sp = 27.8;
// Radar de présence LD2410C (24 GHz), caché derrière la façade, antenne vers l'avant
rad_w = 16; rad_h = 22; rad_t = 1.6; rad_x = -72; rad_z = 60;

/* [Mécanisme] */
deck_z = 93;      // dessus du plateau mécanique
deck_t = 4;
gear_m = 1;       // module des engrenages
gear_teeth = 30;  // engrenage servo + plateau tournant
pin_teeth = 25;   // pignon de la crémaillère
gear_t = 6;
y_shaft_ext = 18; // position Y de l'axe du servo de rotation, chariot sorti
door_open_w = 40; door_open_h = 62;
door_link_L = 25; // longueur de la biellette de porte
door_arm_r = 32;  // rayon du bras de porte

// ---------------------------------------------------------------- dérivées
gh = (W/2) * tan(roof_pitch);           // hauteur du pignon
floor_t = 2.5;
c_O = deck_z + floor_t + sv_below;      // plan pattes du servo de rotation
gear_bot_l = horn_top - 2;              // local chariot
arm_top_l = gear_bot_l - 0.5;
arm_bot_l = arm_top_l - 4;
sill_z = c_O + arm_bot_l - 1;           // seuil de la porte
cd = gear_m * gear_teeth;               // entraxe servo / plateau
stroke = PI * gear_m * pin_teeth / 2;   // course pour 180° de servo
y_shaft_rest = y_shaft_ext + stroke;
y_shaft = open_pos ? y_shaft_ext : y_shaft_rest;
// chariot (local)
cb_x = sv_W/2 + 0.3 + 2;                // demi-largeur caisson
cb_y0 = -sv_off - sv_tab - 2;           // avant caisson
cb_y1 = sv_L - sv_off + sv_tab + 2;     // arrière caisson
rack_y0 = cb_y0; rack_y1 = 39;
rack_px = 11.25;                        // ligne primitive crémaillère (x local)
fl_x = 12;                              // demi-largeur des semelles
// pignon de crémaillère (servo fixe sous le plateau)
pin_O = deck_z - deck_t;
pin_bot = pin_O + horn_top - 2;
rack_lz0 = pin_bot - c_O;
pin_x = rack_px + gear_m * pin_teeth / 2;
pin_y = ((y_shaft_rest + rack_y0 + 3) + (y_shaft_ext + rack_y1 - 3)) / 2;
// porte
door_w = door_open_w + 6; door_h = door_open_h + 4; door_t = 3;
door_travel = door_open_h + 2;
door_bot0 = sill_z - 2;
door_z = door_bot0 + (open_pos ? door_travel : 0);
door_pin_dz = door_h - 3;               // trou de biellette, depuis le bas
z_ds = door_bot0 + door_pin_dz + door_link_L + door_arm_r; // axe servo porte
rail_top = door_bot0 + door_travel + door_h + 2;
// toit
roof_len = (W/2 + roof_ovh) / cos(roof_pitch) + 8;

echo(str("Seuil z=", sill_z, "  course=", stroke, "  pignon y=", pin_y,
         "  axe servo porte z=", z_ds, "  hauteur totale=", H + gh));

// =============================================================== utilitaires
function inv(a) = tan(a) - a * PI / 180;
function polar(r, a) = [r * cos(a), r * sin(a)];
function tooth_th(r, rb, half, pa) =
    half + (inv(pa) - inv(acos(min(1, rb / r)))) * 180 / PI;

module gear2d(z, m = 1, pa = 20, bl = 0.15) {
    rp = m * z / 2; rb = rp * cos(pa); ra = rp + m; rf = rp - 1.25 * m;
    r0 = max(rb, rf + 0.01);
    half = 90 / z - (bl / 2) / rp * 180 / PI;
    N = 6;
    pts = [for (k = [0:z-1]) let(c = 360 * k / z) each concat(
        [polar(rf, c - tooth_th(r0, rb, half, pa))],
        [for (i = [0:N]) let(r = r0 + (ra - r0) * i / N)
            polar(r, c - tooth_th(r, rb, half, pa))],
        [for (i = [N:-1:0]) let(r = r0 + (ra - r0) * i / N)
            polar(r, c + tooth_th(r, rb, half, pa))],
        [polar(rf, c + tooth_th(r0, rb, half, pa))])];
    polygon(pts);
}

// crémaillère 2D : dents vers +X, ligne primitive en x=0, de y0 à y1
module rack2d(y0, y1, m = 1, pa = 20, back = 1.5, bl = 0.15) {
    p = PI * m; ha = m; hf = 1.25 * m;
    n = floor((y1 - y0) / p);
    translate([-hf - back, y0]) square([back + 0.01, y1 - y0]);
    for (i = [0:n-1]) translate([0, y0 + p * (i + 0.5)]) {
        s = p / 2 - bl;
        polygon([[-hf, -s/2 - hf * tan(pa)], [ha, -s/2 + ha * tan(pa)],
                 [ha,  s/2 - ha * tan(pa)], [-hf,  s/2 + hf * tan(pa)]]);
    }
    translate([-hf, y0]) square([0.01 + 0.5, y1 - y0]);
}

module rbox(s, r = 2) { // boîte à arêtes verticales arrondies
    hull() for (x = [r, s[0] - r], y = [r, s[1] - r])
        translate([x, y, 0]) cylinder(r = r, h = s[2]);
}

// servo MG90S (pour vérification d'encombrement)
module servo_model() {
    color("SteelBlue") {
        translate([-sv_off, -sv_W/2, -sv_below]) cube([sv_L, sv_W, sv_below + sv_above]);
        translate([-sv_off - sv_tab, -sv_W/2, -sv_tab_t]) cube([sv_L + 2*sv_tab, sv_W, sv_tab_t]);
        cylinder(d = 4.8, h = horn_top - 2);
    }
    color("White") translate([0, 0, horn_top - 2]) cylinder(d = horn_d - 0.2, h = 2);
}
module servo_tab_holes(d = 1.8, h = 12) {
    for (x = [sv_L/2 - sv_off - sv_hole_sp/2, sv_L/2 - sv_off + sv_hole_sp/2])
        translate([x, 0, -h/2]) cylinder(d = d, h = h);
}

// bossage avec insert M3 sur une face intérieure (direction +Y)
module boss_y(h = 5.6, d = 9) { rotate([-90, 0, 0]) cylinder(d = d, h = h); }
module boss_y_hole(h = 5.6) {
    translate([0, h - ins_l, 0]) rotate([-90, 0, 0]) cylinder(d = ins_d, h = ins_l + 0.1);
}

// ================================================================== CORPS
rail_bx = 33;
rail_boss_pts = [[-rail_bx, sill_z + 2], [rail_bx, sill_z + 2], [-rail_bx, H - 10], [rail_bx, H - 10]];
gable_rail_z = [H + 12, rail_top - 14];

module body() {
    if (modern) intersection() { body_raw(); front_round_clip(); } else body_raw();
}
module front_round_clip() {
    translate([0, 0, -1]) linear_extrude(H + gh + 2) hull() {
        for (s = [-1, 1]) translate([s * (W/2 - corner_r), corner_r]) circle(r = corner_r);
        translate([-W/2, D - 1]) square([W, 1]);
    }
}
module body_raw() {
    col_s = 8;
    difference() {
        union() {
            translate([-W/2, 0, 0]) cube([W, fw, H]);                       // face
            for (s = [-1, 1]) translate([s > 0 ? W/2 - wall : -W/2, 0, 0]) cube([wall, D, H]);
            translate([-W/2, 0, 0]) cube([W, D, wall]);                    // fond
            // glissières du plateau mécanique
            for (s = [-1, 1]) translate([s > 0 ? W/2 - wall - 6 : -W/2 + wall, fw, deck_z - deck_t - 4])
                cube([6, D - fw - bp, 4]);
            // colonnes d'angle (vis du panneau arrière)
            for (s = [-1, 1]) {
                translate([s > 0 ? W/2 - wall - col_s : -W/2 + wall, fw, wall]) cube([col_s, D - fw - bp, col_s]);
                translate([s > 0 ? W/2 - wall - col_s : -W/2 + wall, fw, H - col_s]) cube([col_s, D - fw - bp - 3, col_s]);
            }
            // renforts des arêtes arrondies
            if (modern) for (s = [-1, 1]) translate([s > 0 ? W/2 - wall - 2.5 : -W/2 + wall, fw, 0]) cube([2.5, 2.5, H]);
            // bagues des écrans
            for (s = [-1, 1]) translate([s * eye_x, fw, eye_z]) rotate([-90, 0, 0])
                cylinder(d = eye_pcb_d + 5, h = 5);
            // bossages des rails de porte
            for (p = rail_boss_pts) translate([p[0], fw, p[1]]) boss_y();
            // glissière du radar (la carte s'insère par le haut, antenne contre la façade)
            translate([rad_x, fw, rad_z]) difference() {
                translate([-rad_w/2 - 2, 0, -rad_h/2 - 2]) cube([rad_w + 4, rad_t + 0.4 + 1.6, rad_h + 2 - 4]);
                translate([-rad_w/2 - 0.3, -0.01, -rad_h/2 - 0.3]) cube([rad_w + 0.6, rad_t + 0.4, rad_h + 1]);
                translate([-rad_w/2 + 1.5, -0.01, -rad_h/2 + 1.5]) cube([rad_w - 3, 10, rad_h]);
            }
            // bague haut-parleur
            translate([-W/2 + wall, spk_y, spk_z]) rotate([0, 90, 0]) difference() {
                cylinder(d = spk_d + 5, h = 4); translate([0, 0, -1]) cylinder(d = spk_d + 0.6, h = 6);
            }
        }
        // ouverture de porte
        translate([-door_open_w/2, -1, sill_z]) cube([door_open_w, fw + 2, door_open_h]);
        // yeux : fenêtre + logement PCB
        for (s = [-1, 1]) translate([s * eye_x, 0, eye_z]) rotate([-90, 0, 0]) {
            translate([0, 0, -1]) cylinder(d = eye_view_d, h = fw + 2);
            if (!modern) translate([0, 0, -1]) cylinder(d1 = eye_view_d + 4, d2 = eye_view_d, h = 3);  // chanfrein
            translate([0, 0, fw]) cylinder(d = eye_pcb_d, h = 10);
        }
        // axe du mouvement
        translate([0, -1, dial_z]) rotate([-90, 0, 0]) cylinder(d = mov_hole, h = fw + 2);
        // interrupteurs, LED, étiquettes gravées
        for (i = [0:4]) {
            x = (i - 2) * sw_pitch;
            translate([x, -1, sw_z]) rotate([-90, 0, 0]) cylinder(d = sw_hole, h = fw + 2);
            translate([x + led_dx, -1, sw_z]) rotate([-90, 0, 0]) cylinder(d = led_d, h = fw + 2);
            translate([x, 0.6, 3.6]) rotate([90, 0, 0]) linear_extrude(1)
                text(days[i], size = modern ? 4.5 : 6, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");
        }
        // encodeur (paroi droite)
        translate([W/2 - wall - 1, enc_y, enc_z]) rotate([0, 90, 0]) cylinder(d = enc_hole, h = wall + 2);
        // grille haut-parleur (paroi gauche)
        for (r = [0, 6, 12], a = [0 : (r == 0 ? 360 : 360 / (r)) : 359])
            translate([-W/2 - 1, spk_y + r * cos(a * 1), spk_z + r * sin(a * 1)])
                rotate([0, 90, 0]) cylinder(d = 3, h = wall + 2, $fn = 16);
        // trou de chaînette de la pomme de pin
        translate([45, 30, -1]) cylinder(d = 4.5, h = wall + 2);
        // inserts
        for (p = rail_boss_pts) translate([p[0], fw, p[1]]) boss_y_hole();
        for (s = [-1, 1]) for (z = [wall + col_s/2, H - col_s/2])
            translate([s * (W/2 - wall - col_s/2), D - bp - (z > H/2 ? 3 : 0) - ins_l, z]) rotate([-90, 0, 0])
                cylinder(d = ins_d, h = ins_l + 0.1);
        for (s = [-1, 1]) translate([s * (W/2 - wall - 3), fw + 30, deck_z - deck_t - 4.1])
            cylinder(d = ins_d, h = 4.2);
        for (s = [-1, 1]) translate([s * (W/2 - wall - 3), D - bp - 30, deck_z - deck_t - 4.1])
            cylinder(d = ins_d, h = 4.2);
    }
}

// =========================================================== PANNEAU ARRIÈRE
module back_panel() {
    col_s = 8;
    difference() {
        union() {
            translate([-W/2 + wall + 0.2, D - bp, wall + 0.2]) cube([W - 2*wall - 0.4, bp, H - wall - 0.2]);
            // entretoises carte perforée 70×50
            for (x = [-33, 33], z = [34, 80]) translate([x, D - bp, z]) rotate([90, 0, 0]) cylinder(d = 7, h = 8);
        }
        for (s = [-1, 1]) for (z = [wall + col_s/2, H - col_s/2])
            translate([s * (W/2 - wall - col_s/2), D - bp - 1, z]) rotate([-90, 0, 0]) {
                cylinder(d = 3.4, h = bp + 2);
                translate([0, 0, bp + 1 - 1.8]) cylinder(d1 = 3.4, d2 = 6.6, h = 1.81);
            }
        for (x = [-33, 33], z = [34, 80]) translate([x, D - bp - 9, z]) rotate([-90, 0, 0]) cylinder(d = 3.6, h = 6);
        // passage USB-C
        translate([50 - 5, D - bp - 1, 18 - 2]) cube([10, bp + 2, 4]);
        for (dx = [-7.5, 7.5]) translate([50 + dx, D - bp - 1, 18]) rotate([-90, 0, 0]) cylinder(d = 2.4, h = bp + 2);
        // trous de serrure (accroche murale)
        for (x = [-45, 45]) translate([x, D - bp - 1, H - 35]) rotate([-90, 0, 0]) hull() {
            cylinder(d = 4, h = bp + 2); translate([0, -8, 0]) cylinder(d = 4, h = bp + 2);
        }
        for (x = [-45, 45]) translate([x, D - bp - 1, H - 35]) rotate([-90, 0, 0]) cylinder(d = 8.5, h = bp + 2);
        // aérations
        for (i = [-3:3]) translate([i * 12 - 2, D - bp - 1, 120]) cube([4, bp + 2, 40]);
    }
}

// =================================================================== PIGNONS
gable_rib = 8;
module gable_tri2d(off = 0) {
    offset(delta = -off) polygon([[-W/2, H], [W/2, H], [0, H + gh]]);
}
function roof_pt(s, side) = [side * s * cos(roof_pitch), H + gh - s * sin(roof_pitch)];
roof_screw_s = [30, 90];
chim_s = 51;

module gable(front = true) {
    if (modern) intersection() { gable_raw(front); front_round_clip(); } else gable_raw(front);
}
module gable_raw(front = true) {
    t = front ? fw : bp;
    y0 = front ? 0 : D - bp;
    ry0 = front ? fw : D - bp - gable_rib;
    difference() {
        union() {
            // plaque
            translate([0, y0 + t, 0]) rotate([90, 0, 0]) linear_extrude(t) gable_tri2d();
            // nervures sous les rampants (vis du toit)
            translate([0, ry0 + gable_rib, 0]) rotate([90, 0, 0]) linear_extrude(gable_rib)
                difference() {
                    gable_tri2d();
                    gable_tri2d(gable_rib);
                    translate([-W, H - 1]) square([2*W, gable_rib / sin(roof_pitch) + 4]);
                }
            if (front) {
                for (p = concat([for (z = gable_rail_z, s = [-1, 1]) [s * rail_bx, z]], [[-40, z_ds - 12], [40, z_ds - 12]]))
                    translate([p[0], fw, p[1]]) boss_y();
            } else {
                // languette vissée avec le panneau arrière sur les colonnes hautes
                for (s = [-1, 1]) translate([s > 0 ? W/2 - wall - 8 : -W/2 + wall, D - bp - 3, H - 8]) cube([8, 3.01, 10]);
                translate([-W/2 + wall, D - bp - 3, H - 2]) cube([W - 2*wall, 3.01, 4]);
            }
        }
        // inserts du toit (perpendiculaires au rampant)
        for (side = [-1, 1], s = roof_screw_s) {
            p = roof_pt(s, side);
            translate([p[0], ry0 + gable_rib/2, p[1]]) rotate([0, side * roof_pitch, 0])
                translate([0, 0, -ins_l]) cylinder(d = ins_d, h = ins_l + 1);
        }
        if (front) {
            for (p = concat([for (z = gable_rail_z, s = [-1, 1]) [s * rail_bx, z]], [[-40, z_ds - 12], [40, z_ds - 12]]))
                translate([p[0], fw, p[1]]) boss_y_hole();
            // petit cœur décoratif (lucarne)
            if (!modern) translate([0, -1, H + gh - 22]) rotate([-90, 0, 0]) linear_extrude(fw + 2) heart2d(7);
        } else {
            for (s = [-1, 1]) translate([s * (W/2 - wall - 4), D - bp - 4, H - 4]) rotate([-90, 0, 0]) cylinder(d = 3.4, h = 5);
        }
    }
}
module heart2d(s) {
    translate([0, -s*0.2]) rotate(45) {
        square(s, center = false);
        translate([s/2, s]) circle(d = s);
        translate([s, s/2]) circle(d = s);
    }
}

// ===================================================================== TOIT
module roof(side = 1, hole = true) {
    mirror([side < 0 ? 1 : 0, 0, 0]) difference() {
        intersection() {
            translate([0, -roof_ovh, H + gh]) rotate([0, roof_pitch, 0])
                translate([-8, 0, 0]) union() {
                    cube([roof_len, D + 2*roof_ovh, roof_t]);
                    // tuiles
                    if (!modern) for (i = [1:14]) translate([i * 11 + 2, 0, roof_t - 0.01]) cube([1.6, D + 2*roof_ovh, 1.2]);
                }
            translate([0, -roof_ovh - 1, 0]) cube([W, D + 2*roof_ovh + 2, H + gh + 20]);
        }
        for (s = roof_screw_s, y = [fw + gable_rib/2, D - bp - gable_rib/2]) {
            p = roof_pt(s, 1);
            translate([p[0], y, p[1]]) rotate([0, roof_pitch, 0]) {
                translate([0, 0, -1]) cylinder(d = 3.4, h = 10);
                translate([0, 0, roof_t - 1.8]) cylinder(d1 = 3.4, d2 = 6.6, h = 1.81);
            }
        }
        if (side > 0 && hole) { // passage des fils de la cheminée-bouton
            p = roof_pt(chim_s, 1);
            translate([p[0], D/2, p[1]]) rotate([0, roof_pitch, 0]) translate([0, 0, -1]) cylinder(d = 8, h = 10);
        }
    }
}

// ================================================================= PLATEAU
module deck() {
    y0 = fw + 0.5; y1 = D - bp - 0.5;
    difference() {
        union() {
            translate([-W/2 + wall + 0.3, y0, deck_z - deck_t]) cube([W - 2*wall - 0.6, y1 - y0, deck_t]);
            // guides du chariot (avec lèvre)
            for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) {
                translate([fl_x + 0.4, y0, deck_z]) cube([2, y1 - y0, 4.4]);
                translate([fl_x - 1.6, y0, deck_z + 2.4]) cube([4, y1 - y0, 2]);
            }
        }
        // servo du pignon (monté par-dessous, axe vers le haut)
        translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) {
            translate([-sv_off - 0.3, -sv_W/2 - 0.3, -1]) cube([sv_L + 0.6, sv_W + 0.6, deck_t + 2]);
            servo_tab_holes(2.2);
        }
        // fixation sur les glissières
        for (s = [-1, 1], y = [fw + 30, D - bp - 30]) translate([s * (W/2 - wall - 3), y, deck_z - deck_t - 1])
            cylinder(d = 3.4, h = deck_t + 2);
        // dégagement des renforts d'angle
        for (s = [-1, 1]) translate([s > 0 ? W/2 - wall - 3 : -W/2 + wall - 0.5, fw - 0.5, deck_z - deck_t - 1]) cube([3.5, 3.5, deck_t + 2]);
        // passages de câbles
        for (s = [-1, 1]) translate([s * 30 - 6, 85, deck_z - deck_t - 1]) cube([12, 20, deck_t + 2]);
    }
}

// ================================================================= CHARIOT
module carriage() {
    difference() {
        union() {
            // caisson du servo
            translate([-cb_x, cb_y0, -sv_below - floor_t]) cube([2*cb_x, cb_y1 - cb_y0, sv_below + floor_t - sv_tab_t]);
            // semelles (glissent sous les lèvres du plateau)
            translate([-fl_x, rack_y0, -sv_below - floor_t]) cube([2*fl_x, rack_y1 - rack_y0, 2]);
            // queue + support de crémaillère
            translate([-cb_x, cb_y1 - 0.01, -sv_below - floor_t]) cube([cb_x + rack_px - 1.25, rack_y1 - cb_y1, rack_lz0 + 6 + sv_below + floor_t]);
            translate([cb_x - 0.01, rack_y0, rack_lz0]) cube([rack_px - 1.25 - cb_x + 0.02, rack_y1 - rack_y0, 6]);
            translate([rack_px, 0, rack_lz0]) linear_extrude(6) rack2d(rack_y0, rack_y1, gear_m);
            // joues + bras
            difference() {
                translate([-15, cb_y0, -sv_tab_t]) cube([30, -6.6 - cb_y0, arm_top_l + sv_tab_t]);
                translate([-6.5, cb_y0 - 1, -sv_tab_t - 1]) cube([13, 20, 30]);
            }
            translate([-15, -cd - 17, arm_bot_l]) rbox([30, cb_y0 + cd + 17 + 2, 4], 3);
            translate([0, -cd, arm_bot_l]) cylinder(d = 30, h = 4);
        }
        // logement du servo
        translate([-sv_W/2 - 0.3, -sv_off - 0.3, -sv_below - 0.01]) cube([sv_W + 0.6, sv_L + 0.6, sv_below + 1]);
        rotate([0, 0, 90]) servo_tab_holes(1.8);
        // sortie du câble servo
        translate([-3, sv_L - sv_off, -sv_below]) cube([6, 10, 8]);
        // axe du plateau tournant : vis M3 tête basse par-dessous
        translate([0, -cd, arm_bot_l - 1]) cylinder(d = 3.3, h = 10);
        translate([0, -cd, arm_bot_l - 1]) cylinder(d = 6.2, h = 1 + 1.8);
    }
}

// =============================================================== ENGRENAGES
module horn_gear(teeth) {
    difference() {
        linear_extrude(gear_t) gear2d(teeth, gear_m);
        translate([0, 0, -0.01]) cylinder(d = horn_d, h = 2);       // palonnier rond
        translate([0, 0, -1]) cylinder(d = 7, h = gear_t + 2);       // accès vis centrale
        for (a = [0:90:270]) rotate(a) translate([7.5, 0, -1]) cylinder(d = 1.8, h = gear_t + 2);
    }
}
module gear_turntable() {
    difference() {
        linear_extrude(gear_t) gear2d(gear_teeth, gear_m);
        translate([0, 0, -1]) cylinder(d = 3.4, h = gear_t + 2);
        translate([0, 0, gear_t - 2.6]) cylinder(d = 6.5, h = 3, $fn = 6);   // écrou M3 (frein-filet)
        translate([-8.1, -8.1, gear_t - 1.2]) cube([16.2, 16.2, 2]);         // plaque LEGO 2×2 collée
    }
}

// =================================================================== PORTE
module door() {
    difference() {
        union() {
            translate([-door_w/2, 0, 0]) cube([door_w, door_t, door_h]);
            translate([-4, door_t - 0.01, door_h - 8]) cube([8, 4.8, 8]);  // chape biellette
        }
        translate([0, -1, door_pin_dz]) rotate([-90, 0, 0]) cylinder(d = 2.1, h = 10);
        // planches + arc gravés
        if (!modern) for (x = [-door_open_w/2 + 8 : 8 : door_open_w/2 - 1]) translate([x - 0.5, -0.01, 4]) cube([1, 0.6, door_h - 8]);
    }
    // (pas de bouton en relief : la porte coulisse derrière la façade)
}

module door_rails() {
    zb = door_bot0 - 2;
    for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) {
        difference() {
            union() {
                translate([door_w/2 + 0.4, 0, zb]) cube([4.6, 3.6, rail_top - zb]);            // entretoise
                translate([door_open_w/2 + 1, 3.6, zb]) cube([door_w/2 + 5 - door_open_w/2 - 1, 2, rail_top - zb]);  // lèvre
                // pattes vissées sur les bossages
                for (z = concat([sill_z + 2, H - 10], gable_rail_z))
                    translate([door_w/2 + 0.4, 5.6, z - 5]) cube([rail_bx - door_w/2 + 4.1, 2.5, 10]);
            }
            for (z = concat([sill_z + 2, H - 10], gable_rail_z))
                translate([rail_bx, 0, z]) rotate([-90, 0, 0]) cylinder(d = 3.4, h = 20);
        }
    }
}

module door_arm() {
    difference() {
        hull() {
            cylinder(d = horn_d + 5, h = 3);
            translate([door_arm_r, 0, 0]) cylinder(d = 7, h = 3);
        }
        translate([0, 0, 3 - 2 + 0.01]) cylinder(d = horn_d, h = 2);
        translate([0, 0, -1]) cylinder(d = 3, h = 5);
        for (a = [0:90:270]) rotate(a) translate([7.5, 0, -1]) cylinder(d = 1.8, h = 5);
        translate([door_arm_r, 0, -1]) cylinder(d = 2.1, h = 5);
    }
}
module door_link() {
    difference() {
        hull() { cylinder(d = 6, h = 2.5); translate([door_link_L, 0, 0]) cylinder(d = 6, h = 2.5); }
        for (x = [0, door_link_L]) translate([x, 0, -1]) cylinder(d = 2.3, h = 5);
    }
}

// servo de porte : axe vers l'avant (-Y)
ds_arm_y = fw + door_t + 0.4 + 4.8 + 0.3 + 2.5 + 0.2;  // face avant du bras
ds_O_y = ds_arm_y + 3 + horn_top - 2 + 2;            // plan des pattes
module door_servo_mount() {
    py = ds_O_y + sv_tab_t;
    intersection() {
    translate([0, D, 0]) rotate([90, 0, 0]) linear_extrude(D) gable_tri2d(1.5);
    difference() {
        union() {
            translate([-42, py, z_ds - 16]) cube([84, 4, 26]);
            for (s = [-1, 1]) translate([s > 0 ? 36 : -44, fw + 5.6, z_ds - 16]) cube([8, py - fw - 5.6 + 0.01, 8]);
        }
        translate([-sv_off - 0.3, py - 1, z_ds - sv_W/2 - 0.3]) cube([sv_L + 0.6, 6, sv_W + 0.6]);
        translate([0, py, z_ds]) rotate([-90, 0, 0]) servo_tab_holes(1.8);
        for (s = [-1, 1]) translate([s * 40, fw, z_ds - 12]) rotate([-90, 0, 0]) cylinder(d = 3.4, h = 40);
    }
}
}

// =================================================================== CADRAN
module dial() {
    difference() {
        cylinder(d = dial_d, h = 2);
        translate([0, 0, -1]) cylinder(d = mov_hole + 0.5, h = 4);
    }
    for (h = [1:12]) {
        a = 90 - h * 30;
        translate([0, 0, 2]) {
            if (modern) rotate(a) translate([dial_d/2 - (h % 3 == 0 ? 14 : 8), -(h % 3 == 0 ? 1.5 : 0.8), 0])
                cube([h % 3 == 0 ? 10 : 4, h % 3 == 0 ? 3 : 1.6, 1.2]);
            else rotate(a) translate([dial_d/2 - 5, 0, 0]) cube([5, h % 3 == 0 ? 2.5 : 1.4, 1.2], center = false);
            if (!modern) translate(polar(dial_d/2 - 14, a)) linear_extrude(1.2)
                text(str(h), size = h % 3 == 0 ? 8 : 6, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");
        }
    }
}

// ============================================================== CHEMINÉE
module chimney() {
    difference() {
        intersection() {
            translate([-10, -10, -20]) cube([20, 20, 45]);
            rotate([0, roof_pitch, 0]) translate([-50, -50, 0]) cube([100, 100, 100]);
        }
        translate([-6.2, -6.2, 25 - 4]) cube([12.4, 12.4, 10]);     // bouton tactile 12×12
        translate([0, 0, -30]) cylinder(d = 7, h = 60);             // fils
        if (!modern) for (dx = [-6, 6]) translate([dx, -11, 4]) cube([0.8, 22, 0.8]); // briques
    }
}
module chimney_cap() {
    difference() {
        union() { translate([-9, -9, 0]) cube([18, 18, 3]); translate([-5.8, -5.8, -3]) cube([11.6, 11.6, 3]); }
        translate([0, 0, -3.1]) cylinder(d = 4, h = 2);   // poussoir du bouton
    }
}

// =========================================================== POMME DE PIN
module pinecone() {
    if (modern) weight_modern(); else pinecone_classic();
}
module weight_modern() { // contrepoids épuré (gélule)
    difference() {
        hull() { translate([0, 0, 9]) sphere(d = 18); translate([0, 0, 33]) sphere(d = 18); }
        translate([-20, -20, -20]) cube([40, 40, 20]);
        translate([0, 0, 30]) cylinder(d = 2.5, h = 20);
    }
}
module pinecone_classic() {
    difference() {
        union() {
            for (i = [0:7]) {
                z = i * 6; r = 13 * sin(20 + i * 18);
                for (a = [0:45:359]) rotate(a + i * 22.5) translate([r * 0.55, 0, z])
                    scale([1, 0.8, 0.7]) sphere(r = max(3.5, r * 0.55), $fn = 16);
            }
            cylinder(d = 10, h = 48);
        }
        translate([-20, -20, -20]) cube([40, 40, 20]);
        translate([0, 0, 40]) cylinder(d = 2.5, h = 20);
    }
    translate([0, 0, 50]) rotate([90, 0, 0]) rotate_extrude($fn = 24) translate([3, 0]) circle(d = 2);
}

// =============================================================== ASSEMBLAGE
module minifig_ghost() {
    color("Gold", 0.8) {
        translate([-8, -8, 0]) cube([16, 16, 3.2]);           // plaque 2×2
        translate([-7.8, -4, 3.2]) cube([15.6, 8, 12.8]);      // jambes
        translate([-7.8, -4, 16]) cube([15.6, 8, 12.8]);       // torse
        translate([0, 0, 28.8]) cylinder(d = 9.6, h = 10);     // tête
        translate([0, 0, 38.8]) cylinder(d = 11, h = 4);       // cheveux
    }
}

c_face = modern ? "#ECE8E1" : "BurlyWood";
c_back = modern ? "#D9D4CB" : "Peru";
c_roof = modern ? "#5B4636" : "SaddleBrown";
c_dial = modern ? "#2B2B2B" : "Wheat";
c_door = modern ? "#5B4636" : "Sienna";
c_acc  = modern ? "#E07A3F" : "Firebrick";
module assembly() {
    color(c_face) body();
    color(c_back) back_panel();
    color(c_face) gable(true);
    color(c_back) gable(false);
    color(c_roof) { roof(1); roof(-1); }
    color(c_dial) translate([0, -2, dial_z]) rotate([90, 0, 0]) cylinder(d = dial_d, h = 2);
    color(modern ? "White" : "SaddleBrown") translate([0, -2, dial_z]) rotate([90, 0, 0]) intersection() { dial(); translate([0, 0, 2]) cylinder(d = dial_d + 1, h = 2); }
    color("DimGray") translate([-mov_sq/2, fw, dial_z - mov_sq/2]) cube([mov_sq, mov_depth, mov_sq]);
    // écrans
    for (s = [-1, 1]) color("Black") translate([s * eye_x, fw + 0.5, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_pcb_d - 0.5, h = 4);
    color("Silver", 0.9) deck();
    color("Tomato") translate([0, y_shaft, c_O]) carriage();
    translate([0, y_shaft, c_O]) rotate([0, 0, 90]) servo_model();
    color("Orange") translate([0, y_shaft, c_O + gear_bot_l]) horn_gear(gear_teeth);
    color("Orange") translate([0, y_shaft - cd, c_O + gear_bot_l]) gear_turntable();
    translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t - 1.2]) minifig_ghost();
    // crémaillère / pignon
    translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) servo_model();
    color("Orange") translate([pin_x, pin_y, pin_bot]) horn_gear(pin_teeth);
    // radar LD2410C
    color("ForestGreen") translate([rad_x - rad_w/2, fw + 0.2, rad_z - rad_h/2]) cube([rad_w, rad_t, rad_h]);
    // porte
    color(c_door) translate([0, fw + 0.2, door_z]) door();
    color("DarkGoldenrod") translate([0, fw, 0]) door_rails();
    color("SlateGray") door_servo_mount();
    translate([0, ds_O_y, z_ds]) rotate([90, 0, 0]) servo_model();
    // cheminée-bouton
    color(c_acc) translate([roof_pt(chim_s, 1)[0] + roof_t * sin(roof_pitch), D/2, roof_pt(chim_s, 1)[1] + roof_t * cos(roof_pitch)]) chimney();
    // bras + biellette de porte
    da = open_pos ? -90 : 90;
    color("SlateGray") translate([0, ds_arm_y, z_ds]) rotate([-90, 0, 0]) rotate([0, 0, da]) door_arm();
    tip = [door_arm_r * cos(da), -door_arm_r * sin(da)];
    pinz = door_z + door_pin_dz;
    color("Gray") hull() {
        translate([tip[0], ds_arm_y - 2.7, z_ds + tip[1]]) rotate([-90, 0, 0]) cylinder(d = 6, h = 2.5);
        translate([0, ds_arm_y - 2.7, pinz]) rotate([-90, 0, 0]) cylinder(d = 6, h = 2.5);
    }
    color(modern ? c_acc : "SaddleBrown") translate([45, 30, -70]) pinecone();
}

// ================================================================ SÉLECTION
// Pièces posées dans leur orientation d'impression recommandée.
if (part == "assembly") assembly();
else if (part == "body") rotate([90, 0, 0]) body();                 // face avant sur le plateau
else if (part == "back_panel") translate([0, 0, D]) rotate([-90, 0, 0]) back_panel();
else if (part == "gable_front") rotate([90, 0, 0]) gable(true);
else if (part == "gable_back") translate([0, 0, D]) rotate([-90, 0, 0]) gable(false);
else if (part == "roof_right") roof_flat(1);
else if (part == "roof_left") roof_flat(-1);
else if (part == "deck") translate([0, 0, -deck_z + deck_t]) deck();
else if (part == "carriage") translate([0, 0, sv_below + floor_t]) carriage();   // supports sous le bras
else if (part == "gear_drive") horn_gear(gear_teeth);
else if (part == "gear_turntable") gear_turntable();
else if (part == "pinion") horn_gear(pin_teeth);
else if (part == "door") rotate([90, 0, 0]) door();
else if (part == "door_rails") rotate([90, 0, 0]) door_rails();
else if (part == "door_arm") door_arm();
else if (part == "door_link") door_link();
else if (part == "door_servo_mount") translate([0, 0, ds_O_y + sv_tab_t + 4]) rotate([-90, 0, 0]) door_servo_mount();
else if (part == "dial") dial();
else if (part == "chimney") translate([0, 0, 25]) rotate([180, 0, 0]) chimney();
else if (part == "chimney_cap") translate([0, 0, 3]) rotate([180, 0, 0]) chimney_cap();
else if (part == "pinecone") pinecone();

module roof_flat(side) {
    // remet le pan à plat (face intérieure sur le plateau)
    rotate([0, -roof_pitch, 0]) translate([0, roof_ovh, -H - gh]) roof(1, hole = side > 0);
}
