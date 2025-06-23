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
  [scalar_parallel_vec]
    family = LAGRANGE
    order = FIRST
  []

  [parallel_vec]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_parallel_vec]
    family = MONOMIAL
    order = FIRST
  []
[]

[AuxKernels]
  [B_field_calc]
    type = VectorFunctionAux
    variable = B_field
    function = B_field_fun
  []
  [scalar_parallel_vec_calc]
    type = FunctionAux
    variable = scalar_parallel_vec
    function = scalar_parallel_vec_fun
  []

  [parallel_vec_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = parallel_vec
    property = 'parallel_velocity'
  []
  [div_parallel_vec_value]
    type = ADMaterialRealAux
    variable = div_parallel_vec
    property = 'div_parallel_velocity'
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

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
  [magnetic_parallel_velocity]
    type = MagneticParallelVelocity
    scalar_parallel_vel = scalar_parallel_vec
  []
[]

[Postprocessors]
  [parallel_vec_l2Error]
    type = ElementVectorL2Error
    variable = parallel_vec
    function = parallel_vec_solution
  []
  [div_parallel_vec_l2Error]
    type = ElementL2Error
    variable = div_parallel_vec
    function = div_parallel_vec_solution
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
[]

[Outputs]
  exodus = true
  csv = true
[]
