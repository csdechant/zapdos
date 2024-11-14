#dom0Scale = 1.0

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  #Mesh is define by a previous output file
  [geo]
    type = FileMeshGenerator
    file = 'Lymberopoulos_paper_2D-stuctured.msh'
  []
  coord_type = RZ
  rz_coord_axis = Y
[]

#Defines the problem type, such as FE, eigen value problem, etc.
[Problem]
  type = FEProblem
[]

#Defining IC from previous output file
# (The ICs block is not used in this case)
[Variables]
  [em]
  []

  [Ar+]
  []

  [mean_en]
  []

  [potential]
  []
[]

[ICs]
  [em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  []
  [Ar_pos_ic]
    type = FunctionIC
    variable = Ar+
    function = density_ic_func
  []
  [mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  []
[]

[Kernels]
  #Electron Equations (Same as in paper)
  #Time Derivative term of electron
  [em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  []
  #Advection term of electron
  [em_advection]
    type = EFieldAdvection
    variable = em
    potential = potential
    position_units = 1.0
  []
  #Diffusion term of electrons
  [em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = 1.0
  []
  #Net electron production from ionization
  [em_ionization]
    type = ADEEDFReactionLog
    variable = em
    electrons = em
    target = Ar
    reaction = 'ionization'
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
    potential = potential
    position_units = 1.0
  []
  [Ar+_diffusion]
    type = CoeffDiffusion
    variable = Ar+
    position_units = 1.0
  []
  #Net ion production from ionization
  [Ar+_ionization]
    type = ADEEDFReactionLog
    variable = Ar+
    electrons = em
    target = Ar
    reaction = 'ionization'
    coefficient = 1
  []

  #Voltage Equations (Same as in paper)
  #Voltage term in Poissons Eqaution
  [potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = 1.0
  []
  #Ion term in Poissons Equation
  [Ar+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Ar+
  []
  #Electron term in Poissons Equation
  [em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
  []

  #Since the paper uses electron temperature as a variable, the energy equation is in
  #a different form but should be the same physics
  #Time Derivative term of electron energy
  [mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
  []
  #Advection term of electron energy
  [mean_en_advection]
    type = EFieldAdvection
    variable = mean_en
    potential = potential
    position_units = 1.0
  []
  #Diffusion term of electrons energy
  [mean_en_diffusion]
    type = CoeffDiffusion
    variable = mean_en
    position_units = 1.0
  []
  #Joule Heating term
  [mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = 1.0
  []
  #Energy loss from ionization
  [Ionization_Loss]
    type = ADEEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    # reaction = 'em + Ar -> em + em + Ar+'
    reaction = 'ionization'
    threshold_energy = -15.7
  []
[]

[AuxVariables]
  [Te]
    order = CONSTANT
    family = MONOMIAL
  []

  [x]
    order = CONSTANT
    family = MONOMIAL
  []

  [x_node]
  []

  [em_lin]
    order = CONSTANT
    family = MONOMIAL
  []

  [Ar+_lin]
    order = CONSTANT
    family = MONOMIAL
  []

  [Ar]
  []

  [Efield]
    order = CONSTANT
    family = MONOMIAL
  []

  [Current_em]
    order = CONSTANT
    family = MONOMIAL
  []
  [Current_Ar]
    order = CONSTANT
    family = MONOMIAL
  []

  [energy]
  []
  [ionization_rate]
  []
  [d_ionization_rate_d_actual_energy]
  []

  [test_postprocess]
  []
[]

[AuxKernels]
  [Te]
    type = ElectronTemperature
    variable = Te
    electron_density = em
    mean_en = mean_en
  []

  [x_g]
    type = Position
    variable = x
    position_units = 1.0
  []

  [x_ng]
    type = Position
    variable = x_node
    position_units = 1.0
  []

  [em_lin]
    type = DensityMoles
    variable = em_lin
    density_log = em
  []
  [Ar+_lin]
    type = DensityMoles
    variable = Ar+_lin
    density_log = Ar+
  []

  [Ar_val]
    type = FunctionAux
    variable = Ar
    function = 'log(1.65e22/6.022e23)'
    execute_on = INITIAL
  []

  #[Efield_calc]
  #  type = Efield
  #  component = 0
  #  potential = potential
  #  variable = Efield
  #  position_units = ${dom0Scale}
  #[]
  [Current_em]
    type = ADCurrent
    potential = potential
    density_log = em
    variable = Current_em
    art_diff = false
    position_units = 1.0
    boundary = 'Bottom_Electrode'
  []
  [Current_Ar]
    type = ADCurrent
    potential = potential
    density_log = Ar+
    variable = Current_Ar
    art_diff = false
    position_units = 1.0
    boundary = 'Bottom_Electrode'
  []

  [energy]
    type = ParsedAux
    variable = energy
    coupled_variables = 'em mean_en'
    expression = 'exp(mean_en - em)'
  []
  [ionization_rate]
    type = ParsedAux
    variable = ionization_rate
    coupled_variables = 'energy'
    expression = 'if(energy<5.3, 0.0, 6.023e23 * 8.7e-15*(energy-5.3)*exp(-4.9/sqrt(energy-5.3)))'
  []
  [d_ionization_rate_d_actual_energy]
    type = ParsedAux
    variable = d_ionization_rate_d_actual_energy
    coupled_variables = 'energy'
    expression = 'if(energy<5.3, 0.0, 6.023e23 * exp(-4.9/sqrt(energy-5.3))*(8.7e-15*sqrt(energy-5.3)+2.1315e-14)/sqrt(energy-5.3))'
  []

  [test_postprocess_kernel]
    type = FunctionAux
    variable = test_postprocess
    function = '1.0'
    execute_on = INITIAL
    enable = false
  []
[]

#Define function used throughout the input file (e.g. BCs)
[Functions]
  [potential_bc_func]
    type = ParsedFunction
    # symbol_names = V_DC
    # symbol_values = DC_Bias
    # expression = '-125*sin(2*pi*13.56e6*t) + V_DC'
    expression = '-150 * sin(2*pi*13.56e6*t)'
  []

  [potential_gap_func]
    type = ParsedFunction
    symbol_names = 'plate'
    symbol_values = 'potential_bc_func'
    expression = 'plate * (4e-2 - x)/(0.8e-2)'
  []

  [density_ic_func]
    type = ParsedFunction
    # expression = 'log((1e13 + 1e18 * (1-y/0.03)^2 * (y/0.03)^2)*cos(pi/4*(x/0.04))*cos(pi/4*(x/0.04))*cos(pi/4*(x/0.04))*cos(pi/4*(x/0.04))/6.022e23)'
    expression = 'log((1e14)/6.022e23)'
  []
  [energy_density_ic_func]
    type = ParsedFunction
    symbol_names = density_ic
    symbol_values = density_ic_func
    expression = 'log(3/2) + density_ic'
  []
[]

[BCs]
  #Voltage Boundary Condition
  [potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'Bottom_Electrode'
    function = potential_bc_func
    preset = false
  []
  [potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'Top_Electrode'
    value = 0
    preset = false
  []
  [potential_gap]
    # type = FunctionDirichletBC
    # variable = potential
    # boundary = 'gap'
    # function = potential_gap_func
    # preset = false
    type = DiffusionLinDoNothingBC
    variable = potential
    position_units = 1.0
    boundary = 'gap'
  []

  #Boundary conditions for electons
  # [em_physical_min]
  #   type = ADMinPenaltyDirichletBC
  #   variable = em
  #   value = -68
  #   min = -68
  #   penalty = 1
  #   boundary = 'Bottom_Electrode Top_Electrode'
  # []
  [em_physical_diffusion]
    type = LymberopoulosElectronBC
    variable = em
    gamma = 0.00
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = 1.0
    boundary = 'Bottom_Electrode Top_Electrode'
  []

  #Boundary conditions for ions
  [Ar_pos_physical_advection]
    type = SakiyamaIonAdvectionBC
    variable = Ar+
    potential = potential
    boundary = 'Bottom_Electrode Top_Electrode'
    position_units = 1.0
  []

  #New Boundary conditions for mean energy, should be the same as in paper
  # [mean_en_physical_min]
  #   type = ADMinPenaltyDirichletBC
  #   variable = mean_en
  #   value = -72
  #   min = -72
  #   penalty = 1
  #   boundary = 'Bottom_Electrode Top_Electrode'
  # []
  [mean_en_physical_diffusion]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'Bottom_Electrode Top_Electrode'
  []

  [em_do_nothing]
    type = DriftDiffusionDoNothingBC
    variable = em
    use_material_props = true
    potential = potential
    boundary = gap
    diff = 0
    mu = 0
    sign = 0
    position_units = 1.0
  []
  [ion_do_nothing]
    type = DriftDiffusionDoNothingBC
    variable = Ar+
    use_material_props = true
    potential = potential
    boundary = gap
    diff = 0
    mu = 0
    sign = 0
    position_units = 1.0
  []
  [mean_en_do_nothing]
    type = DriftDiffusionDoNothingBC
    variable = mean_en
    use_material_props = true
    potential = potential
    boundary = gap
    diff = 0
    mu = 0
    sign = 0
    position_units = 1.0
  []
[]

[Materials]
  [GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = false
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 66.661
    em = em
    potential = potential
    mean_en = mean_en
    user_electron_mobility = 60.0
    user_electron_diffusion_coeff = 240.0
    property_tables_file = electron_moments.txt
  []
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.28
    diffusivity = 8e-3
  []
  [gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  []
  [reaction_1]
    type = ADCoupledEEDFRates
    electrons = em
    mean_energy = mean_en
    reaction = 'k_ionization'
    rate_value = ionization_rate
    d_rate_d_actual_mean_en = d_ionization_rate_d_actual_energy
  []

  [nuAr+]
    type = ADParsedMaterial
    property_name = 'nuAr+'
    constant_names = 'ee         mu_p m_p'
    constant_expressions = '1.6022e-19 0.28 6.64e-26'
    expression = 'ee / (mu_p * m_p)'
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

  start_time = 0.0
  end_time = 1.6593e-5

  # end_time = 1.6593e-5

  # end_time = 7.4e-5
  # end_time = 0.000141076
  # end_time = 21.4822e-5

  #end_time = 14.8e-5

  dt = 1e-9
  # dt = 1e-12
  dtmin = 1e-14

  automatic_scaling = true
  compute_scaling_once = false
  # scheme = newmark-beta
  # scheme = implicit-euler
  solve_type = NEWTON
  line_search = none

  l_max_its = 20
  nl_max_its = 25
  # nl_abs_tol = 1e-12
  nl_rel_tol = 1e-6

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  #petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  #petsc_options_value = 'lu NONZERO 1.e-10'
  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly   lu       superlu_dist'

  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount'
  #petsc_options_value = 'lu superlu_dist NONZERO 1.e-10'
[]

#Defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  checkpoint = true
  [out]
    type = Exodus
  []
[]
