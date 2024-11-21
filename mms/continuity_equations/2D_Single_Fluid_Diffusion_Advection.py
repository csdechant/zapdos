#!/usr/bin/env python3

import mms

#Know solutions
ne = '(sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A'
V = '-(ee*(2*x_max*x_max*cos((pi*x)/(2*x_max)) + y_max*y_max*cos((pi*y)/y_max)*sin(2*pi*f*t)))/(5*diffpotential*pi*pi)'

#Solving source terms
#Basic Diffusion-Advection Problem
fu,su = mms.evaluate('diff(ne,t) + div(-diffem_coeff * grad(ne) + muem_coeff*ne*grad(V))',
                     ne, variable='ne',
                     V=V,
                     scalars=['N_A','ee','diffem_coeff','muem_coeff','diffpotential','x_max','y_max','f'])

mms.print_hit(fu, 'em_source')
