# Python script to generate the manufactured solutions for testing CoeffPerpendicularDiffusion

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
density = sin(pi*C.x*C.y*C.z) + 2.0

B_mag = B_field.magnitude()
unit_vector = B_field / (B_field.magnitude())

perp_diff = 2.0

nabla_parallel_n = unit_vector.dot(gradient(density))
nabla_prep_n = gradient(density) - unit_vector * nabla_parallel_n

source_term = -1.0 * divergence(perp_diff * nabla_prep_n)


print("Magnetic Field is: "+exprToStr(simplify(B_field))+" \n")
print("Density is: "+exprToStr(simplify(density))+" \n")
print("Source Term is: "+exprToStr(simplify(source_term))+" \n")

