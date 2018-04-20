dom0Mult = 1e3;

lc = 0.1 * 1e-3 * dom0Mult;
dc = 0.5; // Stands for don't care

//Center of top Plane (top left of domain)
Point(1) = {0, 2e-3 * dom0Mult, 0, lc};

// Top right of domain
Point(2) = {2e-3 * dom0Mult, 2e-3 * dom0Mult, 0, lc};

//Right side midpoint
Point(3) = {2e-3 * dom0Mult, 1e-3 * dom0Mult, 0, lc};

// Outer bound of ground plane (bottom right of domain)
Point(4) = {2e-3 * dom0Mult, 0, 0, lc};

// Center of ground plane (bottom left of domain)
Point(5) = {0, 0, 0, lc};

//Left side midpoint
Point(6) = {0, 1e-3 * dom0Mult, 0, dc};


// Axis of symmetry
Line(1) = {1, 6};
Line(2) = {6, 5};

// Cathode
Line(3) = {2, 1};

// Anode
Line(4) = {5, 4};

// Wall (right side)
Line(5) = {2, 3};
Line(6) = {3, 4};

Line Loop(7) = {1, 2, 4, -6, -5, 3};
Plane Surface(8) = {7};

// Plasma domain
Physical Surface("plasma") = {8};

// Physical Cathode
Physical Line("Top_plate") = {3};

// Physical Anode
Physical Line("dish") = {4};

// Physical Walls
Physical Line("walls") = {5, 6};

// Physical axis of symmetry
Physical Line("axis") = {1, 2};
