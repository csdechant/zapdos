from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")

# B_field = 2 * C.x * C.i + 3 * C.y * C.j + 4 * C.z * C.k
B_field = 2 * C.i + 3 * C.j + 4 * C.k
v_parallel = 14 * C.x + 13 * C.y + 15 * C.z

v_vector = B_field * v_parallel / (B_field.magnitude())
div_v = divergence(v_vector)

div_v_other = (v_parallel * divergence(B_field) + gradient(v_parallel).dot(B_field)) / (B_field.magnitude())

print(exprToStr(v_vector)+" \n")

print(exprToStr(div_v)+" \n")

print(exprToStr(div_v_other)+" \n")