#dom0Scale=25.4e-3
dom0Scale=1.0

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'GEC_mesh_NoScale_Coarse_Structured.msh'
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [./potential_ion]
  [../]

  [./SMDeriv]
    initial_condition = 1.0
  [../]
[]

[DriftDiffusionAction]
  [./Plasma]
    electrons = em
    secondary_charged_particles = Ar+
    Neutrals = Ar*
    mean_energy = mean_en
    potential = potential
    eff_potentials = potential_ion
    Is_potential_unique = true
    using_offset = false
    position_units = ${dom0Scale}
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
    file_location = 'Argon_reactions_paper_RateCoefficients'
    potential = 'potential'
    use_log = true
    position_units = ${dom0Scale}
    block = 'plasma'
    reactions = 'em + Ar -> em + Ar         : EEDF [elastic]
                 em + Ar -> em + Ar*        : EEDF [-11.56]
                 em + Ar -> em + em + Ar+   : EEDF [-15.7]
                 em + Ar* -> em + Ar        : EEDF [11.56]
                 em + Ar* -> em + em + Ar+  : EEDF [-4.14]
                 em + Ar* -> em + Ar_r      : 1.2044e11
                 Ar* + Ar* -> Ar+ + Ar + em : 373364000
                 Ar* + Ar -> Ar + Ar        : 1806.6
                 Ar* + Ar + Ar -> Ar_2 + Ar : 39890.9324'
  [../]
[]


[Kernels]
  #Effective potential for the Ions
  [./Ion_potential_time_deriv]
    type = TimeDerivative
    variable = potential_ion
  [../]
  [./Ion_potential_reaction]
    type = ScaledReaction
    variable = potential_ion
    collision_freq = 12833708.75
  [../]
  [./Ion_potential_coupled_force]
    type = CoupledForce
    variable = potential_ion
    v = potential
    coef = 12833708.75
  [../]

  ####################################################

  #Argon Excited Equations For Shooting Method
  #Time Derivative term of excited Argon
  [./SM_Ar*_time_deriv]
    type = TimeDerivative
    variable = SMDeriv
    enable = false
  [../]
  #Diffusion term of excited Argon
  [./SM_Ar*_diffusion]
    type = CoeffDiffusionForShootMethod
    variable = SMDeriv
    density = Ar*
    position_units = ${dom0Scale}
    enable = false
  [../]
  #Net excited Argon loss from superelastic collisions
  [./SM_Ar*_collisions]
    type = EEDFReactionLogForShootMethod
    variable = SMDeriv
    density = Ar*
    electron = em
    energy = mean_en
    reaction = 'em + Ar* -> em + Ar'
    number = 3
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from step-wise ionization
  [./SM_Ar*_stepwise_ionization]
    type = EEDFReactionLogForShootMethod
    variable = SMDeriv
    density = Ar*
    electron = em
    energy = mean_en
    reaction = 'em + Ar* -> em + em + Ar+'
    number = 4
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from quenching to resonant
  [./SM_Ar*_quenching]
    type = ReactionSecondOrderLogForShootMethod
    variable = SMDeriv
    density = Ar*
    v = em
    reaction = 'em + Ar* -> em + Ar_r'
    number = 5
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from  metastable pooling
  [./SM_Ar*_pooling]
    type = ReactionSecondOrderLogForShootMethod
    variable = SMDeriv
    density = Ar*
    v = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    number = 6
    coefficient = -2
    enable = false
  [../]
  #Net excited Argon loss from two-body quenching
  [./SM_Ar*_2B_quenching]
    type = ReactionSecondOrderLogForShootMethod
    variable = SMDeriv
    density = Ar*
    v = Ar
    reaction = 'Ar* + Ar -> Ar + Ar'
    number = 7
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from three-body quenching
  [./SM_Ar*_3B_quenching]
    type = ReactionThirdOrderLogForShootMethod
    variable = SMDeriv
    density = Ar*
    v = Ar
    w = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    number = 8
    coefficient = -1
    enable = false
  [../]

  [./SM_Dummy_Reaction]
    type = Reaction
    variable = SMDeriv
  [../]
  [./SM_Dummy_Force]
    type = BodyForce
    variable = SMDeriv
    value = 1.0
  [../]
[]


[AuxVariables]
  [./Ar*S]
  [../]

  [./emDeBug]
  [../]
  [./Ar+_DeBug]
  [../]
  [./Ar*_DeBug]
  [../]
  [./mean_enDeBug]
  [../]
  [./potential_DeBug]
  [../]

  [./Te]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./x_node]
  [../]

  [./y_node]
  [../]

  [./Ar]
  [../]

  [./Efieldx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Efieldy]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Current_em]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./Current_Ar]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./emRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./exRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./swRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./deexRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./quRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./poolRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./TwoBRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./ThreeBRate]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
[]

[AuxKernels]
  [./Ar*S_for_Shooting]
    type = QuotientAux
    variable = Ar*S
    numerator = Ar*
    denominator = 1.0
    enable = false
    execute_on = 'TIMESTEP_END'
  [../]

  [./emDeBug]
    type = DebugResidualAux
    variable = emDeBug
    debug_variable = em
  [../]
  [./Ar+_DeBug]
    type = DebugResidualAux
    variable = Ar+_DeBug
    debug_variable = Ar+
  [../]
  [./mean_enDeBug]
    type = DebugResidualAux
    variable = mean_enDeBug
    debug_variable = mean_en
  [../]
  [./Ar*_DeBug]
    type = DebugResidualAux
    variable = Ar*_DeBug
    debug_variable = Ar*
  [../]
  [./Potential_DeBug]
    type = DebugResidualAux
    variable = potential_DeBug
    debug_variable = potential
  [../]

  [./Te]
    type = ElectronTemperature
    variable = Te
    electron_density = em
    mean_en = mean_en
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    component = 0
    position_units = ${dom0Scale}
  [../]
  [./y_ng]
    type = Position
    variable = y_node
    component = 1
    position_units = ${dom0Scale}
  [../]

  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 3.22e22
    value = -2.928623
    execute_on = INITIAL
  [../]

  [./Efieldx_calc]
    type = Efield
    component = 0
    potential = potential
    variable = Efieldx
    position_units = ${dom0Scale}
  [../]
  [./Efieldy_calc]
    type = Efield
    component = 1
    potential = potential
    variable = Efieldy
    position_units = ${dom0Scale}
  [../]

  [./Current_em]
    type = Current
    potential = potential
    density_log = em
    variable = Current_em
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]
  [./Current_Ar]
    type = Current
    potential = potential_ion
    density_log = Ar+
    variable = Current_Ar
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]

[]


[BCs]
#Voltage Boundary Condition, same as in paper
  [./potential_top_plate]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'Top_Electrode'
    function = potential_top_bc_func
  [../]
  [./potential_bottom_plate]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'Bottom_Electrode'
    function = potential_bottom_bc_func
  [../]
  [./potential_dirichlet_bottom_plate]
    type = DirichletBC
    variable = potential
    boundary = 'Walls'
    value = 0
  [../]
  [./potential_Dielectric]
    type = EconomouDielectricBC_Rearranged
    variable = potential
    boundary = 'Top_Insulator Bottom_Insulator'
    em = em
    ip = Ar+
    potential_ion = potential_ion
    mean_en = mean_en
    dielectric_constant = 1.859382e-11
    thickness = 0.0127
    users_gamma = 0.01
    position_units = ${dom0Scale}
  [../]


#New Boundary conditions for electons, same as in paper
  [./em_physical_diffusion]
    type = SakiyamaElectronDiffusionBC
    variable = em
    mean_en = mean_en
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    position_units = ${dom0Scale}
  [../]
  [./em_Ar+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    potential = potential_ion
    ip = Ar+
    users_gamma = 0.01
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
  [./Ar+_physical_advection]
    type = SakiyamaIonAdvectionBC
    variable = Ar+
    potential = potential_ion
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
#(except the metastables are not set to zero, since Zapdos uses log form)
  [./Ar*_physical_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    value = 1e-5
  [../]

#New Boundary conditions for mean energy, should be the same as in paper
[./mean_en_physical_diffusion]
  type = SakiyamaEnergyDiffusionBC
  variable = mean_en
  em = em
  boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
  position_units = ${dom0Scale}
[../]
[./mean_en_Ar+_second_emissions]
  type = SakiyamaEnergySecondaryElectronBC
  variable = mean_en
  em = em
  ip = Ar+
  potential = potential_ion
  Tse_equal_Te = true
  se_coeff = 0.01
  boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
  position_units = ${dom0Scale}
[../]

[]


[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  [../]
  [./Ar+_ic]
    type = FunctionIC
    variable = Ar+
    function = density_ic_func
  [../]
  [./Ar*_ic]
    type = FunctionIC
    variable = Ar*
    function = meta_density_ic_func
  [../]
  [./mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  [../]

  [./potential_ic]
    type = FunctionIC
    variable = potential
    function = potential_ic_func
  [../]
[]

[Functions]
  [./potential_top_bc_func]
    type = ParsedFunction
    value = '30.0*sin(2*pi*13.56e6*t)'
  [../]
  [./potential_bottom_bc_func]
    type = ParsedFunction
    value = '-30.0*sin(2*pi*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = 0
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e14)/6.022e23)'
  [../]
  [./meta_density_ic_func]
    type = ParsedFunction
    value = 'log((1e14)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log((3./2.)) + log((1e14)/6.022e23)'
  [../]
[]

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = true
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 133.322
    em = em
    potential = potential
    mean_en = mean_en
    user_se_coeff = 0.00
    property_tables_file = Argon_reactions_paper_RateCoefficients/electron_moments.txt
  [../]
  [./gas_species_0]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.144409938
    diffusivity = 6.428571e-3
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    diffusivity = 7.515528e-3
  [../]
  [./gas_species_2]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
[]

#Acceleration Schemes are dictated by MultiApps, Transfers,
#and PeriodicControllers
[MultiApps]
  #MultiApp of Acceleration by Shooting Method
  [./Shooting]
    type = FullSolveMultiApp
    input_files = 'GEC_NoScaledCoarseMeshStructured_At1Torr_Rearranged_Actions_Shooting.i'
    execute_on = 'TIMESTEP_END'
    enable = false
  [../]
[]


[Transfers]
  #MultiApp Transfers for Acceleration by Shooting Method
  [./Ar*_to_Shooting]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = Ar*S
    variable = Ar*
    enable = false
  [../]
  [./Ar*S_to_Shooting]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = Ar*S
    variable = Ar*S
    enable = false
  [../]
  [./Ar*T_to_Shooting]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = Ar*
    variable = Ar*T
    enable = false
  [../]
  [./SMDeriv_to_Shooting]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SMDeriv
    variable = SMDeriv
    enable = false
  [../]


  [./Ar*New_from_Shooting]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = Ar*
    variable = Ar*
    enable = false
  [../]
  [./SMDerivReset_from_Shooting]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = SMDerivReset
    variable = SMDeriv
    enable = false
  [../]
[]

#The Action the add the TimePeriod Controls to turn off and on the MultiApps
[PeriodicControllers]
  [./Shooting]
    Enable_at_cycle_start = '*::Ar*S_for_Shooting'

    Enable_during_cycle = '*::SM_Ar*_time_deriv *::SM_Ar*_diffusion *::SM_Ar*_stepwise_ionization
                           *::SM_Ar*_collisions *::SM_Ar*_quenching *::SM_Ar*_pooling
                           *::SM_Ar*_2B_quenching *::SM_Ar*_3B_quenching'

    Disable_during_cycle = '*::SM_Dummy_Reaction *::SM_Dummy_Force'

    Enable_at_cycle_end = 'MultiApps::Shooting
                           Transfers::Ar*_to_Shooting *::Ar*S_to_Shooting
                           *::Ar*T_to_Shooting *::SMDeriv_to_Shooting
                           *::Ar*New_from_Shooting *::SMDerivReset_from_Shooting'
    starting_cycle = 75
    cycle_frequency = 13.56e6
    cycles_between_controls = 55
    num_controller_set = 2000
    name = Shooting
  [../]
[]

#New postprocessor that calculates the inverse of the plasma frequency
[Postprocessors]
  [./InversePlasmaFreq]
    type = PlasmaFrequencyInverse
    variable = em
    use_moles = true
    execute_on = 'INITIAL TIMESTEP_BEGIN'
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
  #end_time = 7.4e-3
  end_time = 3.6874e-5
  automatic_scaling = true
  compute_scaling_once = false
  solve_type = NEWTON
  scheme = bdf2
  dtmax = 1e-9
  dtmin = 1e-14
  line_search = none
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
