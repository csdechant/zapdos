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
  [dummy]
  []
[]

[Kernels]
  [dummy_null]
    type = NullKernel
    variable = dummy
  []
[]

[AuxVariables]
  [B_field]
    family = LAGRANGE_VEC
    order = FIRST
  []
[]

[AuxKernels]
  [B_field_calc]
    type = VectorFunctionAux
    variable = B_field
    function = B_field_fun
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []
  [scalar_parallel_vec_fun]
    type = ParsedFunction
    expression = '2.0*x + 3.0*y + 4.0*z'
  []

  [parallel_vec_solution]
    type = ParsedVectorFunction
    expression_x = '((2.0*x + 3.0*y + 4.0*z)*sin(x*y*z)/sqrt(cos(x*y*z)^2 + 1))'
    expression_y = '((-2.0*x - 3.0*y - 4.0*z)*cos(x*y*z)/sqrt(cos(x*y*z)^2 + 1))'
    expression_z = '((2.0*x + 3.0*y + 4.0*z)*cos(x*y*z)/sqrt(cos(x*y*z)^2 + 1))'
  []
  [div_parallel_vec_solution]
    type = ParsedFunction
    expression = '((cos(x*y*z)^2 + 1)*(-x*y*(2.0*x + 3.0*y + 4.0*z)*sin(x*y*z) + x*z*(2.0*x + 3.0*y + 4.0*z)*sin(x*y*z) + y*z*(2.0*x + 3.0*y + 4.0*z)*cos(x*y*z) + 2.0*sin(x*y*z) + 1.0*cos(x*y*z)) + (2.0*x + 3.0*y + 4.0*z)*(x*y*cos(x*y*z) - x*z*cos(x*y*z) + y*z*sin(x*y*z))*sin(x*y*z)*cos(x*y*z))/(cos(x*y*z)^2 + 1)^(3/2) '
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
[]

[Outputs]
  exodus = true
  csv = true
[]
