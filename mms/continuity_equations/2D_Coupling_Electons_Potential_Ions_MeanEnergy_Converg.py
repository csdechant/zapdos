#!/usr/bin/env python3
#mpiexec -n 3 ../zapdos-opt

import mms
df = mms.run_spatial('2D_Coupling_Electons_Potential_Ions_MeanEnergy.i', 4, y_pp=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'])

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df, label=['em_l2Error','ion_l2Error','potential_l2Error','mean_en_l2Error'], marker='o', markersize=8, num_fitted_points=5)
fig.save('Test.png')
