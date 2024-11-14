
// Bottom Axis Point
Point(1) = {0, 0, 0};

// End of Bottom Electrode
Point(2) = {3.2e-2, 0, 0};

// Bottom Right Point
Point(3) = {4e-2, 0, 0};

// Center Wall Point
Point(4) = {4e-2, 1.5e-2, 0};

// Top Right Point
Point(5) = {4e-2, 3e-2, 0};

// Vertical Symetric Point of Bottom Electron
Point(6) = {3.2e-2, 3e-2, 0};

// Top Axis Point
Point(7) = {0, 3e-2, 0};

// Center Axis Point
Point(8) = {0, 1.5e-2, 0};

// Center of Bottom Electron Symetry
Point(9) = {3.2e-2, 1.5e-2, 0};




// Bottom Lines
Line(1) = {1,2};
Line(2) = {2,3};

// Right Wall
Line(3) = {3,4};
Line(4) = {4,5};

// Top Lines
Line(5) = {5,6};
Line(6) = {6,7};


// Axis
Line(7) = {7,8};
Line(8) = {8,1};


// Vertical Lines
Line(9) = {2,9};
Line(10) = {6,9};

// Horizontial Lines
Line(11) = {9,8};
Line(12) = {9,4};

Transfinite Curve{1, -11, -6} = 32;
Transfinite Curve{-2, -12, 5} = 13 Using Progression 1.10;

Transfinite Curve{-8, 9, 3} = 20 Using Progression 1.10;
Transfinite Curve{7, 10, -4} = 20 Using Progression 1.10;


Line Loop(1) = {1,9,11,8};
Line Loop(2) = {2,3,-12,-9};
Line Loop(3) = {12,4,5,10};
Line Loop(4) = {-11,-10,6,7};

Plane Surface(100) = {1};
Plane Surface(200) = {2};
Plane Surface(300) = {3};
Plane Surface(400) = {4};


Transfinite Surface{100,200,300,400};
Recombine Surface{100,200,300,400};

Physical Line("axis") = {7,8};
Physical Line("Top_Electrode") = {3,4,5,6};
Physical Line("gap") = {2};
Physical Line("Bottom_Electrode") = {1};
Physical Surface("plasma") = {100,200,300,400};

