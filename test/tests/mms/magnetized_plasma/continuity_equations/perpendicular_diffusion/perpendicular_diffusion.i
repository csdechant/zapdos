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
  [u]
  []
[]

[Kernels]
  [perpendicular_diffusion]
    type = CoeffPerpendicularDiffusionLin
    variable = u
  []
  [forcing_term]
    type = ADBodyForce
    variable = u
    function = forcing_fun
  []
[]

[AuxVariables]
  [B_field]
    family = LAGRANGE_VEC
    order = FIRST
  []
[]

[AuxKernels]
  [B_field_calc]
    type = VectorFunctionAux
    variable = B_field
    function = B_field_fun
  []
[]

[BCs]
  [DirichletBC]
    type = ADFunctionDirichletBC
    variable = u
    function = u_solution
    boundary = '0 1 2 3 4 5'
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []

  [u_solution]
    type = ParsedFunction
    expression = 'sin(x*y*z*pi) + 2.0'
  []
  [forcing_fun]
    type = ParsedFunction
    expression = '-(0.5*pi*(-4*x^2*y^2*pi*(cos(2*x*y*z) + 3)^2*sin(x*y*z*pi) + 14*x^2*y^2*pi*sin(x*y*z*pi) - 8*x^2*y^2*pi*sin(x*y*z*(2 - pi)) + 8*x^2*y^2*sin(x*y*z*(2 - pi)) + 8*x^2*y^2*sin(x*y*z*(2 + pi)) + 8*x^2*y^2*pi*sin(x*y*z*(2 + pi)) - x^2*y^2*pi*sin(x*y*z*(4 - pi)) + x^2*y^2*pi*sin(x*y*z*(pi + 4)) - 28*x^2*y*z*pi*sin(x*y*z*pi) - 16*x^2*y*z*sin(x*y*z*(2 - pi)) + 16*x^2*y*z*pi*sin(x*y*z*(2 - pi)) - 16*x^2*y*z*pi*sin(x*y*z*(2 + pi)) - 16*x^2*y*z*sin(x*y*z*(2 + pi)) + 2*x^2*y*z*pi*sin(x*y*z*(4 - pi)) - 2*x^2*y*z*pi*sin(x*y*z*(pi + 4)) - 4*x^2*z^2*pi*(cos(2*x*y*z) + 3)^2*sin(x*y*z*pi) + 14*x^2*z^2*pi*sin(x*y*z*pi) - 8*x^2*z^2*pi*sin(x*y*z*(2 - pi)) + 8*x^2*z^2*sin(x*y*z*(2 - pi)) + 8*x^2*z^2*sin(x*y*z*(2 + pi)) + 8*x^2*z^2*pi*sin(x*y*z*(2 + pi)) - x^2*z^2*pi*sin(x*y*z*(4 - pi)) + x^2*z^2*pi*sin(x*y*z*(pi + 4)) + 4*x*y^2*z*(cos(4*x*y*z) + 1)*cos(x*y*z*pi) - 20*x*y^2*z*cos(x*y*z*pi) - 24*x*y^2*z*cos(x*y*z*(2 - pi)) + 12*x*y^2*z*pi*cos(x*y*z*(2 - pi)) - 12*x*y^2*z*pi*cos(x*y*z*(2 + pi)) - 24*x*y^2*z*cos(x*y*z*(2 + pi)) - 2*x*y^2*z*cos(x*y*z*(4 - pi)) + 2*x*y^2*z*pi*cos(x*y*z*(4 - pi)) - 2*x*y^2*z*pi*cos(x*y*z*(pi + 4)) - 2*x*y^2*z*cos(x*y*z*(pi + 4)) - 4*x*y*z^2*(cos(4*x*y*z) + 1)*cos(x*y*z*pi) + 20*x*y*z^2*cos(x*y*z*pi) - 12*x*y*z^2*pi*cos(x*y*z*(2 - pi)) + 24*x*y*z^2*cos(x*y*z*(2 - pi)) + 24*x*y*z^2*cos(x*y*z*(2 + pi)) + 12*x*y*z^2*pi*cos(x*y*z*(2 + pi)) - 2*x*y*z^2*pi*cos(x*y*z*(4 - pi)) + 2*x*y*z^2*cos(x*y*z*(4 - pi)) + 2*x*y*z^2*cos(x*y*z*(pi + 4)) + 2*x*y*z^2*pi*cos(x*y*z*(pi + 4)) + 28*x*cos(x*y*z*pi) + 16*x*cos(x*y*z*(2 - pi)) + 16*x*cos(x*y*z*(2 + pi)) + 2*x*cos(x*y*z*(4 - pi)) + 2*x*cos(x*y*z*(pi + 4)) - 4*y^2*z^2*pi*(cos(2*x*y*z) + 3)^2*sin(x*y*z*pi) + 10*y^2*z^2*pi*sin(x*y*z*pi) - 16*y^2*z^2*sin(x*y*z*(2 - pi)) + 4*y^2*z^2*pi*sin(x*y*z*(2 - pi)) - 16*y^2*z^2*sin(x*y*z*(2 + pi)) - 4*y^2*z^2*pi*sin(x*y*z*(2 + pi)) + y^2*z^2*pi*sin(x*y*z*(4 - pi)) - y^2*z^2*pi*sin(x*y*z*(pi + 4)) - 12*y*sin(x*y*z*(2 - pi)) - 12*y*sin(x*y*z*(2 + pi)) - 2*y*sin(x*y*z*(4 - pi)) - 2*y*sin(x*y*z*(pi + 4)) + 12*z*sin(x*y*z*(2 - pi)) + 12*z*sin(x*y*z*(2 + pi)) + 2*z*sin(x*y*z*(4 - pi)) + 2*z*sin(x*y*z*(pi + 4)))/(cos(2*x*y*z) + 3)^2)'
  []
[]

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
  [div_mat_vector]
    type = ADGenericFunctionMaterial
    prop_names = 'perp_diffu'
    prop_values = '2.0'
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
