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

[GlobalParams]
  position_units = 1.0
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [density]
  []
[]

# [ICs]
#   [density_curvature]
#     type = FunctionIC
#     variable = density_curvature
#     function = density_solution
#   []
# []

[Kernels]

  [parallel_grad_density]
    type = CoeffParallelDiffusionLin
    variable = density
    mat_coeff = 1.0
    v = density
  []
  [density_forcing_term]
    type = BodyForce
    variable = density
    function = density_source_term
  []

  # [bracket_operator]
  #   type = MatBracketOperatorLin
  #   variable = density
  #   mat_coeff = 1.0
  #   v = potential
  #   w = density
  # []

  [curvature_operator]
    type = MatCurvatureOperatorLin
    variable = density
    mat_coeff = 1.0
    v = density
  []
[]

[BCs]
  [density_DirichletBC]
    type = ADFunctionDirichletBC
    variable = density
    function = density_solution
    boundary = 'bottom top left right front back'
  []
[]

[AuxVariables]
  [B_field]
    family = LAGRANGE_VEC
  []

  [potential]
  []
  [electron_velocity]
  []

  [density_solution]
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
  [electron_velocity_calc]
    type = FunctionAux
    variable = electron_velocity
    function = electron_velocity_fun
  []

  [density_solution_calc]
    type = FunctionAux
    variable = density_solution
    function = density_solution
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []

  [potential_fun]
    type = ParsedFunction
    expression = '-(sin(x - z) - 0.001*cos(y - z))*sin(6.28*x) '
  []
  [electron_velocity_fun]
    type = ParsedFunction
    expression = '2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z)'
  []

  [density_solution]
    type = ParsedFunction
    expression = '0.9*x + 0.01*sin(y - z) + 0.9'
  []

  [density_source_term]
    type = ParsedFunction

    # parallel
    # expression = '(0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))/sqrt(cos(x*y*z)^2 + 1)'

    # parallel + bracket
    # expression = '1.0*(-0.01*sin(6.28*x)*sin(x*y*z)*cos(x - z)*cos(y - z) - 0.9*sin(6.28*x)*cos(x*y*z)*cos(x - z) + 0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))/sqrt(cos(x*y*z)^2 + 1)'

    # parallel + bracket + curvature
    # expression = '(-0.9*x*y*sin(x*y*z)^3 + 0.03*x*y*sin(x*y*z)^2*cos(x*y*z)*cos(y - z) + 0.02*x*y*cos(x*y*z)^3*cos(y - z) - 0.9*x*z*sin(x*y*z)^3 + 0.03*x*z*sin(x*y*z)^2*cos(x*y*z)*cos(y - z) + 0.02*x*z*cos(x*y*z)^3*cos(y - z) - 0.02*sin(6.28*x)*sin(x*y*z)^3*cos(x - z)*cos(y - z) - 1.8*sin(6.28*x)*sin(x*y*z)^2*cos(x*y*z)*cos(x - z) - 0.04*sin(6.28*x)*sin(x*y*z)*cos(x*y*z)^2*cos(x - z)*cos(y - z) - 3.6*sin(6.28*x)*cos(x*y*z)^3*cos(x - z) + 1.8*sin(x*y*z)^3 - 0.04*sin(x*y*z)^2*cos(x*y*z)*cos(y - z) + 3.6*sin(x*y*z)*cos(x*y*z)^2 - 0.08*cos(x*y*z)^3*cos(y - z))/(sqrt(cos(x*y*z)^2 + 1)*(1.0*cos(2*x*y*z) + 3.0))'

    # parallel + curvature
    expression = '(-0.9*x*y*sin(x*y*z)^3 + 0.03*x*y*sin(x*y*z)^2*cos(x*y*z)*cos(y - z) + 0.02*x*y*cos(x*y*z)^3*cos(y - z) - 0.9*x*z*sin(x*y*z)^3 + 0.03*x*z*sin(x*y*z)^2*cos(x*y*z)*cos(y - z) + 0.02*x*z*cos(x*y*z)^3*cos(y - z) + 1.8*sin(x*y*z)^3 - 0.04*sin(x*y*z)^2*cos(x*y*z)*cos(y - z) + 3.6*sin(x*y*z)*cos(x*y*z)^2 - 0.08*cos(x*y*z)^3*cos(y - z))/(sqrt(cos(x*y*z)^2 + 1)*(1.0*cos(2*x*y*z) + 3.0))'
  []
[]

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
[]

[Postprocessors]
  [density_l2Error]
    type = ElementL2Error
    variable = density
    function = density_solution
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
  # type = Transient
  # scheme = newmark-beta
  # dt = 0.01
  # end_time = 1.0

  solve_type = 'NEWTON'
  line_search = 'NONE'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu superlu_dist NONZERO 1.e-10'

  # nl_forced_its = 3
[]

[Outputs]
  exodus = true
  csv = true
[]
