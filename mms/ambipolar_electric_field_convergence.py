#!/usr/bin/env python3
# Script to run spatial convergence study on microwave_heating.i

import mms

df1 = mms.run_spatial('2D_Electron_With_AmbipolarEField.i', 4, console=False, x_pp='h', y_pp=['em_l2Error', 'Efield_Error'],mpi=16)

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df1, label=['Electrons', 'Electric Field'], marker='o', markersize=8)
fig.save('ambipolar_electric_field_convergence.png')
df1.to_csv('ambipolar_electric_field_convergence.csv')
