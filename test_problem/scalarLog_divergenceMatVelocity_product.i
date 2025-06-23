[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 5
    ny = 5
    nz = 5
  []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [u]
  []
[]

[Kernels]
  [Reaction]
    # u
    type = ADReaction
    variable = u
  []
  [forcing_term]
    type = ADBodyForce
    variable = u
    function = forcing_fun
  []
[]

# [BCs]
#   [DirichletBC]
#     type = ADFunctionDirichletBC
#     variable = u
#     function = u_solution
#     boundary = '0 1 2 3'
#   []
# []

[Functions]
  [u_solution]
    type = ParsedFunction
    expression = 'sin(x*y*pi)'
  []
  [forcing_fun]
    type = ParsedFunction
    expression = 'sin(x*y*pi)'
  []
[]

[Postprocessors]
  [u_l2Error]
    type = ElementL2Error
    variable = u
    function = u_solution
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
