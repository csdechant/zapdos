import netCDF4 as nc
# import xarray as xr
# import numpy as np
# import matplotlib
# import matplotlib.pyplot as plt

# fp='TCV-X21-reference_scenario/reference_equilibrium.nc'
# nc = netCDF4.Dataset(fp)
# # print(nc)
# # print(nc.groups)
# # print(nc.groups['Magnetic_geometry'].variables['Z'][:])
# nc.open_dataset('destination.nc')

fp='reference_equilibrium.nc'
data = nc.Dataset(fp)
# nc = netCDF4.Dataset(fp)
print(data.groups)
