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
    exodus_folder = "../../../../../../tutorial/tutorial01-Diffusion/gold/ambipolar-diffusion_out.e"
else:                                          # if in test folder
    exodus_folder = "../gold/ambipolar-diffusion_out.e"

nc = netCDF4.Dataset(exodus_folder)

solution = nc.variables['vals_nod_var1'][1]
x_nodes = nc.variables['coordx'][:]

density = nc.variables['vals_nod_var3'][1]

fig = plt.figure()
line1, = plt.plot(x_nodes, density, label='Zapdos Results')
line2, = plt.plot(x_nodes, solution, linestyle='dashed', label='Analytical Solution')

plt.xlabel("Distance from Plasma Center [m]")
plt.ylabel("Density [m$^{-3}$]")

plt.legend(handles=[line1, line2])

fig.savefig('ambipolar_diffusion.png', bbox_inches='tight', dpi=300)
