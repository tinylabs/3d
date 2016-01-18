/**
 *  Open test tube
 *
 *  All rights reserved.
 *  Tiny Labs
 *  2015
 */

// Constants
PI = 3.14159;
$fn = 60;

// Input parameters
wall = 1;
d_out = 16;
Vml = 15;  // Volume in mL
neck_h = 6;
fit = 0.4; // Fudge factor to press fit
lip_x = 0.4;
lip_z = 2;

// Derived variables
// Outside diameter
d_in = d_out -  2 * wall;
r_in = d_in / 2;
r_out = d_out / 2;
Vmm3 = Vml * 1000;

// Calculate height of tube
h = (Vmm3 - 2/3 * PI * pow(r_in, 3)) / (PI * pow (r_in,2));



module tube (h, r_out) {
	cylinder (r = r_out, h = h);
	sphere (r = r_out);
}

module test_tube (h, r, wall, neck_h)
{
	difference () {
		union () {		

			// Solid body
			tube (h, r);

			// Add neck
			translate ([0, 0, h])
			//cylinder (h = neck_h, r = r_out + wall);	
			cylinder (h = neck_h, r = r_out);	
		}

		// negative
		tube (h + neck_h, r - wall);
	}
	
	// Add retention lip
	translate ([0, 0, h + neck_h - lip_z])
	difference () {
		cylinder (h = lip_z, r = r + lip_x);		
		cylinder (h = lip_z, r = r);
	}

}

module stopper (r_min, r_max, h)
{
	difference () {

		hull () {
			linear_extrude (height = 1)
			circle (r = r_max);

			translate ([0, 0, h - 1])
			linear_extrude (height = 1)
			circle (r = r_min);
		}

		// Remove negative
		cylinder (r = r_min - wall, h = h);
	}		
}

module lip (r, h) {
	translate ([0, 0, h])
	rotate_extrude ()
	translate ([r, 0, 0])
	polygon([[0,0], [lip_x, 0], [lip_x, 2]]);
}

module cap (r, wall, h)
{
	// Base
	linear_extrude (height = wall)
	circle (r = r + wall + fit);

	// Wall
	difference () {
		cylinder (r = r + wall + fit + lip_x, h = h);

		translate ([0, 0, wall])
		cylinder (r = r + fit + lip_x, h = h - wall);
	}

	// Add stopper
	translate ([0, 0, wall])
	stopper (r_in - wall, r_in, h - wall);

	// Add grip ridges
	for (d = [0 : 60 : 360]) {
		rotate ([0, 0, d])
		translate ([r + wall + fit + lip_x, 0, 0])
		cylinder (r = 0.8, h = h);
	}
	

	difference () {
		// Add cap edge
		translate ([0, 0, h - 2])
		cylinder (h = 2, r = r + wall + fit + 1.2);

		translate ([0, 0, h - 2])
		cylinder (h = 2, r = r + wall + fit);
	}

	// Add catch lip
	lip (r + fit, wall + lip_z + fit);
}

//cap (r_out, wall, neck_h * 2);
//translate ([0, 0, h + 20])
//rotate ([180, 0, 0])
test_tube (h, r_out, wall, neck_h);

