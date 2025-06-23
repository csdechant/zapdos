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
    csv_folder_term01 = "../../../test/tests/mms/magnetized_plasma/continuity_equations/divergence_of_flux_with_logarithmic_variable/gold/scalarLog_divergenceMatVelocity_product.csv"
    csv_folder_term02 = "../../../test/tests/mms/magnetized_plasma/continuity_equations/divergence_of_flux_with_logarithmic_variable/gold/matVector_gradentScalarLog_product.csv"
    csv_folder_combined = "../../../test/tests/mms/magnetized_plasma/continuity_equations/divergence_of_flux_with_logarithmic_variable/gold/divergence_of_flux.csv"
else:                                          # if in test folder
    csv_folder_term01 = "./gold/scalarLog_divergenceMatVelocity_product.csv"
    csv_folder_term02 = "./gold/matVector_gradentScalarLog_product.csv"
    csv_folder_combined = "./gold/divergence_of_flux.csv"


data_01 = np.loadtxt(open(csv_folder_term01, "rb"), delimiter=",", skiprows=1)
data_02 = np.loadtxt(open(csv_folder_term02, "rb"), delimiter=",", skiprows=1)
data_combined = np.loadtxt(open(csv_folder_combined, "rb"), delimiter=",", skiprows=1)

h_01 = data_01[:,1]
u_01 = data_01[:,2]

h_02 = data_02[:,1]
u_02 = data_02[:,2]

h_combined = data_combined[:,1]
u_combined = data_combined[:,2]

u_01_slope = np.polyfit(np.log10(h_01), np.log10(u_01), 1)
u_02_slope = np.polyfit(np.log10(h_02), np.log10(u_02), 1)
u_combined_slope = np.polyfit(np.log10(h_combined), np.log10(u_combined), 1)

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h_01,u_01, marker='o', linestyle='dashed',color='r',label='$N$ solved with first term only: {:.3f}'.format(u_01_slope[0]))
ax1.loglog(h_02,u_02, marker='o', linestyle='dashed',color='g',label='$N$ solved with second term only: {:.3f}'.format(u_02_slope[0]))
ax1.loglog(h_combined,u_combined, marker='o', linestyle='solid',color='b',label='$N$ solved with total divergence term: {:.3f}'.format(u_combined_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('divergence_of_flux_log_convergence.png', bbox_inches='tight', dpi=300)
