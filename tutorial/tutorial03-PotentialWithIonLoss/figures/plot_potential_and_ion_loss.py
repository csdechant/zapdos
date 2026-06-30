# This python script is used to generate the figure for the Zapdos website
# To run this script within the MOOSE conda environment, the 'netCDF4' package needs to be installed
# This can be done by inputting the following into the terminal:
#
#      conda install conda-forge::netcdf4
#
# If you are new to Exodus file format, it is strongly recommended to use a visualization tools to access the output data (such as Paraview)

import netCDF4
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, PillowWriter
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract data from 'gold' Zapdos run
if "/zapdos/doc/" in script_folder.lower():     # if in documentation folder
    exodus_folder = "../../../../../../tutorial/tutorial03-PotentialWithIonLoss/gold/potential-with-ion-drain_out.e"
else:                                          # if in test folder
    exodus_folder = "../gold/potential-with-ion-drain_out.e"

nc = netCDF4.Dataset(exodus_folder)

potential = nc.variables['vals_nod_var3']
ions = nc.variables['vals_elem_var1eb1']

potential_solution = nc.variables['vals_nod_var4']
ions_solution = nc.variables['vals_nod_var2']

x_nodes = nc.variables['coordx'][:]
x_elem = nc.variables['vals_elem_var2eb1']

time = nc.variables['time_whole']

fig, ax1 = plt.subplots()
ax2 = ax1.twinx()

def animate(i):
    for line in ax1.lines:
        line.remove()
    for line in ax2.lines:
        line.remove()

    ax1.set_xlim(0,0.1)
    ax1.set_xlabel("Position [m]")
    ax1.set_ylim(0,2e16)
    ax1.set_ylabel("Ion Density [m$^{-3}$]", color='red')
    ax1.tick_params(axis='y', labelcolor='red')
    line1, = ax1.plot(x_elem[1], ions[i], color='red', label='Zapdos Results: Ions')
    line2, = ax1.plot(x_nodes, ions_solution[i], linestyle='dashed', color='violet', label='Analytical Solution: Ions')

    ax2.set_ylim(0,230000)
    ax2.set_ylabel("Potential [V]", color='blue')
    ax2.tick_params(axis='y', labelcolor='blue')
    line3, = ax2.plot(x_nodes, potential[i], color='blue', label='Zapdos Results: Potential')
    line4, = ax2.plot(x_nodes, potential_solution[i], linestyle='dashed', color='cyan', label='Analytical Solution: Potential')

    ax1.legend(handles=[line1, line2, line3, line4], loc = 'lower center')
    fig.suptitle(f"Current Time: {time[i]:.1e}")
    fig.tight_layout()

    return line1, line2, line3, line4,

ani = FuncAnimation(fig, animate, interval=40, blit=True, repeat=True, frames=100)
ani.save("potential_and_ion_decay.gif", dpi=300, writer=PillowWriter(fps=25))
