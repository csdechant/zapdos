from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.y", "y").replace("C.z", "z")


n = (0.9 + 0.9*C.x + 0.2*cos(10*t)*sin(5*C.x*C.x - 2*C.z))
# B_field = 2 * C.x * C.i + 3 * C.y * C.j + 4 * C.z * C.k # For Lagrange Variables
B_field = 2 * C.i + 3 * C.j + 4 * C.k # For Nedelec Variables
v_parallel = 14 * C.x + 13 * C.y + 15 * C.z

v_vector = B_field * v_parallel
div_v = divergence(v_vector)
div_v = div_v / (B_field.magnitude())

n_dot_div_v = n * div_v
dn_dt = diff(n, t)

sol = dn_dt - n_dot_div_v

print("B_field is "+exprToStr(B_field)+" \n")

print("n is "+exprToStr(n)+" \n")

print("v_parallel is "+exprToStr(v_parallel)+" \n")

print("Body Force is "+exprToStr(sol)+" \n")

print("div_v is "+exprToStr(div_v)+" \n")
