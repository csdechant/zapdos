#!/usr/bin/env python3
# Script to run spatial convergence study on microwave_heating.i

import mms
import sympy
import os

if os.path.isfile('../zapdos-opt'):
    executable = '../zapdos-opt'

df1 = mms.run_spatial('2D_Single_Fluid_Diffusion_Advection.i', 4, console=True, executable=executable, x_pp='h', y_pp=['em_l2Error', 'dielectric_real_Error', 'dielectric_image_Error', 'dielectric_real_grad_Error', 'dielectric_image_grad_Error'],mpi=6)

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df1, label=['Elec. Density', 'dielectric_real', 'dielectric_image', 'dielectric_real_grad', 'dielectric_image_grad'], marker='o', markersize=8)
fig.save('spatial_convergence.png')
df1.to_csv('spatial_convergence.csv')