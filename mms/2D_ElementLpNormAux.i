[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [dummy]
  []
[]

[ICs]
  [em_IC]
    type = FunctionIC
    function = em_ICs
    variable = em
  []
[]

[Kernels]
  [dummy_diffusion]
    type = Diffusion
    variable = dummy
  []
  [dummy_source]
    type = BodyForce
    variable = em
    function = 1.0
  []
[]

[AuxVariables]
  [u]
  []
  [v]
  []

  [L2Diff]
    family = MONOMIAL
    order = CONSTANT
  []
  [L2Diff_sol]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [u]
    type = FunctionAux
    variable = u
    function = u_fun
  []
  [v]
    type = FunctionAux
    variable = u
    function = u_fun
  []

  [L2Diff]
    type = ElementLpDiffNormAux
    variable = L2Diff
    v = u
    w = v
  []
  [L2Diff_sol]
    type = FunctionAux
    variable = u
    function = L2Diff_fun
  []
[]

[Functions]
  [u_fun]
    type = ParsedFunction
    value = 'sin(x*y)'
  []
  [v_fun]
    type = ParsedFunction
    value = 'cos(x*y)'
  []

  [L2Diff_fun]
    type = ParsedFunction
    vars = 'u     v'
    vals = 'u_fun v_fun'
    value = 'sqrt((u - v)^2)'
  []
[]

[Postprocessors]
  [L2Diff_l2Error]
    type = ElementL2Error
    variable = L2Diff
    function = L2Diff_fun
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

  nl_abs_tol = 1e-13
[]

[Outputs]
  csv = true
[]
