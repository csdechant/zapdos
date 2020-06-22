dom0Scale=25.4e-3

[Mesh]
  type = FileMesh
  file = 'Lymberopoulos_paper.msh'
[]

[GlobalParams]
  potential_units = kV
  use_moles = true
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
  [./Ar*_physical_right_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'right'
    value = 1e-5
  [../]
  [./Ar*_physical_left_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'left'
    value = 1e-5
  [../]
[]

[Postprocessors]
  [./Meta_Relative_Diff]
    type = RelativeElementL2Difference
    variable = Ar*
    other_variable = Ar*S
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
  line_search = basic
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
  [../]
[]
