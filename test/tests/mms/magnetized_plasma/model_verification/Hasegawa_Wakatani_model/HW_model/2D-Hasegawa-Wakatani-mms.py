# Python script to generate the manufactured solutions for testing
# the Hasegawa-Wakatani model.
# NOTE: This formulation of the MMS solution is based on BOUT++'s MMS
#       found at https://github.com/boutproject/BOUT-dev and the paper
#       "Verification of BOUT++ by the method of manufactured solutions"

from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.z", "y").replace("C.y", "z")

density = 0.9 + 0.9 * C.x + 0.2 * cos(10 * t) * sin(5.0 * C.x*C.x - 2 * C.z)
vorticity = 0.9 + 0.7 * C.x + 0.2 * cos(7 * t) * sin(2.0 * C.x*C.x - 3 * C.z)
potential = sin(pi * C.x) * (0.5 * C.x - cos(7 * t) * sin(3.0 * C.x*C.x - 3 * C.z))

alpha = 1.0
k = 0.5
D_n = 1.0
D_omega = 1.0

B_field = 1.0 * C.j
B_mag = B_field.magnitude()
unit_vector = B_field / (B_field.magnitude())

E_cross_B = gradient(potential).cross(B_field) / (B_mag * B_mag)

nabla_parallel_n = unit_vector.dot(gradient(density))
nabla_prep_n = gradient(density) - unit_vector * nabla_parallel_n

nabla_parallel_omega = unit_vector.dot(gradient(vorticity))
nabla_prep_omega = gradient(vorticity) - unit_vector * nabla_parallel_omega

nabla_parallel_pot = unit_vector.dot(gradient(potential))
nabla_prep_pot = gradient(potential) - unit_vector * nabla_parallel_pot

density_source_term = diff(density,t) + E_cross_B.dot(gradient(density)) - alpha * (potential - density) + k * diff(potential,C.z) - D_n * divergence(nabla_prep_n)
vorticity_source_term = diff(vorticity,t) + E_cross_B.dot(gradient(vorticity)) - alpha * (potential - density) - D_omega * divergence(nabla_prep_omega)
potential_source_term = vorticity - divergence(nabla_prep_pot)


print("Density is: "+exprToStr(simplify(density))+" \n")
print("Density Source Term is: "+exprToStr(simplify(density_source_term))+" \n \n")

print("Vorticity is: "+exprToStr(simplify(vorticity))+" \n")
print("Vorticity Source Term is: "+exprToStr(simplify(vorticity_source_term))+" \n \n")

print("Potential is: "+exprToStr(simplify(potential))+" \n")
print("Potential Source Term is: "+exprToStr(simplify(potential_source_term))+" \n \n")
