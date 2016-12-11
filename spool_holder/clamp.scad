/**
 * Clamp for spool holder
 */
$fn = 40;
wall = 3;
clamp_x = 74.0;
clamp_y = 45;
clamp_z = 3;
clamp_r = 3;


mount_c2c = 81;
mount_z = 22;
mount_r = 3.5 / 2;

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


module m3 () {
    
    cylinder (r = 3.5/2, h = 2 * wall);
}

module relief (h, th) 
{
    hull () {
        cylinder (r = 2, h = th);
        translate ([0, h - 4, 0])
        cylinder (r = 2, h = th);
    }     
}

module cutout () {
    for (i = [0 : 6]) {
        rotate ([90, 0, 0])
        translate ([i * 10, 0, 0])
        relief (20, 4);
    }
}

module cutout2 () {
    for (i = [0 : 5]) {
        rotate ([90, 0, 0])
        translate ([i * 10, 0, 0])
        relief (15, 4);
    }
}

module clamp () {
    
    difference () {
        rcube (clamp_x + 2 * wall, clamp_y, clamp_z, clamp_r);
        translate ([wall, wall, 0])
        rcube (clamp_x, clamp_y - 20, clamp_z, clamp_r);
        translate ([wall, clamp_y -10, 0])
        cube ([clamp_x, 4.8, clamp_z]);
        translate ([((clamp_x + 2 * wall) - 60) / 2, clamp_y - 18, 0])
        cube ([60, 10, clamp_z]);
    }
}

module mount () {
    
    difference () {
        hull () {
            translate ([mount_c2c - clamp_x + mount_r + wall, 
                        mount_r, 0])
            cube ([clamp_x, mount_z, wall]);
            cylinder (r = mount_r + wall, h = wall);
            translate ([mount_c2c, 0, 0])
            cylinder (r = mount_r + wall, h = wall);
        }
        // Remove screw holes
        cylinder (r = mount_r, h = wall);
        translate ([mount_c2c, 0, 0])
        cylinder (r = mount_r, h = wall);
        
        // Remove extra space
        translate ([16, 0, 0])
        rcube (60, mount_z, wall, 1);
    }
}

clamp ();
translate ([-(mount_c2c - clamp_x), -mount_z, 0])
mount ();
