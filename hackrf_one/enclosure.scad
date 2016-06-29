/**
 *  Hack RF one enclosure
 *  uses brass m3 inserts
 *  printed in PLA
 */
 
 // Set facet size
 $fs = 2;
// $fs = 0.5;
 
 // All m3 holes
 m3r = 3.5/2;
 m3hr = 6/2;
 
 // Pcb dimensions
 pcb_x = 75;
 pcb_y = 120.3;
 pcb_z = 1.6;

 // pcb radius
 pcb_r = 3;
 
 pcb_x_pad = 1;
 pcb_y_pad = 1;
 
 // Bottom standoff
 bot_z_off = 1.5;
 
 // Wall thinkness
 wall = 1.2;
 
 // Wall thickness
 counter_sink = 3;
 bot_wall = counter_sink + wall;
 
 hole = [
    [4, 4],
    [pcb_x - 4, 4],
    [4, 66],
    [44, 70.5],
    [4, pcb_y - 4],
    [pcb_x - 4, pcb_y - 4],
 ];
 
 
 module bot_standoff ()
 {
     difference () {
        cylinder (r = m3hr, h = bot_z_off);
        cylinder (r = m3r, h = bot_z_off);
     }
 }

module bot_standoffs ()
{
        for (i = [0 : 5]) {
            translate ([hole[i][0], hole[i][1], 0])
            bot_standoff ();
        }
}

module rcube (x, y, z, r)
{
    hull () {
        translate ([r, r, 0])
        cylinder (r = r, h = z);
        translate ([x - r, r, 0])
        cylinder (r = r, h = z);
        translate ([r, y - r, 0])
        cylinder (r = r, h = z);
        translate ([x - r, y - r, 0])
        cylinder (r = r, h = z);
    }
}

module m3_holes (h)
{
    for (i = [0 : 5]) {
        translate ([hole[i][0], hole[i][1], 0])
        cylinder (r = m3r, h = h);
    }
}

module counter_sinks (h)
{
    for (i = [0 : 5]) {
        translate ([hole[i][0], hole[i][1], 0])
        cylinder (r = m3hr, h = h);
    }    
}

module side_b ()
{
    difference () {
        union () {
            translate ([0, 0, -bot_z_off - bot_wall])
            rcube (pcb_x, pcb_y, bot_wall, pcb_r);
            translate ([0, 0, -bot_z_off])
            bot_standoffs ();
        }
        
        // Remove screw hole
        translate ([0, 0, -bot_wall - bot_z_off])
        m3_holes (bot_wall + bot_z_off);

        // Remove counter sinks
        translate ([0, 0, -bot_z_off - bot_wall])
        counter_sinks (counter_sink);
    }
}

side_b ();
