// Precision for rounded stuff.
$fs = 1;

// Constants:
//
// Units are in mm.

HAIR_WIDTH = 15;
HAIR_HEIGHT = 75;
HAIR_DEPTH = 2;

PILLAR_DIAMETER = 2;

// For now, LEDs are just rectangles.
// TODO: make them be rectangle + half-circle shaped.
LED_WIDTH = 3;
LED_HEIGHT = 1.5;
LED_DEPTH = 1;

module Hair() {
  cube(size = [HAIR_WIDTH, HAIR_HEIGHT - HAIR_WIDTH, HAIR_DEPTH]);
  // Rounded end.
  translate([HAIR_WIDTH / 2, HAIR_HEIGHT - HAIR_WIDTH, 0])
    cylinder(h=HAIR_DEPTH, r=HAIR_WIDTH/2);
}

Hair();
