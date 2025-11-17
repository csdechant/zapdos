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

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []

  # Div(n V_ExB) Coeff.
  [B_mag_inverse]
    type = ADParsedMaterial
    material_property_names = 'mag_magnetic_field'
    expression = '1/mag_magnetic_field'
    property_name = B_mag_inverse
  []
  [density_2_div_B_mag]
    type = ADParsedMaterial
    coupled_variables = 'density'
    material_property_names = 'mag_magnetic_field'
    expression = '2*density/mag_magnetic_field'
    property_name = density_2_div_B_mag
  []

  # Div(n V_dia) Coeff.
  [minus_2_density_div_B_mag]
    type = ADParsedMaterial
    coupled_variables = 'density'
    material_property_names = 'mag_magnetic_field'
    expression = '-2*density/(mag_magnetic_field)'
    property_name = minus_2_density_div_B_mag
  []
  [minus_2_elec_temp_div_B_mag]
    type = ADParsedMaterial
    coupled_variables = 'electron_temp'
    material_property_names = 'mag_magnetic_field'
    expression = '-2*electron_temp/(mag_magnetic_field)'
    property_name = minus_2_elec_temp_div_B_mag
  []

  # Div(n V_||)
  [density_mat]
    type = ADParsedMaterial
    coupled_variables = 'density'
    expression = 'density'
    property_name = density_mat
  []
  [electron_velocity_mat]
    type = ADParsedMaterial
    coupled_variables = 'electron_velocity'
    expression = 'electron_velocity'
    property_name = electron_velocity_mat
  []
[]

[Kernels]
  # Div(n V_ExB)
  [density_bracket_operator]
    type = MatBracketOperatorLin
    variable = density
    mat_coeff = B_mag_inverse
    v = potential
    w = density
  []
  [density_curvature_operator_on_potential]
    type = MatCurvatureOperatorLin
    variable = density
    mat_coeff = density_2_div_B_mag
    v = potential
  []

  # Div(n V_dia)
  [density_curvature_operator_on_temp]
    type = MatCurvatureOperatorLin
    variable = density
    mat_coeff = minus_2_density_div_B_mag
    v = electron_temp
  []
  [density_curvature_operator_density]
    type = MatCurvatureOperatorLin
    variable = density
    mat_coeff = minus_2_elec_temp_div_B_mag
    v = density
  []

  # Div(n V_||)
  [density_parallel_grad_V_e]
    type = CoeffParallelDiffusionLin
    variable = density
    mat_coeff = density_mat
    v = electron_velocity
  []
  [V_e_parallel_grad_density]
    type = CoeffParallelDiffusionLin
    variable = density
    mat_coeff = electron_velocity_mat
    v = density
  []

  [density_forcing_term]
    type = BodyForce
    variable = density
    function = density_source_term
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
  [electron_temp]
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
  [electron_temp_calc]
    type = FunctionAux
    variable = electron_temp
    function = electron_temp_fun
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
  [electron_temp_fun]
    type = ParsedFunction
    expression = '0.5*cos(3*x^2 - 2*z) + 1'
  []

  [density_solution]
    type = ParsedFunction
    expression = '0.9*x + 0.01*sin(y - z) + 0.9'
  []

  [density_source_term]
    type = ParsedFunction

    # All terms?
    expression = '(((0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))*(2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z)) + (0.9*x + 0.01*sin(y - z) + 0.9)*(-(0.3*x*sin(3*x^2 + 2*y - 2*z) + (2.0 - 4*x)*cos(z + (x - 0.5)^2))*sin(x*y*z) + (0.1*sin(3*x^2 + 2*y - 2*z) + 2*cos(z + (x - 0.5)^2))*cos(x*y*z) + 0.1*sin(3*x^2 + 2*y - 2*z)*cos(x*y*z)))*(cos(x*y*z)^2 + 1)^(19/2)*(0.9*x + 0.01*sin(y - z) + 0.9) + (-x*(0.5*cos(3*x^2 - 2*z) + 1)*(0.01125*y*cos(x*y*z - y + z) + 0.01125*y*cos(x*y*z + y - z) - 0.00125*y*cos(3*x*y*z - y + z) - 0.00125*y*cos(3*x*y*z + y - z) + 0.01125*z*cos(x*y*z - y + z) + 0.01125*z*cos(x*y*z + y - z) - 0.00125*z*cos(3*x*y*z - y + z) - 0.00125*z*cos(3*x*y*z + y - z) - 0.9*(y + z)*(cos(x*y*z)^2 + 1)*sin(x*y*z) + 1.8*(y + z)*sin(x*y*z)*cos(x*y*z)^2) + (0.9*x + 0.01*sin(y - z) + 0.9)*(-3.0*x^2*(1 - cos(x*y*z)^2)*(y + z)*sin(x*y*z)*sin(3*x^2 - 2*z) + x*(1 - cos(x*y*z)^2)*(y + z)*(-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*y*(2*(x*sin(x*y*z) - z*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) + z*sin(x*y*z))*(cos(x*y*z)^2 + 1))*sin(6.28*x)*sin(y - z) - z*(2*(x*sin(x*y*z) + y*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) - y*sin(x*y*z))*(cos(x*y*z)^2 + 1))*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x) + 1.0*z*(2*(x*sin(x*y*z) + y*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) - y*sin(x*y*z))*(cos(x*y*z)^2 + 1))*sin(3*x^2 - 2*z)))*(cos(x*y*z)^2 + 1)^8*(1.8*x + 0.02*sin(y - z) + 1.8)/2 + (cos(x*y*z)^2 + 1)^9*(0.9*x + 0.01*sin(y - z) + 0.9)*(-0.225*sin(-x*y*z + 5.28*x + z) + 0.225*sin(x*y*z - 7.28*x + z) - 0.225*sin(x*y*z + 5.28*x + z) - 0.225*sin(x*y*z + 7.28*x - z) - 0.00125*cos(-x*y*z + 5.28*x + y) - 0.00125*cos(x*y*z - 7.28*x + y) + 0.00125*cos(x*y*z + 5.28*x + y) + 0.00125*cos(x*y*z + 7.28*x - y) - 0.00125*cos(x*y*z - 7.28*x - y + 2*z) - 0.00125*cos(x*y*z - 5.28*x + y - 2*z) + 0.00125*cos(x*y*z + 5.28*x - y + 2*z) + 0.00125*cos(x*y*z + 7.28*x + y - 2*z)))/((cos(x*y*z)^2 + 1)^10*(0.9*x + 0.01*sin(y - z) + 0.9))'

    # Div(n V_||)
    # expression = '((0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))*(2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z)) + (0.9*x + 0.01*sin(y - z) + 0.9)*(-(0.3*x*sin(3*x^2 + 2*y - 2*z) + (2.0 - 4*x)*cos(z + (x - 0.5)^2))*sin(x*y*z) + (0.1*sin(3*x^2 + 2*y - 2*z) + 2*cos(z + (x - 0.5)^2))*cos(x*y*z) + 0.1*sin(3*x^2 + 2*y - 2*z)*cos(x*y*z)))/sqrt(cos(x*y*z)^2 + 1)'
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
[]

[Outputs]
  exodus = true
  csv = true
[]
