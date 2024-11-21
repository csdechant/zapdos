#!/usr/bin/env python3

import mms
#df1 = mms.run_spatial('2D_Single_Fluid_Diffusion.i', 4, y_pp=['em_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df1, label=['em_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Single_Fluid_Diffusion.png')
#
###########################

#df2 = mms.run_spatial('2D_Single_Fluid_Diffusion_Advection.i', 4, y_pp=['em_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df2, label=['em_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Single_Fluid_Diffusion_Advection.png')
#
###########################

#df3 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df3, label=['em_l2Error','ion_l2Error','potential_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Coupling_Electons_Potential_Ions.png')
#
###########################

#df4 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions_MeanEnergy.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'])
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df4, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Coupling_Electons_Potential_Ions_MeanEnergy.png')
#
###########################

df5 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'])

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df5, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'], marker='o', markersize=8, num_fitted_points=5)
fig.save('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation.png')

##########################

df6 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation_EffEfield.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'])

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df6, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
fig.save('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation_EffEfield.png')
