# Python script to generate the manufactured solutions for testing DiamagneticDriftVelocity

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

pressure = C.x * C.x + 1.5 * C.y * C.y + 2.0 * C.z * C.z
density = sin(pi*C.x*C.y*C.z) + 2.0
charge = 3.0
Z = 0.5


B_mag = B_field.magnitude()
grad_p = gradient(pressure)

dia_vel = B_field.cross(grad_p) / (charge * Z * density * B_mag * B_mag)
div_dia_vel = divergence(dia_vel)


print("Magnetic Field is: "+exprToStr(simplify(B_field))+" \n")
print("Pressure is: "+exprToStr(simplify(pressure))+" \n")
print("Density is: "+exprToStr(simplify(density))+" \n")

print("Diamagnetic Velocity is is: "+exprToStr(simplify(dia_vel))+" \n")
print("Div of Diamagnetic Velocity is: "+exprToStr(simplify(div_dia_vel))+" \n")
