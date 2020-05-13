#Output Log Summary:
#File ran on 4 nodes with 16 cores per node.
#Simulation run for the allowed wall time (48 hours)
#and finished at t=5.921e-6

dom0Scale=25.4e-3

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'GEC_mesh.msh'
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [./potential_ion]
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
[]


[AuxVariables]
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
    type = EconomouDielectricBC_FluidFlux
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
  end_time = 7.4e-3
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
