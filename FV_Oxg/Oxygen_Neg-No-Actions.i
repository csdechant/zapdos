#This tutorial is of an electronegative oxygen discharge
#model. This is explained in Lieberman, page 259.



#A uniform scaling factor of the mesh.
#E.g if set to 1.0, there is not scaling
# and if set to 0.010, there mesh is scaled by a cm
# See Lieberman pg 364 and figure 10.6
#dom0Scale=45e-3
dom0Scale=1.0

[GlobalParams]
  #Scales the potential by V or kV
  potential_units = kV
  #Converts density from #/m^3 to moles/m^3
  use_moles = true
[]

[Mesh]
  #Mesh is define by a Gmsh file
  [./geo]
    type = FileMeshGenerator
    file = 'Lymberopoulos_paper_NoScale.msh'
  [../]
  #Renames all sides with the specified normal
  #For 1D, this is used to rename the end points of the mesh
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
  uniform_refine = 1
[]

#Defines the problem type, such as FE, eigen value problem, etc.
[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
  [../]

  [./O-]
  [../]

  [./O2+]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]
[]


[Kernels]
#Electron Equations
  #Time Derivative term of electron
  [./em_time_deriv]
    type = TimeDerivativeLog
    variable = em
  [../]
  #Advection term of electron
  [./em_advection]
    type = EFieldAdvection
    variable = em
    potential = potential
    position_units = ${dom0Scale}
  [../]
  #Diffusion term of electrons
  [./em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = ${dom0Scale}
  [../]
  #Net electron production from ionization
  [./em_pos_ionization]
    type = ADEEDFReactionLog
    variable = em
    electrons = em
    target = O2
    reaction = 'em + O2 -> em + em + O2+'
    coefficient = 1
  [../]
  #Net electron production from step-wise ionization
  [./em_neg_ionization]
    type = ADEEDFReactionLog
    variable = em
    electrons = em
    target = O2
    reaction = 'em + O2 -> O + O-'
    coefficient = -1
  [../]

#Argon Ion Equations
  #Time Derivative term of the ions
  [./O2+_time_deriv]
    type = TimeDerivativeLog
    variable = O2+
  [../]
  #Advection term of ions
  [./O2+_advection]
    type = EFieldAdvection
    variable = O2+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./O2+_diffusion]
    type = CoeffDiffusion
    variable = O2+
    position_units = ${dom0Scale}
  [../]
  #Net ion production from ionization
  [./O2+_ionization]
    type = ADEEDFReactionLog
    variable = O2+
    electrons = em
    target = O2
    reaction = 'em + O2 -> em + em + O2+'
    coefficient = 1
  [../]
  #Net ion production from metastable pooling
  [./O2+_pooling]
    type = ReactionSecondOrderLog
    variable = O2+
    v = O2+
    w = O-
    reaction = 'O2+ + O- -> O2 + O'
    coefficient = -1
    _v_eq_u = true
  [../]

#Argon Ion Equations
  #Time Derivative term of the ions
  [./O-_time_deriv]
    type = TimeDerivativeLog
    variable = O-
  [../]
  #Advection term of ions
  [./O-_advection]
    type = EFieldAdvection
    variable = O-
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./O-_diffusion]
    type = CoeffDiffusion
    variable = O-
    position_units = ${dom0Scale}
  [../]
  #Net ion production from ionization
  [./O-_ionization]
    type = ADEEDFReactionLog
    variable = O-
    electrons = em
    target = O2
    reaction = 'em + O2 -> O + O-'
    coefficient = 1
  [../]
  #Net ion production from metastable pooling
  [./O-_pooling]
    type = ReactionSecondOrderLog
    variable = O-
    v = O-
    w = O2+
    reaction = 'O2+ + O- -> O2 + O'
    coefficient = -1
    _v_eq_u = true
  [../]

#Voltage Equations
  #Voltage term in Poissons Eqaution
  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]
  #Ion term in Poissons Equation
  [./O2+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = O2+
  [../]
  [./O-_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = O-
  [../]
  #Electron term in Poissons Equation
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
  [../]

#Electron Energy Equations
  #Time Derivative term of electron energy
  [./mean_en_time_deriv]
    type = TimeDerivativeLog
    variable = mean_en
  [../]
  #Advection term of electron energy
  [./mean_en_advection]
    type = EFieldAdvection
    variable = mean_en
    potential = potential
    position_units = ${dom0Scale}
  [../]
  #Diffusion term of electrons energy
  [./mean_en_diffusion]
    type = CoeffDiffusion
    variable = mean_en
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  #Energy loss from ionization
  [./Ionization_Loss]
    type = ADEEDFEnergyLog
    variable = mean_en
    electrons = em
    target = O2
    reaction = 'em + O2 -> em + em + O2+'
    threshold_energy = -12.06
  [../]
[]


[AuxVariables]
  #Add a scaled position units used for plotting other element AuxVariables
  [./x_node]
  [../]

  #Background gas (e.g Ar)
  [./O2]
  [../]

  [./Te]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./O2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./O-_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  #Add at scaled position units used for plotting other element AuxVariables
  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  #Background gas number density (e.g. for 1Torr)
  [./O2_val]
    type = FunctionAux
    variable = O2
    function = 'log(1.6e21/6.022e23)'
    execute_on = INITIAL
  [../]

  [./Te]
    type = ElectronTemperature
    variable = Te
    electron_density = em
    mean_en = mean_en
  [../]
  [./em_lin]
    type = DensityMoles
    variable = em_lin
    density_log = em
  [../]
  [./O2+_lin]
    type = DensityMoles
    variable = O2+_lin
    density_log = O2+
  [../]
  [./O-_lin]
    type = DensityMoles
    variable = O-_lin
    density_log = O-
  [../]
[]

#Currently there is no Action for BC (but one is currently in development)
#Below is the Lymberopulos family of BC
#(For other BC example, please look at Tutorial 04 and Tutorial 06)
[BCs]
#Voltage Boundary Condition Ffor a Power-Ground RF Discharge
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

  #Boundary conditions for electons
  [./em_physical_diffusion]
    type = SakiyamaElectronDiffusionBC
    variable = em
    mean_en = mean_en
    boundary = 'left right'
    position_units = ${dom0Scale}
  [../]

  #Boundary conditions for ions
    [./O-_physical_advection]
      type = SakiyamaIonAdvectionBC
      variable = O-
      potential = potential
      boundary = 'left right'
      position_units = ${dom0Scale}
    [../]

    [./O2+_physical_advection]
      type = SakiyamaIonAdvectionBC
      variable = O2+
      potential = potential
      boundary = 'left right'
      position_units = ${dom0Scale}
    [../]


  #New Boundary conditions for mean energy, should be the same as in paper
    [./mean_en_physical_diffusion]
      type = SakiyamaEnergyDiffusionBC
      variable = mean_en
      em = em
      boundary = 'left right'
      position_units = ${dom0Scale}
    [../]
  []

#Initial conditions for variables.
#If left undefine, the IC is zero
[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  [../]
  [./O-_ic]
    type = FunctionIC
    variable = O-
    function = ion_density_ic_func
  [../]
  [./O2+_ic]
    type = FunctionIC
    variable = O2+
    function = ion_density_ic_func
  [../]
  [./mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
  [../]
[]

#Define function used throughout the input file (e.g. BCs and ICs)
[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    value = '0.050*sin(2*pi*13.56e6*t)'
  [../]
  [./ion_density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/(45e-3))^2 * (x/(45e-3))^2)/6.022e23)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/(45e-3))^2 * (x/(45e-3))^2)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e13 + 1e15 * (1-x/(45e-3))^2 * (x/(45e-3))^2)/6.022e23)'
  [../]
[]

[Materials]
  #The material properties for electrons.
  #Also hold universal constant, such as Avogadro's number, elementary charge, etc.
  [./GasBasics]
    type = GasElectronMoments
    #False means constant electron coeff, defined by user
    interp_trans_coeffs = true
    #Leave as false (CRANE accounts of elastic coeff.)
    interp_elastic_coeff = false
    #Leave as false, unless computational error is due to rapid coeff. changes
    ramp_trans_coeffs = false
    #User difine pressure in pa
    user_p_gas = 6.666
    #Name for electrons (usually 'em')
    em = em
    #Name for potential (usually 'potential')
    potential = potential
    #Name for the electron mean energy density (usually 'mean_en')
    mean_en = mean_en
    #User define electron mobility coeff. (define as 0.0 if not used)
    #user_electron_mobility = 30.0 #2.0160e24
    #User define electron diffusion coeff. (define as 0.0 if not used)
    #user_electron_diffusion_coeff = 119.8757763975 #5.96e24 119.8757763975
    pressure_dependent_electron_coeff = true
    #Name of text file with electron properties
    property_tables_file = rate_coefficients/oxygen_electron_moments.txt
  [../]
  #The material properties of the ion
  [./gas_species_O-]
    type = ADHeavySpecies
    heavy_species_name = O-
    heavy_species_mass = 2.6559e-26
    heavy_species_charge = -1.0
    mobility = 9.5322
    diffusivity = 0.2468
  [../]
  [./gas_species_O2+]
    type = ADHeavySpecies
    heavy_species_name = O2+
    heavy_species_mass = 5.3137e-26
    heavy_species_charge = 1.0
    mobility = 4.7644
    diffusivity = 0.1234
  [../]
  #The material properties of the background gas
  [./gas_species_2]
    type = ADHeavySpecies
    heavy_species_name = O2
    heavy_species_mass = 5.3137e-26
    heavy_species_charge = 0.0
  [../]


  [./reaction_0]
    type = ADDerivativeParsedMaterial
    f_name = 'k_em + O2 -> em + em + O2+'
    args = 'Te'
    function = '2.13e-14 * exp(-14.5/Te) * 6.022e23'
    derivative_order = 1
  [../]
  [./reaction_1]
    type = ADDerivativeParsedMaterial
    f_name = 'k_em + O2 -> O + O-'
    args = 'Te'
    function = '7.89e-17 * exp(-3.07/Te) * 6.022e23'
    derivative_order = 1
  [../]
  [./reaction_2]
    type = GenericRateConstant
    reaction = 'O2+ + O- -> O2 + O'
    #reaction_rate_value = 1.4e-13
    reaction_rate_value = 84308000000
  [../]
[]

#Preconditioning options
#Learn more at: https://mooseframework.inl.gov/syntax/Preconditioning/index.html
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

#How to execute the problem.
#Defines type of solve (such as steady or transient),
# solve type (Newton, PJFNK, etc.) and tolerances
[Executioner]
  type = Transient
  end_time = 7.3746e-5
  #end_time = 1e-5
  dt = 1e-9
  dtmin = 1e-14
  #scheme = bdf2
  scheme = newmark-beta
  solve_type = NEWTON

  #petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options = '-snes_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  nl_rel_tol = 1e-08
  l_max_its = 20

  line_search = none
  automatic_scaling = true
  compute_scaling_once = false
[]

[Outputs]
  #perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
