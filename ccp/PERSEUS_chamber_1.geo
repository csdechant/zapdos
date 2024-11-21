// Gmsh project created on Mon Aug 08 14:34:21 2022

//Unit Scaling (numbers in cm -> m)
sc = 1e-2;
//Element Scaling
lc = 5e-2;

//Center of the Top center electrode
Point(1) = {0, 1.27*sc, 0, lc*sc};

//edge of the Top ring electrode
Point(4) = {9.88*sc, 1.27*sc, 0, lc*sc};

//edge of the Top outer insulator
Point(5) = {19*sc, 1.27*sc, 0, 3*lc*sc};

//bottom right of the ground wall
Point(6) = {19*sc, -9.27*sc, 0, 10*lc*sc};

//bottom left of the ground wall
Point(7) = {13.1*sc, -9.27*sc, 0, 10*lc*sc};

//edge of the Bottom outer insulator
Point(8) = {13.1*sc, -1.27*sc, 0, lc*sc};

//edge of the Bottom ring electrode
Point(9) = {9.88*sc, -1.27*sc, 0, lc*sc};

//edge of the Bottom inner insulator
Point(10) = {8.88*sc, -1.27*sc, 0, lc*sc};

//edge of the Bottom center electrode
Point(11) = {7.62*sc, -1.27*sc, 0, lc*sc};

//edge of the Bottom center electrode
Point(12) = {0, -1.27*sc, 0, lc*sc};

//Center of the Top inner insulator
Point(13) = {0, 3.27*sc, 0, 10*lc*sc};

//inner edge of the Top outer insulator
Point(20) = {9.88*sc, 3.27*sc, 0, 10*lc*sc};

//outer edge of the Top outer insulator
Point(21) = {19*sc, 3.27*sc, 0, 10*lc*sc};

//outer top edge of the ground wall
Point(22) = {21.5*sc, 3.27*sc, 0, 10*lc*sc};

//outer top edge of the ground wall
Point(23) = {21.5*sc, -13*sc, 0, 10*lc*sc};

//inner bottom edge of the ground wall
Point(24) = {13.1*sc, -13*sc, 0, 10*lc*sc};

//Center of the bottom inner insulator
Point(25) = {0, -2.77*sc, 0, 10*lc*sc};

//inner edge of the bottom inner insulator
Point(26) = {7.62*sc, -2.77*sc, 0, 10*lc*sc};

//Center of the bottom ring electrode
Point(27) = {0, -4.82*sc, 0, 10*lc*sc};

//inner edge of the bottom ring electrode
Point(28) = {8.88*sc, -4.82*sc, 0, 10*lc*sc};

//outer Center of the bottom ring electrode
Point(29) = {0, -5.32*sc, 0, 10*lc*sc};

//outer bottom edge of the bottom ring electrode
Point(30) = {11.6*sc, -5.32*sc, 0, 10*lc*sc};

//outer top edge of the bottom ring electrode
Point(31) = {11.6*sc, -3.27*sc, 0, 10*lc*sc};

//inner edge of the bottom outer insulator
Point(32) = {9.88*sc, -3.27*sc, 0, 10*lc*sc};

//inner bottom edge of the bottom outer insulator
Point(33) = {11.6*sc, -13*sc, 0, 10*lc*sc};

//top center electrode
Line(1) = {1, 4};
Line(3) = {13, 20};

//boundary of top ring electrode and top outer insulator
Line(23) = {20, 4};

//top outer insulator
Line(4) = {4, 5};
Line(24) = {20, 21};

//boundary of top outer insulator and wall
Line(25) = {21, 5};

//Ground Wall
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(26) = {21, 22};
Line(27) = {22, 23};
Line(28) = {23, 24};

//boundary of wall and bottom outer insulator
Line(29) = {24, 7};

//Bottom outer insulator
Line(7) = {7, 8};
Line(8) = {8, 9};

//boundary of bottom ring electrode and bottom outer insulator
Line(38) = {30, 31};
Line(39) = {31, 32};
Line(40) = {32, 9};

//Bottom ring electrode
Line(9) = {9, 10};
Line(37) = {29, 30};

//boundary of bottom ring electrode and bottom inner insulator
Line(34) = {27, 28};
Line(35) = {28, 10};

//Bottom inner insulator
Line(10) = {10, 11};
Line(41) = {30, 33};
Line(42) = {33, 24};

//boundary of bottom center electrode and bottom inner insulator
Line(31) = {25, 26};
Line(32) = {26, 11};

//Bottom center electrode
Line(11) = {11, 12};

// Axis of symmetry
Line(2) = {1, 13};
Line(12) = {12, 1};
Line(30) = {12, 25};
Line(33) = {25, 27};
Line(36) = {27, 29};

// Physical axis of symmetry
Physical Line("axis") = {2,12,30,33,36};

//Plasma
Curve Loop(1) = {1, 4, 5, 6, 7, 8, 9, 10, 11, 12};
Plane Surface(1) = {1};
// Plasma domain
Physical Surface("plasma") = {1};

//both center electrodes
Curve Loop(2) = {1, -23, -3, -2};
Plane Surface(2) = {2};
Curve Loop(6) = {11, 30, 31, 32};
Plane Surface(6) = {6};
// center electrodes domain
Physical Surface("Top_Center_Electrode") = {2};
Physical Surface("Bottom_Center_Electrode") = {6};

// inner insulators
Curve Loop(7) = {10, -32, -31, 33, 34, 35};
Plane Surface(7) = {7};
// inner insulators domain
Physical Surface("Bottom_Inner_Insulator") = {7};

// ring electrodes
Curve Loop(8) = {9, -35, -34, 36, 37, 38, 39, 40};
Plane Surface(8) = {8};
// ring electrodes domain
Physical Surface("Bottom_Ring_Electrode") = {8};

//both outer insulators
Curve Loop(5) = {23, 4, -25, -24};
Plane Surface(5) = {5};
Curve Loop(9) = {8, -40, -39, -38, 41, 42, 29, 7};
Plane Surface(9) = {9};
// outer insulators domain
Physical Surface("Top_Outer_Insulator") = {5};
Physical Surface("Bottom_Outer_Insulator") = {9};

//wall
Curve Loop(10) = {26, 27, 28, 29, -6, -5, -25};
Plane Surface(10) = {10};
// ground wall domain
Physical Surface("Walls") = {10};
