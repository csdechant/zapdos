# Script to generate source term for microwave_heating.i

import mms
from sympy import *

ne = '(sin(pi*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 1.0 + cos(pi/2*x))'

E = '(diffion - diffem)/(muion - muem) * (grad('+ne+'))/('+ne+')'

flux_ne = '( -muem*'+ne+'*'+E+' - diffem*grad('+ne+') )'

f, e = mms.evaluate(E, ne, variable='ne', scalars=['diffem','muem','diffion','muion'])
fd, ed = mms.evaluate('diff('+ne+',t) + div('+flux_ne+')', ne, variable='ne', scalars=['diffem','muem','diffion','muion'])

mms.print_hit(ed, 'exact_ne')
mms.print_hit(fd, 'force_ne')

mms.print_hit(f, 'force_E')
