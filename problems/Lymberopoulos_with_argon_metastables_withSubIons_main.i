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
  [./Ar*]
  [../]
[]

[Kernels]
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
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar
        energy = mean_en
        reaction = 'em + Ar -> em + Ar*'
        coefficient = 1
      [../]
      #Net excited Argon loss from step-wise ionization
      [./Ar*_stepwise_ionization]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar*
        energy = mean_en
        reaction = 'em + Ar* -> em + em + Ar+'
        coefficient = -1
        _target_eq_u = true
      [../]
      #Net excited Argon loss from superelastic collisions
      [./Ar*_collisions]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar*
        energy = mean_en
        reaction = 'em + Ar* -> em + Ar'
        coefficient = -1
        _target_eq_u = true
      [../]
      #Net excited Argon loss from quenching to resonant
      [./Ar*_quenching]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar*
        energy = mean_en
        reaction = 'em + Ar* -> em + Ar_r'
        coefficient = -1
        _target_eq_u = true
      [../]
      #Net excited Argon loss from  metastable pooling
      [./Ar*_pooling]
        type = ReactantSecondOrderLog
        variable = Ar*
        v = Ar*
        reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
        coefficient = -2
        _v_eq_u = true
      [../]
      #Net excited Argon loss from two-body quenching
      [./Ar*_2B_quenching]
        type = ReactantSecondOrderLog
        variable = Ar*
        v = Ar
        reaction = 'Ar* + Ar -> Ar + Ar'
        coefficient = -1
      [../]
      #Net excited Argon loss from three-body quenching
      [./Ar*_3B_quenching]
        type = ReactantThirdOrderLog
        variable = Ar*
        v = Ar
        w = Ar
        reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
        coefficient = -1
      [../]
  []


[AuxVariables]
  [./em]
  [../]
  [./mean_en]
  [../]

  [./Ar]
  [../]
[]

[AuxKernels]
  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 3.22e22
    value = -2.928623
    execute_on = INITIAL
  [../]
[]


[BCs]
#New Boundary conditions for ions, should be the same as in paper
#(except the metastables are not set to zero, since Zapdos uses log form)
  [./Ar*_physical_right_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'right'
    value = 100
  [../]
  [./Ar*_physical_left_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'left'
    value = 100
  [../]
[]


[ICs]
  [./Ar*_ic]
    type = FunctionIC
    variable = Ar*
    function = density_ic_func
  [../]
[]

[Functions]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
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
    mean_en = mean_en
    user_electron_mobility = 30.0
    user_electron_diffusion_coeff = 119.8757763975
    property_tables_file = Argon_reactions_paper_RateCoefficients/electron_moments.txt
    position_units = ${dom0Scale}
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

[MultiApps]
  [sub]
    type = TransientMultiApp
    app_type = ZapdosApp
    positions = '0.0 0.0 0.0'
    input_files = 'Lymberopoulos_with_argon_metastables_withSubIons_sub.i'
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    sub_cycling = true
    output_sub_cycles = true
  []
[]

[Transfers]
  [Meta_to_sub]
    type = MultiAppMeshFunctionTransfer
    direction = to_multiapp
    multi_app = sub
    source_variable = Ar*
    variable = Ar*
  [../]
  [./em_from_sub]
    type = MultiAppMeshFunctionTransfer
    direction = from_multiapp
    multi_app = sub
    source_variable = em
    variable = em
  [../]
  [./mean_en_from_sub]
    type = MultiAppMeshFunctionTransfer
    direction = from_multiapp
    multi_app = sub
    source_variable = mean_en
    variable = mean_en
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
  dtmax = 3.7e-6
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  nl_rel_tol = 1e-08
  #nl_abs_tol = 7.6e-5 #Commit out do to test falure on Mac
  dtmin = 1e-14
  l_max_its = 20

  #Time steps based on the inverse of the plasma frequency
  #[./TimeStepper]
  #  type = PostprocessorDT
  #  postprocessor = InversePlasmaFreq
  #[../]
[]

[Outputs]
  print_perf_log = true
  file_base = 'Argon_GEC_1D_1core_subcycling_withIons'
  [./out]
    type = Exodus
  [../]
[]
