#!/usr/bin/env python3

import mms
import csv

#df1 = mms.run_spatial('2D_Single_Fluid_Diffusion.i', 4, y_pp=['em_l2Error'],mpi=6)
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df1, label=['em_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Single_Fluid_Diffusion.png')
#
#df1.to_csv('2D_Single_Fluid_Diffusion.csv')

###########################

#df2 = mms.run_spatial('2D_Single_Fluid_Diffusion_FVAdvection.i', 4, y_pp=['em_l2Error'],mpi=6)
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df2, label=['em_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Single_Fluid_Diffusion_FVAdvection.png')
#
#df2.to_csv('2D_Single_Fluid_Diffusion_FVAdvection.csv')

######

#df3 = mms.run_spatial('2D_Single_Fluid_Diffusion_FEAdvection.i', 4, y_pp=['em_l2Error'],mpi=6)
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df3, label=['em_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Single_Fluid_Diffusion_FEAdvection.png')
#
#df3.to_csv('2D_Single_Fluid_Diffusion_FEAdvection.csv')

###########################

#df3 = mms.run_spatial('FV_2D_Coupling_Electons_Potential_Ions.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error'],mpi=6)
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df3, label=['em_l2Error','ion_l2Error','potential_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('FV_2D_Coupling_Electons_Potential_Ions.png')
#
#df3.to_csv('FV_2D_Coupling_Electons_Potential_Ions.csv')

#########

df4 = mms.run_spatial('FV_2D_Coupling_Electons_Potential_Ions_SGFlux.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error'],mpi=6)

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df4, label=['em_l2Error','ion_l2Error','potential_l2Error'], marker='o', markersize=8, num_fitted_points=5)
fig.save('FV_2D_Coupling_Electons_Potential_Ions_SGFlux.png')

df4.to_csv('FV_2D_Coupling_Electons_Potential_Ions_SGFlux.csv')

###########################
#
#df5 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'],mpi=4)
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df5, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation.png')
#
#df5.to_csv('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation.csv')
#
##########################
#
#df6 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation_EffEfield.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'],mpi=4)
#
#fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
#fig.plot(df6, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error','Ex_l2Error','Ey_l2Error'], marker='o', markersize=8, num_fitted_points=5)
#fig.save('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation_EffEfield.png')
#
#df6.to_csv('2D_Coupling_Electons_Potential_Ions_MeanEnergy_Einstein_Relation_EffEfield.csv')
