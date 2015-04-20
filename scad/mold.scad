// 3D-printable mold for casting a single hair.

// Precision for rounded stuff.
$fs = 1;

use <hair.scad>;

// Constants:
//
// Units are in mm.

MOLD_WALLS = 5;
MOLD_WIDTH = 15 + 2 * MOLD_WALLS;
MOLD_LENGTH = 75 + 2 * MOLD_WALLS;
MOLD_Z_OFFSET = 5;
MOLD_DEPTH = 10;

module Mold() {
  difference() {
    cube(size=[MOLD_WIDTH, MOLD_LENGTH, MOLD_DEPTH]);
    render()
    union() {
      // TODO: this for loop is a hack. I couldn't quickly figure out how to
      // get a profile and extrude it to make the top open for the mold.
      for (i = [0 : MOLD_DEPTH]) {
        translate([MOLD_WALLS, MOLD_WALLS, MOLD_Z_OFFSET + i])
          Hair();
      }
    }
  }
}

Mold();
