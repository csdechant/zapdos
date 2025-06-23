# Python script to generate the manufactured solutions for testing EcrossBDriftVelocity

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
E_field = cos(C.x*C.y*C.z) * C.i + sin(C.x*C.y*C.z) * C.j + sin(C.x*C.y*C.z) * C.k


B_mag = B_field.magnitude()

EcrossB_vel = E_field.cross(B_field) / (B_mag * B_mag)
div_vel = divergence(EcrossB_vel)

print("Magnetic Field is: "+exprToStr(simplify(B_field))+" \n")
print("Electric Field is: "+exprToStr(simplify(E_field))+" \n")
print("E X B Velocity is: "+exprToStr(simplify(EcrossB_vel))+" \n")
print("Div of E X B Velocity is: "+exprToStr(simplify(div_vel))+" \n")
