# This tutorial is

# Global variables can be defined at the top of input files using 'Brace Expressions'
# The two most common functions of 'Brace Expressions' is:
#      - 'units' for unit conversions, and
#      - 'fparse' for function expressions
# Below at the constant variable used through this tutorial.

# plasma_length = '${units 0.5 in -> m}'
# plasma_length = '${units 0.0254 m}'
plasma_length = '${units 0.001 m}'

pressure_og = '${units 133.322 pa}' # 1 Torr
pressure = '${fparse pressure_og}'
background_gas_density = '${units ${fparse pressure/(300 * 1.38e-23)} 1/m^3}'

start_time_s = '${fparse 0 * 7.37e-5}'
end_time_s = '${fparse start_time_s + 7.37e-5}'

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
# [Mesh]
#   [geo]
#     type = FileMeshGenerator
#     file = 'RF_Plasma_Testing_0dot1Torr_out.e'
#     use_for_exodus_restart = true
#   []
#
#   [left]
#     type = SideSetsFromNormalsGenerator
#     normals = '-1 0 0'
#     new_boundary = 'left'
#     input = geo
#   []
#   [right]
#     type = SideSetsFromNormalsGenerator
#     normals = '1 0 0'
#     new_boundary = 'right'
#     input = left
#   []
# []
# This block is generation a mesh and labeling the mesh boundaries
[Mesh]
  #Sets up a 1-D mesh
  [left]
    type = GeneratedMeshGenerator
    xmin = 0
    xmax = '${fparse ${plasma_length}/2}'
    nx = 500
    bias_x = 1.01
    dim = 1
  []
  [left_wall]
    type = SideSetsFromNormalsGenerator
    input = left
    normals = '-1 0 0'
    new_boundary = 'left_wall'
  []
  [left_center]
    type = SideSetsFromNormalsGenerator
    input = left_wall
    normals = '1 0 0'
    new_boundary = 'left_center'
  []
  [right]
    type = GeneratedMeshGenerator
    xmin = '${fparse ${plasma_length}/2}'
    xmax = '${plasma_length}'
    nx = 500
    bias_x = 0.99
    dim = 1
  []
  [right_center]
    type = SideSetsFromNormalsGenerator
    input = right
    normals = '-1 0 0'
    new_boundary = 'right_center'
  []
  [right_wall]
    type = SideSetsFromNormalsGenerator
    input = right_center
    normals = '1 0 0'
    new_boundary = 'right_wall'
  []
  [smg]
    type = StitchMeshGenerator
    inputs = 'left_center right_wall'
    stitch_boundaries_pairs = 'left_center right_center'
  []
[]

# This block defines the problem type (such as FE, eigenvalue problem, etc.)
[Problem]
  type = FEProblem
[]

[Variables]
  [mean_en]
    # initial_from_file_var = mean_en
  []
  [potential]
    # initial_from_file_var = potential
  []
  [ions]
    # initial_from_file_var = ions
  []
  [em]
    # initial_from_file_var = em
  []
[]

[ICs]
  [em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  []
  [ions_ic]
    type = FunctionIC
    variable = ions
    function = density_ic_func
  []
  [mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  []
  # [potential_ic]
  #   type = FunctionIC
  #   variable = potential
  #   function = potential_ic_func
  # []
[]

[DriftDiffusionAction]
  [Plasma]
    #User define name for electrons (usually 'em')
    electrons = em
    #User define name for ions
    ions = ions
    #User define name for potential (usually 'potential')
    field = potential
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    is_field_unique = true
    #User define name for the electron mean energy density (usually 'mean_en')
    electron_energy = mean_en
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    additional_outputs = 'ElectronTemperature'
  []
[]

[Reactions]
  [Argon]
    #Name of reactant species that are variables
    species = 'em ions'
    #Name of reactant species that are auxvariables
    aux_species = 'Ar'
    #Type of coefficient (rate or townsend)
    reaction_coefficient_format = 'rate'
    #Name of background gas
    gas_species = 'Ar'
    #Name of the electron mean energy density (usually 'mean_en')
    electron_energy = 'mean_en'
    #Name of the electrons (usually 'em')
    electron_density = 'em'
    #Defines if electrons are tracked
    include_electrons = true
    #Defines directory holding rate text files
    file_location = 'rate_coefficients'
    #Name of name for potential (usually 'potential')
    potential = 'potential'
    #Defines if log form is used (true for Zapdos)
    use_log = true
    #Defines if automatic differentiation is used (true for Zapdos)
    use_ad = true
    #Name of material block ('0' for an user undefined block)
    block = 0
    #Inputs of the plasma chemsity
    #e.g. Reaction : Constant or EEDF dependent [Threshold Energy] (Text file name)
    #     em + Ar -> em + Ar*        : EEDF [-11.56] (reaction1)
    equation_variables = 'e_temp'
    reactions = 'em + Ar -> em + Ar         : {2.336e-14 * e_temp^1.609 * exp(0.0618 * log(e_temp)^2 - 0.1171 * log(e_temp)^3) * 6.022e23} [elastic]
                 em + Ar -> em + em + ions   : {2.34e-14 * e_temp^0.59 * exp(-17.44/e_temp) * 6.022e23} [-15.76]
                 em + Ar -> em + Ar*        : {2.48e-14 * e_temp^0.33 * exp(-12.78/e_temp) * 6.022e23} [-12.14]'
  []
[]

[AuxVariables]
  #Background gas (e.g Ar)
  [Ar]
  []

  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxKernels]
  #Background gas number density (e.g. for 1Torr)
  [Ar_val]
    type = FunctionAux
    variable = Ar
    function = 'log(${background_gas_density}/6.022e23)'
    execute_on = INITIAL
  []
[]

#Define function used throughout the input file (e.g. BCs)
[Functions]
  [potential_bc_func]
    type = ParsedFunction
    expression = '1000*sin(2*pi*13.56e6*t)'
  []

  # [potential_ic_func]
  #   type = ParsedFunction
  #   expression = '100 * (25.4e-3 - x)'
  # []
  [density_ic_func]
    type = ParsedFunction
    expression = 'log((1e13 + 1e15 * (1-x/${plasma_length})^2 * (x/${plasma_length})^2)/6.022e23)'
  []
  [energy_density_ic_func]
    type = ParsedFunction
    expression = 'log(3./2.) + log((1e13 + 1e15 * (1-x/${plasma_length})^2 * (x/${plasma_length})^2)/6.022e23)'
  []
[]

#Currently there is no Action for BC (but one is currently in development)
#Below is the Sakiyama family of BC
#(For other BC example, please look at Tutorial 05 and Tutorial 06)
[BCs]
  #Voltage Boundary Condition
  [potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left_wall'
    function = potential_bc_func
    preset = false
  []
  [potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right_wall'
    value = 0
    preset = false
  []

  #Boundary conditions for electons
  [em_physical_right]
    # type = LymberopoulosElectronBC
    variable = em
    boundary = 'right_wall left_wall'
    # emission_coeffs = 0.0
    # ks = 1.19e5
    # ions = ions
    electron_energy = mean_en
  []

  #Boundary conditions for ions
  [ions_physical_right_advection]
    # type = LymberopoulosIonBC
    type = SakiyamaIonAdvectionBC
    variable = ions
    boundary = 'right_wall left_wall'
  []

  #Boundary conditions for mean energy
  [mean_en_physical_right]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    electrons = em
    value = 0.5
    boundary = 'right_wall left_wall'
  []
[]

[Materials]
  #The material properties for electrons.
  #Also hold universal constant, such as Avogadro's number, elementary charge, etc.
  [GasBasics]
    type = ElectronTransportCoefficients
    interp_trans_coeffs = false # False means constant electron coeff, defined by user
    ramp_trans_coeffs = false # Leave as false, unless computational error is due to rapid coeff. changes
    p_gas = ${pressure} # User define pressure in pa
    electrons = em # Name for electrons (usually 'em')
    electron_energy = mean_en # Name for the electron mean energy density (usually 'mean_en')
    pressure_dependent_electron_coeff = true
    user_electron_mobility = 9.66e23 # User define electron mobility coeff. (define as 0.0 if not used)
    user_electron_diffusion_coeff = 3.86e24 # User define electron diffusion coeff. (define as 0.0 if not used)
    property_tables_file = rate_coefficients/electron_moments.txt # Name of text file with electron properties
  []
  # The dielectric coefficient of the gas (defaulted to the permittivity of free space)
  [gas_permittivity]
    type = ElectrostaticPermittivity
    potential = potential
  []
  #The material properties of the ion
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = ions
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.144409938
    diffusivity = 6.428571e-3
  []
  [gas_species_2]
    #The material properties of the background gas
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    heavy_species_p = ${pressure}
  []
[]

[Postprocessors]
  [Volume]
    type = VolumePostprocessor
  []
  [Area]
    type = AreaPostprocessor
    boundary = 'left right'
  []

  [ElectronTemp_center]
    type = PointValue
    variable = e_temp
    point = '${fparse ${plasma_length}/2} 0 0'
  []
[]

#Preconditioning options
#Learn more at: https://mooseframework.inl.gov/syntax/Preconditioning/index.html
[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

#How to execute the problem.
#Defines type of solve (such as steady or transient),
# solve type (Newton, PJFNK, etc.) and tolerances
[Executioner]
  type = Transient
  start_time = ${start_time_s}
  end_time = ${end_time_s}
  dt = 1e-9
  dtmin = 1e-14

  scheme = NEWMARK-BETA
  solve_type = NEWTON
  line_search = NONE

  automatic_scaling = true
  compute_scaling_once = false

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-snes_type -pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  petsc_options_value = 'vinewtonrsls lu NONZERO 1.e-10 1e-3'

  l_max_its = 20
[]

#Defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]

[Bounds]
  [energy_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = mean_en
    bound_type = lower
    bound_value = -50
  []
[]
