#This tutorial is of an argon CCP discharge running at
#different pressures. In this case, the electron and ion coefficient are
#linearly proportional. For the following pressures,
#(0.05, 0.1, 1, 10, 100 Torr)
#change the following lines (144, 245, and 257-258).

#A uniform scaling factor of the mesh.
#E.g if set to 1.0, there is not scaling
# and if set to 0.010, there mesh is scaled by a cm
dom0Scale = 1.0

# plasma_length = '${units 0.0254 m}'
plasma_length = '${units 0.04 m}'

pressure_og = '${units 133.322 pa}' # 1 Torr
pressure = '${fparse 10.0 * pressure_og}'
background_gas_density = '${units ${fparse pressure/(300 * 1.38e-23)} 1/m^3}'

[GlobalParams]
  #Scales the potential by V or kV
  potential_units = kV
  #Converts density from #/m^3 to moles/m^3
  use_moles = true
[]

[Mesh]
  #Mesh is defined by a previous output file
  [geo]
    type = FileMeshGenerator
    # file = 'RF_Plasma_WithOut_Metastables_IC.e'
    file = 'Lymberopoulos_paper_modified.msh'
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

# # This block is generation a mesh and labeling the mesh boundaries
# [Mesh]
#   #Sets up a 1-D mesh
#   [left]
#     type = GeneratedMeshGenerator
#     xmin = 0
#     xmax = '${fparse ${plasma_length}/2}'
#     nx = 50
#     bias_x = 1.05
#     dim = 1
#   []
#   [left_wall]
#     type = SideSetsFromNormalsGenerator
#     input = left
#     normals = '-1 0 0'
#     new_boundary = 'left_wall'
#   []
#   [left_center]
#     type = SideSetsFromNormalsGenerator
#     input = left_wall
#     normals = '1 0 0'
#     new_boundary = 'left_center'
#   []
#   [right]
#     type = GeneratedMeshGenerator
#     xmin = '${fparse ${plasma_length}/2}'
#     xmax = '${plasma_length}'
#     nx = 50
#     bias_x = 0.95
#     dim = 1
#   []
#   [right_center]
#     type = SideSetsFromNormalsGenerator
#     input = right
#     normals = '-1 0 0'
#     new_boundary = 'right_center'
#   []
#   [right_wall]
#     type = SideSetsFromNormalsGenerator
#     input = right_center
#     normals = '1 0 0'
#     new_boundary = 'right_wall'
#   []
#   [smg]
#     type = StitchMeshGenerator
#     inputs = 'left_center right_wall'
#     stitch_boundaries_pairs = 'left_center right_center'
#   []
# []

#Defines the problem type, such as FE, eigen value problem, etc.
[Problem]
  type = FEProblem
[]

#Defining IC from previous output file
# (The ICs block is not used in this case)
[Variables]
  [em]
    # initial_from_file_var = em
  []
  [potential]
    # initial_from_file_var = potential
  []
  [Ar+]
    # initial_from_file_var = Ar+
  []
  [mean_en]
    # initial_from_file_var = mean_en
  []
[]

[ICs]
  [em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  []
  [Ar+_ic]
    type = FunctionIC
    variable = Ar+
    function = density_ic_func
  []

  [mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  []

  [potential_ic]
    type = FunctionIC
    variable = potential
    function = potential_ic_func
  []
[]

[DriftDiffusionAction]
  [Plasma]
    #User define name for electrons (usually 'em')
    electrons = em
    #User define name for ions
    ions = Ar+
    #User define name for potential (usually 'potential')
    field = potential
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    is_field_unique = true
    #User define name for the electron mean energy density (usually 'mean_en')
    electron_energy = mean_en
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    additional_outputs = 'ElectronTemperature Current EField'
  []
[]

[Reactions]
  [Argon]
    #Name of reactant species that are variables
    species = 'em Ar+'
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
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Name of material block ('0' for an user undefined block)
    block = 0
    #Inputs of the plasma chemsity
    #e.g. Reaction : Constant or EEDF dependent [Threshold Energy] (Text file name)
    #     em + Ar -> em + Ar*        : EEDF [-11.56] (reaction1)
    # reactions = 'em + Ar -> em + Ar*        : EEDF [-11.56] (reaction1)
    #              em + Ar -> em + em + Ar+   : EEDF [-15.7] (reaction2)'
    equation_variables = 'e_temp'
    reactions = 'em + Ar -> em + em + Ar+   : {2.34e-14 * e_temp^0.59 * exp(-17.44/e_temp) * 6.022e23} [-15.76]
                 em + Ar -> em + Ar*        : {2.48e-14 * e_temp^0.33 * exp(-12.78/e_temp) * 6.022e23} [-12.14]'
    # reactions = 'em + Ar -> em + em + Ar+   : {2.34e-14 * e_temp^0.59 * exp(-17.44/e_temp) * 6.022e23} [-15.76]'
  []
[]

[AuxVariables]
  #Add a scaled position units used for plotting other element AuxVariables
  [x]
    order = CONSTANT
    family = MONOMIAL
  []

  #Background gas (e.g Ar)
  [Ar]
  []
[]

[AuxKernels]
  #Add at scaled position units used for plotting other element AuxVariables
  [x_ng]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  []

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
    expression = '0.100*sin(2*3.1415926*13.56e6*t)'
  []

  [potential_ic_func]
    type = ParsedFunction
    # expression = '0.100 * (25.4e-3 - x)'
    expression = '0.100 * (${plasma_length} - x)'
  []
  [density_ic_func]
    type = ParsedFunction
    # expression = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
    expression = 'log((1e13 + 1e15 * (1-x/${plasma_length})^2 * (x/${plasma_length})^2)/6.022e23)'
  []
  [energy_density_ic_func]
    type = ParsedFunction
    # expression = 'log(3./2.) + log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
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
    boundary = 'left'
    function = potential_bc_func
    preset = false
  []
  [potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 0
    preset = false
  []

  #Boundary conditions for electons
  [em_physical_diffusion]
    type = SakiyamaElectronDiffusionBC
    variable = em
    electron_energy = mean_en
    boundary = 'left right'
    position_units = ${dom0Scale}
  []
  # [em_Ar+_second_emissions]
  #   type = SakiyamaSecondaryElectronBC
  #   variable = em
  #   ions = Ar+
  #   emission_coeffs = 0.01
  #   boundary = 'left right'
  #   position_units = ${dom0Scale}
  # []

  #Boundary conditions for ions
  [Ar+_physical_advection]
    type = SakiyamaIonAdvectionBC
    variable = Ar+
    boundary = 'left right'
    position_units = ${dom0Scale}
  []

  #New Boundary conditions for mean energy, should be the same as in paper
  [mean_en_physical_diffusion]
    type = SakiyamaEnergyDiffusionBC
    variable = mean_en
    electrons = em
    boundary = 'left right'
    position_units = ${dom0Scale}
  []
  # [mean_en_Ar+_second_emissions]
  #   type = SakiyamaEnergySecondaryElectronBC
  #   variable = mean_en
  #   electrons = em
  #   ions = Ar+
  #   secondary_electron_temperature_equal_to_bulk = false
  #   secondary_electron_energy = 1
  #   emission_coeffs = 0.01
  #   boundary = 'left right'
  #   position_units = ${dom0Scale}
  # []
[]

[Materials]
  #The material properties for electrons.
  #Also hold universal constant, such as Avogadro's number, elementary charge, etc.
  [GasBasics]
    type = ElectronTransportCoefficients
    #True means variable electron coeff, defined by user
    interp_trans_coeffs = false
    #Leave as false, unless computational error is due to rapid coeff. changes
    ramp_trans_coeffs = false
    #Name for electrons (usually 'em')
    electrons = em
    #Name for the electron mean energy density (usually 'mean_en')
    electron_energy = mean_en
    #User difine pressure in pa
    p_gas = ${pressure}
    #True if pressure dependent coeff.
    pressure_dependent_electron_coeff = true
    #Name of text file with electron properties
    property_tables_file = rate_coefficients/electron_moments.txt
    ####
    user_electron_mobility = 9.66e23
    user_electron_diffusion_coeff = 3.86e24
  []
  # The dielectric coefficient of the gas (defaulted to the permittivity of free space)
  [gas_permittivity]
    type = ElectrostaticPermittivity
    potential = potential
  []
  #The material properties of the ion
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    heavy_species_p = ${pressure}
  []
  [gas_species_2]
    #The material properties of the background gas
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  []
[]

[Postprocessors]
  [ElectronTemp_center]
    type = PointValue
    variable = e_temp
    point = '${fparse ${plasma_length}/2} 0 0'
  []
[]

#Preconditioning options
#Learn more at: https://mooseframework.inl.gov/syntax/Preconditioning/index.html
[Preconditioning]
  active = 'smp'
  [smp]
    type = SMP
    full = true
  []

  [fdp]
    type = FDP
    full = true
  []
[]

#How to execute the problem.
#Defines type of solve (such as steady or transient),
# solve type (Newton, PJFNK, etc.) and tolerances
[Executioner]
  type = Transient
  end_time = 7.3746e-5
  # start_time = 7.3746e-5
  # end_time = 9.3746e-5
  dt = 1e-9
  dtmin = 1e-14

  scheme = NEWMARK-BETA
  line_search = NONE
  solve_type = NEWTON

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 1e-3'

  nl_rel_tol = 1e-08
  nl_abs_tol = 1e-10
  l_max_its = 20
[]

#Defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]
