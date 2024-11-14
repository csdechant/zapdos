#This tutorial is of an argon CCP discharge running at
#different pressures. In this case, the electron and ion coefficient are
#linearly proportional. For the following pressures,
#(0.1, 1, 10, 100, 1000 Torr)
#change the following lines (144, 245, and 257-258).

#A uniform scaling factor of the mesh.
#E.g if set to 1.0, there is not scaling
# and if set to 0.010, there mesh is scaled by a cm
dom0Scale=1.0

[GlobalParams]
  #Scales the potential by V or kV
  potential_units = kV
  #Converts density from #/m^3 to moles/m^3
  use_moles = true
[]

[Mesh]
  #Mesh is define by a previous output file
  [./geo]
    type = FileMeshGenerator
    file = 'PERSEUS_chamber_1.msh'
  [../]
[]

#Defines the problem type, such as FE, eigen value problem, etc.
[Problem]
  type = FEProblem
[]


[DriftDiffusionAction]
  #define the following for each material, except for walls
  [./plasma]
    #User define name for potential (usually 'potential')
    potential = potential_P
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'plasma'
  [../]
  [./Top_Center_Electrode]
    potential = potential_TCE
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Top_Center_Electrode'
  [../]
  [./Top_Outer_Insulator]
    potential = potential_TOI
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Top_Outer_Insulator'
  [../]
  [./Bottom_Center_Electrode]
    potential = potential_BCE
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Bottom_Center_Electrode'
  [../]
  [./Bottom_Inner_Insulator]
    potential = potential_BII
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Bottom_Inner_Insulator'
  [../]
  [./Bottom_Ring_Electrode]
    potential = potential_BRE
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Bottom_Ring_Electrode'
  [../]
  [./Bottom_Outer_Insulator]
    potential = potential_BOI
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Bottom_Outer_Insulator'
  [../]
  [./Walls]
    potential = potential_Walls
    Is_potential_unique = true
    position_units = ${dom0Scale}
    Additional_Outputs = 'EField'
    block = 'Walls'
  [../]
[]

[AuxVariables]
  #Add a scaled position units used for plotting other element AuxVariables
  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  #Add at scaled position units used for plotting other element AuxVariables
  [./x_ng]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  [../]
[]

#Define function used throughout the input file (e.g. BCs)
[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    value = '8.37*sin(2*3.1415926*13.56e6*t)'
  [../]
[]

#Currently there is no Action for BC (but one is currently in development)
#Below is the Sakiyama family of BC
#(For other BC example, please look at Tutorial 05 and Tutorial 06)
[BCs]
  #Voltage Boundary Condition
  #powered
  [./potential_BCE]
    type = FunctionDirichletBC
    variable = potential_BCE
    boundary = 'BCE_plasma'
    function = potential_bc_func
    preset = false
  [../]
  #grounded
  [./potential_TCE]
    type = DirichletBC
    variable = potential_TCE
    boundary = 'TCE_plasma'
    value = 0
    preset = false
  [../]
  [./potential_Walls]
    type = DirichletBC
    variable = potential_Walls
    boundary = 'Walls_plasma'
    value = 0
    preset = false
  [../]
  # for all interface that plasma touches dielectric
  # Interface BCs:
  [./match_potential_BII]
    type = MatchedValueBC
    variable = potential_BII
    v = potential_BCE
    boundary = 'BII_BCE'
  [../]
  [./match_potential_BOI]
    type = MatchedValueBC
    variable = potential_BOI
    v = potential_Walls
    boundary = 'BOI_Walls'
  [../]
  [./match_potential_TOI]
    type = MatchedValueBC
    variable = potential_TOI
    v = potential_Walls
    boundary = 'TOI_Walls'
  [../]
  [./match_potential_BRE]
    type = MatchedValueBC
    variable = potential_BRE
    v = potential_p
    boundary = 'BRE_plasma'
  [../]
[]

[Materials]
  #The material properties for electrons.
  #Also hold universal constant, such as Avogadro's number, elementary charge, etc.
  [./GasBasics]
    type = GasElectronMoments
    #True means variable electron coeff, defined by user
    interp_trans_coeffs = true
    #Leave as false (CRANE accounts of elastic coeff.)
    interp_elastic_coeff = false
    #Leave as false, unless computational error is due to rapid coeff. changes
    ramp_trans_coeffs = false
    #Name for potential (usually 'potential')
    #potential = potential
    #User difine pressure in pa
    user_p_gas = 0.01
    #True if pressure dependent coeff.
    pressure_dependent_electron_coeff = true
    #Name of text file with electron properties
    property_tables_file = rate_coefficients/electron_moments.txt
  []
  # change the permittivity and block for each dielectric
  [./gas_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_dom1'
    prop_values = '8.8542e-12'
    block = 'plasma'
  [../]
  [./bottom_inner_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_dom2'
    prop_values = '22.4011e-12'
    block = 'Bottom_Inner_Insulator'
  [../]
  [./bottom_outer_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_dom3'
    prop_values = '22.4011e-12'
    block = 'Bottom_Outer_Insulator'
  [../]
  [./top_outer_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_dom4'
    prop_values = '22.4011e-12'
    block = 'Top_Outer_Insulator'
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
  start_time = 0
  end_time = 7.3746e-5
  dt = 1e-9
  dtmin = 1e-14
  scheme = bdf2
  solve_type = NEWTON

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 1e-3'

  nl_rel_tol = 1e-08
  l_max_its = 20
[]

#Defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
