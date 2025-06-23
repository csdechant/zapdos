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
grad_inv_B_mag = gradient(1.0/B_field.magnitude())

unit_vector = B_field / (B_field.magnitude())
div_u = divergence(unit_vector)
curl_u = curl(unit_vector)

print("Magnetic Field is: "+exprToStr(B_field)+" \n")
print("Mag. of Magnetic Field is: "+exprToStr(B_mag)+" \n")
print("Grad of Inv. Mag. of Magnetic Field is: "+exprToStr(grad_inv_B_mag)+" \n")
print("Magnetic Field is: "+exprToStr(B_field)+" \n")
print("Unit Vector is: "+exprToStr(unit_vector)+" \n")
print("Div of Unit Vector is: "+exprToStr(div_u)+" \n")
print("Curl of Unit Vector is: "+exprToStr(curl_u)+" \n")
