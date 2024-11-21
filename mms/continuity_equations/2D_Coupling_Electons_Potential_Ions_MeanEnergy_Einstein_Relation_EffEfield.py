#!/usr/bin/env python3

import mms

#Know solutions
ne = '(sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A'
ni = '(sin(pi*(y/y_max)) + 1.0 + 0.9*cos(pi/2*(x/x_max))) / N_A'
V = '-(ee*(2*x_max*x_max*cos((pi*x)/(2*x_max)) + y_max*y_max*cos((pi*y)/y_max)*sin(2*pi*f*t)))/(5*diffpotential*pi*pi)'
energy = 'sin(pi*(y/y_max)) + sin(2*pi*t*f)*cos(pi*(y/y_max))*sin(pi*(y/y_max)) + 0.75 + cos(pi/2*(x/x_max))'
nenergy = '('+energy+')'+'*'+'('+ne+')'
Ex = '-(ee*x_max*exp(-5*t)*sin((pi*x)/(2*x_max))*(exp(5*t) - 1))/(5*diffpotential*pi)'
Ey = '-exp(-5*t)*((2*ee*f*y_max*sin((pi*y)/y_max))/(diffpotential*(4*f*f*pi*pi + 25)) - 1/10) - (ee*y_max*sin((pi*y)/y_max)*(5*sin(2*pi*f*t) - 2*f*pi*cos(2*pi*f*t)))/(diffpotential*pi*(4*f*f*pi*pi + 25))'

#Energy Dependent coeff.
diffem = 'diffem_coeff*'+'('+energy+')'
muem = 'muem_coeff*'+'('+energy+')'

diffmean_en = 'diffmean_en_coeff*'+'('+energy+')'
mumean_en = 'mumean_en_coeff*'+'('+energy+')'

#Solving source terms
#Electron Diffusion-Advection Problem
fem,sem = mms.evaluate('diff(ne,t) + div(-diffem * grad(ne) - muem*ne*-grad(V))',
                     ne, variable='ne',
                     V=V,
                     scalars=['N_A','ee','diffem_coeff','muem_coeff','diffpotential','x_max','y_max','f'],
                     diffem = diffem,
                     muem = muem)

#Ion Diffusion-Advection Problem
fion,sion = mms.evaluate('diff(ni,t) + div(-diffion * grad(ni) + muion*ni*(Ex*e_i + Ey*e_j))',
                     ni, variable='ni',
                     V=V,
                     Ex=Ex,
                     Ey=Ey,
                     scalars=['N_A','ee','diffion','muion','diffpotential','x_max','y_max','f'])

#Electron Mean-Energy Problem
fenergy,senergy = mms.evaluate('diff(nenergy,t) + div(coeff*energy*(-diffem * grad(ne) - muem*ne*-grad(V)) - ne*diffem*grad(energy)) - '+
                               '(-diffem *(grad(ne).dot(e_i)*grad(V).dot(e_i) + grad(ne).dot(e_j)*grad(V).dot(e_j))'+
                               '+ muem *ne*(grad(V).dot(e_i)*grad(V).dot(e_i) + grad(V).dot(e_j)*grad(V).dot(e_j)))',
                     nenergy, variable='nenergy',
                     energy = energy,
                     V=V,
                     ne=ne,
                     scalars=['coeff','N_A','ee','diffem_coeff','muem_coeff','diffmean_en_coeff', 'mumean_en_coeff','diffpotential','x_max','y_max','f'],
                     diffem = diffem,
                     muem = muem,
                     diffmean_en = diffmean_en,
                     mumean_en = mumean_en)


fV,sV = mms.evaluate('div(-diffpotential * grad(V)) - ee*N_A*(ni + ne)',
                     V, variable='V',
                     ne=ne,
                     ni=ni,
                     scalars=['N_A','ee','diffpotential','x_max','y_max','f'])


mms.print_hit(fem, 'em_source')
mms.print_hit(fion, 'ion_source')
mms.print_hit(fenergy, 'energy_source')
