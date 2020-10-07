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

  [./Ex]
    initial_condition = 1.0
  [../]
  [./Ey]
    initial_condition = 1.0
  [../]
[]

[Kernels]
  #Electron Equations (Same as in paper)
    #Time Derivative term of electron
    [./em_time_deriv]
      type = ElectronTimeDerivative
      variable = em
    [../]
    #Advection term of electron
    [./em_advection]
      type = EFieldAdvectionElectrons
      variable = em
      potential = potential
      mean_en = mean_en
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons
    [./em_diffusion]
      type = CoeffDiffusionElectrons
      variable = em
      mean_en = mean_en
      position_units = ${dom0Scale}
    [../]
    #Net electron production from ionization
    [./em_ionization]
      type = EEDFReactionLog
      variable = em
      electrons = em
      target = Ar
      mean_energy = mean_en
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net electron production from step-wise ionization
    [./em_stepwise_ionization]
      type = EEDFReactionLog
      variable = em
      electrons = em
      target = Ar*
      mean_energy = mean_en
      reaction = 'em + Ar* -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net electron production from metastable pooling
    [./em_pooling]
      type = ReactionSecondOrderLog
      variable = em
      v = Ar*
      w = Ar*
      reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
      coefficient = 1
    [../]

  #Argon Ion Equations (Same as in paper)
    #Time Derivative term of the ions
    [./Ar+_time_deriv]
      type = ElectronTimeDerivative
      variable = Ar+
    [../]
    #Advection term of ions
    [./Ar+_advection]
      type = EffectiveEFieldAdvection
      variable = Ar+
      Ex = Ex
      Ey = Ey
      position_units = ${dom0Scale}
    [../]
    [./Ar+_diffusion]
      type = CoeffDiffusion
      variable = Ar+
      position_units = ${dom0Scale}
    [../]
    #Net ion production from ionization
    [./Ar+_ionization]
      type = EEDFReactionLog
      variable = Ar+
      electrons = em
      target = Ar
      mean_energy = mean_en
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net ion production from step-wise ionization
    [./Ar+_stepwise_ionization]
      type = EEDFReactionLog
      variable = Ar+
      electrons = em
      target = Ar*
      mean_energy = mean_en
      reaction = 'em + Ar* -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net ion production from metastable pooling
    [./Ar+_pooling]
      type = ReactionSecondOrderLog
      variable = Ar+
      v = Ar*
      w = Ar*
      reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
      coefficient = 1
    [../]

    #Argon Excited Equations (Same as in paper)
      #Time Derivative term of excited Argon
      [./Ar*_time_deriv]
        type = ElectronTimeDerivative
        variable = Ar*
      [../]
      #Diffusion term of excited Argon
      [./Ar*_diffusion]
        type = CoeffDiffusion
        variable = Ar*
        position_units = ${dom0Scale}
      [../]
      #Net excited Argon production from excitation
      [./Ar*_excitation]
        type = EEDFReactionLog
        variable = Ar*
        electrons = em
        target = Ar
        mean_energy = mean_en
        reaction = 'em + Ar -> em + Ar*'
        coefficient = 1
      [../]
      #Net excited Argon loss from step-wise ionization
      [./Ar*_stepwise_ionization]
        type = EEDFReactionLog
        variable = Ar*
        electrons = em
        target = Ar*
        mean_energy = mean_en
        reaction = 'em + Ar* -> em + em + Ar+'
        coefficient = -1
      [../]
      #Net excited Argon loss from superelastic collisions
      [./Ar*_collisions]
        type = EEDFReactionLog
        variable = Ar*
        electrons = em
        target = Ar*
        mean_energy = mean_en
        reaction = 'em + Ar* -> em + Ar'
        coefficient = -1
      [../]
      #Net excited Argon loss from quenching to resonant
      [./Ar*_quenching]
        type = EEDFReactionLog
        variable = Ar*
        electrons = em
        target = Ar*
        mean_energy = mean_en
        reaction = 'em + Ar* -> em + Ar_r'
        coefficient = -1
      [../]
      #Net excited Argon loss from  metastable pooling
      [./Ar*_pooling]
        type = ReactionSecondOrderLog
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
        type = ReactionSecondOrderLog
        variable = Ar*
        v = Ar*
        w = Ar
        reaction = 'Ar* + Ar -> Ar + Ar'
        coefficient = -1
        _v_eq_u = true
      [../]
      #Net excited Argon loss from three-body quenching
      [./Ar*_3B_quenching]
        type = ReactionThirdOrderLog
        variable = Ar*
        v = Ar*
        w = Ar
        x = Ar
        reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
        coefficient = -1
        _v_eq_u = true
      [../]

  #Voltage Equations (Same as in paper)
    #Voltage term in Poissons Eqaution
    [./potential_diffusion_dom0]
      type = CoeffDiffusionLin
      variable = potential
      position_units = ${dom0Scale}
    [../]
    #Ion term in Poissons Equation
    [./Ar+_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = Ar+
    [../]
    #Electron term in Poissons Equation
    [./em_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = em
    [../]


  #Since the paper uses electron temperature as a variable, the energy equation is in
  #a different form but should be the same physics
    #Time Derivative term of electron energy
    [./mean_en_time_deriv]
      type = ElectronTimeDerivative
      variable = mean_en
    [../]
    #Advection term of electron energy
    [./mean_en_advection]
      type = EFieldAdvectionEnergy
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons energy
    [./mean_en_diffusion]
      type = CoeffDiffusionEnergy
      variable = mean_en
      em = em
      position_units = ${dom0Scale}
    [../]
    #The correction for electrons energy's diffusion term
    [./mean_en_diffusion_correction]
      type = ThermalConductivityDiffusion
      variable = mean_en
      em = em
      position_units = ${dom0Scale}
    [../]
    #Joule Heating term
    [./mean_en_joule_heating]
      type = JouleHeating
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
    [../]
    #Energy loss from ionization
    [./Ionization_Loss]
      type = EEDFEnergyLog
      variable = mean_en
      electrons = em
      target = Ar
      reaction = 'em + Ar -> em + em + Ar+'
      threshold_energy = -15.7
    [../]
    #Energy loss from excitation
    [./Excitation_Loss]
      type = EEDFEnergyLog
      variable = mean_en
      electrons = em
      target = Ar
      reaction = 'em + Ar -> em + Ar*'
      threshold_energy = -11.56
    [../]
    #Energy loss from step-wise ionization
    [./Stepwise_Ionization_Loss]
      type = EEDFEnergyLog
      variable = mean_en
      electrons = em
      target = Ar*
      reaction = 'em + Ar* -> em + em + Ar+'
      threshold_energy = -4.14
    [../]
    #Energy gain from superelastic collisions
    [./Collisions_Loss]
      type = EEDFEnergyLog
      variable = mean_en
      electrons = em
      target = Ar*
      reaction = 'em + Ar* -> em + Ar'
      threshold_energy = 11.56
    [../]
    # Energy loss from elastic collisions
    [./Elastic_loss]
      type = EEDFElasticLogTempDepend
      variable = mean_en
      electrons = em
      target = Ar
      reaction = 'em + Ar -> em + Ar'
    [../]

    [./Ex]
      type = TimeDerivative
      variable = Ex
    [../]
    [./Ex_Source]
      type = EffectiveEFieldSourceTerm
      variable = Ex
      collision_freq = 12833708.75
      potential = potential
      component = 0
      position_units = ${dom0Scale}
    [../]

    [./Ey]
      type = TimeDerivative
      variable = Ey
    [../]
    [./Ey_Source]
      type = EffectiveEFieldSourceTerm
      variable = Ey
      collision_freq = 12833708.75
      potential = potential
      component = 1
      position_units = ${dom0Scale}
    [../]
  []


[AuxVariables]
  [./Te]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./x_node]
  [../]

  [./y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./y_node]
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

  [./Ar]
  [../]
[]

[AuxKernels]

  [./Te]
    type = ElectronTemperature
    variable = Te
    electron_density = em
    mean_en = mean_en
  [../]

  [./x_g]
    type = Position
    variable = x
    component = 0
    position_units = ${dom0Scale}
  [../]
  [./x_ng]
    type = Position
    variable = x_node
    component = 0
    position_units = ${dom0Scale}
  [../]

  [./y_g]
    type = Position
    variable = y
    component = 1
    position_units = ${dom0Scale}
  [../]
  [./y_ng]
    type = Position
    variable = y_node
    component = 1
    position_units = ${dom0Scale}
  [../]

  [./em_lin]
    type = DensityMoles
    variable = em_lin
    density_log = em
  [../]
  [./Ar+_lin]
    type = DensityMoles
    variable = Ar+_lin
    density_log = Ar+
  [../]
  [./Ar*_lin]
    type = DensityMoles
    variable = Ar*_lin
    density_log = Ar*
  [../]

  [./Ar_val]
    type = FunctionAux
    variable = Ar
    # value = 3.22e22
    function = 'log((3.22e22)/6.02e23)'
    execute_on = INITIAL
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
    type = EconomouDielectricEffectiveEFieldBC
    variable = potential
    boundary = 'Top_Insulator Bottom_Insulator'
    em = em
    ip = Ar+
    Ex = Ex
    Ey = Ey
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
    type = SakiyamaSecondaryElectronEffectiveEFieldBC
    variable = em
    Ex = Ex
    Ey = Ey
    ip = Ar+
    users_gamma = 0.01
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
  [./Ar+_physical_advection]
    type = SakiyamaIonEffectiveEFieldAdvectionBC
    variable = Ar+
    Ex = Ex
    Ey = Ey
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
#(except the metastables are not set to zero, since Zapdos uses log form)
  [./Ar*_physical_diffusion]
    type = DirichletBC
    variable = Ar*
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    value = -50.0
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
  type = SakiyamaEnergySecondaryElectronEffectiveEFieldBC
  variable = mean_en
  em = em
  ip = Ar+
  Ex = Ex
  Ey = Ey
  Tse_equal_Te = false
  user_se_energy = 1.0
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
    value = 0.0
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e14)/6.02e23)'
  [../]
  [./meta_density_ic_func]
    type = ParsedFunction
    value = 'log((1e14)/6.02e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log((3./2.)) + log((1e14)/6.02e23)'
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
    property_tables_file = Argon_reactions_paper_RateCoefficients_New/electron_moments.txt
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
  [./reaction_00]
    type = ZapdosEEDFRateConstant
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients_New/reaction_em + Ar -> em + Ar.txt'
    reaction = 'em + Ar -> em + Ar'
    file_location = ''
    electrons = em
  [../]
  [./reaction_0]
    type = ZapdosEEDFLinearInterpolation
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients_New/reaction_em + Ar -> em + Ar*.txt'
    reaction = 'em + Ar -> em + Ar*'
    file_location = ''
    electrons = em
  [../]
  [./reaction_1]
    type = ZapdosEEDFLinearInterpolation
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients_New/reaction_em + Ar -> em + em + Ar+.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    file_location = ''
    electrons = em
  [../]
  [./reaction_2]
    type = ZapdosEEDFLinearInterpolation
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients_New/reaction_em + Ar* -> em + Ar.txt'
    reaction = 'em + Ar* -> em + Ar'
    file_location = ''
    electrons = em
  [../]
  [./reaction_3]
    type = ZapdosEEDFLinearInterpolation
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients_New/reaction_em + Ar* -> em + em + Ar+.txt'
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
  end_time = 7.4e-3
  automatic_scaling = true
  compute_scaling_once = false
  solve_type = PJFNK
  scheme = bdf2
  dtmax = 1e-9
  dtmin = 1e-14
  #line_search = none
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  l_max_its = 20
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
