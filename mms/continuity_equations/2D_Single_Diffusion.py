#!/usr/bin/env python3

import mms

#Know solutions
ne = '(sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A'

#Solving source terms
#Basic Diffusion Problem
fu,su = mms.evaluate('diff(ne,t) + -div(diffem_coeff * grad(ne))',
                     ne, variable='ne',
                     scalars=['N_A','diffem_coeff','x_max','y_max','f'])

mms.print_hit(fu, 'em_source')
