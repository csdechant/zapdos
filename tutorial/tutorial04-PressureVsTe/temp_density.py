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

from numpy import *

# presssure = [100] #Torr
# temp = [1.21-1.22]
# hours = [2.16]

#pressure_og = array([3.22e24, 3.22e23, 3.22e22, 3.22e21, 1.61e21]) #Torr
pressure_og = array([3.22e23, 3.22e22, 3.22e21]) #Torr
pressure = pressure_og
# temp = array([1.21, 1.45, 1.77, 2.29, 2.5]) # Test values
temp = array([1.21, 1.6, 2.69]) # Test values

e_comb = 1.6e-19
Ar_mass = 6.64e-26

Te_var = linspace(1, 3, 300)

kiz = 2.34e-14 * Te_var**0.59 * exp(-17.44/Te_var)
uB = (e_comb * Te_var / Ar_mass)**0.5
ng_deff = uB / kiz

kmi = 1e-16
# l = 0.025
l = 1
# ng_space = pi * uB / (l * (kiz*kmi)**0.5)

mu_e_ng = 9.66e23
D_e_ng = 3.86e24

mu_i_ng = 4.65e21
D_i_ng = 2.07e20

Da_ng = (mu_i_ng * D_e_ng + mu_e_ng * D_i_ng) / (mu_i_ng + mu_e_ng)


ng_space = (pi / l) * (Da_ng/kiz)**0.5
l_correction = array([0.02, 0.02, 0.018])

fig = plt.figure()
line1, = plt.semilogx(ng_deff, Te_var)
line2, = plt.semilogx(ng_space, Te_var)
line3, = plt.semilogx(pressure * l_correction, temp, marker='s', linestyle='None')

fig.savefig('temp_Vs_pressure.png', bbox_inches='tight', dpi=300)



# # Changes working directory to script directory (for consistent MooseDocs usage)
# script_folder = os.path.dirname(__file__)
# os.chdir(script_folder)
#
# # Extract data from 'gold' Zapdos run
# if "/zapdos/doc/" in script_folder.lower():     # if in documentation folder
#     exodus_folder = "../../../../../../tutorial/tutorial01-Diffusion/gold/ambipolar-diffusion_out.e"
# else:                                          # if in test folder
#     exodus_folder = "../gold/ambipolar-diffusion_out.e"
#
# nc = netCDF4.Dataset(exodus_folder)
#
# solution = nc.variables['vals_nod_var1'][1]
# x_nodes = nc.variables['coordx'][:]
#
# density = nc.variables['vals_nod_var3'][1]
#
# fig = plt.figure()
# line1, = plt.plot(x_nodes, density, label='Zapdos Results')
# line2, = plt.plot(x_nodes, solution, linestyle='dashed', label='Analytical Solution')
#
# plt.xlabel("Distance from Plasma Center [m]")
# plt.ylabel("Density [m$^{-3}$]")
#
# plt.legend(handles=[line1, line2])
#
# fig.savefig('ambipolar_diffusion.png', bbox_inches='tight', dpi=300)
