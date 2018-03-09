dom0Scale=1e-3

[GlobalParams]
  offset = 20
  potential_units = kV
  use_moles = true
  position_units = ${dom0Scale}
  em = em
  potential = potential
  #resist = 1
[]

[Mesh]
  # A 2D parallel plate with a axis of symmetry
  type = FileMesh
  file = '2d_2plates.msh'
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  kernel_coverage_check = false
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    #ksp_norm = none
  [../]
[]

[Executioner]
  type = Transient
  end_time = 1e-1
  solve_type = PJFNK
  nl_rel_tol = 1e-2
    dtmin = 1e-12
    [./TimeStepper]
      type = IterationAdaptiveDT
      cutback_factor = 0.4
      dt = 1e-9
      growth_factor = 1.2
     optimal_iterations = 15
    [../]
  []

  [Outputs]
    print_perf_log = true
    print_linear_residuals = false
    [./out]
      type = Exodus
    [../]
  []

  [Debug]
    show_var_residual_norms = true
  []

[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
    block = plasma
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential
    mean_en = mean_en
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./em_ionization]
    type = ElectronsFromIonization
    variable = em
    potential = potential
    mean_en = mean_en
    em = em
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
    block = plasma
  [../]
  [./em_advection_stabilization]
    type = EFieldArtDiff
    variable = em
    potential = potential
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./potential_diffusion_dom1]
    type = CoeffDiffusionLin
    variable = potential
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./Arp_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Arp
    block = plasma
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
    block = plasma
  [../]
  [./Arp_time_deriv]
    type = ElectronTimeDerivative
    variable = Arp
    block = plasma
  [../]
  [./Arp_advection]
    type = EFieldAdvection
    variable = Arp
    potential = potential
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./Arp_diffusion]
    type = CoeffDiffusion
    variable = Arp
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./Arp_ionization]
    type = IonsFromIonization
    variable = Arp
    potential = potential
    em = em
    mean_en = mean_en
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./Arp_log_stabilization]
    type = LogStabilizationMoles
    variable = Arp
    block = plasma
  [../]
  [./Arp_advection_stabilization]
    type = EFieldArtDiff
    variable = Arp
    potential = potential
    block = plasma
    #position_units = ${dom0Scale}
  [../]
  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
    block = plasma
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./mean_en_ionization]
    type = ElectronEnergyLossFromIonization
    variable = mean_en
    potential = potential
    em = em
    block = plasma
    #position_units = ${dom0Scale}
  [../]
  [./mean_en_elastic]
    type = ElectronEnergyLossFromElastic
    variable = mean_en
    potential = potential
    em = em
    block = plasma
    #position_units = ${dom0Scale}
  [../]
  [./mean_en_excitation]
    type = ElectronEnergyLossFromExcitation
    variable = mean_en
    potential = potential
    em = em
    block = plasma
    #position_units = ${dom0Scale}
  [../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    block = plasma
    offset = 15
  [../]
  [./mean_en_advection_stabilization]
    type = EFieldArtDiff
    variable = mean_en
    potential = potential
    block = plasma
    position_units = ${dom0Scale}
  [../]
[]

[Variables]
  [./potential]
  [../]
  [./em]
    block = plasma
  [../]

  [./Arp]
    block = plasma
  [../]

  [./mean_en]
    block = plasma
  [../]
[]

[AuxVariables]
  [./e_temp]
    block = plasma
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
    block = plasma
  [../]
  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./Arp_lin]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./Efield]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Current_em]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./Current_Arp]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./tot_gas_current]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./EFieldAdvAux_em]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./DiffusiveFlux_em]
    order = CONSTANT
    family = MONOMIAL
    block = plasma
  [../]
  [./PowerDep_em]
   order = CONSTANT
   family = MONOMIAL
   block = plasma
  [../]
  [./PowerDep_Arp]
   order = CONSTANT
   family = MONOMIAL
   block = plasma
  [../]
  [./ProcRate_el]
   order = CONSTANT
   family = MONOMIAL
   block = plasma
  [../]
  [./ProcRate_ex]
   order = CONSTANT
   family = MONOMIAL
   block = plasma
  [../]
  [./ProcRate_iz]
   order = CONSTANT
   family = MONOMIAL
   block = plasma
  [../]
[]

[AuxKernels]
  [./PowerDep_em]
    type = PowerDep
    density_log = em
    potential = potential
    art_diff = false
    potential_units = kV
    variable = PowerDep_em
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./PowerDep_Arp]
    type = PowerDep
    density_log = Arp
    potential = potential
    art_diff = false
    potential_units = kV
    variable = PowerDep_Arp
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./ProcRate_el]
    type = ProcRate
    em = em
    potential = potential
    proc = el
    variable = ProcRate_el
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./ProcRate_ex]
    type = ProcRate
    em = em
    potential = potential
    proc = ex
    variable = ProcRate_ex
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./ProcRate_iz]
    type = ProcRate
    em = em
    potential = potential
    proc = iz
    variable = ProcRate_iz
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./e_temp]
    type = ElectronTemperature
    variable = e_temp
    electron_density = em
    mean_en = mean_en
    block = plasma
  [../]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./rho]
    type = ParsedAux
    variable = rho
    args = 'em_lin Arp_lin'
    function = 'Arp_lin - em_lin'
    execute_on = 'timestep_end'
    block = plasma
  [../]
  [./tot_gas_current]
    type = ParsedAux
    variable = tot_gas_current
    args = 'Current_em Current_Arp'
    function = 'Current_em + Current_Arp'
    execute_on = 'timestep_end'
    block = plasma
  [../]
  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
    block = plasma
  [../]
  [./Arp_lin]
    type = DensityMoles
    convert_moles = true
    variable = Arp_lin
    density_log = Arp
    block = plasma
  [../]
  [./Efield_g]
    type = Efield
    component = 0
    potential = potential
    variable = Efield
    position_units = ${dom0Scale}
    block = plasma
  [../]
  [./Current_em]
    type = Current
    potential = potential
    density_log = em
    variable = Current_em
    art_diff = false
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./Current_Arp]
    type = Current
    potential = potential
    density_log = Arp
    variable = Current_Arp
    art_diff = false
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./EFieldAdvAux_em]
    type = EFieldAdvAux
    potential = potential
    density_log = em
    variable = EFieldAdvAux_em
    block = plasma
    position_units = ${dom0Scale}
  [../]
  [./DiffusiveFlux_em]
    type = DiffusiveFlux
    density_log = em
    variable = DiffusiveFlux_em
    block = plasma
    position_units = ${dom0Scale}
  [../]
[]

[BCs]
  [./potential_cathode]
    type = DirichletBC
    variable = potential
    boundary = Top_plate
    value = 1
    #type = CircuitDirichletPotential
    #surface_potential = cathode_func
    #current = cathode_flux
    #boundary = Top_plate
    #variable = potential
    #surface = Top_plate
    #position_units = ${dom0Scale}
  [../]
  [./potential_anode]
    type = DirichletBC
    variable = potential
    boundary = dish
    value = 0
  [../]
  [./electrons]
    type = HagelaarElectronBC
    variable = em
    boundary = 'dish Top_plate walls'
    # boundary = 'dish Top_plate'
    potential = potential
    ip = Arp
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./sec_electrons]
    type = SecondaryElectronBC
    variable = em
    boundary = 'dish Top_plate walls'
    # boundary = 'dish Top_plate'
    potential = potential
    ip = Arp
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./ions_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'dish Top_plate walls'
    # boundary = 'dish Top_plate'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./ions_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'dish Top_plate walls'
    # boundary = 'dish Top_plate'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'dish Top_plate walls'
    # boundary = 'dish Top_plate'
    potential = potential
    em = em
    ip = Arp
    r = 0
    position_units = ${dom0Scale}
  [../]
[]

[ICs]
  [./em_ic]
    type = ConstantIC
    variable = em
    value = -21
    block = plasma
  [../]
  [./Arp_ic]
    type = ConstantIC
    variable = Arp
    value = -21
    block = plasma
  [../]
  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -20
    block = plasma
  [../]
  [./potential_ic]
    type = ConstantIC
    variable = potential
    value = 0
  [../]
[]

[Materials]
  [./gas_block]
    type = Gas
    interp_trans_coeffs = true
    interp_elastic_coeff = true
    ramp_trans_coeffs = false
    em = em
    potential = potential
    ip = Arp
    mean_en = mean_en
    user_se_coeff = .15
    block = plasma
    property_tables_file = td_argon_mean_en.txt
 [../]
 [./cathode_boundary]
   type = GenericConstantMaterial
   prop_names = 'T_heavy'
   prop_values = '293'
 [../]
[]

#[Postprocessors]
#[./cathode_flux]
    #type = SideTotFluxIntegral
    #execute_on = nonlinear
    ## execute_on = linear
    #boundary = Top_plate
    #mobility = muArp
    #potential = potential
    #variable = Arp
    #r = 0
    #position_units = ${dom0Scale}
  #[../]
#[]

#[Functions]
  #[./cathode_func]
    #type = ParsedFunction
    #value = '-1.25 * tanh(1e6 * t)'
  #[../]
#[]
