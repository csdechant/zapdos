dom0Scale=25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
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

  [./He+]
  [../]

  [./He*singlet]
  [../]
  [./He*triplet]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]

  [./SM_He*singlet]
    initial_condition = 1.0
  [../]
  [./SM_He*triplet]
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
    target = He
    reaction = 'em + He -> em + em + He+'
    coefficient = 1
  [../]

#Helium Ion Equations
  #Time Derivative term of the ions
  [./He+_time_deriv]
    type = ADTimeDerivative
    variable = He+
  [../]
  #Advection term of ions
  [./He+_advection]
    type = EFieldAdvectionLin
    variable = He+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./He+_diffusion]
    type = CoeffDiffusionLin
    variable = He+
    position_units = ${dom0Scale}
  [../]
  #Net ion production from ionization
  [./He+_ionization]
    type = ADEEDFReaction
    variable = He+
    electrons = em
    target = He
    reaction = 'em + He -> em + em + He+'
    coefficient = 1
  [../]

#Helium Singlet Excited Equations
  #Time Derivative term of excited Helium Singlet
  [./He*singlet_time_deriv]
    type = ADTimeDerivative
    variable = He*singlet
  [../]
  #Diffusion term of excited Helium Singlet
  [./He*singlet_diffusion]
    type = CoeffDiffusionLin
    variable = He*singlet
    position_units = ${dom0Scale}
  [../]
  #Net excited Helium Singlet production from excitation
  [./He*singlet_excitation]
    type = ADEEDFReaction
    variable = He*singlet
    electrons = em
    target = He
    reaction = 'em + He -> em + He*singlet'
    coefficient = 1
  [../]

#Helium Triplet Excited Equations
  #Time Derivative term of excited Helium Triplet
  [./He*triplet_time_deriv]
    type = ADTimeDerivative
    variable = He*triplet
  [../]
  #Diffusion term of excited Helium Triplet
  [./He*triplet_diffusion]
    type = CoeffDiffusionLin
    variable = He*triplet
    position_units = ${dom0Scale}
  [../]
  #Net excited Helium Triplet production from excitation
  [./He*triplet_excitation]
    type = ADEEDFReaction
    variable = He*triplet
    electrons = em
    target = He
    reaction = 'em + He -> em + He*triplet'
    coefficient = 1
  [../]

#Voltage Equations
  #Voltage term in Poissons Eqaution
  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]
  #Ion term in Poissons Equation
    [./He+_charge_source]
    type = ChargeSourceMoles_KVLin
    variable = potential
    charged = He+
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
    target = He
    reaction = 'em + He -> em + em + He+'
    threshold_energy = -24.587
  [../]
  #Energy loss from excitation
  [./Excitation_Loss_Singlet]
    type = ADEEDFEnergy
    variable = mean_en
    electrons = em
    target = He
    reaction = 'em + He -> em + He*singlet'
    threshold_energy = -20.61
  [../]
  #Energy loss from excitation
  [./Excitation_Loss_Triplet]
    type = ADEEDFEnergy
    variable = mean_en
    electrons = em
    target = He
    reaction = 'em + He -> em + He*triplet'
    threshold_energy = -19.82
  [../]
  ##Energy loss from ionization
  [./Elastic_Loss]
    type = ADEEDFElastic
    variable = mean_en
    electrons = em
    target = He
    reaction = 'em + He -> em + He'
  [../]

###################################################################################

#Helium singlet Excited Equations
  #Time Derivative term of excited Helium singlet
  [./SM_He*singlet_time_deriv]
    type = MassLumpedTimeDerivative
    variable = SM_He*singlet
    enable = false
  [../]
  #Diffusion term of excited Helium singlet
  [./SM_He*singlet_diffusion]
   type = CoeffDiffusionForShootMethod
   variable = SM_He*singlet
   density = He*singlet
   position_units = ${dom0Scale}
   enable = false
  [../]

  [./SM_He*singlet_Null]
    type = NullKernel
    variable = SM_He*singlet
  [../]

#Helium triplet Excited Equations
  #Time Derivative term of excited Helium singlet
  [./SM_He*triplet_time_deriv]
    type = MassLumpedTimeDerivative
    variable = SM_He*triplet
    enable = false
  [../]
  #Diffusion term of excited Helium singlet
  [./SM_He*triplet_diffusion]
   type = CoeffDiffusionForShootMethod
   variable = SM_He*triplet
   density = He*triplet
   position_units = ${dom0Scale}
   enable = false
  [../]

  [./SM_He*triplet_Null]
    type = NullKernel
    variable = SM_He*triplet
  [../]
[]

#Variables for scaled nodes and background gas
[AuxVariables]
  [./SM_He*singlet_Reset]
    initial_condition = 1.0
  [../]
  [./He*singlet_S]
  [../]

  [./SM_He*triplet_Reset]
    initial_condition = 1.0
  [../]
  [./He*triplet_S]
  [../]

  [./x_node]
  [../]

  [./He]
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
  [./He+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He*singlet_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He*triplet_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

#Kernels that define the scaled nodes and background gas
[AuxKernels]
  [./He*singlet_S_for_Shooting]
    type = QuotientAux
    variable = He*singlet_S
    numerator = He*singlet
    denominator = 1.0
    enable = false
    execute_on = 'TIMESTEP_END'
  [../]
  [./Constant_SM_He*singlet_Reset]
    type = ConstantAux
    variable = SM_He*singlet_Reset
    value = 1.0
    execute_on = INITIAL
  [../]

  [./He*triplet_S_for_Shooting]
    type = QuotientAux
    variable = He*triplet_S
    numerator = He*triplet
    denominator = 1.0
    enable = false
    execute_on = 'TIMESTEP_END'
  [../]
  [./Constant_SM_He*triplet_Reset]
    type = ConstantAux
    variable = SM_He*triplet_Reset
    value = 1.0
    execute_on = INITIAL
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./He_val]
    type = FunctionAux
    variable = He
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
  [./He+_lin]
    type = DensityMolesLin
    variable = He+_lin
    density = He+
  [../]
  [./He*singlet_lin]
    type = DensityMolesLin
    variable = He*singlet_lin
    density = He*singlet
  [../]
  [./He*triplet_lin]
    type = DensityMolesLin
    variable = He*triplet_lin
    density = He*triplet
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
  [./em_He+_second_emissions]
    type = SakiyamaSecondaryElectronBCLin
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He+
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
  [./He+_physical_advection]
    type = SakiyamaIonAdvectionBCLin
    variable = He+
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
  [./mean_en_He+_second_emissions]
    type = SakiyamaEnergySecondaryElectronBCLin
    variable = mean_en
    em = em
    ip = He+
    potential = potential
    Tse_equal_Te = false
    user_se_energy = 0.75
    se_coeff = 0.01
    boundary = 'right left'
    position_units = ${dom0Scale}
  [../]


  #Boundary conditions for metastables
  [./He*singlet_physical_diffusion]
    type = ADDirichletBC
    variable = He*singlet
    boundary = 'right left'
    value = 0.0
  [../]
  [./He*triplet_physical_diffusion]
    type = ADDirichletBC
    variable = He*triplet
    boundary = 'right left'
    value = 0.0
  [../]
[]

[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  [../]
  [./He+_ic]
    type = FunctionIC
    variable = He+
    function = density_ic_func
  [../]
  [./He*singlet_ic]
    type = FunctionIC
    variable = He*singlet
    function = density_ic_func
  [../]
  [./He*triplet_ic]
    type = FunctionIC
    variable = He*triplet
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
    value = '0.075*sin(2*pi*13.56e6*t)'
  [../]
  [./potential_bottom_bc_func]
    type = ParsedFunction
    value = '-0.075*sin(2*pi*13.56e6*t)'
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
    property_tables_file = '../Helium_reactions/electron_moments.txt'
  [../]
  [./gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = He+
    heavy_species_mass = 6.6465e-27
    heavy_species_charge = 1.0
    mobility = 2.018
    diffusivity = 5.218e-02
  [../]
  [./gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = He
    heavy_species_mass = 6.6465e-27
    heavy_species_charge = 0.0
  [../]
  [./gas_species_1]
    type = ADHeavySpecies
    heavy_species_name = He*singlet
    heavy_species_mass = 6.6465e-27
    heavy_species_charge = 0.0
    diffusivity = 8.833e-02
  [../]
  [./gas_species_3]
    type = ADHeavySpecies
    heavy_species_name = He*triplet
    heavy_species_mass = 6.6465e-27
    heavy_species_charge = 0.0
    diffusivity = 8.833e-02
  [../]
  [./reaction_0]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Helium_reactions/reaction_em + He -> em + He.txt'
    reaction = 'em + He -> em + He'
    file_location = ''
    electrons = em
  [../]
  [./reaction_1]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Helium_reactions/reaction_em + He -> em + em + He+.txt'
    reaction = 'em + He -> em + em + He+'
    file_location = ''
    electrons = em
  [../]
  [./reaction_2]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Helium_reactions/reaction_em + He -> em + He*singlet.txt'
    reaction = 'em + He -> em + He*singlet'
    file_location = ''
    electrons = em
  [../]
  [./reaction_3]
    type = InterpolatedCoefficientLinearLin
    mean_energy = mean_en
    property_file = '../Helium_reactions/reaction_em + He -> em + He*triplet.txt'
    reaction = 'em + He -> em + He*triplet'
    file_location = ''
    electrons = em
  [../]
[]

#Acceleration Schemes are dictated by MultiApps, Transfers,
#and PeriodicControllers
[MultiApps]
  #MultiApp of Acceleration by Shooting Method
  [./Shooting]
    type = FullSolveMultiApp
    input_files = 'He-NonLog-RF_Plasma_Shooting.i'
    execute_on = 'TIMESTEP_END'
    enable = false
    #clone_master_mesh = true
  [../]
[]


[Transfers]
  #MultiApp Transfers for Acceleration by Shooting Method
  [./SM_He*singlet_Reset_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SM_He*singlet_Reset
    variable = SM_He*singlet_Reset
    enable = false
  [../]
  [./SM_He*triplet_Reset_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SM_He*triplet_Reset
    variable = SM_He*triplet_Reset
    enable = false
  [../]

  [./He*singlet_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = He*singlet
    variable = He*singlet
    enable = false
  [../]
  [./He*triplet_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = He*triplet
    variable = He*triplet
    enable = false
  [../]

  [./He*singlet_S_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = He*singlet_S
    variable = He*singlet_S
    enable = false
  [../]
  [./He*triplet_S_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = He*triplet_S
    variable = He*triplet_S
    enable = false
  [../]

  [./He*singlet_T_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = He*singlet
    variable = He*singlet_T
    enable = false
  [../]
  [./He*triplet_T_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = He*triplet
    variable = He*triplet_T
    enable = false
  [../]

  [./SMDeriv_singlet_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SM_He*singlet
    variable = SM_He*singlet
    enable = false
  [../]
  [./SMDeriv_triplet_to_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Shooting
    source_variable = SM_He*triplet
    variable = SM_He*triplet
    enable = false
  [../]

  [./He*singlet_New_from_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = He*singlet
    variable = He*singlet
    enable = false
  [../]
  [./He*triplet_New_from_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = He*triplet
    variable = He*triplet
    enable = false
  [../]

  [./SM_He*singlet_Reset_from_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = SM_He*singlet_Reset
    variable = SM_He*singlet
    enable = false
  [../]
  [./SM_He*triplet_Reset_from_Shooting]
    #type = MultiAppCopyTransfer
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Shooting
    source_variable = SM_He*triplet_Reset
    variable = SM_He*triplet
    enable = false
  [../]

  [./He*_singlet_Relative_Diff]
    type = MultiAppPostprocessorTransfer
    direction = from_multiapp
    multi_app = Shooting
    from_postprocessor = Meta_singlet_Relative_Diff
    to_postprocessor = Meta_singlet_Relative_Diff
    reduction_type = minimum
    enable = false
  [../]
  [./He*_triplet_Relative_Diff]
    type = MultiAppPostprocessorTransfer
    direction = from_multiapp
    multi_app = Shooting
    from_postprocessor = Meta_triplet_Relative_Diff
    to_postprocessor = Meta_triplet_Relative_Diff
    reduction_type = minimum
    enable = false
  [../]
[]

#The Action the add the TimePeriod Controls to turn off and on the MultiApps
[PeriodicControllers]
  [./Shooting]
    Enable_at_cycle_start = '*::He*singlet_S_for_Shooting *::He*triplet_S_for_Shooting'

    Enable_during_cycle = '*::SM_He*singlet_time_deriv *::SM_He*singlet_diffusion
                           *::SM_He*triplet_time_deriv *::SM_He*triplet_diffusion'

    Enable_at_cycle_end = 'MultiApps::Shooting

                           *::SM_He*singlet_Reset_to_Shooting *::He*singlet_to_Shooting
                           *::He*singlet_S_to_Shooting *::He*singlet_T_to_Shooting
                           *::SMDeriv_singlet_to_Shooting *::He*singlet_New_from_Shooting
                           *::SM_He*singlet_Reset_from_Shooting *::He*_singlet_Relative_Diff

                           *::SM_He*triplet_Reset_to_Shooting *::He*triplet_to_Shooting
                           *::He*triplet_S_to_Shooting *::He*triplet_T_to_Shooting
                           *::SMDeriv_triplet_to_Shooting *::He*triplet_New_from_Shooting
                           *::SM_He*triplet_Reset_from_Shooting *::He*_triplet_Relative_Diff'

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
  [./Meta_singlet_Relative_Diff]
    type = Receiver
  [../]
  [./Meta_triplet_Relative_Diff]
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
  #end_time = 4.056e-6 #~55 RF cycles
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
