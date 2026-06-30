# This tutorial is of a 0D transient kinetics between 3 species densities with first order decay rates.
# This problem is about on Section 9.2 of "Principles of Plasma Discharges and Materials Processing" by Lieberman and Lichtenberg

# Global variables can be defined at the top of input files using 'Brace Expressions'
# The two most common functions of 'Brace Expressions' is:
#      - 'units' for unit conversions, and
#      - 'fparse' for function expressions
# Below at the constant variable used through this tutorial.

# Decay rate for species A
k_A = '${units 1 1/s}'

# Decay rate for species B
k_B = '${units 5 1/s}'

initial_density_species_A = '${units 1 1/m^3}'

# This block is generation a mesh and labeling the mesh boundaries
[Mesh]
  #Sets up a sudo-0D mesh (a 1D mesh with only 1 element)
  [geo]
    type = GeneratedMeshGenerator
    nx = 1
    dim = 1
  []
[]

# This block defines the problem type (such as FE, eigenvalue problem, etc.)
[Problem]
  type = FEProblem
[]

# This block defines the nonlinear variables
# By default, the variable's family and order of the shape function is Lagrange and First Order, respectively
# This can be changed using the parameters 'family = ' and 'order = '.
[Variables]
  [nA]
  []
  [nB]
  []
  [nC]
  []
[]

# This block defines the initial conditions of the nonlinear variables
# If not included in the input file, the default initial condition is zero
[ICs]
  [nA_ic]
    type = FunctionIC
    variable = nA
    function = ${initial_density_species_A}
  []
[]

# This block defines the volume integrated physics terms of each declared variable
[Kernels]
  # Include the time derivatives for each species density
  [nA_time_derv]
    type = TimeDerivative
    variable = nA
  []
  [nB_time_derv]
    type = TimeDerivative
    variable = nB
  []
  [nC_time_derv]
    type = TimeDerivative
    variable = nC
  []
[]

# This block is CRANE's Reactions Action that inputs the reactions as source terms for the variables
[Reactions]
  [Gas]
    # Name of each variable on the reactant side
    species = 'nA nB nC'
    # Define type of coefficient (rate or townsend)
    reaction_coefficient_format = 'rate'
    # Define if using log form
    use_log = false
    # Define if using automatic differentiation
    use_ad = true
    # Define which mesh domain (known as "block" in MOOSE syntax) the reactions take place.
    # For undefine blocks, naming starts at 0
    block = 0
    # Define reactions and coefficients
    reactions = 'nA -> nB  : ${k_A}
                 nB -> nC  : ${k_B}'
  []
[]

# This block defines the auxiliary variables (e.g., variable that are not required to solve the main set of PDEs)
# Similar to 'Variables', the default family and order of the shape function is Lagrange and First Order
[AuxVariables]
  # Declaring variables to represent the known solution for this transient kinetics problem
  [Solution_nA]
  []
  [Solution_nB]
  []
  [Solution_nC]
  []
[]

# This block defines the operators that defines the auxiliary variables
[AuxKernels]
  # Object that calculates the known solution for species A from the analytical function
  [Solution_nA]
    type = FunctionAux
    variable = Solution_nA
    function = '${initial_density_species_A} * exp(-${k_A}*t)'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Object that calculates the known solution for species B from the analytical function
  [Solution_nB]
    type = FunctionAux
    variable = Solution_nB
    function = '${initial_density_species_A} * ${k_A} / (${k_B} - ${k_A}) * (exp(-${k_A}*t) - exp(-${k_B}*t))'
  []
  # Object that calculates the known solution for species C from the analytical function
  [Solution_nC]
    type = FunctionAux
    variable = Solution_nC
    function = '${initial_density_species_A} * (1.0 + 1.0 / (${k_A} - ${k_B}) * (${k_B}*exp(-${k_A}*t) - ${k_A}*exp(-${k_B}*t)))'
  []
[]

# This block defines preconditioning methods and options
[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

# This block defines type of solver (such as steady or transient), solve type (Newton, PJFNK, etc.), and tolerances
[Executioner]
  type = Transient
  end_time = 3
  dt = 0.01
  scheme = bdf2
  solve_type = NEWTON

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

# This block defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]
