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

import scipy as sp
from numpy import *

# presssure = [100] #Torr
# temp = [1.21-1.22]
# hours = [2.16]

pressure_og = array([3.22e24, 3.22e23, 3.22e22, 3.22e21, 1.61e21]) #Torr
pressure = 0.04 * pressure_og
temp = array([1.21, 1.45, 1.77, 2.29, 2.5]) # Test values

e_comb = 1.6e-19
Ar_mass = 6.64e-26

Te_var = linspace(5, 8, 300)

kiz = 2.34e-14 * Te_var**0.59 * exp(-17.44/Te_var)

# data = loadtxt('rate_coefficients/reaction2.txt',delimiter='\t')
# x=zeros(len(data))
# y=zeros(len(data))
# for i in range(len(data)):
#     x[i] = data[i][0]
#     y[i] = data[i][1]
# kiz_fun = sp.interpolate.interp1d(x,y,kind='linear')
# kiz = kiz_fun(Te_var)

uB = (e_comb * Te_var / Ar_mass)**0.5
ng_deff = uB / kiz

fig = plt.figure()
line1, = plt.semilogx(ng_deff, Te_var)
line2, = plt.semilogx(pressure, temp, marker='s', linestyle='None')

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
