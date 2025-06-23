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
    csv_folder_p = "../../../test/tests/mms/magnetized_plasma/material_velocities_and_unit_vector/parallel_velocity/gold/parallel_velocity.csv"
    csv_folder_e = "../../../test/tests/mms/magnetized_plasma/material_velocities_and_unit_vector/EcrossB_velocity/gold/EcrossB_velocity.csv"
    csv_folder_d = "../../../test/tests/mms/magnetized_plasma/material_velocities_and_unit_vector/diamagnetic_velocity/gold/diamagnetic_velocity.csv"


data_p = np.loadtxt(open(csv_folder_p, "rb"), delimiter=",", skiprows=1)
data_e = np.loadtxt(open(csv_folder_e, "rb"), delimiter=",", skiprows=1)
data_d = np.loadtxt(open(csv_folder_d, "rb"), delimiter=",", skiprows=1)

h_p = data_p[:,1]
u_p = data_p[:,3]

h_e = data_e[:,1]
u_e = data_e[:,3]

h_d = data_d[:,1]
u_d = data_d[:,3]


u_p_slope = np.polyfit(np.log10(h_p), np.log10(u_p), 1)
u_e_slope = np.polyfit(np.log10(h_e), np.log10(u_e), 1)
u_d_slope = np.polyfit(np.log10(h_d), np.log10(u_d), 1)


fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=16)
ax1.set_ylabel('$L_2$ Error', fontsize=16)

ax1.loglog(h_p,u_p, marker='o', linestyle='dashed',color='g',label='$\\nabla \\cdot \\vec v _\\parallel$: {:.3f}'.format(u_p_slope[0]))
ax1.loglog(h_e,u_e, marker='o', linestyle='dashed',color='r',label='$\\nabla \\cdot\\vec v _E$: {:.3f}'.format(u_e_slope[0]))
ax1.loglog(h_d,u_d, marker='o', linestyle='dashed',color='b',label='$\\nabla \\cdot\\vec v ^*$: {:.3f}'.format(u_d_slope[0]))

ax1.grid(True, which='both', color=[0.8]*3)
ax1.yaxis.offsetText.set_fontsize(20)
ax1.xaxis.offsetText.set_fontsize(10)
plt.legend(loc='lower right',fontsize=16)
plt.rc('font', size=16)
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('magnetic_unit_vector_convergence.png', bbox_inches='tight', dpi=300)
