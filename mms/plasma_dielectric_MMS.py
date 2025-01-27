# Script to generate source term for microwave_heating.i

import mms
from sympy import *


elec = '(sin(pi*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 1.0 + cos(pi/2*x))'

diele_term_r = '(ee*ee / (epsilon_0 * m_e)) * (1 / (omega*omega + nu*nu))'

diele_term_i = '-1.0 * (ee*ee / (epsilon_0 * m_e)) * (nu / (omega*omega*omega + nu*nu*omega))'

dielectric_r = '1 - '+diele_term_r+'*'+elec

dielectric_i = diele_term_i+'*'+elec


f_r, e_r = mms.evaluate('grad('+dielectric_r+')',dielectric_r, variable='u', scalars=['ee','epsilon_0','m_e','omega','nu'])

mms.print_hit(e_r, 'exact_real')
mms.print_hit(f_r, 'force_real_grad')

f_i, e_i = mms.evaluate('grad('+dielectric_i+')',dielectric_i, variable='u', scalars=['ee','epsilon_0','m_e','omega','nu'])

mms.print_hit(e_i, 'exact_image')
mms.print_hit(f_i, 'force_image_grad')

#################################

f_r, e_r = mms.evaluate('diff('+dielectric_r+',t)',dielectric_r, variable='u', scalars=['ee','epsilon_0','m_e','omega','nu'])

# mms.print_hit(e_r, 'exact_real')
mms.print_hit(f_r, 'force_real_dt')

f_i, e_i = mms.evaluate('diff('+dielectric_i+',t)',dielectric_i, variable='u', scalars=['ee','epsilon_0','m_e','omega','nu'])

# mms.print_hit(e_i, 'exact_image')
mms.print_hit(f_i, 'force_image_dt')

#################################

f_r, e_r = mms.evaluate('diff(diff('+dielectric_r+',t),t)',dielectric_r, variable='u', scalars=['ee','epsilon_0','m_e','omega','nu'])

# mms.print_hit(e_r, 'exact_real')
mms.print_hit(f_r, 'force_real_dt2')

f_i, e_i = mms.evaluate('diff(diff('+dielectric_i+',t),t)',dielectric_i, variable='u', scalars=['ee','epsilon_0','m_e','omega','nu'])

# mms.print_hit(e_i, 'exact_image')
mms.print_hit(f_i, 'force_image_dt2')
