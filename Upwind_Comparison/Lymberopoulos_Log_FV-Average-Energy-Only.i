# Notes:
# Failed at 'time = 1.57151e-06' with 'Solve failed and timestep already at or below dtmin'


#dom0Scale=25.4e-3
dom0Scale=1.0

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  [./file]
    type = FileMeshGenerator
    file = 'Lymberopoulos_paper_NoScale.msh'
  [../]
  [./left]
    type = SideSetsFromNormalsGenerator
    normals = '-1 0 0'
    new_boundary = 'left'
    input = file
  [../]
  [./right]
    type = SideSetsFromNormalsGenerator
    normals = '1 0 0'
    new_boundary = 'right'
    input = left
  [../]
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./Ar+]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./mean_en]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  [../]

  [./potential]
  [../]
[]

[FVKernels]
#Electron Equations
  #Time Derivative term of electron
  [./em_time_deriv]
    type = FVTimeKernelLog
    variable = em
  [../]
  #Advection term of electron
  [./em_advection]
    type = FVEFieldAdvection
    variable = em
    potential = potential
    position_units = ${dom0Scale}
    advected_interp_method = upwind
  [../]
  #Diffusion term of electrons
  [./em_diffusion]
    type = FVCoeffDiffusion
    variable = em
    position_units = ${dom0Scale}
  [../]
  #Net electron production from ionization
  [./em_ionization]
    type = FVEEDFReactionLog
    variable = em
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  [../]

#Argon Ion Equations
  #Time Derivative term of the ions
  [./Ar+_time_deriv]
    type = FVTimeKernelLog
    variable = Ar+
  [../]
  #Advection term of ions
  [./Ar+_advection]
    type = FVEFieldAdvection
    variable = Ar+
    potential = potential
    position_units = ${dom0Scale}
    advected_interp_method = upwind
  [../]
  [./Ar+_diffusion]
    type = FVCoeffDiffusion
    variable = Ar+
    position_units = ${dom0Scale}
  [../]
  #Net ion production from ionization
  [./Ar+_ionization]
    type = FVEEDFReactionLog
    variable = Ar+
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  [../]

#Electron Energy Equations
  #Time Derivative term of electron energy
  [./mean_en_time_deriv]
    type = FVTimeKernelLog
    variable = mean_en
  [../]
  #Advection term of electron energy
  [./mean_en_advection]
    type = FVEFieldAdvection
    variable = mean_en
    potential = potential
    position_units = ${dom0Scale}
    advected_interp_method = average
  [../]
  #Diffusion term of electrons energy
  [./mean_en_diffusion]
    type = FVCoeffDiffusion
    variable = mean_en
    position_units = ${dom0Scale}
  [../]
  #The correction for electrons energy's diffusion term
  #[./mean_en_diffusion_correction]
  #  type = FVThermalConductivityDiffusion
  #  variable = mean_en
  #  em = em
  #  position_units = ${dom0Scale}
  #[../]
  #Joule Heating term
  [./mean_en_joule_heating]
    type = FVJouleHeating_Element
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  #Energy loss from ionization
  [./Ionization_Loss]
    type = FVEEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    threshold_energy = -15.7
  [../]
  #Energy loss from excitation
  [./Excitation_Loss]
    type = FVEEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar*'
    threshold_energy = -11.56
  [../]
[]

[Kernels]
  #Voltage Equations
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

  [./em_mole]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Ar+_mole]
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
    position_units = ${dom0Scale}
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./em_mole]
    type = DensityMoles
    variable = em_mole
    density_log = em
  [../]
  [./Ar+_mole]
    type = DensityMoles
    variable = Ar+_mole
    density_log = Ar+
  [../]

  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 3.22e22
    #value = 0.053470617
    value = -2.928623
    execute_on = INITIAL
  [../]
[]

[FVBCs]
#Boundary conditions for electons
  [./em_physical_right]
    type = FVLymberopoulosElectronBC
    variable = em
    boundary = 'right'
    gamma = 0.01
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
    # Using Upwind since the advection term is based on the ions
    advected_interp_method = upwind
  [../]
  [./em_physical_left]
    type = FVLymberopoulosElectronBC
    variable = em
    boundary = 'left'
    gamma = 0.01
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
    # Using Upwind since the advection term is based on the ions
    advected_interp_method = upwind
  [../]

#Boundary conditions for ions
  [./Ar+_physical_right_advection]
    type = FVLymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'right'
    position_units = ${dom0Scale}
    advected_interp_method = upwind
  [../]
  [./Ar+_physical_left_advection]
    type = FVLymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'left'
    position_units = ${dom0Scale}
    advected_interp_method = upwind
  [../]

#Boundary conditions for electron mean energy
  [./mean_en_physical_right]
    type = FVElectronTemperatureDirichletBC_Flux
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'right'
  [../]
  [./mean_en_physical_left]
    type = FVElectronTemperatureDirichletBC_Flux
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'left'
  [../]
[]

[BCs]
#Voltage Boundary Condition
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left'
    function = potential_bc_func
    preset = false
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 0
    preset = false
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
  [./mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  [../]
[]

[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    value = '100.0*sin(2*pi*13.56e6*t)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/(25.4e-3))^2 * (x/(25.4e-3))^2)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e13 + 1e15 * (1-x/(25.4e-3))^2 * (x/(25.4e-3))^2)/6.022e23)'
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
    #potential = potential
    mean_en = mean_en
    user_electron_mobility = 30.0
    user_electron_diffusion_coeff = 119.8757763975
    property_tables_file = Argon_reactions_RateCoefficients/electron_moments.txt
  [../]
  [./gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.144409938
    diffusivity = 6.428571e-3
  [../]
  [./gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
  [./reaction_0]
    type = InterpolatedCoefficientLinear
    mean_energy = mean_en
    property_file = 'Argon_reactions_RateCoefficients/reaction_em + Ar -> em + Ar*.txt'
    reaction = 'em + Ar -> em + Ar*'
    file_location = ''
    electrons = em
  [../]
  [./reaction_1]
    type = InterpolatedCoefficientLinear
    mean_energy = mean_en
    property_file = 'Argon_reactions_RateCoefficients/reaction_em + Ar -> em + em + Ar+.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    file_location = ''
    electrons = em
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
  end_time = 7.375e-5 #~1000 RF cycles
  #end_time = 1e-6
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  line_search = none
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  scheme = newmark-beta
  dt = 1e-9
  dtmin = 1e-14

  automatic_scaling = true
  compute_scaling_once = false
[]

[Outputs]
  file_base = 'Log-Average_mean-Upwind_ion_em'
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
