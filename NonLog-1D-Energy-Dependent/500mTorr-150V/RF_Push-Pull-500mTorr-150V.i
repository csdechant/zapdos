dom0Scale=25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
#  [./geo]
#    type = FileMeshGenerator
#    file = '../Lymberopoulos_paper.msh'
#  [../]
  [geo]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = 0
    xmax = 1
    nx = 100
  []
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

[Adaptivity]
  [./Indicators]
    [./Te_grad_Jump]
      type = GradientJumpIndicator
      variable = Te
    [../]
  [../]
  [./Markers]
    [./marker]
      type = ErrorToleranceMarker
      #coarsen = 0.0001
      indicator = Te_grad_Jump
      refine = 0.1
    [../]
    #[./box_refine]
    #  type = BoxMarker
    #  bottom_left = '0.05 0 0'
    #  top_right = '0.95 0 0'
    #  inside = DO_NOTHING
    #  outside = DONT_MARK
    #[../]
    [./combo]
      type = ComboMarker
      markers = 'marker'
    [../]
  [../]
  marker = combo
  max_h_level = 3
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
  [../]

  [./Ar+]
  [../]

  [./Ar*]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]

  [./SM_Ar*]
    initial_condition = 1.0
  [../]
[]

[Kernels]
#Electron Equations
  #Time Derivative term of electron
  [./em_time_deriv]
    type = ADTimeDerivative
    variable = em
  [../]
  #Advection term of electron
  [./em_advection]
    type = EFieldAdvectionLin
    variable = em
    potential = potential
    position_units = ${dom0Scale}
  [../]
  #Diffusion term of electrons
  [./em_diffusion]
    type = CoeffDiffusionLin
    variable = em
    position_units = ${dom0Scale}
  [../]
  #Net electron production from ionization
  [./em_ionization]
    type = ADEEDFReaction
    variable = em
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  [../]
  #Net electron production from step-wise ionization
  [./em_stepwise_ionization]
    type = ADEEDFReaction
    variable = em
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = 1
  [../]
  #Net electron production from metastable pooling
  [./em_pooling]
    type = ReactionSecondOrder
    variable = em
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = 1
  [../]

#Argon Ion Equations
  #Time Derivative term of the ions
  [./Ar+_time_deriv]
    type = ADTimeDerivative
    variable = Ar+
  [../]
  #Advection term of ions
  [./Ar+_advection]
    type = EFieldAdvectionLin
    variable = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./Ar+_diffusion]
    type = CoeffDiffusionLin
    variable = Ar+
    position_units = ${dom0Scale}
  [../]
  #Net ion production from ionization
  [./Ar+_ionization]
    type = ADEEDFReaction
    variable = Ar+
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  [../]
  #Net ion production from step-wise ionization
  [./Ar+_stepwise_ionization]
    type = ADEEDFReaction
    variable = Ar+
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = 1
  [../]
  #Net ion production from metastable pooling
  [./Ar+_pooling]
    type = ReactionSecondOrder
    variable = Ar+
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = 1
  [../]

#Argon Excited Equations
  #Time Derivative term of excited Argon
  [./Ar*_time_deriv]
    type = ADTimeDerivative
    variable = Ar*
  [../]
  #Diffusion term of excited Argon
  [./Ar*_diffusion]
    type = CoeffDiffusionLin
    variable = Ar*
    position_units = ${dom0Scale}
  [../]
  #Net excited Argon production from excitation
  [./Ar*_excitation]
    type = ADEEDFReaction
    variable = Ar*
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar*'
    coefficient = 1
  [../]
  #Net excited Argon loss from step-wise ionization
  [./Ar*_stepwise_ionization]
    type = ADEEDFReaction
    variable = Ar*
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = -1
  [../]
  #Net excited Argon loss from superelastic collisions
  [./Ar*_collisions]
    type = ADEEDFReaction
    variable = Ar*
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + Ar'
    coefficient = -1
  [../]
  #Net excited Argon loss from quenching to resonant
  [./Ar*_quenching]
    type = ReactionSecondOrder
    variable = Ar*
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + Ar_r'
    coefficient = -1
    _w_eq_u = true
  [../]
  #Net excited Argon loss from  metastable pooling
  [./Ar*_pooling]
    type = ReactionSecondOrder
    variable = Ar*
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = -2
    _v_eq_u = true
    _w_eq_u = true
  [../]
  #Net excited Argon loss from two-body quenching
  [./Ar*_2B_quenching]
    type = ReactionSecondOrder
    variable = Ar*
    v = Ar
    w = Ar*
    reaction = 'Ar* + Ar -> Ar + Ar'
    coefficient = -1
    _v_eq_u = true
  [../]
  #Net excited Argon loss from three-body quenching
  [./Ar*_3B_quenching]
    type = ReactionThirdOrder
    variable = Ar*
    v = Ar*
    w = Ar
    x = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    coefficient = -1
    _v_eq_u = true
    v_NonLog = true
  [../]

#Voltage Equations
  #Voltage term in Poissons Eqaution
  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]
  #Ion term in Poissons Equation
    [./Ar+_charge_source]
    type = ChargeSourceMoles_KVLin
    variable = potential
    charged = Ar+
  [../]
  #Electron term in Poissons Equation
  [./em_charge_source]
    type = ChargeSourceMoles_KVLin
    variable = potential
    charged = em
  [../]

#Electron Energy Equations
  #Time Derivative term of electron energy
  [./mean_en_time_deriv]
    type = ADTimeDerivative
    variable = mean_en
  [../]
  #Advection term of electron energy
  [./mean_en_advection]
    type = EFieldAdvectionLin
    variable = mean_en
    potential = potential
    position_units = ${dom0Scale}
  [../]
  #Diffusion term of electrons energy
  [./mean_en_diffusion]
    type = CoeffDiffusionLin
    variable = mean_en
    position_units = ${dom0Scale}
  [../]
  #The correction for electrons energy's diffusion term
  [./mean_en_diffusion_correction]
    type = ThermalConductivityDiffusionLin
    variable = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
  #Joule Heating term
  [./mean_en_joule_heating]
    type = JouleHeatingLin
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  #Energy loss from ionization
  [./Ionization_Loss]
    type = ADEEDFEnergy
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    threshold_energy = -15.7
  [../]
  #Energy loss from excitation
  [./Excitation_Loss]
    type = ADEEDFEnergy
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar*'
    threshold_energy = -11.56
  [../]
  #Energy loss from step-wise ionization
  [./Stepwise_Ionization_Loss]
    type = ADEEDFEnergy
    variable = mean_en
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    threshold_energy = -4.14
  [../]
  #Energy gain from superelastic collisions
  [./Collisions_Loss]
    type = ADEEDFEnergy
    variable = mean_en
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + Ar'
    threshold_energy = 11.56
  [../]
  ##Energy loss from ionization
  [./Elastic_Loss]
    type = ADEEDFElastic
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar'
  [../]

###################################################################################

#Argon Excited Equations
  #Time Derivative term of excited Argon
  [./SM_Ar*_time_deriv]
    type = MassLumpedTimeDerivative
    variable = SM_Ar*
    enable = false
  [../]
  #Diffusion term of excited Argon
  [./SM_Ar*_diffusion]
   type = CoeffDiffusionForShootMethod
   variable = SM_Ar*
   density = Ar*
   position_units = ${dom0Scale}
   enable = false
  [../]
  #Net excited Argon loss from step-wise ionization
  [./SM_Ar*_stepwise_ionization]
    type = EEDFReactionForShootMethod
    variable = SM_Ar*
    electron = em
    density = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from superelastic collisions
  [./SM_Ar*_collisions]
    type = EEDFReactionForShootMethod
    variable = SM_Ar*
    electron = em
    density = Ar*
    reaction = 'em + Ar* -> em + Ar'
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from quenching to resonant
  [./SM_Ar*_quenching]
    type = ReactionSecondOrderForShootMethod
    variable = SM_Ar*
    density = Ar*
    v = em
    reaction = 'em + Ar* -> em + Ar_r'
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from  metastable pooling
  [./SM_Ar*_pooling]
    type = ReactionSecondOrderForShootMethod
    variable = SM_Ar*
    density = Ar*
    v = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = -2
    enable = false
  [../]
  #Net excited Argon loss from two-body quenching
  [./SM_Ar*_2B_quenching]
    type = ReactionSecondOrderForShootMethod
    variable = SM_Ar*
    density = Ar*
    v = Ar
    reaction = 'Ar* + Ar -> Ar + Ar'
    coefficient = -1
    enable = false
  [../]
  #Net excited Argon loss from three-body quenching
  [./SM_Ar*_3B_quenching]
    type = ReactionThirdOrderForShootMethod
    variable = SM_Ar*
    density = Ar*
    v = Ar
    w = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    coefficient = -1
    enable = false
  [../]

  [./SM_Ar*_Null]
    type = NullKernel
    variable = SM_Ar*
  [../]
[]

#Variables for scaled nodes and background gas
[AuxVariables]
  [./SM_Ar*Reset]
    initial_condition = 1.0
  [../]
  [./Ar*S]
  [../]

  [./x_node]
  [../]

  [./Ar]
  [../]

  [./Te]
  #  order = CONSTANT
  #  family = MONOMIAL
  [../]
  [./Te_Element]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Ar+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Ar*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

#Kernels that define the scaled nodes and background gas
[AuxKernels]
  [./Ar*S_for_Shooting]
    type = QuotientAux
    variable = Ar*S
    numerator = Ar*
    denominator = 1.0
    enable = false
    execute_on = 'TIMESTEP_END'
  [../]

  [./Constant_SM_Ar*Reset]
    type = ConstantAux
    variable = SM_Ar*Reset
    value = 1.0
    execute_on = INITIAL
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./Ar_val]
    type = FunctionAux
    variable = Ar
    # value = 3.22e22
    function = '(1.61e22/6.02e23)'
    execute_on = INITIAL
  [../]

  [./Te]
    type = ElectronTemperatureLin
    variable = Te
    electron_density = em
    mean_en = mean_en
  [../]

  [./Te_Element]
    type = ElectronTemperatureLin
    variable = Te_Element
    electron_density = em
    mean_en = mean_en
  [../]

  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  [../]

  [./em_lin]
    type = DensityMolesLin
    variable = em_lin
    density = em
  [../]
  [./Ar+_lin]
    type = DensityMolesLin
    variable = Ar+_lin
    density = Ar+
  [../]
  [./Ar*_lin]
    type = DensityMolesLin
    variable = Ar*_lin
    density = Ar*
  [../]
[]

[BCs]
#Voltage Boundary Condition
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left'
    function = potential_top_bc_func
    preset = false
  [../]
  [./potential_dirichlet_right]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'right'
    function = potential_bottom_bc_func
    preset = false
  [../]

#Boundary conditions for electons
  #[./em_physical_right]
  #  type = LymberopoulosElectronBC
  #  variable = em
  #  boundary = 'right left'
  #  gamma = 0.01
  #  ks = 1.19e5
  #  ion = Ar+
  #  potential = potential
  #  position_units = ${dom0Scale}
  #[../]
  [./em_physical_diffusion]
    type = SakiyamaElectronDiffusionBCLin
    variable = em
    mean_en = mean_en
    boundary = 'right left'
    position_units = ${dom0Scale}
  [../]
  [./em_Ar+_second_emissions]
    type = SakiyamaSecondaryElectronBCLin
    variable = em
    mean_en = mean_en
    potential = potential
    ip = Ar+
    users_gamma = 0.01
    boundary = 'right left'
    position_units = ${dom0Scale}
  [../]


#Boundary conditions for ions
  #[./Ar+_physical_right_advection]
  #  type = LymberopoulosIonBC
  #  variable = Ar+
  #  potential = potential
  #  boundary = 'right left'
  #  position_units = ${dom0Scale}
  #[../]
  [./Ar+_physical_advection]
    type = SakiyamaIonAdvectionBCLin
    variable = Ar+
    potential = potential
    boundary = 'right left'
    position_units = ${dom0Scale}
  [../]


#Boundary conditions for mean energy
  #[./mean_en_physical_right]
  #  #type = ElectronTemperatureDirichletBC
  #  type = ElectronTemperatureDirichletBC_Flux
  #  variable = mean_en
  #  em = em
  #  value = 0.5
  #  boundary = 'right left'
  #[../]
  [./mean_en_physical_diffusion]
    type = SakiyamaEnergyDiffusionBCLin
    variable = mean_en
    em = em
    boundary = 'right left'
    position_units = ${dom0Scale}
  [../]
  [./mean_en_Ar+_second_emissions]
    type = SakiyamaEnergySecondaryElectronBCLin
    variable = mean_en
    em = em
    ip = Ar+
    potential = potential
    Tse_equal_Te = false
    user_se_energy = 0.75
    se_coeff = 0.01
    boundary = 'right left'
    position_units = ${dom0Scale}
  [../]


  #Boundary conditions for ions
  [./Ar*_physical_right_diffusion]
    type = ADDirichletBC
    variable = Ar*
    boundary = 'right'
    value = 0.0
  [../]
  [./Ar*_physical_left_diffusion]
    type = ADDirichletBC
    variable = Ar*
    boundary = 'left'
    value = 0.0
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
    function = density_ic_func
  [../]
  [./mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  [../]
[]

#Functions for IC and Potential BC
[Functions]
  [./potential_top_bc_func]
    type = ParsedFunction
    value = '0.150*sin(2*pi*13.56e6*t)'
  [../]
  [./potential_bottom_bc_func]
    type = ParsedFunction
    value = '-0.150*sin(2*pi*13.56e6*t)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = '(1e13 + 1e15 * (1-x/(1.0))^2 * (x/(1.0))^2)/6.02e23'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = '(3./2.) * ((1e13 + 1e15 * (1-x/(1.0))^2 * (x/(1.0))^2)/6.02e23)'
  [../]
[]

#Material properties of species and background gas
[Materials]
  [./GasBasics]
    #If elecron mobility and diffusion are NOT constant, set
    #"interp_elastic_coeff = true". This lets the mobility and
    #diffusivity to be energy dependent, as dictated by the txt file
    type = GasElectronMomentsLinearLin
    em = em
    mean_en = mean_en
    interp_trans_coeffs = true
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 66.665
    user_T_gas = 300
    pressure_dependent_electron_coeff = true
    property_tables_file = '../Argon_reactions/electron_moments.txt'
  [../]
  [./gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 2.888e-01
    diffusivity = 1.286e-02
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
    diffusivity = 1.503e-02
  [../]
  [./reaction_00]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Argon_reactions/reaction_em + Ar -> em + Ar.txt'
    reaction = 'em + Ar -> em + Ar'
    file_location = ''
    electrons = em
  [../]
  [./reaction_0]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Argon_reactions/reaction_em + Ar -> em + Ar*.txt'
    reaction = 'em + Ar -> em + Ar*'
    file_location = ''
    electrons = em
  [../]
  [./reaction_1]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Argon_reactions/reaction_em + Ar -> em + em + Ar+.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    file_location = ''
    electrons = em
  [../]
  [./reaction_2]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Argon_reactions/reaction_em + Ar* -> em + Ar.txt'
    reaction = 'em + Ar* -> em + Ar'
    file_location = ''
    electrons = em
  [../]
  [./reaction_3]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Argon_reactions/reaction_em + Ar* -> em + em + Ar+.txt'
    reaction = 'em + Ar* -> em + em + Ar+'
    file_location = ''
    electrons = em
  [../]
  [./reaction_4]
    type = GenericRateConstant
    reaction = 'em + Ar* -> em + Ar_r'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 1.2044e11
  [../]
  [./reaction_5]
    type = GenericRateConstant
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    #reaction_rate_value = 6.2e-16
    reaction_rate_value = 373364000
  [../]
  [./reaction_6]
    type = GenericRateConstant
    reaction = 'Ar* + Ar -> Ar + Ar'
    #reaction_rate_value = 3e-21
    reaction_rate_value = 1806.6
  [../]
  [./reaction_7]
    type = GenericRateConstant
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    #reaction_rate_value = 1.1e-43
    reaction_rate_value = 39890.9324
  [../]
[]

#Acceleration Schemes are dictated by MultiApps, Transfers,
#and PeriodicControllers
[MultiApps]
  #MultiApp of Acceleration by Shooting Method
  [./Shooting]
    type = FullSolveMultiApp
    input_files = 'NonLog-RF_Plasma_Shooting.i'
    execute_on = 'TIMESTEP_END'
    enable = false
    #clone_master_mesh = true
  [../]
[]


[Transfers]
  #MultiApp Transfers for Acceleration by Shooting Method
  [./SM_Ar*Reset_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SM_Ar*Reset
    variable = SM_Ar*Reset
    enable = false
  [../]

  [./Ar*_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = Ar*
    variable = Ar*
    enable = false
  [../]
  [./Ar*S_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = Ar*S
    variable = Ar*S
    enable = false
  [../]
  [./Ar*T_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = Ar*
    variable = Ar*T
    enable = false
  [../]
  [./SMDeriv_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SM_Ar*
    variable = SM_Ar*
    enable = false
  [../]

  [./Ar*New_from_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = Ar*
    variable = Ar*
    enable = false
  [../]
  [./SM_Ar*Reset_from_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = SM_Ar*Reset
    variable = SM_Ar*
    enable = false
  [../]

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

    Enable_during_cycle = '*::SM_Ar*_time_deriv *::SM_Ar*_diffusion *::SM_Ar*_stepwise_ionization
                           *::SM_Ar*_collisions *::SM_Ar*_quenching *::SM_Ar*_pooling
                           *::SM_Ar*_2B_quenching *::SM_Ar*_3B_quenching'

    Enable_at_cycle_end = 'MultiApps::Shooting
                           *::SM_Ar*Reset_to_Shooting *::Ar*_to_Shooting
                           *::Ar*S_to_Shooting *::Ar*T_to_Shooting
                           *::SMDeriv_to_Shooting *::Ar*New_from_Shooting
                           *::SM_Ar*Reset_from_Shooting *::Ar*Relative_Diff'
    cycle_frequency = 13.56e6
    #starting_cycle = 25
    #cycles_between_controls = 25
    starting_cycle = 50
    cycles_between_controls = 50
    cycles_per_controls = 1
    num_controller_set = 2000
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
  end_time = 3.6873e-4 #~5000 RF cycles
  #end_time = 1e-5
  solve_type = NEWTON
  line_search = none
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_factor_mat_solver_package -pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'superlu_dist lu NONZERO 1.e-10'
  scheme = newmark-beta
  dt = 1e-9
  dtmin = 1e-14

  resid_vs_jac_scaling_param = 1.0
  automatic_scaling = true
  compute_scaling_once = false
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
