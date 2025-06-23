from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")

# NOTE: this is not a real magnetic field, since div(B) \neq 0
B_field = sin(C.x*C.y*C.z) * C.i - cos(C.x*C.y*C.z) * C.j + cos(C.x*C.y*C.z) * C.k
scalar_parallel = cos(C.x*C.y*C.z)

unit_vector = B_field / (B_field.magnitude())
vec_parallel = scalar_parallel * unit_vector

div_u = divergence(vec_parallel)


print("Magnetic Field is: "+exprToStr(B_field)+" \n")
print("Parallel Velocity Scalar Value is: "+exprToStr(scalar_parallel)+" \n")
print("Parallel Velocity Vector Value is: "+exprToStr(vec_parallel)+" \n")
print("Div of Parallel Velocity is: "+exprToStr(div_u)+" \n")
