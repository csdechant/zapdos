dom0Mult = 1e3;

lc = .1 * 1e-3 * dom0Mult;
dc = 1; // Stands for don't care

// Needle tip
Point(5) = {0, 1e-3 * dom0Mult, 0, 2e-5};

// Center of radius of curvature
Point(6) = {0, dom0Mult * (1e-3 + 30e-6), 0, 2e-5};

// Point of needle at small radius
Point(7) = {30e-6 * dom0Mult, dom0Mult * (1e-3 + 30e-6), 0, 2e-5};

// Point of needle at large radius (pesudo-bottom left of domain)
Point(8) = {dom0Mult * 180e-6, dom0Mult * 1.5e-3, 0, 2e-5};

// Needle tip edge
Circle(1) = {5, 6, 7};

// Long needle edge
Line(2) = {7, 8};

// Top right of domain
Point(9) = {1e-3 * dom0Mult, 1.5e-3 * dom0Mult, 0, lc};

// Center of ground plane (bottom left of domain)
Point(10) = {0, 0, 0, lc};

// Outer bound of ground plane (bottom right of domain)
Point(11) = {1e-3 * dom0Mult, 0, 0, lc};

// Axis of symmetry
Line(3) = {5, 10};

// Anode
Line(4) = {10, 11};

// Wall 1
Line(5) = {11, 9};

// Wall 2
Line(6) = {9, 8};
Line Loop(7) = {5, 6, -2, -1, 3, 4};
Plane Surface(8) = {7};

// Plasma domain
Physical Surface("plasma") = {8};

// Physical Cathode
Physical Line("needle") = {2, 1};

// Physical Anode
Physical Line("plate") = {4};

// Physical Walls
Physical Line("walls") = {5, 6};

// Physical axis of symmetry
Physical Line("axis") = {3};