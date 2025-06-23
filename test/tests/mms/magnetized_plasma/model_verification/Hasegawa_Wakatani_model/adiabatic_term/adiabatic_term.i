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
  [n]
  []
[]

[Kernels]
  [adiabatric_term]
    type = AdiabaticTurbulence
    variable = n
    density = n
    potential = potential
    adiabaticity = adiabaticity
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
    boundary = '0 1 2 3 4 5'
  []
[]

[Functions]
  [potential_fun]
    type = ParsedFunction
    expression = 'x^2 + 1.5*y^2 + 2.0*z^2'
  []

  [n_solution]
    type = ParsedFunction
    expression = 'log(sin(x*y*z*pi) + 2.0)'
  []
  [forcing_fun]
    type = ParsedFunction
    expression = '-2.0*x^2 - 3.0*y^2 - 4.0*z^2 + 2.0*sin(x*y*z*pi) + 4.0'
  []
[]

[Materials]
  [perp_diff]
    type = ADGenericFunctionMaterial
    prop_names = 'adiabaticity'
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
