dom0Scale=25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'Lymberopoulos.msh'
[]

[MeshModifiers]
  [./left]
    type = SideSetsFromNormals
    normals = '-1 0 0'
    new_boundary = 'left'
  [../]
  [./right]
    type = SideSetsFromNormals
    normals = '1 0 0'
    new_boundary = 'right'
  [../]
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
  [../]

  [./mean_en]
  [../]

  [./potential]
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
      type = ElectronReactantSecondOrderLog
      variable = em
      v = Ar
      energy = mean_en
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net electron production from step-wise ionization
    [./em_stepwise_ionization]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = Ar*
      energy = mean_en
      reaction = 'em + Ar* -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net electron production from metastable pooling
    [./em_pooling]
      type = ProductSecondOrderLog
      variable = em
      v = Ar*
      w = Ar*
      reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
      coefficient = 1
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
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar
      reaction = 'em + Ar -> em + em + Ar+'
      threshold_energy = -15.7
      position_units = ${dom0Scale}
    [../]
    #Energy loss from excitation
    [./Excitation_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar
      reaction = 'em + Ar -> em + Ar*'
      threshold_energy = -11.56
      position_units = ${dom0Scale}
    [../]
    #Energy loss from step-wise ionization
    [./Stepwise_Ionization_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar*
      reaction = 'em + Ar* -> em + em + Ar+'
      threshold_energy = -4.14
      position_units = ${dom0Scale}
    [../]
    #Energy gain from superelastic collisions
    [./Collisions_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar*
      reaction = 'em + Ar* -> em + Ar'
      threshold_energy = 11.56
      position_units = ${dom0Scale}
    [../]
  []


[AuxVariables]
  [./Ar*]
  [../]
  [./Ar+]
  [../]

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

  [./rho]
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

  [./Ar]
  [../]

  [./Efield]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Current_em]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Current_Ar]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./emRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./exRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./swRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./deexRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./quRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./poolRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./TwoBRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./ThreeBRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./emRate]
    type = ProcRateForRateCoeff
    variable = emRate
    v = em
    w = Ar
    reaction = 'em + Ar -> em + em + Ar+'
  [../]
  [./exRate]
    type = ProcRateForRateCoeff
    variable = exRate
    v = em
    w = Ar*
    reaction = 'em + Ar -> em + Ar*'
  [../]
  [./swRate]
    type = ProcRateForRateCoeff
    variable = swRate
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
  [../]
  [./deexRate]
    type = ProcRateForRateCoeff
    variable = deexRate
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + Ar'
  [../]
  [./quRate]
    type = ProcRateForRateCoeff
    variable = quRate
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + Ar_r'
  [../]
  [./poolRate]
    type = ProcRateForRateCoeff
    variable = poolRate
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
  [../]
  [./TwoBRate]
    type = ProcRateForRateCoeff
    variable = TwoBRate
    v = Ar*
    w = Ar
    reaction = 'Ar* + Ar -> Ar + Ar'
  [../]
  [./ThreeBRate]
    type = ProcRateForRateCoeffThreeBody
    variable = ThreeBRate
    v = Ar*
    w = Ar
    vv = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
  [../]
  [./Te]
    type = ElectronTemperature
    variable = Te
    electron_density = em
    mean_en = mean_en
  [../]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
  [../]
  [./Ar+_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar+_lin
    density_log = Ar+
  [../]
  [./Ar*_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar*_lin
    density_log = Ar*
  [../]

  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 3.22e22
    value = -2.928623
    execute_on = INITIAL
  [../]

  [./Efield_calc]
    type = Efield
    component = 0
    potential = potential
    variable = Efield
    position_units = ${dom0Scale}
  [../]
  [./Current_em]
    type = Current
    potential = potential
    density_log = em
    variable = Current_em
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Current_Ar]
    type = Current
    potential = potential
    density_log = Ar+
    variable = Current_Ar
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
[]


[BCs]
#Voltage Boundary Condition, same as in paper
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left'
    function = potential_bc_func
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 0
  [../]

#New Boundary conditions for electons, same as in paper
  [./em_physical_right]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'right'
    gamma = 0.01
    #gamma = 1
    ks = 1.19e5
    #ks = 0.0
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'left'
    gamma = 0.01
    #gamma = 1
    ks = 1.19e5
    #ks = 0.0
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for mean energy, should be the same as in paper
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

[]


[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
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
  [./potential_bc_func]
    type = ParsedFunction
    value = '0.100*sin(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '0.100 * (25.4e-3 - x)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
  [../]
[]

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = false
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 133.322
    em = em
    potential = potential
    mean_en = mean_en
    user_electron_mobility = 30.0
    user_electron_diffusion_coeff = 119.8757763975
    property_tables_file = Argon_reactions_paper_RateCoefficients/electron_moments.txt
    position_units = ${dom0Scale}
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
  [./reaction_0]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar -> em + Ar*.txt'
    reaction = 'em + Ar -> em + Ar*'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_1]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar -> em + em + Ar+.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_2]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar* -> em + Ar.txt'
    reaction = 'em + Ar* -> em + Ar'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_3]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar* -> em + em + Ar+.txt'
    reaction = 'em + Ar* -> em + em + Ar+'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
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
    #reaction_rate_value = 1.1e-42
    reaction_rate_value = 398909.324
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
  end_time = 0.0001036
  #end_time = 3e-7
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  nl_rel_tol = 1e-08
  #nl_abs_tol = 7.6e-5 #Commit out do to test falure on Mac
  dtmin = 1e-14
  l_max_its = 20

  #Time steps based on the inverse of the plasma frequency
  [./TimeStepper]
    type = PostprocessorDT
    postprocessor = InversePlasmaFreq
  [../]
[]

[Outputs]
  print_perf_log = true
  file_base = 'Argon_GEC_1D_1core_subcycling_withIons_sub_sub'
  [./out]
    type = Exodus
  [../]
[]