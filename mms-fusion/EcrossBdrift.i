[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 10
    nz = 1
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
  [E_field]
    family = NEDELEC_ONE
    order = FIRST
  []
  [B_field]
    family = NEDELEC_ONE
    order = FIRST
  []

  [drift]
    family = MONOMIAL_VEC
    order = FIRST
  []
[]

[AuxKernels]
  [E_field_calc]
    type = VectorFunctionAux
    variable = E_field
    function = E_field_fun
  []
  [B_field_calc]
    type = VectorFunctionAux
    variable = B_field
    function = B_field_fun
  []

  [drift_value]
    type = ADVectorMaterialRealVectorValueAux
    variable = drift
    property = 'E_cross_drift'
  []
[]

[Functions]
  [E_field_fun]
    type = ParsedVectorFunction
    expression_x = '14'
    expression_y = '13'
    expression_z = '15'
  []
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '2'
    expression_y = '3'
    expression_z = '4'
  []

  [drift_solution]
    type = ParsedVectorFunction
    expression_x = '7/29'
    expression_y = '-26/29'
    expression_z = '16/29'
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
    electric_field = E_field
    solver = electromagnetic
  []
[]
[Postprocessors]
  [L2Diff_l2Error]
    type = ElementVectorL2Error
    variable = drift
    function = drift_solution
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
