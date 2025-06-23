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
  [pressure]
    family = LAGRANGE
    order = FIRST
  []
  [density]
    family = LAGRANGE
    order = FIRST
  []

  [diamagnetic_vec]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_diamagnetic_vec]
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
  [pressure_calc]
    type = FunctionAux
    variable = pressure
    function = pressure_fun
  []
  [density_calc]
    type = FunctionAux
    variable = density
    function = density_fun
  []

  [diamagnetic_vec_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = diamagnetic_vec
    property = 'diamagnetic_drift'
  []
  [div_diamagnetic_vec_value]
    type = ADMaterialRealAux
    variable = div_diamagnetic_vec
    property = 'div_diamagnetic_drift'
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []
  [pressure_fun]
    type = ParsedFunction
    expression = 'x^2 + 1.5*y^2 + 2.0*z^2'
  []
  [density_fun]
    type = ParsedFunction
    expression = 'log(sin(x*y*z*pi) + 2.0)'
  []

  [diamagnetic_vec_solution]
    type = ParsedVectorFunction
    expression_x = '((-3.0*y - 4.0*z)*cos(x*y*z)/((1.5*sin(x*y*z*pi) + 3.0)*(cos(x*y*z)^2 + 1)))'
    expression_y = '((2*x*cos(x*y*z) - 4.0*z*sin(x*y*z))/((1.5*sin(x*y*z*pi) + 3.0)*(cos(x*y*z)^2 + 1)))'
    expression_z = '((2*x*cos(x*y*z) + 3.0*y*sin(x*y*z))/((1.5*sin(x*y*z*pi) + 3.0)*(cos(x*y*z)^2 + 1)))'
  []
  [div_diamagnetic_vec_solution]
    type = ParsedFunction
    expression = '((1.5*sin(x*y*z*pi) + 3.0)*(cos(x*y*z)^2 + 1)*(-2*x^2*y*sin(x*y*z) - 2*x^2*z*sin(x*y*z) + 3.0*x*y^2*cos(x*y*z) - 4.0*x*z^2*cos(x*y*z) + 3.0*y^2*z*sin(x*y*z) + 4.0*y*z^2*sin(x*y*z)) + 2*(1.5*sin(x*y*z*pi) + 3.0)*(x*y*(2*x*cos(x*y*z) + 3.0*y*sin(x*y*z)) + x*z*(2*x*cos(x*y*z) - 4.0*z*sin(x*y*z)) - y*z*(3.0*y + 4.0*z)*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + 1.5*pi*(cos(x*y*z)^2 + 1)*(-x*y*(2*x*cos(x*y*z) + 3.0*y*sin(x*y*z)) - x*z*(2*x*cos(x*y*z) - 4.0*z*sin(x*y*z)) + y*z*(3.0*y + 4.0*z)*cos(x*y*z))*cos(x*y*z*pi))/((1.5*sin(x*y*z*pi) + 3.0)^2*(cos(x*y*z)^2 + 1)^2)'
  []
[]

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
  [magnetic_diamagnetic_velocity]
    type = DiamagneticDriftVelocity
    density = density
    pressure = pressure
  []
  [charge_density_properties]
    type = GenericFunctionMaterial
    prop_names = 'e sgndensity'
    prop_values = '0.5 3'
  []
[]

[Postprocessors]
  [diamagnetic_vec_l2Error]
    type = ElementVectorL2Error
    variable = diamagnetic_vec
    function = diamagnetic_vec_solution
  []
  [div_diamagnetic_vec_l2Error]
    type = ElementL2Error
    variable = div_diamagnetic_vec
    function = div_diamagnetic_vec_solution
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
