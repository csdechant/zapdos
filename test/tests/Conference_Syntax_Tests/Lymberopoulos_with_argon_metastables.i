dom0Scale = 25.4e-3

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  coord_type = RZ
  rz_coord_axis = Y

  [left_domain]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 2.11811023622
    ymin = 1.5
    ymax = 2.5
    nx = 64
    ny = 32
    subdomain_name = plasma
  []

  [right_middle_domain]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 2.11811023622
    xmax = 4
    ymin = 1.5
    ymax = 2.5
    nx = 64
    ny = 32
    subdomain_name = plasma
  []

  [right_middle2_domain]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 2.11811023622
    xmax = 4
    ymin = 2.5
    ymax = 2.67716535433
    nx = 64
    ny = 6
    subdomain_name = plasma
  []

  [right_top_domain]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 2.11811023622
    xmax = 4
    ymin = 2.67716535433
    ymax = 4
    nx = 64
    ny = 42
    subdomain_name = plasma
  []

  [right_bottom_domain]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 2.11811023622
    xmax = 4
    ymin = 0
    ymax = 1.5
    nx = 64
    ny = 48
    subdomain_name = plasma
  []

  [cmbn]
    type = CombinerGenerator
    inputs = 'left_domain right_middle_domain right_middle2_domain right_top_domain right_bottom_domain'
    avoid_merging_boundaries = true
    show_info = true
  []

  [rename]
    type = RenameBoundaryGenerator
    input = cmbn
    old_boundary = '0 1 2 3
                    4 5 6 7
                    8 9 10 11
                    12 13 14 15
                    16 17 18 19'
    new_boundary = 'ground interior plasma_dielectric_hori axis
                    interior ground interior interior
                    interior ground interior plasma_dielectric_vert
                    interior ground ground ground
                    ground ground interior ground'
  []
[]

[Variables]
  [em]
  []

  [Ar+]
  []

  [Ar*]
  []

  [mean_en]
  []

  [potential]
  []

  [potential_ion]
  []
[]

[Kernels]
  #Time Derivative term of electron
  [em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  []
  #Advection term of electron
  [em_advection]
    type = EFieldAdvection
    variable = em
    position_units = ${dom0Scale}
  []
  #Diffusion term of electrons
  [em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = ${dom0Scale}
  []
  #Net electron production from ionization
  [em_ionization]
    type = EEDFReactionLog
    variable = em
    electrons = em
    target = Ar
    mean_energy = mean_en
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  []
  #Net electron production from step-wise ionization
  [em_stepwise_ionization]
    type = EEDFReactionLog
    variable = em
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = 1
  []
  #Net electron production from metastable pooling
  [em_pooling]
    type = ReactionSecondOrderLog
    variable = em
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = 1
  []

  #Argon Ion Equations (Same as in paper)
  #Time Derivative term of the ions
  [Ar+_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar+
  []
  #Advection term of ions
  [Ar+_advection]
    type = EFieldAdvection
    variable = Ar+
    field_property_name = field_ion
    position_units = ${dom0Scale}
  []
  [Ar+_diffusion]
    type = CoeffDiffusion
    variable = Ar+
    position_units = ${dom0Scale}
  []
  #Net ion production from ionization
  [Ar+_ionization]
    type = EEDFReactionLog
    variable = Ar+
    electrons = em
    target = Ar
    mean_energy = mean_en
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  []
  #Net ion production from step-wise ionization
  [Ar+_stepwise_ionization]
    type = EEDFReactionLog
    variable = Ar+
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = 1
  []
  #Net ion production from metastable pooling
  [Ar+_pooling]
    type = ReactionSecondOrderLog
    variable = Ar+
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = 1
  []

  #Argon Excited Equations (Same as in paper)
  #Time Derivative term of excited Argon
  [Ar*_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar*
  []
  #Diffusion term of excited Argon
  [Ar*_diffusion]
    type = CoeffDiffusion
    variable = Ar*
    position_units = ${dom0Scale}
  []
  #Net excited Argon production from excitation
  [Ar*_excitation]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar
    mean_energy = mean_en
    reaction = 'em + Ar -> em + Ar*'
    coefficient = 1
  []
  #Net excited Argon loss from step-wise ionization
  [Ar*_stepwise_ionization]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = -1
  []
  #Net excited Argon loss from superelastic collisions
  [Ar*_collisions]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + Ar'
    coefficient = -1
  []
  #Net excited Argon loss from quenching to resonant
  [Ar*_quenching]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + Ar_r'
    coefficient = -1
  []
  #Net excited Argon loss from  metastable pooling
  [Ar*_pooling]
    type = ReactionSecondOrderLog
    variable = Ar*
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = -2
    _v_eq_u = true
    _w_eq_u = true
  []
  #Net excited Argon loss from two-body quenching
  [Ar*_2B_quenching]
    type = ReactionSecondOrderLog
    variable = Ar*
    v = Ar*
    w = Ar
    reaction = 'Ar* + Ar -> Ar + Ar'
    coefficient = -1
    _v_eq_u = true
  []
  #Net excited Argon loss from three-body quenching
  [Ar*_3B_quenching]
    type = ReactionThirdOrderLog
    variable = Ar*
    v = Ar*
    w = Ar
    x = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    coefficient = -1
    _v_eq_u = true
  []

  #Voltage term in Poissons Eqaution
  [potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
    block = plasma
  []
  #Ion term in Poissons Equation
  [Ar+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Ar+
    block = plasma
  []
  #Electron term in Poissons Equation
  [em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
    block = plasma
  []

  #Time Derivative term of electron energy
  [mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
    block = plasma
  []
  #Advection term of electron energy
  [mean_en_advection]
    type = EFieldAdvection
    variable = mean_en
    position_units = ${dom0Scale}
    block = plasma
  []
  #Diffusion term of electrons energy
  [mean_en_diffusion]
    type = CoeffDiffusion
    variable = mean_en
    position_units = ${dom0Scale}
    block = plasma
  []
  #Joule Heating term
  [mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    #em = em
    electrons = em
    position_units = ${dom0Scale}
    block = plasma
  []
  #Energy loss from ionization
  [Ionization_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    threshold_energy = -15.7
    block = plasma
  []
  #Energy loss from excitation
  [Excitation_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar*'
    threshold_energy = -11.56
    block = plasma
  []
  #Energy loss from step-wise ionization
  [Stepwise_Ionization_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    threshold_energy = -4.14
    block = plasma
  []
  #Energy gain from superelastic collisions
  [Collisions_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + Ar'
    threshold_energy = 11.56
    block = plasma
  []
  # Energy loss from elastic collisions
  [Elastic_loss]
    type = EEDFElasticLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar'
    block = plasma
  []

  #Effective potential for the Ions
  [Ion_potential_time_deriv]
    type = TimeDerivative
    variable = potential_ion
    block = plasma
  []
  [Ion_potential_reaction]
    type = ScaledReaction
    variable = potential_ion
    collision_freq = 1283370.875
    block = plasma
  []
  [Ion_potential_coupled_force]
    type = CoupledForce
    variable = potential_ion
    v = potential
    coef = 1283370.875
    block = plasma
  []
[]

[AuxVariables]
  [Te]
    order = CONSTANT
    family = MONOMIAL
  []

  [Ar]
  []

  [E_x]
    family = MONOMIAL
    order = FIRST
  []

  [E_y]
    family = MONOMIAL
    order = FIRST
  []
[]

[AuxKernels]
  [E_x_from_mat]
    type = ADMaterialRealVectorValueAux
    property = field_ion # name of the vector material property
    variable = E_x
    component = 0 # x-component
  []

  [E_y_from_mat]
    type = ADMaterialRealVectorValueAux
    property = field_ion # name of the vector material property
    variable = E_y
    component = 1 # y-component
  []

  [Te]
    type = ElectronTemperature
    variable = Te
    electrons = em
    electron_energy = mean_en
  []

  [Ar_val]
    type = ConstantAux
    variable = Ar
    value = -7.5305
    execute_on = INITIAL
  []
[]

[BCs]
  [potential_dirichlet_dielectric_hori]
    type = DielectricBCWithEffEfield
    variable = potential
    boundary = plasma_dielectric_hori
    electrons = em
    ions = Ar+
    electron_energy = mean_en
    electric_field_x = E_x
    electric_field_y = E_y
    dielectric_constant = 1.859382e-11
    thickness = 0.177165354331
    emission_coeffs = 0.01
    position_units = ${dom0Scale}
  []
  [potential_dirichlet_dielectric_vert]
    type = DielectricBCWithEffEfield
    variable = potential
    boundary = plasma_dielectric_vert
    electrons = em
    ions = Ar+
    electron_energy = mean_en
    electric_field_x = E_x
    electric_field_y = E_y
    dielectric_constant = 1.859382e-11
    thickness = 2.1181
    emission_coeffs = 0.01
    position_units = ${dom0Scale}
  []
  [potential_dirichlet_plasma]
    type = DirichletBC
    variable = potential
    boundary = 'ground'
    value = 0
    preset = false
  []

  [em_physical_diffusion]
    type = SakiyamaElectronDiffusionBC
    variable = em
    electron_energy = mean_en
    boundary = 'ground plasma_dielectric_hori plasma_dielectric_vert'
    position_units = ${dom0Scale}
  []
  [em_Ar+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    field_property_name = field_ion
    ions = Ar+
    emission_coeffs = 0.01
    boundary = 'ground plasma_dielectric_hori plasma_dielectric_vert'
    position_units = ${dom0Scale}
  []

  [Ar+_physical_advection]
    type = SakiyamaIonAdvectionBC
    variable = Ar+
    field_property_name = field_ion
    boundary = 'ground plasma_dielectric_hori plasma_dielectric_vert'
    position_units = ${dom0Scale}
  []

  [Ar*_physical_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'ground plasma_dielectric_hori plasma_dielectric_vert'
    value = 100
  []

  [mean_en_physical_diffusion]
    type = SakiyamaEnergyDiffusionBC
    variable = mean_en
    electrons = em
    boundary = 'ground plasma_dielectric_hori plasma_dielectric_vert'
    position_units = ${dom0Scale}
  []
  [mean_en_Ar+_second_emissions]
    type = SakiyamaEnergySecondaryElectronBC
    variable = mean_en
    electrons = em
    ions = Ar+
    field_property_name = field_ion
    secondary_electron_temperature_equal_to_bulk = true
    emission_coeffs = 0.01
    boundary = 'ground plasma_dielectric_hori plasma_dielectric_vert'
    position_units = ${dom0Scale}
  []
[]

[ICs]
  [em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
    block = plasma
  []
  [Ar+_ic]
    type = FunctionIC
    variable = Ar+
    function = density_ic_func
    block = plasma
  []
  [Ar*_ic]
    type = FunctionIC
    variable = Ar*
    function = meta_density_ic_func
    block = plasma
  []
  [mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
    block = plasma
  []
[]

[Functions]
  [density_ic_func]
    type = ParsedFunction
    expression = 'log((1e8)/6.022e23)'
  []
  [meta_density_ic_func]
    type = ParsedFunction
    expression = 'log((1e12)/6.022e23)'
  []
  [energy_density_ic_func]
    type = ParsedFunction
    expression = 'log((3./2.) * 4) + log((1e8)/6.022e23)'
  []
[]

[Materials]
  [field_solver]
    type = FieldSolverMaterial
    potential = potential
  []
  [field_solver_ion]
    type = FieldSolverMaterial
    potential = potential_ion
    property_name = field_ion
  []
  [potential_permittivity]
    type = ElectrostaticPermittivity
    potential = potential
  []
  [GasBasics]
    type = ElectronTransportCoefficients
    interp_trans_coeffs = false
    ramp_trans_coeffs = false
    T_gas = 300
    p_gas = 0.133322
    electrons = em
    electron_energy = mean_en
    property_tables_file = Argon_reactions_paper_RateCoefficients/electron_moments.txt
    user_electron_mobility = 3e6
    user_electron_diffusion_coeff = 1.2e7
  []
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 2.8881
    diffusivity = 6.428571e-2
  []
  [gas_species_1]
    type = ADHeavySpecies
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    diffusivity = 7.515528e-2
  []
  [gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  []
  [reaction_00]
    type = ZapdosEEDFRateConstant
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients/ar_elastic.txt'
    reaction = 'em + Ar -> em + Ar'
    electrons = em
  []
  [reaction_0]
    type = ZapdosEEDFRateConstant
    property_file = 'Argon_reactions_paper_RateCoefficients/ar_excitation.txt'
    reaction = 'em + Ar -> em + Ar*'
    mean_energy = mean_en
    electrons = em
  []
  [reaction_1]
    type = ZapdosEEDFRateConstant
    property_file = 'Argon_reactions_paper_RateCoefficients/ar_ionization.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    mean_energy = mean_en
    electrons = em
  []
  [reaction_2]
    type = ZapdosEEDFRateConstant
    reaction = 'em + Ar* -> em + Ar'
    property_file = 'Argon_reactions_paper_RateCoefficients/ar_deexcitation.txt'
    mean_energy = mean_en
    electrons = em
  []
  #swrate
  [reaction_3]
    type = ZapdosEEDFRateConstant
    reaction = 'em + Ar* -> em + em + Ar+'
    property_file = 'Argon_reactions_paper_RateCoefficients/ar_excited_ionization.txt'
    mean_energy = mean_en
    electrons = em
  []
  [reaction_4]
    type = GenericRateConstant
    reaction = 'em + Ar* -> em + Ar_r'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 1.2044e11
  []
  [reaction_5]
    type = GenericRateConstant
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    #reaction_rate_value = 6.2e-16
    reaction_rate_value = 373364000
  []
  [reaction_6]
    type = GenericRateConstant
    reaction = 'Ar* + Ar -> Ar + Ar'
    #reaction_rate_value = 3e-21
    reaction_rate_value = 1806.6
  []
  [reaction_7]
    type = GenericRateConstant
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    #reaction_rate_value = 1.1e-42
    reaction_rate_value = 398909.324
  []
[]

#New postprocessor that calculates the inverse of the plasma frequency
[Postprocessors]
  [InversePlasmaFreq]
    type = PlasmaFrequencyInverse
    variable = em
    use_moles = true
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

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

[Executioner]
  type = Transient
  end_time = 1e-7
  dtmax = 1e-9
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  nl_rel_tol = 1e-12
  dtmin = 1e-14

  automatic_scaling = true
  compute_scaling_once = false

  #Time steps based on the inverse of the plasma frequency
  [TimeSteppers]
    [Postprocessor]
      type = PostprocessorDT
      postprocessor = InversePlasmaFreq
      scale = 0.1
    []
  []
[]

[Outputs]
  perf_graph = true
  [out]
    type = Exodus
    time_step_interval = 10
  []
[]
