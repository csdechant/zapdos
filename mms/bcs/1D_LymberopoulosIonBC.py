#!/usr/bin/env python3

import mms

#Know solutions
ni = '(1.0 + x*x*(1 - x)*(1 - x)) / N_A'
V = '-(ee*sin((pi*x))*sin(2*pi*f*t))/(5*diffpotential*pi*pi)'

#Solving source terms
#Ion Diffusion-Advection Problem
fion,sion = mms.evaluate('diff(ni,t) + div(-diffion * grad(ni) + muion*ni*-grad(V))',
                     ni, variable='ni',
                     V=V,
                     scalars=['N_A','ee','diffion','muion','diffpotential','x_max','y_max','f'])


fV,sV = mms.evaluate('diff(V,t) + div(-diffpotential * grad(V))',
                     V, variable='V',
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


mms.print_hit(fion, 'ion_source')
mms.print_hit(fV, 'potential_source')
