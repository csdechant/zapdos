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

def perp_grad(b,f):
    """ The bracket operator
    """

    return gradient(f) - b * parallel_grad(b,f)

### Time Versions ###
# density = 0.9 + 0.9*C.x + 0.5 * cos(t) * sin(5*C.x*C.x - C.z) + 0.01 * sin(C.y-C.z)
# potential = (sin(C.z - C.x + t) + 0.001 * cos(C.y-C.z)) * sin(2*3.14*C.x)
# elec_vel = cos(1.5 * t) * (2*sin((C.x-0.5)*(C.x-0.5) + C.z) + 0.05*cos(3*C.x*C.x + 2*C.y - 2*C.z))
# elec_temp = 1 + 0.5 * cos(t) * cos(3*C.x*C.x - 2*C.z) + 0.005 * sin(C.y - C.z) * sin(t)
# ion_vel = -0.01 * cos(7*t) * cos(3*C.x*C.x + 2*C.y - 2*C.z)
# vorticity = 2 * sin(2*t) * cos(x - z + 4*y)

# NOTE: this is not a real magnetic field, since div(B) \neq 0
B_field = sin(C.x*C.y*C.z) * C.i - cos(C.x*C.y*C.z) * C.j + cos(C.x*C.y*C.z) * C.k
potential = (sin(C.z - C.x) + 0.001 * cos(C.y-C.z)) * sin(2*3.14*C.x)
density = 0.9 + 0.9*C.x + 0.01 * sin(C.y-C.z)
elec_vel = (2*sin((C.x-0.5)*(C.x-0.5) + C.z) + 0.05*cos(3*C.x*C.x + 2*C.y - 2*C.z))
# ion_vel = -0.01 * cos(3*C.x*C.x + 2*C.y - 2*C.z)
ion_vel = 2*sin((C.x-0.5)*(C.x-0.5) + C.z)
elec_temp = 1 + 0.5 * cos(3*C.x*C.x - 2*C.z)

B_mag = B_field.magnitude()
b = B_field / (B_field.magnitude())

vorticity = 2 * cos(C.x - C.z + 4*C.y)

# Density_Source = 1/B_mag * bracket(b,potential,density) - 2 * density/B_mag * (curvature(B_mag,b,elec_temp) + elec_temp/density * curvature(B_mag,b,density) - curvature(B_mag,b,potential)) + density * parallel_grad(b,elec_vel) + elec_vel * parallel_grad(b,density)
# elec_vel_Source = 1/B_mag * bracket(b,potential,elec_vel) + elec_vel * parallel_grad(b,elec_vel) + (elec_vel - ion_vel) - parallel_grad(b,potential) + elec_temp/density * parallel_grad(b,density) + 1.71 * parallel_grad(b,elec_temp)
# ion_vel_Source = 1/B_mag * bracket(b,potential,ion_vel) + ion_vel * parallel_grad(b,ion_vel) + parallel_grad(b,elec_temp) + elec_temp/density * parallel_grad(b,density)
# elec_temp_Source = 1/B_mag * bracket(b,potential,elec_temp) + elec_vel * parallel_grad(b,elec_temp) - 4/3 * elec_temp/B_mag * (7/2 * curvature(B_mag,b,elec_temp) + elec_temp/density * curvature(B_mag,b,density) - curvature(B_mag,b,potential)) - 2/3 * elec_temp * (0.71 * parallel_grad(b,ion_vel) - 1.71 * parallel_grad(b,elec_vel) + 0.71/density * (ion_vel - elec_vel) * parallel_grad(b,density))
# vorticity_Source = 1/B_mag * bracket(b,potential,vorticity) + ion_vel * parallel_grad(b,vorticity) - B_mag*B_mag * (parallel_grad(b,ion_vel) - parallel_grad(b,elec_vel) +  (ion_vel - elec_vel)/density *  parallel_grad(b,density)) - 2*B_mag * ( curvature(B_mag,b,elec_temp) + elec_temp/density * curvature(B_mag,b,density) ) - divergence(perp_grad(b,vorticity))

vorticity_Source = 1/B_mag * bracket(b,potential,vorticity) + ion_vel * parallel_grad(b,vorticity) - divergence(perp_grad(b,vorticity)) - 2*B_mag * ( curvature(B_mag,b,elec_temp) + elec_temp/density * curvature(B_mag,b,density) ) - B_mag*B_mag * (parallel_grad(b,ion_vel) - parallel_grad(b,elec_vel) +  (ion_vel - elec_vel)/density *  parallel_grad(b,density))

print("B-field is: "+exprToStr(simplify(B_field))+" \n")
print("density is: "+exprToStr(simplify(density))+" \n")
print("potential is: "+exprToStr(simplify(potential))+" \n")
print("electron vel. is: "+exprToStr(simplify(elec_vel))+" \n")
print("ion vel. is: "+exprToStr(simplify(ion_vel))+" \n")
print("electron temp. is: "+exprToStr(simplify(elec_temp))+" \n")
print("vorticity is: "+exprToStr(simplify(vorticity))+" \n")

print("Forcing Term is: "+exprToStr(simplify(vorticity_Source))+" \n")
