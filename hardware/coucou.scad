// =====================================================================
//  LEGO CUCKOO — 3D-printed ESP32 cuckoo alarm clock, owl head    v0.3
//  Parametric OpenSCAD (tested with 2021.01). Units: mm.
//
//  Axes: X = width, Y = depth (front face at y=0, +Y towards the
//  back), Z = height (bottom of the case at z=0).
//  Pick the part with `part` (Customizer) or on the command line:
//    openscad -D 'part="body"' -o body.stl coucou.scad
//
//  ⚠ Component dimensions (MG90S servo, displays, LD2410C radar, movement)
//    are typical values: measure yours and adjust the "Components"
//    section before printing.
//  The previous chalet / modern-box design lives in git history (v0.2).
// =====================================================================

/* [Render] */
part = "assembly"; // [assembly, body, back_panel, face_mask, beak, door, door_crank, door_link, deck, carriage, gear_drive, gear_turntable, pinion, dial, button_cap, weight]
// Assembly view: 0 = figure retracted, door closed; 1 = figure out, door open
open_pos = 1; // [0:1]
// Door opening angle used in the assembly view (0 = closed, door_open_a = open)
door_a = -1;  // -1 = follow open_pos
$fn = 64;

/* [Case] */
W = 210;          // head width
D = 115;          // depth
wall = 3;         // shell thickness
fw = 4;           // front wall
bp = 3;           // back panel
mask_t = 2;       // face-mask inlay thickness (= pocket depth in the front)
engrave = 0.6;    // depth of the engraved feathers
ins_d = 4.2;      // hole for M3 brass heat-set insert
ins_l = 6;

/* [Owl outline] */
side_top = 165;   // straight sides up to here
tuft = [98, 246]; // ear-tuft tip (x, z)
dip = 220;        // top of the head between the tufts
corner_r = 20;    // bottom corner radius

/* [Components] */
// GC9A01 displays (eyes)
eye_pcb_d = 40.5; eye_view_d = 33; eye_x = 62; eye_z = 148;
// Dial + quartz movement (long shaft recommended, ≥ 8 mm usable thread)
dial_z = 60; dial_d = 80; mov_sq = 56; mov_depth = 16; mov_hole = 8.2;
// Quartz movement driven by the ESP32 + Hall sensor (DRV5032, SOT-23) in the back of the dial
// at 12 o'clock; a Ø3×2 magnet glued under the minute hand at the same radius is the home mark.
hall_r = 28; hall_pk = [4.2, 3.4, 1.4];   // pocket (w × h × depth), leaves 0.6 mm of dial
hall_exit = [32, -20];                    // wire exit (dial frame, x / towards 12 o'clock)
// Weekday switches (MTS-102, M6 thread) + LEDs
// Labels stay French on purpose (L M M J V = Mon–Fri): the clock is for a French kid.
days = ["L","M","M","J","V"];
sw_hole = 6.3; sw_pitch = 26; sw_z = 12; led_d = 3.2; led_dx = 9; // LED to the right of each switch
// Encoder (right wall) and Ø40 speaker (left wall)
enc_hole = 7.4; enc_y = 70; enc_z = 70;
spk_d = 40; spk_y = 65; spk_z = 60;
// MG90S servo: origin = output shaft, top of mounting tabs at z=0,
// body along +X
sv_L = 22.8; sv_W = 12.2; sv_off = 6.1; sv_tab = 4.7; sv_tab_t = 2.5;
sv_below = 18.4;  // tab plane -> bottom of body
sv_above = 4.3;   // tab plane -> top of case
horn_top = 11;    // tab plane -> top of round horn
horn_d = 21.2;    // round horn Ø
sv_hole_sp = 27.8;
// LD2410C presence radar (24 GHz), hidden behind the front face, antenna facing forward
rad_w = 16; rad_h = 22; rad_t = 1.6; rad_x = -72; rad_z = 60;
// Top button: 12×12 tactile switch (7.3 mm tall) under the head, printed cap on top
btn_x = -25; btn_y = 20; tact_h = 7.3;

/* [Mechanism] */
deck_z = 93;      // top of the mechanism deck
deck_t = 4;
gear_m = 1;       // gear module
gear_teeth = 30;  // servo gear + turntable
pin_teeth = 25;   // rack pinion
gear_t = 6;
y_shaft_ext = 18; // Y of the rotation servo shaft, carriage out
door_open_w = 40; door_open_h = 64;
// Side-hinged overlay door (hinge on the right, opens outwards like a real cuckoo door)
door_open_a = 100;          // door opening angle (°)
hinge = [25.5, -3.1];       // hinge axis (x, y), vertical
pin_d = 2;                  // hinge pin: Ø2 brass rod
door_t = 3;
// Door drive = parallelogram linkage: door tab T and servo crank pin H move together.
tab0 = [16, 1.5];           // door tab pin, door closed (x, y)
link_d = [-20, 26];         // T -> H vector (also hinge -> servo shaft)

// ---------------------------------------------------------------- derived
floor_t = 2.5;
c_O = deck_z + floor_t + sv_below;      // rotation servo tab plane
gear_bot_l = horn_top - 2;              // carriage-local
arm_top_l = gear_bot_l - 0.5;
arm_bot_l = arm_top_l - 4;
sill_z = c_O + arm_bot_l - 1;           // door sill
cd = gear_m * gear_teeth;               // servo / turntable centre distance
stroke = PI * gear_m * pin_teeth / 2;   // stroke for 180° of servo
y_shaft_rest = y_shaft_ext + stroke;
y_shaft = open_pos ? y_shaft_ext : y_shaft_rest;
// carriage (local)
cb_x = sv_W/2 + 0.3 + 2;                // servo box half-width
cb_y0 = -sv_off - sv_tab - 2;           // servo box front
cb_y1 = sv_L - sv_off + sv_tab + 2;     // servo box back
rack_y0 = cb_y0; rack_y1 = 39;
rack_px = 11.25;                        // rack pitch line (local x)
fl_x = 12;                              // runner half-width
// rack pinion (fixed servo under the deck)
pin_O = deck_z - deck_t;
pin_bot = pin_O + horn_top - 2;
rack_lz0 = pin_bot - c_O;
pin_x = rack_px + gear_m * pin_teeth / 2;
pin_y = ((y_shaft_rest + rack_y0 + 3) + (y_shaft_ext + rack_y1 - 3)) / 2;
// door
door_w = door_open_w + 6;
door_bot = sill_z - 2;
door_top = sill_z + door_open_h + 2;
door_ang = door_a >= 0 ? door_a : (open_pos ? door_open_a : 0);
crank_v = tab0 - hinge;                 // hinge -> tab, door closed
crank_r = norm(crank_v);
crank_a0 = atan2(crank_v[1], crank_v[0]);
ds_S = hinge + link_d;                  // door servo shaft (x, y)
link_L = norm(link_d);
link_z = 175.7;  link_th = 2.5;         // link plane
tab_z = link_z - 0.3 - 2.2;  tab_th = 2.2;
crank_z = link_z + link_th + 0.3;       // crank bottom (horn recess on top)
ds_tab = crank_z + 3 - 2 + horn_top;    // door servo tab plane (servo upside down)
lug_h = 6;
// top button
btn_top = 221.6;                        // outer top of the head at btn_x (from the outline)
btn_top_in = btn_top - wall;
btn_shelf = btn_top_in - 0.3 - tact_h + 1.2;  // shelf top (switch sits in a 1.2 mm recess)

echo(str("Sill z=", sill_z, "  stroke=", stroke, "  door ", door_bot, "..", door_top,
         "  crank r=", crank_r, "  link L=", link_L, "  door servo shaft=", ds_S,
         "  servo tab z=", ds_tab, "  height=", tuft[1]));

// =============================================================== utilities
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

// 2D rack: teeth towards +X, pitch line at x=0, from y0 to y1
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

module rbox(s, r = 2) { // box with rounded vertical edges
    hull() for (x = [r, s[0] - r], y = [r, s[1] - r])
        translate([x, y, 0]) cylinder(r = r, h = s[2]);
}

// MG90S servo (for clearance checks)
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

// boss with M3 insert on an inner face (+Y direction)
module boss_y(h = 5.6, d = 9) { rotate([-90, 0, 0]) cylinder(d = d, h = h); }
module boss_y_hole(h = 5.6) {
    translate([0, h - ins_l, 0]) rotate([-90, 0, 0]) cylinder(d = ins_d, h = ins_l + 0.1);
}

// ============================================================ OWL OUTLINE
function bez(p0, p1, p2, p3, n) = [for (i = [0:n]) let(t = i / n)
    pow(1 - t, 3) * p0 + 3 * pow(1 - t, 2) * t * p1 + 3 * (1 - t) * t * t * p2 + pow(t, 3) * p3];
function mirx(pts) = [for (i = [len(pts) - 1 : -1 : 0]) [-pts[i][0], pts[i][1]]];
hw = W / 2;
side_pts = bez([hw, side_top], [hw, side_top + 38], [hw - 1, side_top + 61], tuft, 16);
top_pts  = bez(tuft, [tuft[0] - 23, tuft[1] - 16], [35, dip], [0, dip], 24);
outline_pts = concat(
    [for (a = [-90 : 10 : 0]) [hw - corner_r, corner_r] + corner_r * [cos(a), sin(a)]],
    side_pts, [for (i = [1 : len(top_pts) - 1]) top_pts[i]],
    [for (i = [1 : len(top_pts) - 1]) mirx(top_pts)[i]],
    [for (i = [1 : len(side_pts) - 1]) mirx(side_pts)[i]],
    [for (a = [180 : 10 : 270]) [-hw + corner_r, corner_r] + corner_r * [cos(a), sin(a)]]);
module outline2d(off = 0) { offset(delta = off) polygon(outline_pts); }

// 2D shape in the X/Z plane extruded along Y, from y0 to y0 + t
module slab(y0, t) { translate([0, y0 + t, 0]) rotate([90, 0, 0]) linear_extrude(t) children(); }

// cream facial mask: two discs + centre band (inlaid in the front)
module mask2d() {
    intersection() {
        outline2d(-2.5);
        union() {
            for (s = [-1, 1]) translate([s * eye_x, eye_z]) circle(r = 44);
            polygon([[-31, 104], [31, 104], [31, 194], [0, 186], [-31, 194]]);
        }
    }
}
module door_hole2d() { translate([-door_open_w/2, sill_z]) square([door_open_w, door_open_h]); }

// engraved feathers, brows and day labels (2D, front face)
module stroke2d(pts, w) { for (i = [0 : len(pts) - 2]) hull() { translate(pts[i]) circle(d = w, $fn = 12); translate(pts[i + 1]) circle(d = w, $fn = 12); } }
function qbez(p0, p1, p2, n) = [for (i = [0:n]) let(t = i / n) pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + t * t * p2];
module engravings2d() {
    // brows
    for (s = [-1, 1]) stroke2d(qbez([s * 6, 197], [s * 40, 212], [s * 97, 190], 20), 3);
    // forehead chevrons
    for (x = [-22, 0, 22]) stroke2d([[x - 7, 213], [x, 208], [x + 7, 213]], 1.6);
    // chest scallops
    for (row = [0:3], s = [-1, 1], k = [0:2]) {
        z = 34 + row * 18;
        x = s * (55 + k * 16 + (row % 2 ? 8 : 0));
        if (abs(x) + 8 < hw - 4 && !(z > 80 && k == 2))
            translate([x, z]) stroke2d([for (a = [180 : 15 : 360]) 8 * [cos(a), sin(a)]], 1.6);
    }
}

// ================================================================== BODY
// One-piece shell: front + side walls + top + floor. Printed front face down.
boss_pts = [[-95, 10], [95, 10], [-98.5, 100], [98.5, 100], [-98.5, 160], [98.5, 160], [-72, 225], [72, 225]];
boss_len = 12;

module body() {
    difference() {
        union() {
            // front with a 1.5 mm stepped chamfer
            for (i = [0:2]) slab(i * 0.5, 0.5) outline2d(-(1.5 - i * 0.5));
            slab(1.5, fw - 1.5) outline2d();
            // shell
            slab(0, D) difference() { outline2d(); outline2d(-wall); }
            // back-panel bosses (merge into the wall)
            intersection() {
                slab(D - bp - boss_len, boss_len) outline2d(-0.5);
                for (p = boss_pts) translate([p[0], D - bp - boss_len, p[1]]) rotate([-90, 0, 0]) cylinder(d = 9, h = boss_len);
            }
            // mechanism deck ledges
            for (s = [-1, 1]) translate([s > 0 ? hw - wall - 6 : -hw + wall - 0.5, fw, deck_z - deck_t - 4])
                cube([6.5, D - fw - bp, 4]);
            // display rings
            for (s = [-1, 1]) translate([s * eye_x, fw, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_pcb_d + 5, h = 5);
            // radar slot (board slides in from the top, antenna against the front face)
            translate([rad_x, fw, rad_z]) difference() {
                translate([-rad_w/2 - 2, 0, -rad_h/2 - 2]) cube([rad_w + 4, rad_t + 0.4 + 1.6, rad_h + 2 - 4]);
                translate([-rad_w/2 - 0.3, -0.01, -rad_h/2 - 0.3]) cube([rad_w + 0.6, rad_t + 0.4, rad_h + 1]);
                translate([-rad_w/2 + 1.5, -0.01, -rad_h/2 + 1.5]) cube([rad_w - 3, 10, rad_h]);
            }
            // speaker ring
            translate([-hw + wall, spk_y, spk_z]) rotate([0, 90, 0]) difference() {
                cylinder(d = spk_d + 5, h = 4); translate([0, 0, -1]) cylinder(d = spk_d + 0.6, h = 6);
            }
            // door servo shelf (servo hangs upside down, tabs on top) + 2 ribs to the head top
            intersection() {
                slab(0, D) outline2d(-0.5);
                union() {
                    translate([ds_S[0] - 15.5, fw - 0.01, ds_tab - 3]) cube([40, ds_S[1] + 13 - fw, 3]);
                    for (x = [ds_S[0] - 17.5, ds_S[0] + 24.5]) translate([x, fw - 0.01, ds_tab - 3]) cube([2, ds_S[1] + 13 - fw, 60]);
                }
            }
            // top-button shelf + rib
            intersection() {
                slab(0, D) outline2d(-0.5);
                union() {
                    translate([btn_x - 9, fw - 0.01, btn_shelf - 2.5]) cube([18, btn_y + 9 - fw, 2.5]);
                    translate([btn_x - 11, fw - 0.01, btn_shelf - 2.5]) cube([2, btn_y + 9 - fw, 40]);
                }
            }
        }
        // face-mask pocket
        slab(-0.01, mask_t + 0.01) offset(delta = 0.15) mask2d();
        // engravings
        slab(-0.01, engrave + 0.01) engravings2d();
        // door opening
        slab(-1, fw + 2) door_hole2d();
        // eyes: window + PCB pocket
        for (s = [-1, 1]) translate([s * eye_x, 0, eye_z]) rotate([-90, 0, 0]) {
            translate([0, 0, -1]) cylinder(d = eye_view_d, h = fw + 2);
            translate([0, 0, fw]) cylinder(d = eye_pcb_d, h = 10);
        }
        // movement shaft
        translate([0, -1, dial_z]) rotate([-90, 0, 0]) cylinder(d = mov_hole, h = fw + 2);
        // Hall sensor wire hole
        translate([hall_exit[0], -1, dial_z + hall_exit[1]]) rotate([-90, 0, 0]) cylinder(d = 3, h = fw + 2, $fn = 16);
        // switches, LEDs, engraved labels
        for (i = [0:4]) {
            x = (i - 2) * sw_pitch;
            translate([x, -1, sw_z]) rotate([-90, 0, 0]) cylinder(d = sw_hole, h = fw + 2);
            translate([x + led_dx, -1, sw_z]) rotate([-90, 0, 0]) cylinder(d = led_d, h = fw + 2);
            translate([x, 0.6, 3.6]) rotate([90, 0, 0]) linear_extrude(1)
                text(days[i], size = 4.5, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");
        }
        // encoder (right wall)
        translate([hw - wall - 1, enc_y, enc_z]) rotate([0, 90, 0]) cylinder(d = enc_hole, h = wall + 2);
        // speaker grille (left wall)
        for (r = [0, 6, 12], a = [0 : (r == 0 ? 360 : 360 / r) : 359])
            translate([-hw - 1, spk_y + r * cos(a), spk_z + r * sin(a)]) rotate([0, 90, 0]) cylinder(d = 3, h = wall + 2, $fn = 16);
        // weight cord hole
        translate([45, 30, -1]) cylinder(d = 4.5, h = wall + 2);
        // door servo: case through the shelf + tab screws
        translate([ds_S[0], ds_S[1], ds_tab]) {
            translate([-sv_off - 0.3, -sv_W/2 - 0.3, -10]) cube([sv_L + 0.6, sv_W + 0.6, 20]);
            servo_tab_holes(1.8);
        }
        // top button: switch pocket, plunger hole, wire slot
        translate([btn_x - 6.2, btn_y - 6.2, btn_shelf - 1.2]) cube([12.4, 12.4, 2]);
        translate([btn_x, btn_y, btn_top_in - 1]) cylinder(d = 7.2, h = wall + 3);
        translate([btn_x - 1.5, btn_y + 5, btn_shelf - 3]) cube([3, 6, 4]);
        // back-panel inserts
        for (p = boss_pts) translate([p[0], D - bp - ins_l, p[1]]) rotate([-90, 0, 0]) cylinder(d = ins_d, h = ins_l + 0.1);
        // deck inserts
        for (s = [-1, 1], y = [fw + 30, D - bp - 30]) translate([s * (hw - wall - 3), y, deck_z - deck_t - 4.1]) cylinder(d = ins_d, h = 4.2);
    }
}

// =========================================================== BACK PANEL
module back_panel() {
    difference() {
        union() {
            slab(D - bp, bp) outline2d(-wall - 0.2);
            // standoffs for 70×50 perfboard
            for (x = [-33, 33], z = [34, 80]) translate([x, D - bp, z]) rotate([90, 0, 0]) cylinder(d = 7, h = 8);
        }
        for (p = boss_pts) translate([p[0], D - bp - 1, p[1]]) rotate([-90, 0, 0]) {
            cylinder(d = 3.4, h = bp + 2);
            translate([0, 0, bp + 1 - 1.8]) cylinder(d1 = 3.4, d2 = 6.6, h = 1.81);
        }
        for (x = [-33, 33], z = [34, 80]) translate([x, D - bp - 9, z]) rotate([-90, 0, 0]) cylinder(d = 3.6, h = 6);
        // USB-C cutout
        translate([50 - 5, D - bp - 1, 18 - 2]) cube([10, bp + 2, 4]);
        for (dx = [-7.5, 7.5]) translate([50 + dx, D - bp - 1, 18]) rotate([-90, 0, 0]) cylinder(d = 2.4, h = bp + 2);
        // keyholes (wall mount)
        for (x = [-45, 45]) translate([x, D - bp - 1, 190]) rotate([-90, 0, 0]) {
            hull() { cylinder(d = 4, h = bp + 2); translate([0, -8, 0]) cylinder(d = 4, h = bp + 2); }
            cylinder(d = 8.5, h = bp + 2);
        }
        // vents
        for (i = [-3:3]) translate([i * 12 - 2, D - bp - 1, 120]) cube([4, bp + 2, 40]);
    }
}

// ============================================================ FACE MASK
// Cream inlay glued in the front pocket; carries the two door hinge lugs.
module face_mask() {
    difference() {
        union() {
            slab(0, mask_t) mask2d();
            for (z = [door_bot - 0.4 - lug_h, door_top + 0.4]) hull() {
                translate([hinge[0], hinge[1], z]) cylinder(r = 2.8, h = lug_h);
                translate([hinge[0] - 2.8, 0, z]) cube([5.6, 0.01, lug_h]);
            }
        }
        slab(-1, mask_t + 2) door_hole2d();
        for (s = [-1, 1]) translate([s * eye_x, -1, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_view_d + 7, h = mask_t + 2);
        translate([hinge[0], hinge[1], door_bot - lug_h - 2]) cylinder(d = pin_d - 0.05, h = door_top - door_bot + 2 * lug_h + 4, $fn = 16);
    }
}

// ================================================================== BEAK
module beak() {
    hull() {
        slab(-0.01, 0.01) polygon([[-8, 114], [8, 114], [0, 101.5]]);
        slab(-4, 0.01) polygon([[-3, 111], [3, 111], [0, 106]]);
    }
}

// ================================================================== DOOR
// Door frame: hinge axis at the origin, door closed along -X, outside face towards -Y.
// The axis sits 1 mm behind the plate centre so the knuckle is flush with the outside face.
module door() {
    hx = hinge[0]; hy = hinge[1];
    zb = door_bot; h = door_top - door_bot;
    difference() {
        union() {
            // plate (outside face 2.5 mm in front of the hinge axis)
            translate([-door_w/2 - hx, -2.5, 0]) cube([door_w/2 + hx, door_t, h]);
            translate([0, 0, 0]) cylinder(r = 2.5, h = h);
            // drive tab (behind the plate)
            translate([0, 0, tab_z - zb]) hull() {
                translate(crank_v) cylinder(r = 2.8, h = tab_th);
                translate([crank_v[0] - 2.8, 0.4, 0]) cube([5.6, 0.1, tab_th]);
            }
        }
        translate([0, 0, -1]) cylinder(d = pin_d + 0.25, h = h + 2, $fn = 16);
        translate([crank_v[0], crank_v[1], tab_z - zb - 1]) cylinder(d = 2.2, h = tab_th + 2, $fn = 16);
        // engraved feathers on the outside face
        for (i = [0:3]) translate([-hx, -2.5 - 0.01, 0]) rotate([-90, 0, 0]) linear_extrude(engrave + 0.01)
            stroke2d(qbez([-10, -(14 + i * 13)], [0, -(8 + i * 13)], [10, -(14 + i * 13)], 8), 1.4);
        // finger notch on the free edge
        translate([-door_w/2 - hx - 1, -3, h/2 - 6]) cube([3, 5, 12]);
    }
}
module door_placed(a) {
    translate([hinge[0], hinge[1], door_bot]) rotate([0, 0, a]) door();
}

// crank on the door servo horn (pin hole at crank_r)
module door_crank() {
    difference() {
        hull() { cylinder(d = horn_d + 5, h = 3); rotate(0) translate([crank_r, 0, 0]) cylinder(d = 6, h = 3); }
        translate([0, 0, 3 - 2 + 0.01]) cylinder(d = horn_d, h = 2);
        translate([0, 0, -1]) cylinder(d = 3, h = 5);
        for (a = [45:90:315]) rotate(a) translate([7.5, 0, -1]) cylinder(d = 1.8, h = 5, $fn = 16);
        translate([crank_r, 0, -1]) cylinder(d = 2.2, h = 5, $fn = 16);
    }
}
module door_link() {
    difference() {
        hull() { cylinder(d = 5.6, h = link_th); translate([link_L, 0, 0]) cylinder(d = 5.6, h = link_th); }
        for (x = [0, link_L]) translate([x, 0, -1]) cylinder(d = 2.2, h = 5, $fn = 16);
    }
}
// whole door drive at a given opening angle
module door_drive(a) {
    tp = hinge + [crank_r * cos(crank_a0 + a), crank_r * sin(crank_a0 + a)];
    door_placed(a);
    translate([ds_S[0], ds_S[1], crank_z]) rotate([0, 0, crank_a0 + a]) door_crank();
    translate([tp[0], tp[1], link_z]) rotate([0, 0, atan2(link_d[1], link_d[0])]) door_link();
}

// ========================================================== TOP BUTTON
module button_cap() {
    stem = (btn_top - wall) - (btn_shelf + tact_h) + wall - 0.1;  // reaches the plunger
    cylinder(d = 6.6, h = stem + 0.01);
    intersection() {
        translate([0, 0, stem]) scale([1, 1, 0.45]) sphere(d = 14);
        translate([0, 0, stem]) cylinder(d = 20, h = 10);
    }
}

// ================================================================= DECK   
module deck() {
    y0 = fw + 0.5; y1 = D - bp - 0.5;
    difference() {
        union() {
            translate([-W/2 + wall + 0.3, y0, deck_z - deck_t]) cube([W - 2*wall - 0.6, y1 - y0, deck_t]);
            // carriage guides (with lip)
            for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) {
                translate([fl_x + 0.4, y0, deck_z]) cube([2, y1 - y0, 4.4]);
                translate([fl_x - 1.6, y0, deck_z + 2.4]) cube([4, y1 - y0, 2]);
            }
        }
        // pinion servo (mounted from below, shaft up)
        translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) {
            translate([-sv_off - 0.3, -sv_W/2 - 0.3, -1]) cube([sv_L + 0.6, sv_W + 0.6, deck_t + 2]);
            servo_tab_holes(2.2);
        }
        // screws onto the ledges
        for (s = [-1, 1], y = [fw + 30, D - bp - 30]) translate([s * (W/2 - wall - 3), y, deck_z - deck_t - 1])
            cylinder(d = 3.4, h = deck_t + 2);
        // cable passages
        for (s = [-1, 1]) translate([s * 30 - 6, 85, deck_z - deck_t - 1]) cube([12, 20, deck_t + 2]);
    }
}

// ================================================================= CARRIAGE
module carriage() {
    difference() {
        union() {
            // servo box
            translate([-cb_x, cb_y0, -sv_below - floor_t]) cube([2*cb_x, cb_y1 - cb_y0, sv_below + floor_t - sv_tab_t]);
            // runners (slide under the deck lips)
            translate([-fl_x, rack_y0, -sv_below - floor_t]) cube([2*fl_x, rack_y1 - rack_y0, 2]);
            // tail + rack support
            translate([-cb_x, cb_y1 - 0.01, -sv_below - floor_t]) cube([cb_x + rack_px - 1.25, rack_y1 - cb_y1, rack_lz0 + 6 + sv_below + floor_t]);
            translate([cb_x - 0.01, rack_y0, rack_lz0]) cube([rack_px - 1.25 - cb_x + 0.02, rack_y1 - rack_y0, 6]);
            translate([rack_px, 0, rack_lz0]) linear_extrude(6) rack2d(rack_y0, rack_y1, gear_m);
            // cheeks + arm
            difference() {
                translate([-15, cb_y0, -sv_tab_t]) cube([30, -6.6 - cb_y0, arm_top_l + sv_tab_t]);
                translate([-6.5, cb_y0 - 1, -sv_tab_t - 1]) cube([13, 20, 30]);
            }
            translate([-15, -cd - 17, arm_bot_l]) rbox([30, cb_y0 + cd + 17 + 2, 4], 3);
            translate([0, -cd, arm_bot_l]) cylinder(d = 30, h = 4);
        }
        // servo pocket
        translate([-sv_W/2 - 0.3, -sv_off - 0.3, -sv_below - 0.01]) cube([sv_W + 0.6, sv_L + 0.6, sv_below + 1]);
        rotate([0, 0, 90]) servo_tab_holes(1.8);
        // servo cable exit
        translate([-3, sv_L - sv_off, -sv_below]) cube([6, 10, 8]);
        // turntable axle: low-head M3 screw from below
        translate([0, -cd, arm_bot_l - 1]) cylinder(d = 3.3, h = 10);
        translate([0, -cd, arm_bot_l - 1]) cylinder(d = 6.2, h = 1 + 1.8);
    }
}

// =============================================================== GEARS     
module horn_gear(teeth) {
    difference() {
        linear_extrude(gear_t) gear2d(teeth, gear_m);
        translate([0, 0, -0.01]) cylinder(d = horn_d, h = 2);       // round horn
        translate([0, 0, -1]) cylinder(d = 7, h = gear_t + 2);       // centre screw access
        for (a = [0:90:270]) rotate(a) translate([7.5, 0, -1]) cylinder(d = 1.8, h = gear_t + 2);
    }
}
module gear_turntable() {
    difference() {
        linear_extrude(gear_t) gear2d(gear_teeth, gear_m);
        translate([0, 0, -1]) cylinder(d = 3.4, h = gear_t + 2);
        translate([0, 0, gear_t - 2.6]) cylinder(d = 6.5, h = 3, $fn = 6);   // M3 nut (threadlocker)
        translate([-8.1, -8.1, gear_t - 1.2]) cube([16.2, 16.2, 2]);         // glued LEGO 2×2 plate
    }
}

// =================================================================== DIAL  
module dial() {
    difference() {
        cylinder(d = dial_d, h = 2);
        translate([0, 0, -1]) cylinder(d = mov_hole + 0.5, h = 4);
        // Hall sensor pocket + wire groove (back face)
        translate([-hall_pk[0]/2, hall_r - hall_pk[1]/2, -0.01]) cube([hall_pk[0], hall_pk[1], hall_pk[2]]);
        hull() { translate([0, hall_r, -0.01]) cylinder(d = 2, h = 1.2, $fn = 16);
                 translate([hall_exit[0], hall_exit[1], -0.01]) cylinder(d = 2, h = 1.2, $fn = 16); }
    }
    for (h = [1:12]) {
        a = 90 - h * 30;
        translate([0, 0, 2]) {
            rotate(a) translate([dial_d/2 - (h % 3 == 0 ? 14 : 8), -(h % 3 == 0 ? 1.5 : 0.8), 0])
                cube([h % 3 == 0 ? 10 : 4, h % 3 == 0 ? 3 : 1.6, 1.2]);
        }
    }
}

// ================================================================ WEIGHT
module weight() { // capsule-shaped pull weight
    difference() {
        hull() { translate([0, 0, 9]) sphere(d = 18); translate([0, 0, 33]) sphere(d = 18); }
        translate([-20, -20, -20]) cube([40, 40, 20]);
        translate([0, 0, 30]) cylinder(d = 2.5, h = 20);
    }
}

// =============================================================== ASSEMBLY
module minifig_ghost() {
    color("Gold", 0.8) {
        translate([-8, -8, 0]) cube([16, 16, 3.2]);           // 2×2 plate
        translate([-7.8, -4, 3.2]) cube([15.6, 8, 12.8]);      // legs
        translate([-7.8, -4, 16]) cube([15.6, 8, 12.8]);       // torso
        translate([0, 0, 28.8]) cylinder(d = 9.6, h = 10);     // head
        translate([0, 0, 38.8]) cylinder(d = 11, h = 4);       // hair
    }
}
module door_servo_placed() { translate([ds_S[0], ds_S[1], ds_tab]) mirror([0, 0, 1]) servo_model(); }

c_body = "#6B4F3A"; c_back = "#57402F"; c_mask = "#EFE9DF"; c_door = "#57402F";
c_dial = "#2B2B2B"; c_acc = "#E07A3F";
module assembly() {
    color(c_body) body();
    color(c_back) back_panel();
    color(c_mask) face_mask();
    color(c_acc) beak();
    color(c_dial) translate([0, -2, dial_z]) rotate([90, 0, 0]) cylinder(d = dial_d, h = 2);
    color("White") translate([0, -2, dial_z]) rotate([90, 0, 0]) intersection() { dial(); translate([0, 0, 2.05]) cylinder(d = dial_d + 1, h = 2); }
    color("DimGray") translate([-mov_sq/2, fw, dial_z - mov_sq/2]) cube([mov_sq, mov_depth, mov_sq]);
    for (s = [-1, 1]) color("Black") translate([s * eye_x, fw + 0.5, eye_z]) rotate([-90, 0, 0]) cylinder(d = eye_pcb_d - 0.5, h = 4);
    color("Silver", 0.9) deck();
    color("Tomato") translate([0, y_shaft, c_O]) carriage();
    translate([0, y_shaft, c_O]) rotate([0, 0, 90]) servo_model();
    color("Orange") translate([0, y_shaft, c_O + gear_bot_l]) horn_gear(gear_teeth);
    color("Orange") translate([0, y_shaft - cd, c_O + gear_bot_l]) gear_turntable();
    translate([0, y_shaft - cd, c_O + gear_bot_l + gear_t - 1.2]) minifig_ghost();
    translate([pin_x, pin_y, pin_O]) rotate([0, 0, 90]) servo_model();
    color("Orange") translate([pin_x, pin_y, pin_bot]) horn_gear(pin_teeth);
    color("ForestGreen") translate([rad_x - rad_w/2, fw + 0.2, rad_z - rad_h/2]) cube([rad_w, rad_t, rad_h]);
    color(c_door) door_drive(door_ang);
    door_servo_placed();
    color(c_acc) translate([btn_x, btn_y, btn_top]) button_cap();
    color(c_acc) translate([45, 30, -64]) weight();
}

// ================================================================ SELECTION
// Parts are laid out in their recommended print orientation.
if (part == "assembly") assembly();
else if (part == "body") rotate([90, 0, 0]) body();                          // front face on the bed
else if (part == "back_panel") translate([0, 0, D]) rotate([-90, 0, 0]) back_panel();
else if (part == "face_mask") rotate([-90, 0, 0]) translate([0, -mask_t, 0]) face_mask();   // back on the bed, lugs up
else if (part == "beak") rotate([-90, 0, 0]) beak();                         // base on the bed
else if (part == "door") rotate([90, 0, 0]) translate([0, 2.5, 0]) door();   // outside face on the bed
else if (part == "door_crank") door_crank();
else if (part == "door_link") door_link();
else if (part == "deck") translate([0, 0, -deck_z + deck_t]) deck();
else if (part == "carriage") translate([0, 0, sv_below + floor_t]) carriage();   // supports under the arm
else if (part == "gear_drive") horn_gear(gear_teeth);
else if (part == "gear_turntable") gear_turntable();
else if (part == "pinion") horn_gear(pin_teeth);
else if (part == "dial") dial();
else if (part == "button_cap") button_cap();                               // stem on the bed
else if (part == "weight") weight();
