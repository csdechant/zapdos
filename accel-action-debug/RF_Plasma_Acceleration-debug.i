dom0Scale=25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
  [./geo]
    type = FileMeshGenerator
    file = 'RF_Plasma_NoActions_Acceleration_IC_out.e'
    use_for_exodus_restart = true
  [../]
  [./left]
    type = SideSetsFromNormalsGenerator
    normals = '-1 0 0'
    new_boundary = 'left'
    input = geo
  [../]
  [./right]
    type = SideSetsFromNormalsGenerator
    normals = '1 0 0'
    new_boundary = 'right'
    input = left
  [../]
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
    initial_from_file_var = em
  [../]

  [./Ar+]
    initial_from_file_var = Ar+
  [../]

  [./Ar*]
    initial_from_file_var = Ar*
  [../]

  [./mean_en]
    initial_from_file_var = mean_en
  [../]

  [./potential]
    initial_from_file_var = potential
  [../]

  [./SM_Ar*]
    initial_from_file_var = SM_Ar*
  [../]
[]


[DriftDiffusionAction]
  [./Plasma]
    electrons = em
    charged_particle = Ar+
    Neutrals = Ar*
    mean_energy = mean_en
    potential = potential
    Is_potential_unique = true
    using_offset = false
    position_units = ${dom0Scale}
    Additional_Outputs = 'ElectronTemperature'
  [../]
[]

[Reactions]
  [./Argon]
    species = 'Ar* em Ar+'
    aux_species = 'Ar'
    reaction_coefficient_format = 'rate'
    gas_species = 'Ar'
    electron_energy = 'mean_en'
    electron_density = 'em'
    include_electrons = true
    file_location = 'rate_coefficients'
    potential = 'potential'
    use_log = true
    use_ad = true
    position_units = ${dom0Scale}
    block = 0
    interpolation_type = 'linear'
    reactions = 'em + Ar -> em + Ar*        : EEDF [-11.56] (reaction1.txt)
                 em + Ar -> em + em + Ar+   : EEDF [-15.7] (reaction2.txt)
                 em + Ar* -> em + Ar        : EEDF [11.56] (reaction3.txt)
                 em + Ar* -> em + em + Ar+  : EEDF [-4.14] (reaction4.txt)
                 em + Ar* -> em + Ar_r      : 1.2044e11
                 Ar* + Ar* -> Ar+ + Ar + em : 373364000
                 Ar* + Ar -> Ar + Ar        : 1806.6
                 Ar* + Ar + Ar -> Ar_2 + Ar : 39890.9324'
  [../]
[]

[ShootingAcceleration]
  [./Metastable]
    accel_species = 'Ar*'
    species = 'Ar* em Ar+'
    aux_species = 'Ar'
    reaction_coefficient_format = 'rate'
    gas_species = 'Ar'
    electron_energy = 'mean_en'
    electron_density = 'em'
    include_electrons = true
    file_location = 'rate_coefficients'
    potential = 'potential'
    use_log = true
    use_ad = true
    position_units = ${dom0Scale}
    block = 0
    interpolation_type = 'linear'
    reactions = 'em + Ar -> em + Ar*        : EEDF [-11.56] (reaction1.txt)
                 em + Ar -> em + em + Ar+   : EEDF [-15.7] (reaction2.txt)
                 em + Ar* -> em + Ar        : EEDF [11.56] (reaction3.txt)
                 em + Ar* -> em + em + Ar+  : EEDF [-4.14] (reaction4.txt)
                 em + Ar* -> em + Ar_r      : 1.2044e11
                 Ar* + Ar* -> Ar+ + Ar + em : 373364000
                 Ar* + Ar -> Ar + Ar        : 1806.6
                 Ar* + Ar + Ar -> Ar_2 + Ar : 39890.9324'
  [../]
[]

[Kernels]
#Electron Energy Equations
  #The correction for electrons energy's diffusion term
  [./mean_en_diffusion_correction]
    type = ThermalConductivityDiffusion
    variable = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
[]

#Variables for scaled nodes and background gas
[AuxVariables]
  [./x_node]
  [../]

  [./Ar]
  [../]
[]

#Kernels that define the scaled nodes and background gas
[AuxKernels]
  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./Ar_val]
    type = FunctionAux
    variable = Ar
    # value = 3.22e22
    function = 'log(3.22e22/6.02e23)'
    execute_on = INITIAL
  [../]
[]

[BCs]
#Voltage Boundary Condition
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left'
    function = potential_bc_func
    preset = false
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 0
    preset = false
  [../]

#Boundary conditions for electons
  [./em_physical_right]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'right'
    gamma = 0.01
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'left'
    gamma = 0.01
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]

#Boundary conditions for ions
  [./Ar+_physical_right_advection]
    type = LymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'right'
    position_units = ${dom0Scale}
  [../]
  [./Ar+_physical_left_advection]
    type = LymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'left'
    position_units = ${dom0Scale}
  [../]

#Boundary conditions for mean energy
  [./mean_en_physical_right]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'right'
  [../]
  [./mean_en_physical_left]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'left'
  [../]

  #Boundary conditions for ions
  [./Ar*_physical_right_diffusion]
    type = ADDirichletBC
    variable = Ar*
    boundary = 'right'
    value = -50.0
  [../]
  [./Ar*_physical_left_diffusion]
    type = ADDirichletBC
    variable = Ar*
    boundary = 'left'
    value = -50.0
  [../]
[]

#Functions for IC and Potential BC
[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    value = '0.100*sin(2*pi*13.56e6*t)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/(1.0))^2 * (x/(1.0))^2)/6.02e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e13 + 1e15 * (1-x/(1.0))^2 * (x/(1.0))^2)/6.02e23)'
  [../]
[]

#Material properties of species and background gas
[Materials]
  [./GasBasics]
    #If elecron mobility and diffusion are NOT constant, set
    #"interp_elastic_coeff = true". This lets the mobility and
    #diffusivity to be energy dependent, as dictated by the txt file
    type = GasElectronMoments
    em = em
    mean_en = mean_en
    interp_elastic_coeff = false
    interp_trans_coeffs = false
    ramp_trans_coeffs = false
    user_p_gas = 133.33
    user_T_gas = 300
    user_electron_mobility = 30.0
    user_electron_diffusion_coeff = 119.8757763975
    property_tables_file = Argon_reactions_RateCoefficients/electron_moments.txt
  [../]
  [./gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.144409938
    diffusivity = 6.428571e-3
  [../]
  [./gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
  [./gas_species_1]
    type = ADHeavySpecies
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    diffusivity = 7.515528e-3
  [../]
[]


[Transfers]
  [./Ar*Relative_Diff]
    type = MultiAppPostprocessorTransfer
    direction = from_multiapp
    multi_app = Shooting
    from_postprocessor = Meta_Relative_Diff
    to_postprocessor = Meta_Relative_Diff
    reduction_type = minimum
    enable = false
  [../]
[]

#The Action the add the TimePeriod Controls to turn off and on the MultiApps
[PeriodicControllers]
  [./Shooting]
    Enable_at_cycle_start = '*::Ar*S_for_Shooting'

    Enable_during_cycle = '*::SM_Ar*_time_deriv *::SM_Ar*_diffusion *::SM_kernel_eedf_030_
                           *::SM_kernel_eedf_020_ *::SM_kernel_noneedf_04_0_ *::SM_kernel_noneedf_05_0_
                           *::SM_kernel_noneedf_06_0_ *::SM_kernel_noneedf_07_0_'

    Enable_at_cycle_end = '*::Shooting
                           *::SM_Ar*Reset_to_Shooting *::Ar*_to_Shooting
                           *::Ar*S_to_Shooting *::Ar*T_to_Shooting
                           *::SM_Ar*_to_Shooting *::Ar*_from_Shooting
                           *::SM_Ar*Reset_from_Shooting *::Ar*Relative_Diff'
    cycle_frequency = 13.56e6
    #starting_cycle = 25
    #cycles_between_controls = 25
    starting_cycle = 50
    cycles_between_controls = 50
    cycles_per_controls = 1
    num_controller_set = 2
    name = Shooting
  [../]
[]

[Postprocessors]
  #Hold the metastable relative difference during the
  #Shooting Method acceleration
  [./Meta_Relative_Diff]
    type = Receiver
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  start_time = 3.6873e-6
  end_time = 3.798e-6

  solve_type = NEWTON
  line_search = none
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  scheme = newmark-beta
  dt = 1e-9
  dtmin = 1e-14
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
    #execute_on = 'FINAL'
  [../]
[]
