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
  [field]
    # family = LAGRANGE_VEC
    family = NEDELEC_ONE
    order = FIRST
  []

  [curl_field]
    # family = LAGRANGE_VEC
    family = NEDELEC_ONE
    order = FIRST
  []
[]

[AuxKernels]
  [field_calc]
    type = VectorFunctionAux
    variable = field
    function = field_fun
  []

  [curl_field]
    type = ADVectorMaterialRealVectorValueAux
    variable = curl_field
    property = 'field_solver_interface_property_curl'
  []
[]

[Functions]
  [field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []

  [curl_field_solution]
    type = ParsedVectorFunction
    expression_x = '(-x*y*sin(x*y*z) - x*z*sin(x*y*z))'
    expression_y = '(x*y*cos(x*y*z) + y*z*sin(x*y*z))'
    expression_z = '(-x*z*cos(x*y*z) + y*z*sin(x*y*z))'
  []
[]

[Materials]
  [field_solver]
    type = FieldSolverMaterial
    electric_field = field
    solver = electromagnetic
  []
[]

[Postprocessors]
  [curl_field_l2Error]
    type = ElementVectorL2Error
    variable = curl_field
    function = curl_field_solution
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
