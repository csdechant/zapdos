# This tutorial is an ambipolar diffusion case with the density is pinned at the wall boundary.
# This problem is about on Section 5.2 of "Principles of Plasma Discharges and Materials Processing" by Lieberman and Lichtenberg

# Global variables can be defined at the top of input files using 'Brace Expressions'
# The two most common functions of 'Brace Expressions' is:
#      - 'units' for unit conversions, and
#      - 'fparse' for function expressions
# Below at the constant variable used through this tutorial.

# The plasma length (convert from inches to meters)
plasma_length = '${units 1 in -> m}'

# The background gas density (based on 1 Torr)
background_gas_density = '${units 3.22e16 1/cm^3 -> 1/m^3}'

# The background gas molar density (Zapdos solves in molar density)
background_molar_density = '${units ${fparse background_gas_density/6.022e23} moles/m^3}'

# The initial value of the quasi-neutral plasma density
initial_density = '${units 1e8 1/cm^3 -> 1/m^3}'

# The initial quasi-neutral molar density (Zapdos solves in molar density)
initial_molar_density = '${units ${fparse initial_density/6.022e23} moles/m^3}'

# Electron transport coefficients (based on argon at 1 Torr)
mu_e = '${units 30.0 m^2/(V*s)}'
D_e = '${units 119.87 m^2/s}'

# Ion transport coefficients (based on argon at 1 Torr)
mu_i = '${units 1.44e-1 m^2/(V*s)}'
D_i = '${units 6.42e-3 m^2/s}'

# Ambipolar diffusion coefficient
D_a = '${fparse (mu_i*D_e + mu_e*D_i)/(mu_i + mu_e)}'

# Effective reaction rate
k_eff = '${units 5.584e-3 1/s}'

# A scaling factor, for a scaled mesh is used
# For example, if set to 1.0, there is no scaling and if set to 0.010, the mesh was scaled up by a cm
dom0Scale = 1.0

# This block defines the parameter inputs that are common between multiple objects.
# This is used to avoid defining these parameters multiple time throughout the input file.
# In Zapdos, this is usually the scaling parameters
[GlobalParams]
  potential_units = V # Scales the potential by V or kV
  use_moles = true # Converts density from #/m^3 to moles/m^3
  position_units = ${dom0Scale} # Scales gradient operators when utilizing a scaled mesh
[]

# This block is generation a mesh and labeling the mesh boundaries
[Mesh]
  #Sets up a 1-D mesh
  [geo]
    type = GeneratedMeshGenerator
    xmin = 0 # Start the mesh a point 0 (Based on the problem statement, this represents the center of the plasma)
    xmax = '${fparse ${plasma_length}/2}' # Defining the other end of the mesh (Based on the problem statement, this half the plasma length)
    nx = 100 # Defining number of elements
    bias_x = 0.90 # Adding a slight bias so that there are more elements near the wall boundary
    dim = 1 # Restricting the mesh to 1D
  []
  # Labeling the mesh boundaries
  [left]
    type = SideSetsFromNormalsGenerator
    input = geo # Name of previous meshing block to apply changes.
    normals = '-1 0 0' # Calling the outward facing normal that defines a boundary (for a 1D mesh, this is the left most point)
    new_boundary = 'plasma_center' # Defining the boundary label
  []
  [right]
    type = SideSetsFromNormalsGenerator
    input = left # Name of previous meshing block to apply changes.
    normals = '1 0 0' # Calling the outward facing normal that defines a boundary (for a 1D mesh, this is the right most point)
    new_boundary = 'wall' # Defining the boundary label
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
  # Declaring the quasi-neutral plasma density as 'n'
  [n]
  []
[]

# This block defines coefficients that exist within the simulation domain (most commonly used for material properties)
[Materials]
  # Declaring the material and transport properties of the quasi-neutral plasma density
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = n
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    # To call a global variable into an object parameter, a brace expressions must be used
    diffusivity = ${D_a}
  []
  # Declaring the effective rate coefficient as 'FirstOrderRate'
  [FirstOrder_Reaction]
    type = GenericRateConstant
    reaction = FirstOrderRate
    reaction_rate_value = ${k_eff}
  []
[]

# This block defines the initial conditions of the nonlinear variables
# If not included in the input file, the default initial condition is zero
[ICs]
  [n_ic]
    type = FunctionIC
    variable = n
    # Zapdos needs the logarithmic of value of the molar density (this is used the avoid negative densities)
    function = 'log(${initial_molar_density})'
  []
[]

# This block defines the volume integrated physics terms of each declared variable
[Kernels]
  # Including the diffusion term
  [n_diffusion]
    type = CoeffDiffusion
    variable = n
  []
  # Including the source term
  [n_source]
    type = ReactionFirstOrderLog
    variable = n
    # The 'fparse' can be used in object parameters.
    v = '${fparse log(background_molar_density)}'
    reaction = FirstOrderRate
    _v_eq_u = false
    coefficient = 1
  []
[]

# This block defines the boundary conditions of each declared variable
# If a boundary condition is not defined, the default condition is a zero flux boundary condition
[BCs]
  # Defines a Dirichlet BC for the quasi-neutral logarithmic molar density at the wall
  [n_physical_right_diffusion]
    type = LogDensityDirichletBC
    variable = n
    boundary = 'wall'
    value = 0
  []
[]

# This block defines the auxiliary variables (e.g., variable that are not required to solve the main set of PDEs)
# Similar to 'Variables', the default family and order of the shape function is Lagrange and First Order
[AuxVariables]
  # Declaring a variable to convert the mole-log form of the quasi-neutral plasma density to #/m^3
  [n_density]
  []

  # Declaring a variable to represent the known solution for this diffusion problem
  [Solution]
  []
[]

# This block defines the operators that defines the auxiliary variables
[AuxKernels]
  # Object that converts the mole-log form of the quasi-neutral plasma density to #/m^3
  [n_density]
    type = DensityMoles
    variable = n_density
    density_log = n
  []
  # Object that calculates the known solution from the analytical function
  [Solution]
    type = FunctionAux
    variable = Solution
    function = '${background_gas_density} * ${k_eff} * ${plasma_length}^2 / (8. * ${D_a}) * (1 - (2*x / ${plasma_length})^2.)'
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
  type = Steady
  solve_type = NEWTON

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-18
[]

# This block defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]
