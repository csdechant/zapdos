#!/usr/bin/env python3

import mms

#Know solutions
ne = '() / N_A'
ni = '() / N_A'

V = ''
Ex = ''
Ey = ''

energy = '(3*massem*pi*(diffpotential*pi*cos(pi*t) - cos(pi*t)*(sin(pi*x) + sin(pi*y)) + 4)*(diffpotential*pi*cos(pi*t) - cos(pi*t)*(sin(pi*x) + sin(pi*y)) + 4))/(16*ee*16*ee*16*ee*(sin(pi*x) + sin(pi*y) + (cos(pi*y)*sin(2*pi*t))/5 + 2)*(sin(pi*x) + sin(pi*y) + (cos(pi*y)*sin(2*pi*t))/5 + 2))'
nenergy = '('+energy+')'+'*'+'('+ne+')'

#Ion Diffusion-Advection Problem
fem,sem = mms.evaluate('diff(ne,t) + div(-diffem * grad(ne) - muem*ne*-grad(V))',
                     ne, variable='ne',
                     V=V,
                     scalars=['N_A','ee','diffem','muem','diffpotential','x_max','y_max','f'])

fion,sion = mms.evaluate('diff(ni,t) + div(-diffion * grad(ni) + muion*ni*(Ex*e_i + Ey*e_j))',
                     ni, variable='ni',
                     Ex=Ex,
                     Ey=Ey,
                     scalars=['N_A','ee','diffion','muion','diffpotential','x_max','y_max','f'])

fV,sV = mms.evaluate('diff(V,t) + div(-diffpotential * grad(V))',
                     V, variable='V',
                     ne=ne,
                     ni=ni,
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


fEx,sEx = mms.evaluate('diff(Ex,t) + div(-diffpotential * grad(Ex))',
                     Ex, variable='Ex',
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


fEy,sEy = mms.evaluate('diff(Ey,t) + div(-diffpotential * grad(Ey))',
                     Ey, variable='Ey',
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])

fenergy,senergy = mms.evaluate('diff(nenergy,t) + div(-diffmean_en * grad(nenergy))',
                     nenergy, variable='nenergy',
                     scalars=['N_A','ee','diffem','muem','massem','diffmean_en','x_max','y_max','f'])


mms.print_hit(fem, 'em_source')
mms.print_hit(fion, 'ion_source')
mms.print_hit(fenergy, 'energy_source')
mms.print_hit(fEx, 'Ex_source')
mms.print_hit(fEy, 'Ey_source')
mms.print_hit(fV, 'potential_source')
