// Gmsh project created on Wed Nov  5 12:39:15 2025

cc = 0.02;

Point(1) = {0.6, 0, -0.9, cc};
Point(2) = {1.25, 0, -0.9, cc};
Point(3) = {1.25, 0, 0.8, cc};
Point(4) = {0.6, 0, 0.8, cc};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Curve Loop(1) = {1, 2, 3, 4};

Surface(1) = {1};

Extrude {{0, 0, 1}, {0, 0, 0}, Pi/2} {
  Surface{1}; Layers{6};
}

Extrude {{0, 0, 1}, {0, 0, 0}, Pi/2} {
  Surface{26}; Layers{6};
}

Extrude {{0, 0, 1}, {0, 0, 0}, Pi/2} {
  Surface{48}; Layers{6};
}

Extrude {{0, 0, 1}, {0, 0, 0}, Pi/2} {
  Surface{70}; Layers{6};
}

Physical Volume("plasma", 92) = {1, 2, 3, 4};
Physical Surface("edges", 93) = {87, 21, 43, 65, 83, 17, 39, 61, 79, 13, 35, 57, 69, 47, 91, 25};
