// OpenSCAD model for a single Disco Wookie hair

// === please wrap at 80 cols ==================================================

// Precision for rounded stuff.
$fa = 1;  // smallest angle to use for circles
$fs = 1;  // smallest size edge in a circle

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

// Color to use for demo renderings.
WOOKIE_BROWN = [0.52, 0.35, 0.24];

// Used to avoid near-zero-width facets.
FUDGE = 0.01;

function even(x) = x % 2 == 0;

// Rounded rectangle base.
module DivingBoard() {
  cube(size=[HAIR_WIDTH, HAIR_LENGTH - HAIR_WIDTH / 2, HAIR_DEPTH]);
  // Rounded end.
  translate([HAIR_WIDTH / 2, HAIR_LENGTH - HAIR_WIDTH / 2, 0])
    cylinder(h=HAIR_DEPTH, r=HAIR_WIDTH/2);
}

module Groove(angle = 45, depth = 1, width = HAIR_WIDTH * 2) {
  length = 2 * depth / tan(angle);
  big = max(HAIR_LENGTH, HAIR_WIDTH, HAIR_DEPTH) * 2;
  inverseAngle = 90 - angle;
  intersection() {
    cube(size=[width, length, depth]);
    translate([0, length / 2, 0]) rotate([inverseAngle, 0, 0])
      translate([0, 0, -big / 2]) cube(big);
    translate([0, length / 2, 0]) rotate([-inverseAngle, 0, 0])
      translate([0, -big, -big / 2]) cube(big);
  }
}

// Produces a shape resembling a tuft of hair, using two circular edges and one
// flat edge. Arguments:
//
//   - length is the distance from base to tip
//   - tipSpan is the interior angle between edges at the tip of the tuft
//   - tipDirection is the average angle of the edges at the tip, relative to y
//   - height is the constant height of the whole shape
//
// tipSpan must be in the open range (0, 180) and tipDirection must be less than
// tipSpan / 2. If tipSpan is over 90, part of the curve may protrude beyond
// the tip, meaning that length is not an overall bound.
module ConvexTuft(length = 60, height = 5, tipSpan = 30, tipDirection = 10) {
  bezel = height / 4;
  a = tipSpan / 2 + tipDirection;
  b = tipSpan / 2 - tipDirection;
  ra = length / sin(a);
  rb = length / sin(b);
  s = ra * cos(a) + rb * cos(b);
  translate([rb - s, 0, 0]) intersection() {
    cylinder(h = height, r1 = ra, r2 = ra - bezel);
    translate([s, 0, 0]) {
      cylinder(h = height, r1 = rb, r2 = rb - bezel);
    }
    cube([s, length, height]);
  }
}

module GroovedTuft(length = 60, height = 5, tipSpan = 30, tipDirection = 10) {
  grooveSpacing = 0.50;
  grooveDepth = 0.25;
  grooveSink = grooveDepth * 0.9;  // fudge to avoid epsilon overhang
  difference() {
    ConvexTuft(length = length, height = height, tipSpan = tipSpan, 
               tipDirection = tipDirection);
    for (i = [ 0 : grooveSpacing : length ])
      translate([0, i, height - grooveSink]) Groove(depth = grooveDepth);
  }
}

// LED shape, used for subtracting.
module Led() {
  // Go a small delta below the surface to make difference work cleanly.
  translate([(HAIR_WIDTH - LED_WIDTH) / 2, LED_OFFSET, -FUDGE])
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

module Tufts() {
  // TODO(cody): automatically center tufts rather than manual adjustment.
  translate([-1, 0, 0])
    GroovedTuft(length = 70, height = 2, tipSpan = 28, tipDirection = -5);
  GroovedTuft(length = 60, height = 4, tipSpan = 30, tipDirection = 8);
  GroovedTuft(length = 55, height = 6, tipSpan = 25, tipDirection = -5);
  GroovedTuft(length = 45, height = 8, tipSpan = 35, tipDirection = -12);
}

// Shape removed from the outward surface of the hair, to scatter light.
module Divot(size) {
  difference() {
    cylinder(h = size, r1 = 0, r2 = size, $fs = 0.1);
    rotate([0, 0, 180])
      translate([-size - FUDGE, 0, -FUDGE])
        cube(size = 2 * (size + FUDGE));
  }
}

module DivotRow(size, width, spacing) {
  for (i = [ 0 : spacing : width ])
    translate([i, 0, 0])
      Divot(size);
}

// Field of divots that grows gradually denser farther from the light source.
module DivotField(size, width, length, yspacing, xspacing) {
  divotDensityRange = 6;
  rows = length / yspacing;
  for (i = [ 0 : rows ]) {
    spacing = xspacing / (1 + divotDensityRange * i / rows);
    translate([even(i) ? spacing / 2 : 0, i * yspacing, 0])
      DivotRow(size, width, spacing);
  }
}

// Draws a basic hair with pillars and LED hole.
module SimpleHair() {
  divotSize = 0.2;
  difference() {
    DivingBoard();
    Led();
    translate([0, 0, HAIR_DEPTH - divotSize + FUDGE])
      DivotField(divotSize, HAIR_WIDTH, HAIR_LENGTH,
                 yspacing = 1, xspacing = 5);
  }
  Pillars();
}

// Draws four overlapping tufts.
module TuftyHair() {
  difference() {
    color(WOOKIE_BROWN, 1) {
      Tufts();
      Pillars();
    }
    Led();
  }
}

SimpleHair();
