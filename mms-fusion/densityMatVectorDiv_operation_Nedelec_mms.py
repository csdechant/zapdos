#!/usr/bin/env python3
# Script to run spatial convergence study on scalar_azim_magnetic_time_deriv.i

import mms
import sympy

import mooseutils
import copy
import pandas
import os

import pyhit
import moosetree

x_pp = 'h'
y_pp = ['n_l2Error']

x = []
y = [ [] for _ in range(len(y_pp)) ]


runs = 5

executable = '../zapdos-opt'

for i in range(0, runs):
    mpi = 6
    console = True

    # Read the file
    root = pyhit.load('densityMatVectorDiv_operation_Nedelec.i')

    # Locate and modify "x_max" parameter for the mesh
    mesh = moosetree.find(root, func=lambda n: n.fullpath == '/Mesh/gmg')
    mesh["nx"] = 5*2**i
    mesh["ny"] = 5*2**i

    # Write the modified file
    pyhit.write("densityMatVectorDiv_operation_Nedelec.i", root)

    input_files = ['densityMatVectorDiv_operation_Nedelec.i']
    cli_args = ['-i'] + input_files
    a = copy.copy(cli_args)

    out = mooseutils.run_executable(executable, *a, mpi=mpi, suppress_output=not console)

    fcsv = input_files[-1].replace('.i', '_out.csv')
    current = pandas.read_csv(fcsv)

    x.append(current[x_pp].iloc[-1])
    for index,pp in enumerate(y_pp):
        y[index].append(current[pp].iloc[-1])

    df_dict = {x_pp:x}
    df_columns = [x_pp]
    for i in range(len(y_pp)):
        df_dict.update({y_pp[i]:y[i]})
        df_columns.append(y_pp[i])

    data = pandas.DataFrame(df_dict, columns=df_columns)

# Reset mesh
mesh["nx"] = 5
mesh["ny"] = 5
pyhit.write("densityMatVectorDiv_operation_Nedelec.i", root)


fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(data, label=['n'], marker='o', markersize=8)
fig.save('densityMatVectorDiv_operation_Nedelec.png')
data.to_csv('densityMatVectorDiv_operation_Nedelec.csv')
