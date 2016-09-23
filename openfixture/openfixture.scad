/**
 * This is an open source fixture design based on a chebyshev linkage
 *
 * Free for all uses
 * Tiny Labs Inc
 *  2016
 */
 $fs = 1;
 
 // Material properties
 // Acrylic 0.118" = 3mm
 acrylic_th = 2.4;
 acrylic_kerf = 0.2;
 acrylic_id = acrylic_th + acrylic_kerf;
 
 // Active work area
 // Defining this will change the rest of the parameters
 // Tyler dimensions
 //warea_x = 44;  // 1.7"
 //warea_y = 36;  // 1.4"
 // keysy dimensions
 warea_x = 28;
 warea_y = 45;


 // Space between laser cuts
 laser_space = 2;
 
 // Pivot holes
 pivot_r = 5/2;
 
 // Screw holes
 screw_r = 3.2 / 2;
 screw_z = 10.5;
 screw_head_z = 3;
 
 // Common lip around holes
 hlip = 2;
 
 // Interlock material
 interlock_th = 3;
 
 // Tongue and groove parameters
 tng_w = 4.5;
 tng_id = tng_w + acrylic_kerf;
 tng_offset = 4;
 
 // Tnut depth
 tnut_ypad = 0.2;
 tnut_zpad = 2;
 tnut_y = (screw_r * 2) + tnut_ypad;
 tnut_depth = screw_z - acrylic_th + tnut_zpad;
 tnut_grip = 2;
 tnut_nut_x = 5.5;
 tnut_nut_z = 2.3;
 
 // Pogo z depth
 pogo_z = 22;
 pogo_r = 1.85 / 2;
 
 
 // Do not edit these!!
 //

 // Core geometry
 L3 = warea_y;
 L2 = 2.5 * L3;
 L1 = 2 * L3;
 
 // Head parameters
 head_pad_x1 = pivot_r + hlip;
 head_pad_x2 = pivot_r + hlip + tnut_depth;
 head_x = L3 + head_pad_x1 + head_pad_x2;
 head_y =  pogo_z + 2 * interlock_th;
 head_pad_y = screw_head_z + 2;
 head_back_w = 2 * acrylic_th + 2 * head_pad_y + warea_x;

 // Insert dimensions
 insert_y = L3 + head_pad_x1;
 //insert_x = 
 insert_z = 2 * acrylic_th;
 
 // Base parameters
 base_feet = 4;
 base_th = 2 * acrylic_th + 2 * interlock_th;
 
 module tng_p ()
 {
     translate ([-acrylic_th, screw_r + tng_offset, 0])
     cube ([acrylic_th, tng_w, acrylic_th]);
     translate ([-acrylic_th, -screw_r - tng_w - tng_offset, 0])
     cube ([acrylic_th, tng_w, acrylic_th]);
 }

 module tng_n ()
 {
     translate ([0, screw_r + tng_offset - (acrylic_kerf/2), 0])
     cube ([acrylic_th, tng_id, acrylic_th]);
     translate ([0, -screw_r - tng_id - tng_offset + (acrylic_kerf/2), 0])
     cube ([acrylic_th, tng_id, acrylic_th]);

     // Remove screw hole
     translate ([0, -tnut_y/2, 0])
     cube ([acrylic_th, tnut_y, acrylic_th]);
 }
 
 module tnut () {
     translate ([0, -tnut_y / 2, 0])
     cube ([tnut_depth, tnut_y, acrylic_th]);
     translate ([tnut_grip, -tnut_nut_x/2, 0])
     cube ([tnut_nut_z, tnut_nut_x, acrylic_th]);
 }
 
 module head_side ()
 {
     difference () {
        translate([-(L3 / 2) - head_pad_x2, -head_y / 2, 0])
        cube ([head_x, head_y, acrylic_th]);
         
         // Remove swivel holes
         translate ([L3 / 2, 0, 0])
         cylinder (r = pivot_r, h = acrylic_th);
         translate ([-L3 / 2, 0, 0])
         cylinder (r = pivot_r, h = acrylic_th);
         
         // Remove slots
         translate ([-L3 / 2, (head_y / 2) - (interlock_th) - acrylic_id, 0])
         cube ([insert_y, acrylic_id, acrylic_th]); 
         translate ([-L3 / 2, -(head_y / 2) + (interlock_th), 0])
         cube ([insert_y, acrylic_id, acrylic_th]);
         
         // Remove tnut slot
         translate ([-L3/2 - head_pad_x2, 0, 0])
         tnut ();
     }
     
     // Add tongue and groove
     translate ([-L3/2 - head_pad_x2, 0, 0])
     tng_p ();
 }
 
 module head_back ()
 {
     difference () {
        translate ([-head_back_w/2, -head_y/2, 0])
        cube ([head_back_w, head_y, acrylic_th]);
         
         // Remove tng slots
         translate ([-head_back_w/2, 0, 0])
         tng_n ();
         translate ([head_back_w/2 - acrylic_th, 0, 0])
         tng_n ();

         // Remove slots for pogo carriers
         translate ([0, head_y/2 - interlock_th - (acrylic_id / 2), acrylic_th/2])
         cube ([warea_x, acrylic_id, acrylic_th], center = true);
         translate ([0, -(head_y/2 - interlock_th - (acrylic_id / 2)), acrylic_th/2])
         cube ([warea_x, acrylic_id, acrylic_th], center = true);
     }
 }
 
 module stand_side ()
 {
    difference () {
        
        union () {
            hull () {
                translate ([0, L1 + head_y / 2, 0])
                cylinder (r = pivot_r * 2, h = acrylic_th);
                translate ([0, -base_th - base_feet, 0])
                cylinder (r = pivot_r * 2, h = acrylic_th);
            }
            
            // Add base cube
            translate ([0, -base_th, 0])
            cube ([L2 + hlip, base_th, acrylic_th]);
            
            // Add foot
            translate ([L2 + hlip - (pivot_r * 2), 0, 0])
            hull () {
                translate ([0, -(pivot_r * 2), 0])
                cylinder (r = pivot_r * 2, h = acrylic_th);
                translate ([0, -base_th - base_feet, 0])
                cylinder (r = pivot_r * 2, h = acrylic_th);                
            }
            
            // Add crossbar support
            hull () {
                translate ([0, head_y, 0])
                cylinder (r = pivot_r * 2, h = acrylic_th);
                translate ([head_y + 2 * pivot_r, -(2 * pivot_r), 0])
                cylinder (r = pivot_r * 2, h = acrylic_th);
            }
        }
        
        // Remove mount holes
        translate ([0, head_y / 2, 0])
        cylinder (r = pivot_r, h = acrylic_th);
        translate ([0, L1 + head_y / 2, 0])
        cylinder (r = pivot_r, h = acrylic_th);
        
        // Remove carrier slots
        translate ([(L2 + hlip) - insert_y, -insert_z - interlock_th, 0])
        cube ([insert_y, insert_z, acrylic_th]);
        
        // Remove bottom support slot
        translate ([pivot_r * 2, -acrylic_id - interlock_th, 0]) 
        cube ([head_y + (2 * acrylic_kerf), acrylic_id, acrylic_th]);
        
        // Remove back support slot
        translate ([-acrylic_id/2, head_y / 2 + (L1 / 4) - acrylic_kerf, 0])
        cube ([acrylic_id, L1 / 2 + (2 * acrylic_kerf), acrylic_th]);
        
        // Remove tnut holes
        translate ([0, head_y / 2 + (L1 / 4) - tng_offset, 0])
        cylinder (r = screw_r, h = acrylic_th);
        translate ([0, head_y / 2 + (L1 / 2) + (L1 / 4) + tng_offset, 0])
        cylinder (r = screw_r, h = acrylic_th);
    }
 }
 
 module bottom_support ()
 {
     translate ([0, 0, acrylic_th / 2])
     cube ([head_y , head_back_w, acrylic_th], center = true);
     translate ([0, 0, acrylic_th / 2])
     cube ([head_y + (2 * interlock_th), head_back_w - (2 * acrylic_th), acrylic_th], center = true);
 }
 
 module back_support ()
 {
     difference () {
         union () {
            cube ([head_back_w, L1 / 2 + 4 * tng_offset, acrylic_th]);
         
             // tongue 1
             translate ([-acrylic_th, 2 * tng_offset, 0])
             cube ([acrylic_th, L1 / 2, acrylic_th]);
            
             // tongue 2
             translate ([head_back_w, 2 * tng_offset, 0])
             cube ([acrylic_th, L1 / 2, acrylic_th]);
         }
         // Remove tnuts
         translate ([0, tng_offset, 0])
         tnut ();
         translate ([0, L1 / 2 + 3 * tng_offset, 0])
         tnut ();
         translate ([head_back_w + 0.05, tng_offset, 0])
         rotate ([0, 0, 180])
         tnut ();
         translate ([head_back_w + 0.05, L1 / 2 + 3 * tng_offset, 0])
         rotate ([0, 0, 180])
         tnut ();
     }
 }
 
 module linkage ()
 {
     difference () {
         hull () {
            cylinder (r = pivot_r * 2, h = acrylic_th);
            translate ([0, L2, 0])
            cylinder (r = pivot_r * 2, h = acrylic_th);
         }
         // Remove holes
         cylinder (r = pivot_r, h = acrylic_th);
         translate ([0, L2, 0])
         cylinder (r = pivot_r, h = acrylic_th);         
     }
 }
 
 module laser_parts ()
 {
     // 2 side stands
     stand_side ();
     translate ([L2 + laser_space, L2 + laser_space, 0])
     rotate([0, 0, 180])
     stand_side ();
     
     // 2 head side
     //translate ([L2 - head_x / 2 + laser_space, head_y/2 + laser_space, 0])
     translate ([head_x + head_y / 2 + laser_space, head_y/2 + laser_space, 0])
     head_side ();
     translate ([head_x / 2 + laser_space, L2 - head_y/2, 0])
     rotate ([0, 0, 180])
     head_side ();
     
     // 1 head back
     translate ([head_back_w / 2 + head_x/2 - laser_space, (head_y/2) + head_y + 2 * laser_space, 0])
     head_back ();
     
     // 4 linkage connections
     translate ([L2 + pivot_r * 6, 0, 0])
     linkage ();
     translate ([L2 + pivot_r * 11, 0, 0])
     linkage ();
     translate ([L2 + pivot_r * 16, 0, 0])
     linkage ();
     translate ([L2 + pivot_r * 21, 0, 0])
     linkage ();
     
     // 1 back support
     translate ([L2 + 25 * pivot_r, 0, 0])
     back_support ();
     
     // Bottom support
     translate ([L2 + 25 * pivot_r + (head_back_w/2), L1, 0])
    rotate ([0, 0, 90])
    bottom_support ();
 }
 
 if (0) {
 // sides
 translate ([0, head_back_w - acrylic_th, 0])
 rotate ([90, 0, 0])
 head_side ();
 rotate ([90, 0, 0])
 head_side (); 

 // back
 translate ([-(L3 /2) - head_pad_x2 - acrylic_th, head_back_w/2 - acrylic_th, 0])
 rotate ([0, 90, 0])
 rotate ([0, 0, 90])
 head_back ();
     
 // Side stands
 translate ([-L2 + (L3/2), 0, -head_y/2])
 rotate ([90, 0, 0])
 stand_side ();
 translate ([0, head_back_w - acrylic_th, 0])
 translate ([-L2 + (L3/2), 0, -head_y/2])
 rotate ([90, 0, 0])
 stand_side ();
 } 
 
 // Testing
 if (1) {
 //tnut ();
 //tng_p ();
 //tng_n ();
 //head_back ();
 //translate ([0, 0, 10])
 //head_side ();
  //stand_side ();  
  //bottom_support ();
  //back_support ();
  //linkage ();
 }
 
 // Laserable parts
 if (1) {
     projection (cut = false)
     laser_parts();
 }