from sympy import *
from sympy.vector import *

C = CoordSys3D('C')
t = symbols("t")

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

LHS_1 = bracket_n_pot

LHS_2 = alpha * (pot - n)

LHS_3 = -kappa * diff(pot,C.z)

# \nabla_\parallel:
# \nabla_\parallel f = \vec{b} \cdot \nabla f

# \nabla_\prep:
# \nabla_\prep f = nabla f -  b ( \nabla_\parallel f )

nabla_parallel_n = b.dot(gradient(n))
nabla_prep_n = gradient(n) - b * nabla_parallel_n

LHS_4 = divergence(D_n * nabla_prep_n)

LHS = LHS_1 + LHS_2 + LHS_3 + LHS_4
RHS = diff(n,t)
