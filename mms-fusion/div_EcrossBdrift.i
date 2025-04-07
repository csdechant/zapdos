[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 40
    ny = 40
    nz = 40
    zmax = 0.001
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
    # family = LAGRANGE_VEC
    family = NEDELEC_ONE
    order = FIRST
  []
  [E_field]
    # family = LAGRANGE_VEC
    family = NEDELEC_ONE
    order = FIRST
  []

  [div_EcrossB_drift]
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

  [div_EcrossB_drift_value]
    type = ADMaterialRealAux
    variable = div_EcrossB_drift
    property = 'div_E_cross_drift'
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y))'
    expression_y = '(-cos(x*y))'
    expression_z = '2.0'
  []
  [E_field_fun]
    type = ParsedVectorFunction
    expression_x = '(-sin(x*y))'
    expression_y = '(cos(x*y))'
    expression_z = '4.0'
  []

  [div_EcrossB_drift_solution]
    type = ParsedFunction
    expression = '(6*x*cos(x*y) - 6*y*sin(x*y))/(sin(x*y)^2 + cos(x*y)^2 + 4)'
  []
[]

[Materials]
  [drift]
    type = MagneticPerpVelocity
    magnetic_field = B_field
  []
  [field_solver]
    type = FieldSolverMaterial
    electric_field = E_field
    solver = electromagnetic
  []
[]

[Postprocessors]
  [div_EcrossB_drift_l2Error]
    type = ElementL2Error
    variable = div_EcrossB_drift
    function = div_EcrossB_drift_solution
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
