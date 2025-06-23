[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 5
    ny = 5
    nz = 5
    elem_type = HEX20
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [u]
  []
[]

[Kernels]
  [u_times_div_vector]
    type = ScalarLogDivergenceMatVelocityProduct
    variable = u
    mat_vector = mat_vector
  []
  [forcing_term]
    type = ADBodyForce
    variable = u
    function = forcing_fun
  []
[]

[BCs]
  [DirichletBC]
    type = ADFunctionDirichletBC
    variable = u
    function = u_solution
    boundary = '0 1 2 3 4 5'
  []
[]

[Functions]
  [vector_fun_x]
    type = ParsedFunction
    expression = '(cos(x*y*z))'
  []
  [vector_fun_y]
    type = ParsedFunction
    expression = '(sin(x*y*z))'
  []
  [vector_fun_z]
    type = ParsedFunction
    expression = '(sin(x*y*z))'
  []
  [div_vector_fun]
    type = ParsedFunction
    expression = 'x*y*cos(x*y*z) + x*z*cos(x*y*z) - y*z*sin(x*y*z)'
  []

  [u_solution]
    type = ParsedFunction
    expression = 'log(sin(x*y*z*pi) + 2.0)'
  []
  [forcing_fun]
    type = ParsedFunction
    expression = '(sin(x*y*z*pi) + 2.0)*(x*y*cos(x*y*z) + x*z*cos(x*y*z) - y*z*sin(x*y*z))'
  []
[]

[Materials]
  [mat_vector]
    type = ADGenericFunctionVectorMaterial
    prop_names = mat_vector
    prop_values = '(cos(x*y*z)) (sin(x*y*z)) (sin(x*y*z))'
  []
  [div_mat_vector]
    type = ADGenericFunctionMaterial
    prop_names = div_mat_vector
    prop_values = 'div_vector_fun'
  []
[]

[Postprocessors]
  [u_l2Error]
    type = ElementL2Error
    variable = u
    function = u_solution
  []

  [h]
    type = AverageElementSize
  []
[]

[Preconditioning]
  active = 'smp'
  [smp]
    type = SMP
    full = true
  []

  [fdp]
    type = FDP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
[]

[Outputs]
  exodus = true
  csv = true
[]
