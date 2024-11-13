#!/usr/bin/env python3
# Script to run spatial convergence study on microwave_heating.i

import mms
import sympy
import os

if os.path.isfile('../zapdos-opt'):
    executable = '../zapdos-opt'

df1 = mms.run_temporal('2D_Single_Fluid_Diffusion_Advection_temporal.i', 4, dt=0.05, console=True, executable=executable, x_pp='h', y_pp=['em_l2Error'],mpi=6)

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df1, label=['Elec. Density'], marker='o', markersize=8)
fig.save('temporal_spatial_convergence_og.png')
df1.to_csv('temporal_convergence_og.csv')