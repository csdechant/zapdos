#!/usr/bin/env python3

import mms

#Know solutions
ne = '(sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A'
ni = '(sin(pi*(y/y_max)) + 1.0 + 0.9*cos(pi/2*(x/x_max))) / N_A'
V = '-(ee*(2*x_max*x_max*cos((pi*x)/(2*x_max)) + y_max*y_max*cos((pi*y)/y_max)*sin(2*pi*f*t)))/(5*diffpotential*pi*pi)'

#Solving source terms
#Electron Diffusion-Advection Problem
fem,sem = mms.evaluate('diff(ne,t) + div(-diffem_coeff * grad(ne) - muem_coeff*ne*-grad(V))',
                     ne, variable='ne',
                     V=V,
                     scalars=['N_A','ee','diffem_coeff','muem_coeff','diffpotential','x_max','y_max','f'])

#Ion Diffusion-Advection Problem
fion,sion = mms.evaluate('diff(ni,t) + div(-diffion * grad(ni) + muion*ni*-grad(V))',
                     ni, variable='ni',
                     V=V,
                     scalars=['N_A','ee','diffion','muion','diffpotential','x_max','y_max','f'])


fV,sV = mms.evaluate('div(-diffpotential * grad(V)) - ee*N_A*(ni + ne)',
                     V, variable='V',
                     ne=ne,
                     ni=ni,
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


mms.print_hit(fem, 'em_source')
mms.print_hit(fion, 'ion_source')
