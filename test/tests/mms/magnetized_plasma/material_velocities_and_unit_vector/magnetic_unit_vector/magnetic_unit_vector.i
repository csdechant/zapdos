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

  [mag_B_field]
    family = MONOMIAL
    order = FIRST
  []
  [grad_mag_B_field]
    family = MONOMIAL_VEC
    order = FIRST
  []

  [unit_vector]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_unit_vector]
    family = MONOMIAL
    order = FIRST
  []
  [curl_unit_vector]
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

  [mag_B_field_value]
    type = ADMaterialRealAux
    variable = mag_B_field
    property = 'mag_magnetic_field'
  []
  [grad_mag_B_field_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = grad_mag_B_field
    property = 'grad_mag_magnetic_field'
  []

  [unit_vector_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = unit_vector
    property = 'magnetic_unit_vector'
  []
  [div_unit_vector_value]
    type = ADMaterialRealAux
    variable = div_unit_vector
    property = 'div_magnetic_unit_vector'
  []
  [curl_unit_vector_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = curl_unit_vector
    property = 'curl_magnetic_unit_vector'
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []

  [mag_B_field_solution]
    type = ParsedFunction
    expression = 'sqrt(cos(x*y*z)^2 + 1)'
  []
  [grad_mag_B_field_solution]
    type = ParsedVectorFunction
    expression_x = '(-sqrt(2)*y*z*sin(2*x*y*z)/(2*sqrt(cos(2*x*y*z) + 3)))'
    expression_y = '(-sqrt(2)*x*z*sin(2*x*y*z)/(2*sqrt(cos(2*x*y*z) + 3)))'
    expression_z = '(-sqrt(2)*x*y*sin(2*x*y*z)/(2*sqrt(cos(2*x*y*z) + 3)))'
  []

  [unit_vector_solution]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z)/sqrt(cos(x*y*z)^2 + 1))'
    expression_y = '(-cos(x*y*z)/sqrt(cos(x*y*z)^2 + 1))'
    expression_z = '(cos(x*y*z)/sqrt(cos(x*y*z)^2 + 1))'
  []
  [div_unit_vector_solution]
    type = ParsedFunction
    expression = '2*sqrt(2)*(-x*y*sin(x*y*z) + x*z*sin(x*y*z) + 2*y*z*cos(x*y*z))/(cos(2*x*y*z) + 3)^(3/2)'
  []
  [curl_unit_vector_solution]
    type = ParsedVectorFunction
    expression_x = '(x*(-y - z)*sin(x*y*z)/(cos(x*y*z)^2 + 1)^(3/2))'
    expression_y = '(y*(2*x*sin(x*y*z)^2*cos(x*y*z) + 2*x*cos(x*y*z)^3 + z*sin(x*y*z)^3 + z*sin(x*y*z)*cos(x*y*z)^2)/(cos(x*y*z)^2 + 1)^(3/2))'
    expression_z = '(z*(-2*x*sin(x*y*z)^2*cos(x*y*z) - 2*x*cos(x*y*z)^3 + y*sin(x*y*z)^3 + y*sin(x*y*z)*cos(x*y*z)^2)/(cos(x*y*z)^2 + 1)^(3/2))'
  []
[]

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
[]

[Postprocessors]
  [mag_B_field_l2Error]
    type = ElementL2Error
    variable = mag_B_field
    function = mag_B_field_solution
  []
  [grad_mag_B_field_l2Error]
    type = ElementVectorL2Error
    variable = grad_mag_B_field
    function = grad_mag_B_field_solution
  []

  [unit_vector_l2Error]
    type = ElementVectorL2Error
    variable = unit_vector
    function = unit_vector_solution
  []
  [div_unit_vector_l2Error]
    type = ElementL2Error
    variable = div_unit_vector
    function = div_unit_vector_solution
  []
  [curl_unit_vector_l2Error]
    type = ElementVectorL2Error
    variable = curl_unit_vector
    function = curl_unit_vector_solution
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
  solve_type = NEWTON
[]

[Outputs]
  exodus = true
  csv = true
[]
