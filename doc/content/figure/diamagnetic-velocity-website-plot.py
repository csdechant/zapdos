#!/usr/bin/env python3
# Script to run spatial convergence study on diamagnetic_velocity.i

## NOTE: I need use symbolic linking, instead of just copying the file over...

import matplotlib.pyplot as plt
import numpy as np
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract data from 'gold' Zapdos run
if "/zapdos/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../test/tests/mms/magnetized_plasma/material_velocities_and_unit_vector/diamagnetic_velocity/gold/diamagnetic_velocity.csv"
else:                                          # if in test folder
    csv_folder = "./gold/diamagnetic_velocity.csv"


data = np.loadtxt(open(csv_folder, "rb"), delimiter=",", skiprows=1)

h = data[:,1]
velocity = data[:,2]
div_velocity = data[:,3]

velocity_slope = np.polyfit(np.log10(h), np.log10(velocity), 1)
div_velocity_slope = np.polyfit(np.log10(h), np.log10(div_velocity), 1)

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h,velocity, marker='o', linestyle='solid',color='b',label='$\\vec v ^*$: {:.3f}'.format(velocity_slope[0]))
ax1.loglog(h,div_velocity, marker='o', linestyle='dashed',color='r',label='$\\nabla \\cdot \\vec v ^*$: {:.3f}'.format(div_velocity_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('diamagnetic_velocity_convergence.png', bbox_inches='tight', dpi=300)
