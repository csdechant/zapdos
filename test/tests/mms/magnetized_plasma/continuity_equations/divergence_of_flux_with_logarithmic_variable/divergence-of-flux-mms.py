# Python script to generate the manufactured solutions for testing
# ScalarLogDivergenceMatVelocityProduct and MatVectorGradientScalarLogProduct

from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")

vector = cos(C.x*C.y*C.z) * C.i + sin(C.x*C.y*C.z) * C.j + sin(C.x*C.y*C.z) * C.k
scalar = sin(pi*C.x*C.y*C.z) + 2.0

div_vector = divergence(vector)
grad_scalar = gradient(scalar)

flux = vector * scalar
div_flux = divergence(flux)

term_one = scalar*div_vector

print("Vector is: "+exprToStr(simplify(vector))+" \n")
print("Scalar is: "+exprToStr(simplify(scalar))+" \n")
print("Div of Vector is: "+exprToStr(simplify(div_vector))+" \n")

print("First Term Source Term is: "+exprToStr(simplify(term_one))+" \n")
print("Second Term Source Term is: "+exprToStr(simplify(vector.dot(grad_scalar)))+" \n")

print("Total Source Term is: "+exprToStr(simplify(div_flux))+" \n")

