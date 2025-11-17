import netCDF4
import numpy as np
import matplotlib.pyplot as plt

fp='reference_equilibrium.nc'
nc = netCDF4.Dataset(fp)
mg_Z = nc.groups['Magnetic_geometry'].variables['Z'][:]
mg_R = nc.groups['Magnetic_geometry'].variables['R'][:]
mg_psi = nc.groups['Magnetic_geometry'].variables['psi'][:]

psi_gradient_Z, psi_gradient_R = np.gradient(mg_psi,mg_Z,mg_R)

R, Z = np.meshgrid(mg_R, mg_Z)

B_R = psi_gradient_Z/R
B_Z = -1.0 * psi_gradient_R/R

plt.contourf(R,Z,B_R)
plt.colorbar()
plt.show()

Z, R = np.meshgrid(mg_R, mg_Z)
plt.contourf(Z,R,mg_psi)
plt.colorbar()
# plt.contour(mg_R, mg_Z,mg_psi)

divertor_R = nc.groups['divertor_polygon'].variables['R_points'][:]
divertor_Z = nc.groups['divertor_polygon'].variables['Z_points'][:]
plt.plot(divertor_R,divertor_Z,color='red')

exclusion_R = nc.groups['exclusion_polygon'].variables['R_points'][:]
exclusion_Z = nc.groups['exclusion_polygon'].variables['Z_points'][:]
plt.plot(exclusion_R,exclusion_Z,color='orange')

plt.show()
