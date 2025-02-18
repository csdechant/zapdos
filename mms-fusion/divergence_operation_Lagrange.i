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

  [scalar_velocity]
    family = LAGRANGE
    order = FIRST
  []

  [vector_velocity]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_velocity]
    family = MONOMIAL
    order = FIRST
  []

  [vector_velocity_solution_value]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_velocity_solution_value]
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

  [scalar_velocity_calc]
    type = FunctionAux
    variable = scalar_velocity
    function = scalar_velocity_fun
  []

  [vector_velocity_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = vector_velocity
    property = 'parallel_velocity'
  []
  [div_velocity_value]
    type = ADMaterialRealAux
    variable = div_velocity
    property = 'div_parallel_velocity'
  []

  [vector_velocity_solution_value]
    type = VectorFunctionAux
    variable = vector_velocity_solution_value
    function = vector_velocity_solution
  []
  [div_velocity_solution_value]
    type = FunctionAux
    variable = div_velocity_solution_value
    function = div_velocity_solution
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '2*x'
    expression_y = '3*y'
    expression_z = '4*z'
  []
  [scalar_velocity_fun]
    type = ParsedFunction
    expression = '14*x + 13*y + 15*z'
  []

  [vector_velocity_solution]
    type = ParsedVectorFunction
    expression_x = '(2*x*(14*x + 13*y + 15*z)/sqrt(4*x^2 + 9*y^2 + 16*z^2))'
    expression_y = '(3*y*(14*x + 13*y + 15*z)/sqrt(4*x^2 + 9*y^2 + 16*z^2))'
    expression_z = '(4*z*(14*x + 13*y + 15*z)/sqrt(4*x^2 + 9*y^2 + 16*z^2))'
  []
  [div_velocity_solution]
    type = ParsedFunction
    # expression = '-8*x^2*(14*x + 13*y + 15*z)/(4*x^2 + 9*y^2 + 16*z^2)^(3/2) + 28*x/sqrt(4*x^2 + 9*y^2 + 16*z^2) - 27*y^2*(14*x + 13*y + 15*z)/(4*x^2 + 9*y^2 + 16*z^2)^(3/2) + 39*y/sqrt(4*x^2 + 9*y^2 + 16*z^2) - 64*z^2*(14*x + 13*y + 15*z)/(4*x^2 + 9*y^2 + 16*z^2)^(3/2) + 60*z/sqrt(4*x^2 + 9*y^2 + 16*z^2) + 9*(14*x + 13*y + 15*z)/sqrt(4*x^2 + 9*y^2 + 16*z^2)'
    expression = '(154*x + 156*y + 195*z)/sqrt(4*x^2 + 9*y^2 + 16*z^2)'
  []
[]

[Materials]
  [drift]
    type = MagneticParallelVelocity
    magnetic_field = B_field
    scalar_parallel_vel = scalar_velocity
    output_properties = 'div_parallel_velocity'
    outputs = 'all'
  []
[]

[Postprocessors]
  [vector_velocity_l2Error]
    type = ElementVectorL2Error
    variable = vector_velocity
    function = vector_velocity_solution
  []
  [div_velocity_l2Error]
    type = ElementL2Error
    variable = div_velocity
    function = div_velocity_solution
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

  automatic_scaling = true
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  line_search = none
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  # nl_forced_its = 3
[]

[Outputs]
  exodus = true
  csv = true
[]
