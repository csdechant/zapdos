from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")


B_field = sin(C.x*C.y) * C.i - cos(C.x*C.y) * C.j + 2 * C.k
E_field = -sin(C.x*C.y) * C.i + cos(C.x*C.y) * C.j + 4 * C.k

# Method 1:
cross_b = E_field.cross(B_field)
div_cross_b_M1 = divergence(cross_b) / (B_field.magnitude() * B_field.magnitude())

# Method 2:
curl_B = curl(B_field)
curl_E = curl(E_field)

div_cross_b_M2 = (B_field.dot(curl_E) - E_field.dot(curl_B)) / (B_field.magnitude() * B_field.magnitude())

print("B_field is "+exprToStr(B_field)+" \n")

print("E_field is "+exprToStr(E_field)+" \n")

print(exprToStr(div_cross_b_M1)+" \n")

print(exprToStr(div_cross_b_M2)+" \n")
