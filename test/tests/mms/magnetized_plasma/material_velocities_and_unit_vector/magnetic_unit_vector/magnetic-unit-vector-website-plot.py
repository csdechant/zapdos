#!/usr/bin/env python3
# Script to run spatial convergence study on magnetic_unit_vector.i

## NOTE: I need use symbolic linking, instead of just copying the file over...

import matplotlib.pyplot as plt
import numpy as np
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract data from 'gold' Zapdos run
if "/zapdos/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../test/tests/mms/magnetized_plasma/material_velocities_and_unit_vector/magnetic_unit_vector/gold/magnetic_unit_vector.csv"
else:                                          # if in test folder
    csv_folder = "./gold/magnetic_unit_vector.csv"


data = np.loadtxt(open(csv_folder, "rb"), delimiter=",", skiprows=1)

h = data[:,1]
mag_B = data[:,2]
grad_mag_B = data[:,3]
unit_vector = data[:,4]
div_unit_vector = data[:,5]
curl_unit_vector = data[:,6]

mag_B_slope = np.polyfit(np.log10(h), np.log10(mag_B), 1)
grad_mag_B_slope = np.polyfit(np.log10(h), np.log10(grad_mag_B), 1)
unit_vector_slope = np.polyfit(np.log10(h), np.log10(unit_vector), 1)
div_unit_vector_slope = np.polyfit(np.log10(h), np.log10(div_unit_vector), 1)
curl_unit_vector_slope = np.polyfit(np.log10(h), np.log10(curl_unit_vector), 1)

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h,mag_B, marker='o', linestyle='solid',color='g',label='$|B|$: {:.3f}'.format(mag_B_slope[0]))
ax1.loglog(h,grad_mag_B, marker='o', linestyle='dashed',color='c',label='$\\nabla |B|$: {:.3f}'.format(grad_mag_B_slope[0]))
ax1.loglog(h,unit_vector, marker='o', linestyle='solid',color='b',label='$\\vec b$: {:.3f}'.format(unit_vector_slope[0]))
ax1.loglog(h,div_unit_vector, marker='o', linestyle='dashed',color='r',label='$\\nabla \\cdot \\vec b$: {:.3f}'.format(div_unit_vector_slope[0]))
ax1.loglog(h,curl_unit_vector, marker='o', linestyle='solid',color='m',label='$\\nabla \\times \\vec b$: {:.3f}'.format(curl_unit_vector_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('magnetic_unit_vector_convergence.png', bbox_inches='tight', dpi=300)
