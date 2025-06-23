#!/usr/bin/env python3
# Script to run spatial convergence study on divergence_of_flux.i

## NOTE: I need use symbolic linking, instead of just copying the file over...

import matplotlib.pyplot as plt
import numpy as np
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract data from 'gold' Zapdos run
if "/zapdos/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../test/tests/mms/magnetized_plasma/model_verification/Hasegawa_Wakatani_model/directional_potential_gradient/gold/directional_potential_gradient.csv"
else:                                          # if in test folder
    csv_folder = "./gold/directional_potential_gradient.csv"


data = np.loadtxt(open(csv_folder, "rb"), delimiter=",", skiprows=1)

h = data[:,1]
u = data[:,2]

u_slope = np.polyfit(np.log10(h), np.log10(u), 1)

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h,u, marker='o', linestyle='solid',color='b',label='$n$ with an directional $\\nabla \\phi$ source term: {:.3f}'.format(u_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('directional_potential_gradient_convergence.png', bbox_inches='tight', dpi=300)
