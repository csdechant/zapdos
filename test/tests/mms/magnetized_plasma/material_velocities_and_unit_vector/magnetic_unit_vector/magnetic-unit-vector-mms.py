# Python script to generate the manufactured solutions for testing MagneticUnitVector

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

B_mag = B_field.magnitude()
grad_B_mag = gradient(B_field.magnitude())

unit_vector = B_field / (B_field.magnitude())
div_u = divergence(unit_vector)
curl_u = curl(unit_vector)

print("Magnetic Field is: "+exprToStr(simplify(B_field))+" \n")
print("Mag. of Magnetic Field is: "+exprToStr(simplify(B_mag))+" \n")
print("Grad of Mag. of Magnetic Field is: "+exprToStr(simplify(grad_B_mag))+" \n")
print("Unit Vector is: "+exprToStr(simplify(unit_vector))+" \n")
print("Div of Unit Vector is: "+exprToStr(simplify(div_u))+" \n")
print("Curl of Unit Vector is: "+exprToStr(simplify(curl_u))+" \n")
