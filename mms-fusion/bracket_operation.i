[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 5
    ny = 5
    nz = 5
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
  [bracket_operation]
    type = MatVelocityDiffusionProduct
    variable = n
    velocity = E_cross_drift
    position_units = 1.0
  []
  [body_force]
    type = BodyForce
    variable = n
    function = body_force_fun
  []
[]

[AuxVariables]
  [B_field]
    family = NEDELEC_ONE
    order = FIRST
  []
  [potential]
    family = LAGRANGE
    order = FIRST
  []

  [drift]
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

  [potential_calc]
    type = FunctionAux
    variable = potential
    function = potential_fun
  []

  [drift_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = drift
    property = 'E_cross_drift'
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '0'
    expression_y = '0'
    expression_z = '1'
  []
  [potential_fun]
    type = ParsedFunction
    expression = '(sin(pi*x)*(0.5*x - cos(7*t)*sin(3*x*x - 3*y)))'
  []

  [body_force_fun]
    type = ParsedFunction
    expression = '3.0*(2.0*x*cos(10*t)*cos(5*x^2 - 2*y) + 0.9)*sin(x*pi)*cos(7*t)*cos(3*x^2 - 3*y) - 0.4*(-pi*(0.5*x - sin(3*x^2 - 3*y)*cos(7*t))*cos(x*pi) - (-6*x*cos(7*t)*cos(3*x^2 - 3*y) + 0.5)*sin(x*pi))*cos(10*t)*cos(5*x^2 - 2*y) - 2.0*sin(10*t)*sin(5*x^2 - 2*y)'
  []

  [n_solution]
    type = ParsedFunction
    expression = 'log(0.9 + 0.9*x + 0.2*cos(10*t)*sin(5*x*x - 2*y))'
  []
[]

[Materials]
  [drift]
    type = MagneticPerpVelocity
    magnetic_field = B_field
    field_property_name = field_solver_interface_property
  []
  [field_solver]
    type = FieldSolverMaterial
    potential = potential
    solver = electrostatic
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
