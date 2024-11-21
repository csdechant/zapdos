#This MMS test was designed to test TimeDerivativeLog and CoeffDiffusion.

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    nx = 4
    ny = 4
  []
[]


[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
  [../]
[]

[Kernels]
#Electron Equations - Diffusion Only
  [./em_time_derivative]
    type = TimeDerivativeLog
    variable = em
  [../]
  [./em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = 1.0
  [../]
  [./em_source]
    type = BodyForce
    variable = em
    function = 'em_source'
  [../]
[]

[AuxVariables]
  [./em_sol]
  [../]
[]

[AuxKernels]
  [./em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_fun
  [../]
[]

[Functions]
#Scaling factors to scale the known solutios to a mesh
  [./x_max]
    type = ConstantFunction
    value = 1.0
  [../]
  [./y_max]
    type = ConstantFunction
    value = 1.0
  [../]

#The frequency of oscillation
  [./f]
    type = ConstantFunction
    value = 1.0
  [../]

#Material Variables
  #Electron diffusion coeff.
  [./diffem_coeff]
    type = ConstantFunction
    value = 0.05
  [../]
  #Avogadro's number
  [./N_A]
    type = ConstantFunction
    value = 1.0
  [../]
  #Elementary Charge
  [./ee]
    type = ConstantFunction
    value = 1.0
  [../]


#Manufactured Solutions
  #The manufactured electron density solution
  [./em_fun]
    type = ParsedFunction
    vars = 'N_A x_max y_max f'
    vals = 'N_A x_max y_max f'
    value = 'log((sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A)'
  [../]

#Source Terms in moles
  #The electron source term.
  [em_source]
    type = ParsedFunction
    value = '-diffem_coeff*(-pi^2*sin(y*pi/y_max)/y_max^2 - 0.2*pi^2*sin(2*pi*f*t)*cos(y*pi/y_max)/y_max^2)/N_A + (1/4)*pi^2*diffem_coeff*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) + 0.4*pi*f*cos(y*pi/y_max)*cos(2*pi*f*t)/N_A'
    vars = 'N_A f diffem_coeff y_max x_max'
    vals = 'N_A f diffem_coeff y_max x_max'
  []

  [./em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + cos(pi/2*x)) / N_A)'
  [../]
[]

[ICs]
  [./em_ICs]
    type = FunctionIC
    variable = em
    function = em_ICs
  [../]
[]

[BCs]
  [./em_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_fun'
    boundary = '0 1 2 3'
  [../]
[]

[Materials]
  [./Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e N_A'
    prop_values = 'ee N_A'
  [../]
  [./ADMaterial_Coeff]
    type = ADGenericFunctionMaterial
    prop_names =  'diffem'
    prop_values = 'diffem_coeff'
  [../]
  [./Charge_Signs]
    type = GenericConstantMaterial
    prop_names =  'sgnem'
    prop_values = '-1.0'
  [../]
[]

[Postprocessors]
  [./em_l2Error]
    type = ElementL2Error
    variable = em
    function = em_fun
  [../]

  [./h]
    type = AverageElementSize
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 51
  #dt = 0.05
  #dt = 0.025
  dt = 0.01
  #dt = 0.008
  #dt = 0.005

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
  exodus = true
  csv = true
[]
