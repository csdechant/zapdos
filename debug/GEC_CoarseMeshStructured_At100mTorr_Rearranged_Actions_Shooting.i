dom0Scale=25.4e-3

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'GEC_mesh_Coarse_Structured.msh'
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [./Ar*]
  [../]
[]

[AuxVariables]
  [./Ar*S]
  [../]
  [./Ar*T]
  [../]

  [./SMDeriv]
  [../]
  [./SMDerivReset]
    initial_condition = 1.0
  [../]
[]

[Kernels]
  [./Shoot_Method]
    type = ShootMethodLog
    variable = Ar*
    density_at_start_cycle = Ar*S
    density_at_end_cycle = Ar*T
    sensitivity_variable = SMDeriv
    growth_limit = 100.0
  [../]
[]

[BCs]
  [./Ar*_physical_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
    value = 1e-5
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
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres'
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
  [../]
[]
