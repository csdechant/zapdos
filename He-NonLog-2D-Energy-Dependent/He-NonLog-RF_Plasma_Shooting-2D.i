dom0Scale=25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
  [./geo]
    type = FileMeshGenerator
    file = 'GEC_mesh_Coarse_Structured.msh'
  [../]
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [./He*singlet]
  [../]
  [./He*triplet]
  [../]
[]

[AuxVariables]
  [./He*singlet_S]
  [../]
  [./He*triplet_S]
  [../]

  [./He*singlet_T]
  [../]
  [./He*triplet_T]
  [../]

  [./SM_He*singlet]
  [../]
  [./SM_He*triplet]
  [../]

  [./SM_He*singlet_Reset]
    initial_condition = 1.0
  [../]
  [./SM_He*triplet_Reset]
    initial_condition = 1.0
  [../]

  [./x_node]
  [../]
  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./Shoot_Method_singlet]
    type = ShootMethod
    variable = He*singlet
    density_at_start_cycle = He*singlet_S
    density_at_end_cycle = He*singlet_T
    sensitivity_variable = SM_He*singlet
    growth_limit = 100
  [../]
  [./Shoot_Method_triplet]
    type = ShootMethod
    variable = He*triplet
    density_at_start_cycle = He*triplet_S
    density_at_end_cycle = He*triplet_T
    sensitivity_variable = SM_He*triplet
    growth_limit = 100
  [../]
[]

[AuxKernels]
  [./Constant_SM_He*singlet_Reset]
    type = ConstantAux
    variable = SM_He*singlet_Reset
    value = 1.0
    execute_on = 'TIMESTEP_BEGIN'
  [../]
  [./Constant_SM_He*triplet_Reset]
    type = ConstantAux
    variable = SM_He*triplet_Reset
    value = 1.0
    execute_on = 'TIMESTEP_BEGIN'
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  [../]
[]

[BCs]
  #Boundary conditions for metastables
  [./He*singlet_physical_diffusion]
    type = ADDirichletBC
    variable = He*singlet
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    value = 0.0
  [../]
  [./He*triplet_physical_diffusion]
    type = ADDirichletBC
    variable = He*triplet
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    value = 0.0
  [../]
[]

[Postprocessors]
  [./Meta_singlet_Relative_Diff]
    type = RelativeElementL2Difference
    variable = He*singlet
    other_variable = He*singlet_S
    execute_on = 'TIMESTEP_END'
  [../]
  [./Meta_triplet_Relative_Diff]
    type = RelativeElementL2Difference
    variable = He*triplet
    other_variable = He*triplet_S
    execute_on = 'TIMESTEP_END'
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
  type = Steady

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON

  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
  [../]
[]
