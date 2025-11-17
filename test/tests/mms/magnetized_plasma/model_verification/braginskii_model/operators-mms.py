# Python script to generate the manufactured solutions for testing EcrossBDriftVelocity

from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")


def bracket(b,f,g):
    """ The bracket operator
    """

    grad_f = gradient(f)
    grad_g = gradient(g)

    return b.dot(grad_f.cross(grad_g))

def curvature(B_mag,b,f):
    """ The bracket operator
    """

    curl_b_div_B = curl(b/B_mag)
    grad_f = gradient(f)

    return B_mag/2 * curl_b_div_B.dot(grad_f)

def parallel_grad(b,f):
    """ The bracket operator
    """

    grad_f = gradient(f)

    return b.dot(grad_f)

### Time Versions ###
# density = 0.9 + 0.9*C.x + 0.5 * cos(t) * sin(5*C.x*C.x - C.z) + 0.01 * sin(C.y-C.z)
# potential = (sin(C.z - C.x + t) + 0.001 * cos(C.y-C.z)) * sin(2*3.14*C.x)
# elec_vel = cos(1.5 * t) * (2*sin((C.x-0.5)*(C.x-0.5) + C.z) + 0.05*cos(3*C.x*C.x + 2*C.y - 2*C.z))

# NOTE: this is not a real magnetic field, since div(B) \neq 0
B_field = sin(C.x*C.y*C.z) * C.i - cos(C.x*C.y*C.z) * C.j + cos(C.x*C.y*C.z) * C.k
potential = (sin(C.z - C.x) + 0.001 * cos(C.y-C.z)) * sin(2*3.14*C.x)
density = 0.9 + 0.9*C.x + 0.01 * sin(C.y-C.z)
elec_vel = (2*sin((C.x-0.5)*(C.x-0.5) + C.z) + 0.05*cos(3*C.x*C.x + 2*C.y - 2*C.z))

B_mag = B_field.magnitude()
b = B_field / (B_field.magnitude())

# Density_Source = parallel_grad(b,density) + bracket(b,potential,density) + curvature(B_mag,b,density)
Density_Source = parallel_grad(b,density) + curvature(B_mag,b,density)

print("density is: "+exprToStr(simplify(density))+" \n")
print("potential is: "+exprToStr(simplify(potential))+" \n")
print("electron vel. is: "+exprToStr(simplify(elec_vel))+" \n")

print("Forcing Term is: "+exprToStr(simplify(Density_Source))+" \n")
