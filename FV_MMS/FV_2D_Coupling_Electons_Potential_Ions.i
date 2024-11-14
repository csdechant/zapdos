#This MMS test was designed to test TimeDerivativeLog, CoeffDiffusion, EFieldAdvection,
#CoeffDiffusionLin, and ChargeSourceMoles_KV.

[GlobalParams]
  advected_interp_method = average
[]

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
  [em]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  []
  [potential]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  []
  [ion]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  []
[]

[FVKernels]
  #Electron Equations
  [em_time_derivative]
    type = FVTimeKernelLog
    variable = em
  []
  [em_diffusion]
    type = FVCoeffDiffusion
    variable = em
    position_units = 1.0
  []
  [em_advection]
    type = FVEFieldAdvection
    variable = em
    #mean_en = mean_en
    potential = 'potential'
    position_units = 1.0
  []
  [em_source]
    type = FVBodyForce
    variable = em
    function = 'em_source'
  []

  #Ion Equations
  [ion_time_derivative]
    type = FVTimeKernelLog
    variable = ion
  []
  [ion_diffusion]
    type = FVCoeffDiffusion
    variable = ion
    position_units = 1.0
  []
  [ion_advection]
    type = FVEFieldAdvection
    variable = ion
    potential = 'potential'
    position_units = 1.0
  []
  [ion_source]
    type = FVBodyForce
    variable = ion
    function = 'ion_source'
  []

  #Potential Equations
  [potential_diffusion]
    type = FVCoeffDiffusionNonLog
    variable = potential
    position_units = 1.0
  []
  [ion_charge_source]
    type = FVChargeSourceMoles_KV
    variable = potential
    charged = ion
    potential_units = V
  []
  [em_charge_source]
    type = FVChargeSourceMoles_KV
    variable = potential
    charged = em
    potential_units = V
  []
[]

[AuxVariables]
  [potential_sol]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  []

  [em_sol]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  []

  [ion_sol]
    family = MONOMIAL
    order = CONSTANT
    fv = true
  []
[]

[AuxKernels]
  [potential_sol]
    type = FunctionAux
    variable = potential_sol
    function = potential_fun
  []

  [em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_fun
  []

  [ion_sol]
    type = FunctionAux
    variable = ion_sol
    function = ion_fun
  []
[]

[Functions]
  #Scaling factors to scale the known solutios to a mesh
  [x_max]
    type = ConstantFunction
    value = 1.0
  []
  [y_max]
    type = ConstantFunction
    value = 1.0
  []

  #The frequency of oscillation
  [f]
    type = ConstantFunction
    value = 1.0
  []

  #Material Variables
  #Electron diffusion coeff.
  [diffem_coeff]
    type = ConstantFunction
    value = 0.05
  []
  #Electron mobility coeff.
  [muem_coeff]
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
  #Avogadro's number
  [N_A]
    type = ConstantFunction
    value = 1.0
  []
  #Elementary Charge
  [ee]
    type = ConstantFunction
    value = 1.0
  []
  #Permittivity of Free Space - "Potential diffusion coeff."
  [diffpotential]
    type = ConstantFunction
    value = 0.01
  []

  #Manufactured Solutions
  #The manufactured electron density solution
  [em_fun]
    type = ParsedFunction
    vars = 'N_A x_max y_max f'
    vals = 'N_A x_max y_max f'
    value = 'log((sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A)'
  []
  #The manufactured ion density solution
  [ion_fun]
    type = ParsedFunction
    vars = 'N_A x_max y_max f'
    vals = 'N_A x_max y_max f'
    value = 'log((sin(pi*(y/y_max)) + 1.0 + 0.9*cos(pi/2*(x/x_max))) / N_A)'
  []
  #The manufactured electron density solution
  [potential_fun]
    type = ParsedFunction
    vars = 'ee diffpotential x_max y_max f'
    vals = 'ee diffpotential x_max y_max f'
    value = '-(ee*(2*x_max^2*cos((pi*x)/(2*x_max)) + y_max^2*cos((pi*y)/y_max)*sin(2*pi*f*t)))/(5*diffpotential*pi^2)'
  []

  #Source Terms in moles
  #The electron source term.
  [em_source]
    type = ParsedFunction
    value = '-diffem_coeff*(-pi^2*sin(y*pi/y_max)/y_max^2 - 0.2*pi^2*sin(2*pi*f*t)*cos(y*pi/y_max)/y_max^2)/N_A + (1/4)*pi^2*diffem_coeff*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) + 0.4*pi*f*cos(y*pi/y_max)*cos(2*pi*f*t)/N_A + (1/5)*ee*muem_coeff*y_max*(-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*sin(y*pi/y_max)*sin(2*pi*f*t)/(pi*N_A*diffpotential) + (1/5)*ee*muem_coeff*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential) + (1/10)*ee*muem_coeff*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*cos((1/2)*x*pi/x_max)/(N_A*diffpotential) - 1/10*ee*muem_coeff*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential)'
    vars = 'diffem_coeff x_max f diffpotential N_A y_max muem_coeff ee'
    vals = 'diffem_coeff x_max f diffpotential N_A y_max muem_coeff ee'
  []

  #The ion source term.
  [ion_source]
    type = ParsedFunction
    value = 'pi^2*diffion*sin(y*pi/y_max)/(N_A*y_max^2) + 0.225*pi^2*diffion*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) - 1/5*ee*muion*(sin(y*pi/y_max) + 0.9*cos((1/2)*x*pi/x_max) + 1.0)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential) - 1/10*ee*muion*(sin(y*pi/y_max) + 0.9*cos((1/2)*x*pi/x_max) + 1.0)*cos((1/2)*x*pi/x_max)/(N_A*diffpotential) + 0.09*ee*muion*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential) - 1/5*ee*muion*sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential)'
    vars = 'x_max f diffion diffpotential N_A muion y_max ee'
    vals = 'x_max f diffion diffpotential N_A muion y_max ee'
  []

  [em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + cos(pi/2*x)) / N_A)'
  []
  [ion_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + 0.9*cos(pi/2*x)) / N_A)'
  []
[]

[ICs]
  [em_ICs]
    type = FunctionIC
    variable = em
    function = em_ICs
  []
  [ion_ICs]
    type = FunctionIC
    variable = ion
    function = ion_ICs
  []
[]

[FVBCs]
  [potential_BC]
    type = FVFunctionDirichletBC
    variable = potential
    function = 'potential_fun'
    boundary = '0 1 2 3'
  []

  [em_BC]
    type = FVFunctionDirichletBC
    variable = em
    function = 'em_fun'
    boundary = '0 1 2 3'
  []

  [ion_BC]
    type = FVFunctionDirichletBC
    variable = ion
    function = 'ion_fun'
    boundary = '0 1 2 3'
  []
[]

[Materials]
  [Material_Coeff]
    type = GenericFunctionMaterial
    prop_names = 'e N_A'
    prop_values = 'ee N_A'
  []
  [ADMaterial_Coeff_Set1]
    type = ADGenericFunctionMaterial
    prop_names = 'diffpotential diffion muion'
    prop_values = 'diffpotential diffion muion'
  []
  [ADMaterial_Coeff_Set2]
    type = ADGenericFunctionMaterial
    prop_names = 'diffem        muem'
    prop_values = 'diffem_coeff  muem_coeff'
  []
  [Charge_Signs]
    type = GenericConstantMaterial
    prop_names = 'sgnem  sgnion'
    prop_values = '-1.0   1.0'
  []
[]

[Postprocessors]
  [em_l2Error]
    type = ElementCenterL2Error
    variable = em
    function = em_fun
  []
  [ion_l2Error]
    type = ElementCenterL2Error
    variable = ion
    function = ion_fun
  []
  [potential_l2Error]
    type = ElementCenterL2Error
    variable = potential
    function = potential_fun
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
  end_time = 10
  #dt = 0.05
  #dt = 0.025
  #dt = 0.01
  #dt = 0.008
  #dt = 0.005
  dt = 0.001

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
  console = false
  csv = true
[]
