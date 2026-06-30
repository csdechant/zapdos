# This python script is used to generate the figure for the Zapdos website
# To run this script within the MOOSE conda environment, the 'netCDF4' package needs to be installed
# This can be done by inputting the following into the terminal:
#
#      conda install conda-forge::netcdf4
#
# If you are new to Exodus file format, it is strongly recommended to use a visualization tools to access the output data (such as Paraview)

import netCDF4
import matplotlib.pyplot as plt
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract data from 'gold' Zapdos run
if "/zapdos/doc/" in script_folder.lower():     # if in documentation folder
    exodus_folder = "../../../../../../tutorial/tutorial02-ReactionNetwork/gold/transient-kinetics_out.e"
else:                                          # if in test folder
    exodus_folder = "../gold/transient-kinetics_out.e"

nc = netCDF4.Dataset(exodus_folder)

time = nc.variables['time_whole'][:]

solution_nA = nc.variables['vals_nod_var1'][:,0]
solution_nB = nc.variables['vals_nod_var2'][:,0]
solution_nC = nc.variables['vals_nod_var3'][:,0]

nA = nc.variables['vals_nod_var4'][:,0]
nB = nc.variables['vals_nod_var5'][:,0]
nC = nc.variables['vals_nod_var6'][:,0]

fig = plt.figure()

line1, = plt.plot(time, nA, label='Zapdos Results: n$_A$')
line2, = plt.plot(time, nB, label='Zapdos Results: n$_B$')
line3, = plt.plot(time, nC, label='Zapdos Results: n$_C$')

line4, = plt.plot(time[:], solution_nA, linestyle='dashed', label='Analytical Solution: n$_A$')
line5, = plt.plot(time, solution_nB, linestyle='dashed', label='Analytical Solution: n$_B$')
line6, = plt.plot(time, solution_nC, linestyle='dashed', label='Analytical Solution: n$_C$')

plt.xlabel("Time [s]")
plt.ylabel("Density [m$^{-3}$]")

plt.legend(handles=[line1, line2, line3, line4, line5, line6])

fig.savefig('reaction_evolution.png', bbox_inches='tight', dpi=300)
