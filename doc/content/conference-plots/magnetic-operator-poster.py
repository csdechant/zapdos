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
    csv_folder_div = "../../../test/tests/mms/magnetized_plasma/continuity_equations/divergence_of_flux/gold/divergence_of_flux.csv"
    csv_folder_div_log = "../../../test/tests/mms/magnetized_plasma/continuity_equations/divergence_of_flux_with_logarithmic_variable/gold/divergence_of_flux.csv"
    csv_folder_perp = "../../../test/tests/mms/magnetized_plasma/continuity_equations/perpendicular_diffusion/gold/perpendicular_diffusion.csv"
    csv_folder_perp_log = "../../../test/tests/mms/magnetized_plasma/continuity_equations/perpendicular_diffusion_logarithmic_variable/gold/perpendicular_diffusion.csv"


data_div = np.loadtxt(open(csv_folder_div, "rb"), delimiter=",", skiprows=1)
data_div_log = np.loadtxt(open(csv_folder_div_log, "rb"), delimiter=",", skiprows=1)
data_perp = np.loadtxt(open(csv_folder_perp, "rb"), delimiter=",", skiprows=1)
data_perp_log = np.loadtxt(open(csv_folder_perp_log, "rb"), delimiter=",", skiprows=1)

h_div = data_div[:,1]
u_div = data_div[:,2]

h_div_log = data_div_log[:,1]
u_div_log = data_div_log[:,2]

h_perp = data_perp[:,1]
u_perp = data_perp[:,2]

h_perp_log = data_perp_log[:,1]
u_perp_log = data_perp_log[:,2]


u_div_slope = np.polyfit(np.log10(h_div), np.log10(u_div), 1)
u_div_log_slope = np.polyfit(np.log10(h_div_log), np.log10(u_div_log), 1)
u_perp_slope = np.polyfit(np.log10(h_perp), np.log10(u_perp), 1)
u_perp_log_slope = np.polyfit(np.log10(h_perp_log), np.log10(u_perp_log), 1)


fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=16)
ax1.set_ylabel('$L_2$ Error', fontsize=16)

ax1.loglog(h_div,u_div, marker='o', linestyle='solid',color='g',label='$f$ for $\\nabla \\cdot (f \\vec v)$: {:.3f}'.format(u_div_slope[0]))
ax1.loglog(h_perp,u_perp, marker='o', linestyle='solid',color='b',label='$f$ for $\\nabla \\cdot (\\nabla _\\perp f)$: {:.3f}'.format(u_perp_slope[0]))
ax1.loglog(h_div_log,u_div_log, marker='o', linestyle='dashed',color='g',label='$N$ for $\\nabla \\cdot (n \\vec v)$: {:.3f}'.format(u_div_log_slope[0]))
ax1.loglog(h_perp_log,u_perp_log, marker='o', linestyle='dashed',color='b',label='$N$ for $\\nabla \\cdot (\\nabla _\\perp n)$: {:.3f}'.format(u_perp_log_slope[0]))

ax1.grid(True, which='both', color=[0.8]*3)
ax1.yaxis.offsetText.set_fontsize(20)
ax1.xaxis.offsetText.set_fontsize(10)
plt.legend(loc='lower right',fontsize=16)
plt.rc('font', size=16)
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('magnetic_unit_vector_convergence.png', bbox_inches='tight', dpi=300)
