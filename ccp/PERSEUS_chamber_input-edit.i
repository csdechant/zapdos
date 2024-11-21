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

  [./plasma_bottom_inner]
    # plasma master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'plasma'
    paired_block = 'Bottom_Inner_Insulator'
    new_boundary = 'plasma_bottom_inner'
    input = geo
  [../]
  [./dielectric_bottom_inner]
    # bottom inner dielectric master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'Bottom_Inner_Insulator'
    paired_block = 'plasma'
    new_boundary = 'dielectric_bottom_inner'
    input = plasma_bottom_inner
  [../]

  [./plasma_bottom_outer]
    # plasma master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'plasma'
    paired_block = 'Bottom_Outer_Insulator'
    new_boundary = 'plasma_bottom_outer'
    input = dielectric_bottom_inner
  [../]
  [./dielectric_bottom_outer]
    # bottom outer dielectric master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'Bottom_Outer_Insulator'
    paired_block = 'plasma'
    new_boundary = 'dielectric_bottom_outer'
    input = plasma_bottom_outer
  [../]

  [./plasma_top_outer]
    # plasma master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'plasma'
    paired_block = 'Top_Outer_Insulator'
    new_boundary = 'plasma_top_outer'
    input = dielectric_bottom_outer
  [../]
  [./dielectric_top_outer]
    # top outer dielectric master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'Top_Outer_Insulator'
    paired_block = 'plasma'
    new_boundary = 'dielectric_top_outer'
    input = plasma_top_outer
  [../]

  [./plasma_bottom_center]
    # plasma master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'plasma'
    paired_block = 'Bottom_Center_Electrode'
    new_boundary = 'plasma_bottom_center'
    input = dielectric_top_outer
  [../]
  [./electrode_bottom_center]
    # bottom center electrode master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'Bottom_Center_Electrode'
    paired_block = 'plasma'
    new_boundary = 'electrode_bottom_center'
    input = plasma_bottom_center
  [../]

  [./plasma_bottom_ring]
    # plasma master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'plasma'
    paired_block = 'Bottom_Ring_Electrode'
    new_boundary = 'plasma_bottom_ring'
    input = electrode_bottom_center
  [../]
  [./electrode_bottom_ring]
    # bottom ring electrode master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'Bottom_Ring_Electrode'
    paired_block = 'plasma'
    new_boundary = 'electrode_bottom_ring'
    input = plasma_bottom_ring
  [../]

  [./plasma_top_ring]
    # plasma master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'plasma'
    paired_block = 'Top_Center_Electrode'
    new_boundary = 'plasma_top_ring'
    input = electrode_bottom_ring
  [../]
  [./electrode_top_ring]
    # top ring electrode master
    type = SideSetsBetweenSubdomainsGenerator
    primary_block = 'Top_Center_Electrode'
    paired_block = 'plasma'
    new_boundary = 'electrode_top_ring'
    input = plasma_top_ring
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
    potential = potential_plasma
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'plasma'
  [../]
  [./Top_Center_Electrode]
    #User define name for potential (usually 'potential')
    potential = potential_top_electrode
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'Top_Center_Electrode'
  [../]
  [./Top_Outer_Insulator]
    #User define name for potential (usually 'potential')
    potential = potential_top_insulator
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'Top_Outer_Insulator'
  [../]
  [./Bottom_Center_Electrode]
    #User define name for potential (usually 'potential')
    potential = potential_bottom_electrode
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'Bottom_Center_Electrode'
  [../]
  [./Bottom_Inner_Insulator]
    #User define name for potential (usually 'potential')
    potential = potential_bottom_inner_insulator
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'Bottom_Inner_Insulator'
  [../]
  [./Bottom_Ring_Electrode]
    #User define name for potential (usually 'potential')
    potential = potential_bottom_electrode
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'Bottom_Ring_Electrode'
  [../]
  [./Bottom_Outer_Insulator]
    #User define name for potential (usually 'potential')
    potential = potential_bottom_out_insulator
    #Defines if this potential exist in only one block/material (set 'true' for single gases)
    Is_potential_unique = true
    #The position scaling for the mesh, define at top of input file
    position_units = ${dom0Scale}
    #Additional outputs, such as ElectronTemperature, Current, and EField.
    Additional_Outputs = 'EField'
    block = 'Bottom_Outer_Insulator'
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
    value = '8.37*sin(2*pi*13.56e6*t)'
  [../]
[]

#Currently there is no Action for BC (but one is currently in development)
#Below is the Sakiyama family of BC
#(For other BC example, please look at Tutorial 05 and Tutorial 06)
[BCs]
  #Voltage Boundary Condition
  #powered
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential_plasma
    boundary = 'electrode_bottom_center'
    function = potential_bc_func
    preset = false
  [../]
  #grounded
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential_plasma
    boundary = 'plasma_top_ring'
    value = 0
    preset = false
  [../]
  # for all interface that plasma touches dielectric
  # Interface BCs:
  [./match_potential_bottom_inner]
    type = MatchedValueBC
    variable = potential_bottom_inner_insulator
    v = potential_plasma
    boundary = 'dielectric_bottom_inner'
  [../]
  [./match_potential_bottom_outer]
    type = MatchedValueBC
    variable = potential_bottom_out_insulator
    v = potential_plasma
    boundary = 'dielectric_bottom_outer'
  [../]
  [./match_potential_top_outer]
    type = MatchedValueBC
    variable = potential_top_insulator
    v = potential_plasma
    boundary = 'dielectric_top_outer'
  [../]
[]

[Materials]
  #The material properties for electrons.
  #Also hold universal constant, such as Avogadro's number, elementary charge, etc.
  #[./GasBasics]
  #  type = GasElectronMoments
  #  #True means variable electron coeff, defined by user
  #  interp_trans_coeffs = false
  #  #Leave as false (CRANE accounts of elastic coeff.)
  #  interp_elastic_coeff = false
  #  #Leave as false, unless computational error is due to rapid coeff. changes
  #  ramp_trans_coeffs = false
  #  #Name for potential (usually 'potential')
  #  potential = potential_plasma
  #  #User difine pressure in pa
  #  user_p_gas = 0.01
  #  #True if pressure dependent coeff.
  #  pressure_dependent_electron_coeff = true
  #  #Name of text file with electron properties
  #  property_tables_file = rate_coefficients/electron_moments.txt
  #[]
  # change the permittivity and block for each dielectric
  [./gas_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_plasma'
    prop_values = '8.8542e-12'
    block = 'plasma'
  [../]
  [./bottom_inner_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_bottom_inner_insulator'
    prop_values = '22.4011e-12'
    block = 'Bottom_Inner_Insulator'
  [../]
  [./bottom_outer_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_bottom_out_insulator'
    prop_values = '22.4011e-12'
    block = 'Bottom_Outer_Insulator'
  [../]
  [./top_outer_phase]
    type = ADGenericConstantMaterial
    prop_names = 'diffpotential_top_insulator'
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
  #end_time = 7.3746e-5
  end_time = 1e-8
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
