#!/usr/bin/env python3

import mms
#df1 = mms.run_spatial('2D_IonBC.i', 4, y_pp=['ion_l2Error','Ex_l2Error','Ey_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df1, label=['ion_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_IonBC.png')

###########################

#df2 = mms.run_spatial('2D_IonBC_NegivateOutWardFacingEfield.i', 4, y_pp=['ion_l2Error','Ex_l2Error','Ey_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df2, label=['ion_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_IonBC_NegivateOutWardFacingEfield.png')

###########################

#df3 = mms.run_spatial('2D_EnergyBC.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df3, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_EnergyBC.png')

###########################

#df4 = mms.run_spatial('2D_EnergyBC_NegivateOutWardFacingEfield.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'])

#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df4, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_EnergyBC_NegivateOutWardFacingEfield.png')

###########################

#df5 = mms.run_spatial('2D_ElectronBC.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'])

#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df5, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_ElectronBC.png')

##########################

#df6 = mms.run_spatial('2D_ElectronBC_NegivateOutWardFacingEfield.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'])

#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df6, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_ElectronBC_NegivateOutWardFacingEfield.png')

df7 = mms.run_spatial('2D_PotentialBC.i', 2, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'])

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df7, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
fig.save('2D_PotentialBC.png')
