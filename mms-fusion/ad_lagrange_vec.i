# This example reproduces the libmesh vector_fe example 1 results

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 15
  ny = 15
  xmin = -1
  ymin = -1
  elem_type = QUAD9
  second_order = true
[]

[Variables]
  [./u]
    # family = LAGRANGE_VEC
    family = NEDELEC_ONE
    order = FIRST
  [../]
[]

[Kernels]
  # [./diff]
  #   type = VectorDiffusion
  #   variable = u
  # [../]
  [./body_force]
    type = VectorBodyForce
    variable = u
    function_x = 'ffx'
    function_y = 'ffy'
  [../]
[]

[BCs]
  [./bnd]
    type = VectorPenaltyDirichletBC
    variable = u
    x_exact_sln = 'x_exact_sln'
    y_exact_sln = 'y_exact_sln'
    penalty = 1e8
    boundary = 'left right top bottom'
  [../]
[]

[Functions]
  [./x_exact_sln]
    type = ParsedFunction
    expression = 'cos(.5*pi*x)*sin(.5*pi*y)'
  [../]
  [./y_exact_sln]
    type = ParsedFunction
    expression = 'sin(.5*pi*x)*cos(.5*pi*y)'
  [../]
  [./ffx]
    type = ParsedFunction
    expression = '.5*pi*pi*cos(.5*pi*x)*sin(.5*pi*y)'
  [../]
  [./ffy]
    type = ParsedFunction
    expression = '.5*pi*pi*sin(.5*pi*x)*cos(.5*pi*y)'
  [../]
[]

[Preconditioning]
  [./pre]
    type = SMP
  [../]
[]

[Executioner]
  type = Steady

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-07

  solve_type = 'NEWTON'
  line_search = none
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
[]

[Outputs]
  exodus = true
[]
