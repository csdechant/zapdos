from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

def exprToStr(expr):
    """ Convert a sympy expression to a string for MOOSE input
    """
    return str(expr).replace("**", "^").replace("C.x", "x").replace("C.z", "y")

# known density
n = (0.9 + 0.9*C.x + 0.2*cos(10*t)*sin(5*C.x*C.x - 2*C.z))

# known potential
pot = (sin(pi*C.x)*(0.5*C.x - cos(7*t)*sin(3*C.x*C.x - 3*C.z)))

# Magnetic field magnitude and unit vector
B = 1.0
b = 1*C.j

# Coefficients
alpha = 1.0
kappa = 0.5
D_n = 1.0

# bracket operation:
# [f,pot] = 1/|B| \vec{b} \times \nabla pot \cdot \nabla f
# where b is the unit vector of the magnetic field (usually b is just [0,1,0])

# This is wrong? Maybe due to sympys order of operations?
# bracket_n_pot  = (1/B * b.cross(gradient(pot))).dot(gradient(n))

cross_b = b.cross(gradient(pot))
bracket_n_pot = -1/B * cross_b.dot(gradient(n))

dn_dt = diff(n, t)

sol = dn_dt - bracket_n_pot

print(exprToStr(sol))
