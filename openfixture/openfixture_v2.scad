/**
 *  OpenFixture v2 - The goal is to have a turnkey pcb fixturing solution as long as you have access to access to
 *  a laser cutter or laser cutting service.
 *
 *  The input is:
 *   1. (x, y) work area that is >= pcb size
 *   2. (x, y) cooridates of test point centers
 *   3. dxf of pcb outline aligned with (0,0) on the top left.
 *   4. Material parameters: acrylic thickness, kerf, etc
 *
 *  The output is a dxf containing all the parts (minus M3 hardware) to assemble the fixture.
 *
 *  Creative Commons Licensed  (CC BY-SA 4.0)
 *  Tiny Labs
 *  2016
 */
// Smothness function for circles
$fn = 20;

// This should usually be fine but might have to be adjusted
//kerf = 0.125;
kerf = 0.11;

// Work area of PCB
// Must be >= PCB size
area_x = 28;
area_y = 45;

// Test points
tps = [
    [0, 0],
    [area_x, 0],
    [0, area_y],
    [area_x, area_y],
];

// DXF outline of pcb
pcb_outline = "/home/elliot/projects/3d/openfixture/keysy_outline.dxf";

// All measurements in mm
// Material parameters
acr_th = 2.5;

// Active area offset from edges
// This must account for hardware on the sides but we make it even
// all the way around to simplify
area_offset = 2 * acr_th + 3;

// Screw radius (we want this tight to avoid play)
// This should work for M3 hardware
screw_r = (2.9 - kerf) / 2;
screw_d = (screw_r * 2);
// M3 head machine head
screw_head_th = 3.2;

// Change to larger size if you want different hardware for pivoting mechanism
pivot_r = screw_r;
pivot_d = (2 * pivot_r);

// Nut dimensions (common m3 hardware)
nut_od = 5.5;
nut_th = 2.3;

// Just the threads, not including head
screw_len = 11;

// Pogo pin receptable dimensions
// I use the 2 part pogos with replaceable pins. Its a life save when a pin breaks
pogo_r = (1.7 - kerf) / 2;
pogo_h = 24;

//
// DO NOT EDIT below (unless you feel like it)
//

// To account for kerf
acr_od = acr_th + 2 * kerf;
acr_id = acr_th;

// Pad between hole and edge
pad_h2e = 2 * acr_th;

// Padding for structuring element (ie: tnut)
pad_str = acr_th;

// Chebyshev linkage parameters
L3 = area_y + (2 * area_offset) - (2 * acr_id) - (2 * pad_h2e);
L2 = L3 * 2.5;
L1 = L3 * 2;

// Front to hole
//front2hole = ((area_y + (2 * area_offset)) - L3) / 2;

//
// MODULES
//

module tnut_female ()
{
    // Screw hole
    translate ([0, -screw_r, 0])
    cube ([screw_len - acr_id, screw_d + kerf, acr_id]);
    
    // Make space for nut
    translate ([pad_str, - nut_od/2, 0])
    cube ([nut_th, nut_od, acr_id]);
}

module tnut_hole ()
{
    cylinder (r = screw_r + kerf, h = acr_th);
}

module tng_n (length, cnt)
{
    tng_y = (length / cnt);
    
    translate ([0, -length / 2 - kerf, 0])
    union () {
        for (i = [0 : 2 : cnt - 1]) {
            translate ([0, i * tng_y, 0])
            cube ([acr_od, tng_y + 2 * kerf, acr_th]);
        }
    }
}

module tng_p (length, cnt)
{
    tng_y = length / cnt;
    
    translate ([0, -length / 2, 0])
    union () {
        for (i = [1 : 2 : cnt - 1]) {
            translate ([0, i * tng_y, 0])
            cube ([acr_od, tng_y, acr_th]);
        }
    }
}

module side ()
{
    y = area_y + (2 * area_offset);
    x = pogo_h;
    
    difference () {
        // base cube
        cube ([x, y, acr_th]);
        
        // Drop holes for chebychev linkage
        translate ([acr_id + pad_h2e, (y - L3) / 2, 0])
        cylinder (r = pivot_r, h = acr_th);
        translate ([acr_id + pad_h2e, y - ((y - L3) / 2), 0])
        cylinder (r = pivot_r, h = acr_th);
        
        // Remove tng (top and bottom)
        translate ([0, y/2, 0])
        tng_n (y, 5);
        translate ([x - acr_od, y/2, 0])
        tng_n (y, 5);
        
        // Remove tng back
        translate ([x/2, y - acr_id, 0])
        rotate ([0, 0, 90])
        tng_p (x, 3);
        
        // Remove tnuts
        translate ([acr_id, y / 2, 0])
        tnut_female ();
        translate ([x - acr_id, y / 2, 0])
        rotate ([0, 0, 180])
        tnut_female ();
    }
}

module back ()
{
    x = area_x + (2 * area_offset);
    y = pogo_h;
    
    difference () {
        // Base cube
        cube ([x, y, acr_th]);
        
        // Remove bottom and top tng
        translate ([x/2, 0, 0])
        rotate ([0, 0, 90])
        tng_n (x, 5);
        translate ([x/2, y - acr_id, 0])
        rotate ([0, 0, 90])
        tng_n (x, 5);
        
        // Remove left/right tng
        translate ([0, y / 2, 0])
        tng_n (y, 3);
        translate ([x - acr_id, y / 2, 0])
        tng_n (y, 3);

        // Remove tnuts
        translate ([x/2, acr_id, 0])
        rotate ([0, 0, 90])
        tnut_female ();
        translate ([x/2, y - acr_id, 0])
        rotate ([0, 0, -90])
        tnut_female ();
    }
}

module tp_base (test_points, tp_cnt)
{
    x = area_x + (2 * area_offset);
    y = area_y + (2 * area_offset);
    
    difference () {
        cube ([x, y, acr_th]);
    
        // Calc (x,y) origin = (0, 0)
        origin_x = area_offset;
        origin_y = area_offset + area_y;
    
        // Loop over test points
        for ( i = [0 : tp_cnt - 1] ) {
        
            // Drop pins for test points
            translate ([origin_x + test_points[i][0], origin_y - test_points[i][1], 0])
            cylinder (r = pogo_r, h = acr_th);
        }
        
        // Remove tongue and groove
        translate ([0, y / 2, 0])
        tng_p (y, 5);
        translate ([x - acr_id, y / 2, 0])
        tng_p (y, 5);
        translate ([x/2, y - acr_od, 0])
        rotate ([0, 0, 90])
        tng_p (x, 5);
        
        // Remove tnut holes
        translate ([acr_id / 2, y / 2, 0])
        tnut_hole ();
        translate ([x / 2, y - acr_id/2, 0])
        tnut_hole ();
        translate ([x - acr_id/2, y / 2, 0])
        tnut_hole ();
    }
}

module stand_side ()
{
    pivot_offset = acr_id + pad_h2e + screw_head_th;
    base_offset = (4 * acr_th);
    base_x = L2 + area_offset;

    difference () {
        union () {
            // vertical support
            hull () {
                translate ([0, L1 + base_offset + pivot_offset, 0])
                cylinder (r = pivot_d, h = acr_th);
                cylinder (r = pivot_d, h = acr_th);
            }
            // Base structure
            hull () {        
                cylinder (r = pivot_d, h = acr_th);
                translate ([0, base_offset - pivot_d, 0])
                cylinder (r = pivot_d, h = acr_th);
                translate ([L2 + area_offset - pivot_d, base_offset - pivot_d, 0])
                cylinder (r = pivot_d, h = acr_th);
                translate ([L2 + area_offset - pivot_d, 0, 0])
                cylinder (r = pivot_d, h = acr_th);
            }
            
            // Cross support
            translate ([sqrt( pow((L1/2), 2) / 2), base_offset - pivot_d, 0])
            rotate ([0, 0, 45])
            hull () {
                cylinder (r = pivot_d, h = acr_th);
                translate ([0, L1 / 2, 0])
                cylinder (r = pivot_d, h = acr_th);
            }
        }
        
        // Remove holes
        translate ([0, base_offset + pivot_offset, 0])
        cylinder (r =  pivot_r, h = acr_th); 
        translate ([0, base_offset + pivot_offset + L1, 0])
        cylinder (r =  pivot_r, h = acr_th);
        
        // Remove tng for carrier
        translate ([area_y / 2 + base_x - area_offset - area_y, base_offset - acr_th, 0])
        rotate ([0, 0, 90])
        tng_n (area_y + 2 * area_offset, 5);
        translate ([area_y / 2 + base_x - area_offset - area_y, base_offset - (2 * acr_th), 0])
        rotate ([0, 0, 90])
        tng_n (area_y + 2 * area_offset, 5);
        
        // Remove tng for base support
        translate ([(L2 - area_y) / 2, 0, 0])
        rotate ([0, 0, 90])
        tng_n (L2 - area_y, 3);
        
        // Remove tng for back support
        translate ([-acr_od / 2, base_offset + pivot_offset + L1 / 2, 0])
        tng_n (L2 / 2, 3);
        
        // Remove support holes
        translate ([0, base_offset + pivot_offset + L1 / 2, 0])
        tnut_hole ();
        translate ([(L2 - area_y) / 2, acr_id / 2, 0])
        tnut_hole ();
    }    
}

module stand_base_support (y)
{
    x = area_x + (2 * area_offset);

    difference () {
        // Base cube
        cube ([x, y, acr_th]);
        
        // Remove tng
        translate ([0, y / 2, 0])
        tng_p (y, 3);
        translate ([x - acr_id, y / 2, 0])
        tng_p (y, 3);
        
        // Remove tnuts
        translate ([acr_id, y / 2, 0])
        tnut_female ();
        translate ([x - acr_id, y / 2, 0])
        rotate ([0, 0, 180])
        tnut_female ();
    }
}

module linkage (length)
{
    difference () {
        hull () {            
            cylinder (r = pivot_d, h = acr_th);
            translate ([0, length, 0])
            cylinder (r = pivot_d, h = acr_th);
        }
        
        // Remove holes
        cylinder (r = pivot_r, h = acr_th);
        translate ([0, length, 0])
        cylinder (r = pivot_r, h = acr_th);
    }
}

module linkage_handle (length)
{
    handle_length = 20;
    difference () {
        hull () {            
            cylinder (r = pivot_d, h = acr_th);
            translate ([0, length + handle_length, 0])
            cylinder (r = pivot_d, h = acr_th);
        }
        
        // Remove holes
        cylinder (r = pivot_r, h = acr_th);
        translate ([0, length, 0])
        cylinder (r = pivot_r, h = acr_th);
    }
}
module spacer ()
{
    difference () {
        cylinder (r = screw_d, h = acr_th);
        cylinder (r = screw_r, h = acr_th);
    }
}

module carrier (dxf_filename) {

    x = area_x + 2 * area_offset;
    y = area_y + 2 * area_offset;
    
    difference () {
        // Base cube
        cube ([x, y, acr_th]);
        
        // Remove pcb
        translate ([area_offset, area_y + area_offset, 0])
        hull () {
            linear_extrude (height = acr_th)
            import (dxf_filename);
        }
        
        // Remove tng
        translate ([0, y/2, 0])
        tng_p (y, 5);
        translate ([x - acr_id, y/2, 0])
        tng_p (y, 5);
    }
}

// Laser layout
module lasercut_head () 
{
    // Bases
    tp_base (tps, 4);
    translate ([area_x + 2 * area_offset + pogo_h, 0, 0])
    tp_base (tps, 4);
    
    // Sides
    translate ([area_x + (2 * area_offset), 0, 0])
    side ();
    translate ([area_x + (2 * area_offset) + 1, area_y + (2 * area_offset) + pogo_h + 1, 5])
    rotate ([0, 0, -90])
    side ();

    // Back
    translate ([0, area_y + (2 * area_offset), 0])
    back ();
    
    // Add pcb carrier
    translate ([2 * (area_x + 2 * area_offset) + pogo_h + 1, 0, 0])
    carrier (pcb_outline);
    
    // Add blank carrier
    translate ([3 * (area_x + 2 * area_offset) + pogo_h + 2, 0, 0])
    carrier ();
    
    // Add spacers
    // Calculate spacers for the front
    spacer_front_cnt = 2 + ceil (screw_head_th / acr_th);
    
    // 4 for rear linkage
    spacer_cnt = 4 + 4 * spacer_front_cnt;
    
    // Calculate offsets
    spacer_x_offset = 2 * (area_x + 2 * area_offset) + pogo_h + 1;
    spacer_y_offset = area_y + (2 * area_offset) + screw_d + 1;
    
    for (i = [0 : spacer_cnt - 1]) {
        if (i < spacer_cnt / 2) {
            translate ([spacer_x_offset + (2 * screw_d) * i, spacer_y_offset, 0])
            spacer ();
        } 
        else {
            translate ([spacer_x_offset + (2 * screw_d) * (i - spacer_cnt / 2), spacer_y_offset + (2 * screw_d) + 1, 0])
            spacer ();
        }
    }
}

module lasercut_stand ()
{
    
}

projection (cut = false)
lasercut_head ();

// Testing
if (1) {
    //tnut_female_n ();
    //rotate ([0, -90, 0])
    //tp_base (tps, 4);
    //side ();
    //back ();
    //tnut_hole ();
    //tng_p (area_x + (2 * area_offset), 5);
    //translate ([0, 0, 3])
    //tng_n (area_x + (2 * area_offset), 5);
    //stand_side ();
    //stand_base_support (L2 - area_y);
    //stand_base_support (L2 / 2);
    //linkage (L2);
    //linkage_handle (L2);
    //spacer ();
    //carrier ("/home/elliot/projects/3d/openfixture/keysy_outline.dxf");
    //carrier ();
}
