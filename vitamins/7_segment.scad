//
// NopSCADlib Copyright Chris Palmer 2021
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// This file is part of NopSCADlib.
//
// NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with NopSCADlib.
// If not, see <https://www.gnu.org/licenses/>.
//

//
//! 7 Segment displays
//
include <../utils/core/core.scad>


function 7_segment_size(type)       = type[1]; //! Size of the body
function 7_segment_digit_size(type) = type[2]; //! Size of the actual digit and segemnt width and angle
function 7_segment_pins(type)       = type[3]; //! [x, y] array of pins
function 7_segment_pin_pitch(type)  = type[4]; //! x and y pin pitches and pin diameter

module 7_segment_digit(type, colour = grey(95), pin_length = 6.4) { //! Draw the specified 7 segment digit
    size = 7_segment_size(type);
    digit = 7_segment_digit_size(type);
    pins = 7_segment_pins(type);
    pin_pitch = 7_segment_pin_pitch(type);

    color(grey(95))
        linear_extrude(size.z)
            square([size.x - 0.1, size.y], center = true);

    color(grey(15))
        translate_z(size.z)
            cube([size.x - 0.1, size.y, eps], center = true);

    color(colour)
         translate_z(size.z)
            linear_extrude(2 * eps) {
                t = digit[2];
                a = digit[3];
                sq = [digit.x - 2 * t, (digit.y - 3 * t) / 2];

                multmatrix([                    // Skew
                    [1, tan(a), 0, 0],
                    [0, 1, 0, 0],
                    [0, 0, 1, 0],
                    [0, 0, 0, 1]
                ])
                difference() {
                    square([digit.x, digit.y], center = true);

                    for(y = [-1, 1], x = [-1, 1]) {
                        translate([0, y * (t + sq.y) / 2])
                            square(sq, center = true);


                        translate([x * digit.x / 2, y * digit.y / 2])
                            rotate(-45 * x * y) {
                                square([10, t], center = true);

                                square([t / 5, 10], center = true);
                            }

                        translate([x * (digit.x - t) / 2, 0])
                            rotate(45) {
                                square([t / 5, t * 2], center = true);

                                square([t * 2, t / 5], center = true);

                                translate([x * t / 2, -x * t / 2])
                                    square([t, t], center = true);
                            }
                    }
                }
                r = 1.25 * t / 2;
                translate([digit.x / 2 - r + digit.y / 2 * tan(a), -digit.y / 2 + r])
                    circle(r);
            }

    color(silver)
        translate_z(-pin_length)
            linear_extrude(pin_length)
                for(x = [0 : 1 : pins.x - 1], y = [0 : 1 : pins.y - 1])
                    translate([(x - (pins.x - 1) / 2) * pin_pitch.x, (y - (pins.y - 1) / 2) * pin_pitch.y])
                        circle(d = pin_pitch[2], $fn = 16);
}

module 7_segment_digits(type, n, colour = grey(70), pin_length = 6.4, cutout = false) { //! Draw n digits side by side
    size = 7_segment_size(type);

    if(cutout)
        linear_extrude(100)
            square([n * size.x, size.y], center = true);
    else
        for(i = [0 : 1 : n - 1])
            translate([(i - (n - 1) / 2) * size.x, 0])
                7_segment_digit(type, colour, pin_length);
}
