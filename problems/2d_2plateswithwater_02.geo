dom0Mult = 1e3;
dom1Mult = 1e7;

lc = 0.25 * 1e-3 * dom0Mult;
wc = 0.5 * 1e-7 * dom1Mult;
dc = 0.5; // Stands for don't care

//Center of top Plane (top left of domain)
Point(1) = {0, 2e-3 * dom0Mult + 1e-7 * dom1Mult, 0, lc};

// Top right of domain
Point(2) = {2e-3 * dom0Mult, 2e-3 * dom0Mult + 1e-7 * dom1Mult, 0, lc};

//Right side midpoint Plasma
Point(3) = {2e-3 * dom0Mult, 1e-3 * dom0Mult + 1e-7 * dom1Mult, 0, lc};

// Bottom right of Plasma
Point(4) = {2e-3 * dom0Mult, 1e-7 * dom1Mult, 0, dc};

//Right side midpoint Water
Point(5) = {2e-3 * dom0Mult, 0.5e-7 * dom1Mult, 0, wc};

// Outer bound of ground plane (bottom right of domain)
Point(6) = {2e-3 * dom0Mult, 0, 0, wc};

// Center of ground plane (bottom left of domain)
Point(7) = {0, 0, 0, wc};

//Left side midpoint Water
Point(8) = {0, 0.5e-7 * dom1Mult, 0, dc};

// Bottom left of Plasma
Point(9) = {0, 1e-7 * dom1Mult, 0, lc};

//Left side midpoint Plasma
Point(10) = {0, 1e-3 * dom0Mult + 1e-7 * dom1Mult, 0, dc};

// Axis of symmetry Plasma
Line(5) = {9, 10};
Line(6) = {10, 1};

Line(7) = {9, 8};
Line(8) = {8, 7};

// Cathode
Line(1) = {1, 2};

// Anode
Line(9) = {7, 6};

// Wall (right side)
Line(2) = {2, 3};
Line(3) = {3, 4};

Line(11) = {5, 4};
Line(10) = {6, 5};

//Plasma Liquid Boundary
Line(4) = {4, 9};

//Plasma
Line Loop(20) = {1, 2, 3, 4, 5, 6};
Plane Surface(30) = {20};

//Water
Line Loop(21) = {4, 7, 8, 9, 10, 11};
Plane Surface(31) = {21};

// Plasma domain
Physical Surface("plasma") = {30};

// Water domain
Physical Surface("water") = {31};

// Physical Cathode
Physical Line("Top_plate") = {1};

// Physical Anode
Physical Line("dish") = {9};

// Physical Walls
Physical Line("walls_plasma") = {2, 3};
Physical Line("walls_water") = {10, 11};

// Physical axis of symmetry
Physical Line("axis") = {-8, -7, 5, 6};
