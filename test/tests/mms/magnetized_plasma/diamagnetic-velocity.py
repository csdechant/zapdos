#!/usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np

pv_data = np.loadtxt(open("magneticUnitVector_and_velocities/gold/parallel_velocity.csv", "rb"), delimiter=",", skiprows=1)
EcBd_data = np.loadtxt(open("magneticUnitVector_and_velocities/gold/EcrossB_velocity.csv", "rb"), delimiter=",", skiprows=1)
dd_data = np.loadtxt(open("magneticUnitVector_and_velocities/gold/diamagnetic_velocity.csv", "rb"), delimiter=",", skiprows=1)


h_parallel = pv_data[:,1]
parallel = pv_data[:,2]
div_parallel = pv_data[:,3]

h_EcrossB = EcBd_data[:,1]
EcrossB = EcBd_data[:,2]
div_EcrossB = EcBd_data[:,3]

h_diamag = dd_data[:,1]
diamag = dd_data[:,2]
div_diamag = dd_data[:,3]

paralle_slope = np.polyfit(np.log10(h_parallel), np.log10(parallel), 1)
div_paralle_slope = np.polyfit(np.log10(h_parallel), np.log10(div_parallel), 1)

EcrossB_slope = np.polyfit(np.log10(h_EcrossB), np.log10(EcrossB), 1)
div_EcrossB_slope = np.polyfit(np.log10(h_EcrossB), np.log10(div_EcrossB), 1)

diamag_slope = np.polyfit(np.log10(h_diamag), np.log10(diamag), 1)
div_diamag_slope = np.polyfit(np.log10(h_diamag), np.log10(div_diamag), 1)

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h_parallel,parallel, marker='o', linestyle='solid',color='r',label='Parallel Velocity: {:.3f}'.format(paralle_slope[0]))
ax1.loglog(h_EcrossB,EcrossB, marker='o', linestyle='solid',color='b',label='EXB Drift: {:.3f}'.format(EcrossB_slope[0]))
ax1.loglog(h_diamag,diamag, marker='o', linestyle='solid',color='b',label='Diamagnetic Drift: {:.3f}'.format(diamag_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('velocity_convergence.png')

fig, ax1 = plt.subplots()
ax1.set_xlabel('Element Size ($h$)', fontsize=12)
ax1.set_ylabel('$L_2$ Error', fontsize=12)
ax1.loglog(h_parallel,div_parallel, marker='o', linestyle='dashed',color='k',label='Div. of Parallel Vel.: {:.3f}'.format(div_paralle_slope[0]))
ax1.loglog(h_EcrossB,div_EcrossB, marker='o', linestyle='dashed',color='g',label='Div. of EXB Drift: {:.3f}'.format(div_EcrossB_slope[0]))
ax1.loglog(h_diamag,div_diamag, marker='o', linestyle='dashed',color='g',label='Div. of EXB Drift: {:.3f}'.format(div_diamag_slope[0]))
ax1.grid(True, which='both', color=[0.8]*3)
plt.legend(loc='upper left')
fig.set_figwidth(5.5)
fig.set_figheight(6)
fig.savefig('divergence_convergence.png')
