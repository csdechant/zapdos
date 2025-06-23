# Python script to generate the manufactured solutions for testing DirectionalPotentialGradient

from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")

potential = C.x * C.x + 1.5 * C.y * C.y
grad_potential_y = diff(potential,C.y)
density = sin(pi*C.x*C.y) + 2.0
grad_density = gradient(density)

k = 2.0

source_term = -divergence(grad_density) + k * grad_potential_y


print("Potential is: "+exprToStr(simplify(potential))+" \n")
print("Density is: "+exprToStr(simplify(density))+" \n")
print("Source Term is: "+exprToStr(simplify(source_term))+" \n")

