dom0Scale=1

[GlobalParams]
  offset = 20
  # offset = 0
  #potential_units = kV
  use_moles = true
  time_units = 1
  potential_units = V
[]

[Mesh]
  type = FileMesh
  #file = 'sakiyama_grid.msh'
  file = 'Hemke_1D_V04.msh'
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
  # kernel_coverage_check = false
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    electrode_area = 0.0314159
    ballast_resist = 1e3
    e = 1.6e-19
  [../]
[]

[Variables]
  [./em]
  [../]

  [./He*]
  [../]

  [./He+]
  [../]

  [./He_2*]
  [../]

  [./He_2+]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]
[]

[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
    # offset = 30
  [../]

  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]

  [./He+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = He+
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
  [../]
  [./He_2+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = He_2+
  [../]

  [./He+_time_deriv]
    type = ElectronTimeDerivative
    variable = He+
  [../]
  [./He+_advection]
    type = EFieldAdvection
    variable = He+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./He+_diffusion]
    type = CoeffDiffusion
    variable = He+
    position_units = ${dom0Scale}
  [../]
  [./He+_log_stabilization]
    type = LogStabilizationMoles
    variable = He+
    #offset = 20
  [../]

  [./He_2+_time_deriv]
    type = ElectronTimeDerivative
    variable = He_2+
  [../]
  [./He_2+_advection]
    type = EFieldAdvection
    variable = He_2+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./He_2+_diffusion]
    type = CoeffDiffusion
    variable = He_2+
    position_units = ${dom0Scale}
  [../]
  [./He_2+_log_stabilization]
    type = LogStabilizationMoles
    variable = He_2+
    #offset = 20
  [../]


  [./He*_time_deriv]
    type = ElectronTimeDerivative
    variable = He*
  [../]
  [./He*_diffusion]
    type = CoeffDiffusion
    variable = He*
    position_units = ${dom0Scale}
  [../]
  [./He*_log_stabilization]
    type = LogStabilizationMoles
    variable = He*
    #offset = 20
    offset = 30
  [../]

  [./He_2*_time_deriv]
    type = ElectronTimeDerivative
    variable = He_2*
  [../]
  [./He_2*_diffusion]
    type = CoeffDiffusion
    variable = He_2*
    position_units = ${dom0Scale}
  [../]
  [./He_2*_log_stabilization]
    type = LogStabilizationMoles
    variable = He_2*
    offset = 30
  [../]


  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    # offset = 20
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

  [./rho]
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
  [./He*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./He_2*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./He_2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./He]
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
  [./Current_He]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Current_He2]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./tot_gas_current]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./e_temp]
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
  [./He+_lin]
    type = DensityMoles
    convert_moles = true
    variable = He+_lin
    density_log = He+
  [../]
  [./He*_lin]
    type = DensityMoles
    convert_moles = true
    variable = He*_lin
    density_log = He*
  [../]
  [./He_2*_lin]
    type = DensityMoles
    convert_moles = true
    variable = He_2*_lin
    density_log = He_2*
  [../]
  [./He_2+_lin]
    type = DensityMoles
    convert_moles = true
    variable = He_2+_lin
    density_log = He_2+
  [../]

  [./He_val]
    type = ConstantAux
    variable = He
    # value = 2.4463141e25
    value = 3.7043332
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
  [./Current_He]
    type = Current
    potential = potential
    density_log = He+
    variable = Current_He
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Current_He2]
    type = Current
    potential = potential
    density_log = He_2+
    variable = Current_He2
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./tot_gas_current]
    type = ParsedAux
    variable = tot_gas_current
    args = 'Current_em Current_He Current_He2'
    function = 'Current_em + Current_He + Current_He2'
    execute_on = 'timestep_end'
    block = 0
  [../]


[]


[BCs]
  # [./potential_left]
  #   type = NeumannCircuitVoltageMoles_KV
  #   variable = potential
  #   boundary = left
  #   function = potential_bc_func
  #   ip = Ar+
  #   data_provider = data_provider
  #   em = em
  #   mean_en = mean_en
  #   r = 0
  #   position_units = ${dom0Scale}
  # [../]
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

  [./em_physical_right]
    type = HagelaarElectronBC
    variable = em
    boundary = 'right'
    potential = potential
    mean_en = mean_en
    r = 0.0
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = HagelaarElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./He+_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He+
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He+_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = He+
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]


  [./He+_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He+
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He+_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = He+
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./He*_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He*
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He*_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He*
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./He_2*_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He_2*
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He_2*_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He_2*
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./He_2+_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He_2+
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He_2+_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = He_2+
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He_2+_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = He_2+
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./He_2+_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = He_2+
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./mean_en_physical_right]
    # type = HagelaarEnergyBC
    type = EnergyBC2
    variable = mean_en
    boundary = 'right'
    potential = potential
    em = em
    ip = He+
    args = 'He+ He_2+'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_left]
    # type = HagelaarEnergyBC
    type = EnergyBC2
    variable = mean_en
    boundary = 'left'
    potential = potential
    em = em
    ip = He+
    args = 'He+ He_2+'
    r = 0
    position_units = ${dom0Scale}
  [../]

[]


[ICs]
  [./em_ic]
    type = ConstantIC
    variable = em
    value = -21
  [../]
  [./He+_ic]
    type = ConstantIC
    variable = He+
    value = -21
  [../]
  [./He*_ic]
    type = ConstantIC
    variable = He*
    value = -21
  [../]
  [./He_2*_ic]
    type = ConstantIC
    variable = He_2*
    value = -24
  [../]
  [./He_2+_ic]
    type = ConstantIC
    variable = He_2+
    value = -24
  [../]

  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -20
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
    value = '240*cos(2*3.1415926*13.56e6*t)'
    # value = '0.2'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    # value = '1.25 * (1.0001e-3 - x)'
    # value = '0.2 * (1.0001e-3 - x)'
    value = '0.2*cos(0)'
  [../]
[]

# [Postprocessors]
#   [./dk_den_parsed]
#     type = ElementIntegralMaterialProperty
#     mat_prop = dk_den
#   [../]
#   # [./dk_den_exact]
#   #   type = ElementIntegralMaterialProperty
#   #   mat_prop = dk_den_exact
#   # [../]
# []

[Materials]
  [./GasBasics]
    type = Gas_Helium
    interp_trans_coeffs = false
    interp_elastic_coeff = true
    ramp_trans_coeffs = false
    user_p_gas = 1.01325e5
    em = em
    potential = potential
    mean_en = mean_en
    user_se_coeff = 0
    #property_tables_file = electron_moments.txt
    property_tables_file = Helium_reactions/electron_moments.txt
    position_units = ${dom0Scale}
  [../]
  [./gas_species_0]
   type = HeavySpeciesMaterial
   heavy_species_name = He+
   heavy_species_mass = 6.646e-27
   heavy_species_charge = 1.0
   #mobility = 2.16e-3
   #diffusivity = 2.999e-5
   mobility = 1.3009e-3
   diffusivity = 3.8676e-5
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = He*
    heavy_species_mass = 6.646e-27
    heavy_species_charge = 0.0
    mobility = 0
    #diffusivity = 1.64e-4
    diffusivity = 2.02e-4
  [../]
  [./gas_species_2]
    type = HeavySpeciesMaterial
    heavy_species_name = He_2*
    heavy_species_mass = 1.3292e-26
    heavy_species_charge = 0.0
    mobility = 0
    #diffusivity = 4.75e-5
    diffusivity = 5.86e-5
  [../]
  [./gas_species_3]
    type = HeavySpeciesMaterial
    heavy_species_name = He_2+
    heavy_species_mass = 1.3292e-26
    heavy_species_charge = 1.0
    #mobility = 1.83e-3
    #diffusivity = 4.731e-5
    mobility = 2.1092e-3
    diffusivity = 6.2708e-5
  [../]

  # Note that He neutrals are not a nonlinear variable here.
  # However, some kernels may need the mass, charge, etc. parameters regardless.
  [./gas_species_5]
    type = HeavySpeciesMaterial
    heavy_species_name = He
    heavy_species_mass = 6.646e-27
    heavy_species_charge = 0.0
    mobility = 0
    diffusivity = 2.999e-5
  [../]
[]


[ChemicalReactions]
  [./ZapdosNetwork]
    species = 'em He He* He+ He_2* He_2+'
    aux_species = 'He'
    reaction_coefficient_format = 'townsend'
    electron_energy = 'mean_en'
    species_energy = 'mean_en'
    electron_density = 'em'
    include_electrons = true
    potential = 'potential'
    position_units = ${dom0Scale}

    file_location = 'Helium_reactions'
    equation_constants = 'Tg'
    equation_values = '345'
    equation_variables = 'Te Efield'

    reactions = 'He + em -> He* + em                    : BOLOS [-19.8]
                 He + em -> He+ + em + em               : BOLOS [-24.6]
                 em + He -> em + He                     : BOLOS [elastic]
                 He* + em -> He+ + em + em              : BOLOS [-4.7]
                 em + He_2+ -> He* + He                 : 8.9e-15*((Te*11604.505)/Tg)^-1.5
                 He_2* + He_2* -> He + He + He_2+ + em  : 1.5e-15
                 He* + He* -> He_2+ + em                : 1.5e-15
                 He* + He + He -> He_2* + He            : 2e-46
                 He+ + He + He -> He_2+ + He            : 1.1e-43
                 em + em + He+ -> em + He*              : 1.63e-21*(Te*11604.505)^-4.5'

    # reactions = 'He + em -> He* + em          : {3.88e-16*exp(-1.4e6/Efield)}
    #              He + em -> He+ + em + em     : {4.75e-16*exp(-2.31e6/Efield)}
    #              He* + em -> He+ + em + em    : {2.02e-13*exp(-3.10e5/Efield)}
    #              He* + He + He -> He_2* + He  : 2.0e-46
    #              He+ + He + He -> He_2+ + He  : 1.1e-43
    #              He_2* -> He + He             : 1.0e4
    #              He* + He* -> He_2+ + em      : 1.5e-15
    #              He_2* + He_2* -> He_2+ + em  : 1.5e-15
    #              He_2+ + em -> He* + He       : {8.9e-15*((Te*11600/Tg)^(-1.5))}
    #              He* + N_2 -> N_2+ + He + em  : 5.0e-17
    #              He_2* + N_2 -> N_2+ + em     : 3.0e-17
    #              He_2+ + N_2 -> N_2+ + He_2*  : 1.4e-15
    #              N_2+ + em -> N_2             : {4.8e-13*(Te/Tg)^(-0.5)}'
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
    # ksp_norm = none
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  end_time = 1e-4
  # dt = 1e-9
  #dtmax = 1e-8
  dtmax = 2.96e-9
  # num_steps = 100
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  # dt = 1e-9
  # solve_type = JFNK
  # solve_type = PJFNK
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  # petsc_options_value = 'lu NONZERO 1.e-10 1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 7.6e-5
  dtmin = 1e-14
  l_max_its = 20

  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    growth_factor = 1.2
    optimal_iterations = 20
  [../]
[]

[Outputs]
  print_perf_log = true
  file_base = Helium_COST_rf_NO_SCALE_240V
  #print_linear_residuals = false
  [./out]
    type = Exodus
  [../]
[]