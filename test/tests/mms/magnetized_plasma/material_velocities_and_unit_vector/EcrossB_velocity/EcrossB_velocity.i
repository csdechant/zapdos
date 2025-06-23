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
  [E_field]
    family = LAGRANGE_VEC
    order = FIRST
  []

  [EcrossB_vec]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_EcrossB_vec]
    family = MONOMIAL
    order = FIRST
  []

  [EcrossB_vec_sol]
    family = MONOMIAL_VEC
    order = FIRST
  []
  [div_EcrossB_sol]
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
  [E_field_calc]
    type = VectorFunctionAux
    variable = E_field
    function = E_field_fun
  []

  [EcrossB_vec_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = EcrossB_vec
    property = 'E_cross_B_drift'
  []
  [div_EcrossB_vec_value]
    type = ADMaterialRealAux
    variable = div_EcrossB_vec
    property = 'div_E_cross_B_drift'
  []

  [EcrossB_vec_sol]
    type = VectorFunctionAux
    variable = EcrossB_vec_sol
    function = EcrossB_vec_solution
  []
  [div_EcrossB_sol]
    type = FunctionAux
    variable = div_EcrossB_sol
    function = div_EcrossB_vec_solution
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []
  [E_field_fun]
    type = ParsedVectorFunction
    expression_x = '(cos(x*y*z))'
    expression_y = '(sin(x*y*z))'
    expression_z = '(sin(x*y*z))'
  []

  [EcrossB_vec_solution]
    type = ParsedVectorFunction
    expression_x = '(2*sin(2*x*y*z)/(cos(2*x*y*z) + 3))'
    expression_y = '(-cos(2*x*y*z)/(cos(x*y*z)^2 + 1))'
    expression_z = '(-1/(cos(x*y*z)^2 + 1))'
  []
  [div_EcrossB_vec_solution]
    type = ParsedFunction
    expression = '2*(z*(cos(x*y*z)^2 + 1)*(x*sin(2*x*y*z) - y*sin(x*y*z)^2 + y*cos(x*y*z)^2) + (-x*y - x*z*cos(2*x*y*z) + y*z*sin(2*x*y*z))*sin(x*y*z)*cos(x*y*z))/(cos(x*y*z)^2 + 1)^2'
  []
[]

[Materials]
  [electric_field_solver]
    type = FieldSolverMaterial
    solver = electromagnetic
    electric_field = E_field
  []
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
  [EcrossB_Drift]
    type = EcrossBDriftVelocity
  []
[]

[Postprocessors]
  [EcrossB_vec_l2Error]
    type = ElementVectorL2Error
    variable = EcrossB_vec
    function = EcrossB_vec_solution
  []
  [div_EcrossB_vec_l2Error]
    type = ElementL2Error
    variable = div_EcrossB_vec
    function = div_EcrossB_vec_solution
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
