[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 5
    ny = 5
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [n]
  []
[]

[Kernels]
  [diffusion]
    type = Diffusion
    variable = n
  []
  [directional_potential_gradient]
    type = DirectionalPotentialGradient
    variable = n
    potential = potential
    k = k
    component = 1
  []
  [forcing_term]
    type = ADBodyForce
    variable = n
    function = forcing_fun
  []
[]

[AuxVariables]
  [potential]
  []
[]

[AuxKernels]
  [potential_calc]
    type = FunctionAux
    variable = potential
    function = potential_fun
  []
[]

[BCs]
  [DirichletBC]
    type = ADFunctionDirichletBC
    variable = n
    function = n_solution
    boundary = '0 1 2 3'
  []
[]

[Functions]
  [potential_fun]
    type = ParsedFunction
    expression = 'x^2 + 1.5*y^2'
  []

  [n_solution]
    type = ParsedFunction
    expression = 'sin(x*y*pi) + 2.0'
  []
  [forcing_fun]
    type = ParsedFunction
    expression = 'x^2*pi^2*sin(x*y*pi) + y^2*pi^2*sin(x*y*pi) + 6.0*y'
  []
[]

[Materials]
  [perp_diff]
    type = ADGenericFunctionMaterial
    prop_names = 'k'
    prop_values = '2.0'
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
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
[]

[Outputs]
  exodus = true
  csv = true
[]
