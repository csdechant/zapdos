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
    csv_folder = "../../../test/tests/mms/magnetized_plasma/model_verification/Hasegawa_Wakatani_model/HW_model/gold/2D_Hasegawa_Wakatani.csv"
else:                                          # if in test folder
    csv_folder = "./gold/2D_Hasegawa_Wakatani.csv"


data = np.loadtxt(open(csv_folder, "rb"), delimiter=",", skiprows=1)

h = data[:,1]
density = data[:,2]
vorticity = data[:,3]
potential = data[:,4]

density_slope = np.polyfit(np.log10(h), np.log10(density), 1)
vorticity_slope = np.polyfit(np.log10(h), np.log10(vorticity), 1)
potential_slope = np.polyfit(np.log10(h), np.log10(potential), 1)

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h,density, marker='o', linestyle='solid',color='r',label='$n$: {:.3f}'.format(density_slope[0]))
ax1.loglog(h,vorticity, marker='o', linestyle='solid',color='b',label='$\\omega$: {:.3f}'.format(vorticity_slope[0]))
ax1.loglog(h,potential, marker='o', linestyle='solid',color='g',label='$\\phi$ with an adiabatic source term: {:.3f}'.format(potential_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('2D_Hasegawa_Wakatani_convergence.png', bbox_inches='tight', dpi=300)
