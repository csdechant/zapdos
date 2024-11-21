#!/usr/bin/env python3

import mms

#Know solutions
ne = '((sin(2*pi*f*t) + 2) * ((x)*(1 - x) + 1)) / N_A'
ni = '((sin(2*pi*f*t) + 2) * ((x)*(1 - x) + 1)) / N_A'
V = '-sin(2*pi*f*t)*(x)*(x) + (x)*(x)'

#Solving source terms
#Electron Diffusion-Advection Problem
fem,sem = mms.evaluate('diff(ne,t) + div(-diffem * grad(ne) - muem*ne*-grad(V))',
                     ne, variable='ne',
                     V=V,
                     scalars=['N_A','ee','diffem','muem','diffpotential','x_max','y_max','f'])

#Ion Diffusion-Advection Problem
fion,sion = mms.evaluate('diff(ni,t) + div(-diffion * grad(ni) + muion*ni*-grad(V))',
                     ni, variable='ni',
                     V=V,
                     scalars=['N_A','ee','diffion','muion','diffpotential','x_max','y_max','f'])


fV,sV = mms.evaluate('div(-diffpotential * grad(V))',
                     V, variable='V',
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


mms.print_hit(fem, 'em_source')
mms.print_hit(fion, 'ion_source')
mms.print_hit(fV, 'potential_source')
