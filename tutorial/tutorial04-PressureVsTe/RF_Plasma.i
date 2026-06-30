# This tutorial is ...

# Global variables can be defined at the top of input files using 'Brace Expressions'
# The two most common functions of 'Brace Expressions' is:
#      - 'units' for unit conversions, and
#      - 'fparse' for function expressions
# Below at the constant variable used through this tutorial.

# The plasma length
plasma_length = '${units 0.0254 m}'

# The baseline pressure, set to 1 Torr
baseline_pressure = '${units 133.322 pa}'

# The modified pressure value
pressure = '${fparse 1.0 * baseline_pressure}'

# The background gas density (argon) as a function of pressure,
# assuming constant gas temperature of 300k.
background_gas_density = '${units ${fparse pressure/(300 * 1.38e-23)} 1/m^3}'


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
  #Mesh is defined existing mesh file
  [geo]
    type = FileMeshGenerator
    file = 'Lymberopoulos_paper.msh'
  []
  #Renames all sides with the specified normal
  #For 1D, this is used to rename the end points of the mesh
  [left]
    type = SideSetsFromNormalsGenerator
    normals = '-1 0 0'
    new_boundary = 'left'
    input = geo
  []
  [right]
    type = SideSetsFromNormalsGenerator
    normals = '1 0 0'
    new_boundary = 'right'
    input = left
  []
[]

# This block defines the problem type (such as FE, eigenvalue problem, etc.)
[Problem]
  type = FEProblem
[]

#Defining IC from previous output file
# (The ICs block is not used in this case)
[Variables]
  [n]
  []

  [energy_density]
  []
[]

[Kernels]
  # Including the diffusion term
  [n_diffusion]
    type = CoeffDiffusion
    variable = n
  []

  [mean_en_advection]
    type = EFieldAdvection
    variable = energy_density
    block = 0
    position_units = ${dom0Scale}
  []
  [mean_en_diffusion]
    type = CoeffDiffusion
    variable = energy_density
    block = 0
    position_units = ${dom0Scale}
  []
  [mean_en_joule_heating]
    type = JouleHeating
    variable = energy_density
    electrons = em
    block = 0
    position_units = ${dom0Scale}
  []
[]

# This block is CRANE's Reactions Action that inputs the reactions as source terms for the variables
[Reactions]
  [Argon]
    species = 'n' # Name of reactant species that are variables
    aux_species = 'Ar' # Name of reactant species that are auxvariables
    reaction_coefficient_format = 'rate' # Type of coefficient (rate or townsend)
    gas_species = 'Ar' # Name of background gas
    electron_energy = 'energy_density' # Name of the electron mean energy density
    electron_density = 'n' # Name of the electrons (usually 'em')
    include_electrons = true # Defines if electrons are tracked
    # potential = 'potential' # Name of name for potential
    use_log = true # Defines if log form is used
    use_ad = true # Defines if automatic differentiation is used
    # Inputs of the plasma chemistry, e.g. Reaction : {Function} [Threshold Energy]
    reactions = 'n + Ar -> n + n + ions   : {2.34e-14 * e_temp^0.59 * exp(-17.44/e_temp) * 6.022e23} [-15.76]
                 n + Ar -> n + metastable         : {2.48e-14 * e_temp^0.33 * exp(-12.78/e_temp) * 6.022e23} [-12.14]'
    equation_variables = 'e_temp' # Variable that the reaction function depends on


    # #
    #Name of material block ('0' for an user undefined block)
    block = 0
    # #
    # #
    # #Defines directory holding rate text files
    # file_location = 'rate_coefficients'
    # #
  []
[]

# This block defines the auxiliary variables (e.g., variable that are not required to solve the main set of PDEs)
# Similar to 'Variables', the default family and order of the shape function is Lagrange and First Order
[AuxVariables]
  # Declaring a variable to represent the background gas (in this case, argon)
  [Ar]
  []

  [em]
  []

  [e_temp]
  []

  [electric_field]
  []
[]

# This block defines the operators that defines the auxiliary variables
[AuxKernels]
  # Object that calculates the logarithmic molar density of the background gas
  [Ar_val]
    type = FunctionAux
    variable = Ar
    function = 'log(${background_gas_density}/6.022e23)'
    execute_on = INITIAL
  []

  [e_temp]
    type = ElectronTemperature
    variable = e_temp
    electrons = n
    electron_energy = energy_density
  []

  [em]
    type = ADParsedAux
    variable = em
    coupled_variables = 'n'
    expression = 'n'
  []

  [electric_field]
    type = ADParsedAux
    variable = em
    coupled_variables = 'n'
    expression = 'n'
  []
[]

# This block defines the boundary conditions of each declared variable
# If a boundary condition is not defined, the default condition is a zero flux boundary condition
[BCs]
  # Boundary conditions for electrons
  [density_physical_diffusion]
    type = DirichletBC
    variable = n
    boundary = 'left right'
    value = 0
    preset = false
  []

  # Boundary conditions for electron mean energy density
  [mean_en_physical_value]
    type = DirichletBC
    variable = energy_density
    boundary = 'left right'
    value = 0
    preset = false
  []
[]

# This block defines coefficients that exist within the simulation domain (most commonly used for material properties)
[Materials]
  # The material properties of the electrons.
  [GasBasics]
    type = ElectronTransportCoefficients
    interp_trans_coeffs = false # True means variable electron coeff, defined by user
    ramp_trans_coeffs = false # Leave as false, unless computational error is due to rapid coeff. changes
    electrons = em
    electron_energy = energy_density
    p_gas = ${pressure} # User define pressure in pa
    pressure_dependent_electron_coeff = true # True if pressure dependent coeff.
    user_electron_mobility = 9.66e23 # User defined constant electron mobility
    user_electron_diffusion_coeff = 3.86e24 # User defined constant electron diffusion coefficient
    # ####
    # Name of text file with electron properties
    property_tables_file = rate_coefficients/electron_moments.txt
    # ####
  []

  # The material properties of the ion
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = ions
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    heavy_species_p = ${pressure}
  []

  # The material properties of the background gas
  [gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  []


  # Declaring the transport properties of the quasi-neutral plasma density
  [gas_species_42]
    type = ADParsedMaterial
    property_name = diffn
    material_property_names = 'diffem muem diffions muions'
    expression = '(muions*diffem + muem*diffions)/(muions + muem)'
  []

  [field_solver]
    type = FieldSolverMaterial
    solve = electromagnetic
    electric_field = electric_field
  []
[]

# This block defines several postprocessing calculations (such as point values, volume/side integrated values, and error types).
[Postprocessors]
  # Returns the electron temperature value at the center of the mesh
  [ElectronTemp_center]
    type = PointValue
    variable = e_temp
    point = '${fparse ${plasma_length}/2} 0 0'
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
  line_search = NONE

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  petsc_options_value = 'lu superlu_dist NONZERO 1.e-10 1e-3'

  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-12
  l_max_its = 20
[]

# This block defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]

[ICs]
  [em_ic]
    type = FunctionIC
    variable = n
    function = density_ic_func
  []

  [energy_density_ic]
    type = FunctionIC
    variable = energy_density
    function = energy_density_ic_func
  []
[]

[Functions]
  [density_ic_func]
    type = ParsedFunction
    expression = 'log((1e13 + 1e15 * (1-x/${plasma_length})^2 * (x/${plasma_length})^2)/6.022e23)'
  []
  [energy_density_ic_func]
    type = ParsedFunction
    expression = 'log(3./2.) + log((1e13 + 1e15 * (1-x/${plasma_length})^2 * (x/${plasma_length})^2)/6.022e23)'
  []
[]
