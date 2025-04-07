[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 5
    ny = 5
    nz = 1
    elem_type = HEX20
    zmax = 0.001
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [n]
    family = LAGRANGE
    order = FIRST
  []
[]

[Kernels]
  [dummy_null]
    type = TimeDerivativeLog
    variable = n
  []
  # [density_vec_div_product_operation]
  #   type = DensityMatVelocityDivergenceProduct
  #   variable = n
  #   velocity = parallel_velocity
  #   position_units = 1.0
  # []
  [body_force]
    type = BodyForce
    variable = n
    function = body_force_fun
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

  [parallel_velocity]
    family = MONOMIAL_VEC
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
    expression = '(14*x + 13*y + 15*z )'
  []

  [body_force_fun]
    type = ParsedFunction
    expression = '-(0.9*x + 0.2*sin(5*x^2 - 2*z)*cos(10*t) + 0.9)*(154*x + 156*y + 195*z)/sqrt(4*x^2 + 9*y^2 + 16*z^2) - 2.0*sin(10*t)*sin(5*x^2 - 2*z)'
  []

  [n_solution]
    type = ParsedFunction
    expression = 'log(0.9*x + 0.2*sin(5*x^2 - 2*z)*cos(10*t) + 0.9)'
  []
[]

[Materials]
  [drift]
    type = MagneticParallelVelocity
    magnetic_field = B_field
    scalar_parallel_vel = scalar_velocity
    output_properties = 'div_parallel_velocity'
  []
[]

[BCs]
  [n_BC]
    type = FunctionDirichletBC
    variable = n
    function = 'n_solution'
    boundary = '0 1 2 3 4 5'
  []
[]

[Postprocessors]
  [n_l2Error]
    type = ElementL2Error
    variable = n
    function = n_solution
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
  type = Transient
  end_time = 1
  dt = 0.01

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
