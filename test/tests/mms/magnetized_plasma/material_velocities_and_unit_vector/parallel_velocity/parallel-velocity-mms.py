# Python script to generate the manufactured solutions for testing MagneticParallelVelocity

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
scalar_vel = 2.0 * C.x + 3.0 * C.y + 4.0 * C.z


B_mag = B_field.magnitude()
unit_vector = B_field / (B_field.magnitude())

vector_vel = unit_vector * scalar_vel
div_vel = divergence(vector_vel)

print("Magnetic Field is: "+exprToStr(simplify(B_field))+" \n")
print("Scalar Parallel Velocity is: "+exprToStr(simplify(scalar_vel))+" \n")
print("Vector Parallel Velocity is is: "+exprToStr(simplify(vector_vel))+" \n")
print("Div of Vector Parallel Velocity is: "+exprToStr(simplify(div_vel))+" \n")
