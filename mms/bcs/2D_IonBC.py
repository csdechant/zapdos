#!/usr/bin/env python3

import mms

#Know solutions
ni = '(cos(pi/2*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 1.0 + cos(pi/2*x)) / N_A'

Ex = '-pi*cos(pi*x)*(sin(pi*t) + 1)'
Ey = '-pi*cos(pi*y)*(sin(pi*t) + 1)'

#Ion Diffusion-Advection Problem
fion,sion = mms.evaluate('diff(ni,t) + div(-diffion * grad(ni) + muion*ni*(Ex*e_i + Ey*e_j))',
                     ni, variable='ni',
                     Ex=Ex,
                     Ey=Ey,
                     scalars=['N_A','ee','diffion','muion','diffpotential','x_max','y_max','f'])


fEx,sEx = mms.evaluate('diff(Ex,t) + div(-diffpotential * grad(Ex))',
                     Ex, variable='Ex',
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


fEy,sEy = mms.evaluate('diff(Ey,t) + div(-diffpotential * grad(Ey))',
                     Ey, variable='Ey',
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


mms.print_hit(fion, 'ion_source')
mms.print_hit(fEx, 'Ex_source')
mms.print_hit(fEy, 'Ey_source')
