// Precision for rounded stuff.
$fs = 1;

// Constants:
//
// Units are in mm.

HAIR_WIDTH = 15;
HAIR_LENGTH = 75;
HAIR_DEPTH = 2;

PILLAR_DIAMETER = 2;
// How long the pillars extend below the surface.
PILLAR_DEPTH = 3;
// Offset to center from the top (width) edge.
PILLAR_OFFSET_TOP = 3;
// Offset to center from the side (length) edge.
PILLAR_OFFSET_SIDE = 3;

// For now, LEDs are just rectangles.
// TODO: make them be rectangle + half-circle shaped.
LED_WIDTH = 3;
LED_LENGTH = 1.5;
LED_DEPTH = 1;
// Offset from the "top" edge.
LED_OFFSET = 2;

// Rounded rectangle base.
module Structure() {
  cube(size=[HAIR_WIDTH, HAIR_LENGTH - HAIR_WIDTH, HAIR_DEPTH]);
  // Rounded end.
  translate([HAIR_WIDTH / 2, HAIR_LENGTH - HAIR_WIDTH, 0])
    cylinder(h=HAIR_DEPTH, r=HAIR_WIDTH/2);
}

// LED shape, used for subtracting.
module Led() {
  // Go a small delta below the surface to make difference work cleanly.
  translate([(HAIR_WIDTH - LED_WIDTH) / 2, LED_OFFSET, -0.1])
    cube(size=[LED_WIDTH, LED_LENGTH, LED_DEPTH + 0.1]);
}

// Two pillars, extending in the negative Z direction.
module Pillars() {
  for (x = [PILLAR_OFFSET_SIDE, HAIR_WIDTH - PILLAR_OFFSET_SIDE]) {
    // Small offset in Z to make unions work cleanly.
    translate([x, PILLAR_OFFSET_TOP, 0.1])
      rotate([180, 0, 0])
        cylinder(h=(PILLAR_DEPTH + 0.1), r=PILLAR_DIAMETER);
  }
}

// Draws a single hair with pillars and LED hole.
module Hair() {
  difference() {
    Structure();
    Led();
  }
  Pillars();
}

Hair();
