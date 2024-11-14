#!/usr/bin/env python3

import mms
df3 = mms.run_spatial('2D_Coupling_Electons_Potential_Ions.i', 3, y_pp=['em_l2Error','ion_l2Error','potential_l2Error'])

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df3, label=['em_l2Error','ion_l2Error','potential_l2Error'], marker='o', markersize=8, num_fitted_points=5)
fig.save('2D_Coupling_Electons_Potential_Ions.png')
