from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")


B_field = 2 * C.i + 3 * C.j + 4 * C.k
E_field = 14 * C.i + 13 * C.j + 15 * C.k

cross_b = E_field.cross(B_field) / (B_field.magnitude() * B_field.magnitude())

print(cross_b)
