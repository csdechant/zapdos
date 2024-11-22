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
  [em]
    # initial_from_file_var = em
  []

  [EField]
    family = LAGRANGE_VEC
    order = FIRST
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
#Electron Equations
  [em_time_derivative]
    type = TimeDerivativeLog
    variable = em
  []
  [em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = 1.0
  []
  [em_advection]
    type = EFieldAdvection
    variable = em
    position_units = 1.0
  []
  [em_source]
    type = BodyForce
    variable = em
    function = 'em_source'
  []

  [Ambipolar_EField]
    type = AmbipolarEField
    variable = EField
    em = em
    ion_diffusion = diffion
    ion_mobility = muion
  []
[]

[AuxVariables]
  [em_sol]
  []

  [EField_sol]
    family = LAGRANGE_VEC
    order = FIRST
  []
[]

[AuxKernels]
  [EField_sol]
    type = VectorFunctionAux
    variable = EField_sol
    function = Efield_fun
  []

  [em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_fun
  []
[]

[Functions]
#Material Variables
  #Electron diffusion coeff.
  [diffem]
    type = ConstantFunction
    value = 0.05
  []
  #Electron mobility coeff.
  [muem]
    type = ConstantFunction
    value = 0.01
  []
  #Ion diffusion coeff.
  [diffion]
    type = ConstantFunction
    value = 0.1
  []
  #Ion mobility coeff.
  [muion]
    type = ConstantFunction
    value = 0.025
  []

  [N_A]
    type = ConstantFunction
    value = 1.0
  []
  [ee]
    type = ConstantFunction
    value = 1.0
  []


#Manufactured Solutions
  #The manufactured electron density solution
  [em_fun]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((sin(pi*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 1.0 + cos(pi/2*x)) / N_A)'
  []
  #The manufactured electron density solution
  [Efield_fun]
    type = ParsedVectorFunction
    vars = 'diffem  muem  diffion  muion'
    vals = 'diffem  muem  diffion  muion'
    expression_x = '-1/2*pi*(-diffem + diffion)*sin((1/2)*x*pi)/((-muem + muion)*(sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + cos((1/2)*x*pi) + 1.0))'
    expression_y = '(-diffem + diffion)*(-0.2*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))/((-muem + muion)*(sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + cos((1/2)*x*pi) + 1.0))'
  []

#Source Terms in moles
  #The electron source term.
  [em_source]
    type = ParsedFunction
    vars = 'diffem  muem  diffion  muion  N_A'
    vals = 'diffem  muem  diffion  muion  N_A'
    value = '(-diffem*(-pi^2*sin(y*pi) - 0.2*pi^2*sin(2*pi*t)*cos(y*pi)) + (1/4)*pi^2*diffem*cos((1/2)*x*pi) - muem*(-diffem + diffion)*(-pi^2*sin(y*pi) - 0.2*pi^2*sin(2*pi*t)*cos(y*pi))/(-muem + muion) + (1/4)*pi^2*muem*(-diffem + diffion)*cos((1/2)*x*pi)/(-muem + muion) + 0.4*pi*cos(y*pi)*cos(2*pi*t)) / N_A'
  []

  [em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + cos(pi/2*x)) / N_A)'
  []
[]

[BCs]
  [em_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_fun'
    boundary = '0 1 2 3'
    preset = true
  []

  [Efield_BC]
    type = VectorFunctionDirichletBC
    variable = EField
    function = Efield_fun
    boundary = '0 1 2 3'
  []
[]

[Materials]
  [field_solver]
    type = FieldSolverMaterial
    electric_field = EField
    solver = ELECTROMAGNETIC
  []
  [Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e N_A'
    prop_values = 'ee N_A'
  []
  [ADMaterial_Coeff]
    type = ADGenericFunctionMaterial
    prop_names =  'diffem  muem  diffion  muion'
    prop_values = 'diffem  muem  diffion  muion'
  []
  [Charge_Signs]
    type = GenericConstantMaterial
    prop_names =  'sgnem'
    prop_values = '-1.0'
  []
[]

[Postprocessors]
  [em_l2Error]
    type = ElementL2Error
    variable = em
    function = em_fun
  []

  [Efield_Error]
    type = ElementVectorL2Error
    variable = EField
    function = Efield_fun
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
  type = Transient
  start_time = 0
  end_time = 50
  # dt = 0.05
  # dt = 0.025
  #dt = 0.0125

  # dt = 0.01

  # dt = 0.005

  dt = 0.008
  

  automatic_scaling = true
  compute_scaling_once = false
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  line_search = none
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  scheme = bdf2

  nl_abs_tol = 1e-13
[]

[Outputs]
  csv = true
  exodus = false
[]
