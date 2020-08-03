#This MMS test was designed to test the non-log version of Zapdos'
#kernels with coupling between a single density and the potential.

#Note: Diffusion and mobility coefficients are constant.

[GlobalParams]
  log_form = false
[]

[Mesh]
  [./geo]
    type = FileMeshGenerator
    file = '1D_Mesh.msh'
  [../]
  [./left]
    type = SideSetsFromNormalsGenerator
    normals = '-1 0 0'
    new_boundary = 'left'
    input = geo
  [../]
  [./right]
    type = SideSetsFromNormalsGenerator
    normals = '1 0 0'
    new_boundary = 'right'
    input = left
  [../]
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [./em]
  [../]
  [./potential]
  [../]
[]

[ICs]
  [./em_IC]
    type = FunctionIC
    variable = em
    function = 'em_ICs'
  [../]
[]

[Kernels]
#Electron Equations
  [./em_time_derivative]
    type = ElectronTimeDerivative
    variable = em
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = 0
    position_units = 1.0
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    mean_en = 0
    potential = 'potential'
    position_units = 1.0
  [../]
  [./em_source]
    type = BodyForce
    variable = em
    function = 'em_source'
  [../]

#Potential Equations
  [./potential_diffusion]
    type = CoeffDiffusionLin
    variable = potential
    position_units = 1.0
  [../]
  [./ion_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = ion
    potential_units = V
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
    potential_units = V
  [../]
[]

[AuxVariables]
  [./potential_sol]
  [../]

  [./em_sol]
  [../]

  [./ion]
  [../]
[]

[AuxKernels]
  [./potential_sol]
    type = FunctionAux
    variable = potential_sol
    function = potential_fun
  [../]

  [./em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_fun
  [../]

  [./ion_sol]
    type = FunctionAux
    variable = ion
    function = ion_fun
  [../]
[]

[Functions]
#Constants for the manufactured solutions
  #The lenght between electrode
  [./l]
    type = ConstantFunction
    value = 1.0
  [../]
  #The frequency
  [./f]
    type = ConstantFunction
    value = 1.0
  [../]

#Material Variables
  #Electron diffusion coeff.
  [./diffem]
    type = ConstantFunction
    value = 1.0
  [../]
  #Electron mobility coeff.
  [./muem]
    type = ConstantFunction
    value = 0.1
  [../]
  [./N_A]
    type = ConstantFunction
    value = 1.0
  [../]
  [./ee]
    type = ConstantFunction
    value = 1.0
  [../]
  [./diffpotential]
    type = ConstantFunction
    value = 0.01
  [../]


#Manufactured Solutions
  #The manufactured electron density solution
  [./em_fun]
    type = ParsedFunction
    vars = 'l f N_A'
    vals = 'l f N_A'
    value = '(x*(1.-x/l) + 0.2*sin(2.*pi*f*t)*cos(pi*x/l) + 1.) / N_A'
  [../]
  #The manufactured ion density solution
  [./ion_fun]
    type = ParsedFunction
    vars = 'l N_A'
    vals = 'l N_A'
    value = '(x*(1.-x/l) + 1.) / N_A'
  [../]
  #The manufactured electron density solution
  [./potential_fun]
    type = ParsedFunction
    vars = 'l f ee diffpotential'
    vals = 'l f ee diffpotential'
    value = '-(ee*l^2.*cos((pi*x)/l)*sin(2.*pi*f*t))/(5.*diffpotential*pi^2.)'
  [../]

#Source Terms in moles
  #The electron source term.
  [./em_source]
    type = ParsedFunction
    vars = 'l f ee diffpotential diffem muem N_A'
    vals = 'l f ee diffpotential diffem muem N_A'
    value = '((diffem*(10.*l + pi^2.*cos((pi*x)/l)*sin(2.*pi*f*t)))/(5.*l^2.) +
              (2.*f*pi*cos((pi*x)/l)*cos(2.*pi*f*t))/5. -
              (ee*muem*sin((pi*x)/l)*sin(2.*pi*f*t)*(10.*x - 5.*l + pi*sin((pi*x)/l)*sin(2.*pi*f*t)))/(25.*diffpotential*pi) +
              (ee*muem*cos((pi*x)/l)*sin(2.*pi*f*t)*(5.*l + 5.*l*x - 5.*x^2. + l*cos((pi*x)/l)*sin(2.*pi*f*t)))/(25.*diffpotential*l)) / N_A'
  [../]

  #The left BC dirichlet function
  [./potential_left_BC]
    type = ParsedFunction
    vars = 'l f ee diffpotential'
    vals = 'l f ee diffpotential'
    value = '-(ee*l^2.*sin(2.*pi*f*t))/(5.*diffpotential*pi^2.)'
  [../]
  [./em_left_BC]
    type = ParsedFunction
    vars = 'l f N_A'
    vals = 'l f N_A'
    value = '(sin(2.*pi*f*t)/5. + 1.) / N_A'
  [../]
  #The right BC dirichlet function
  [./potential_right_BC]
    type = ParsedFunction
    vars = 'l f ee diffpotential'
    vals = 'l f ee diffpotential'
    value = '(ee*l^2.*sin(2.*pi*f*t))/(5.*diffpotential*pi^2.)'
  [../]
  [./em_right_BC]
    type = ParsedFunction
    vars = 'l f N_A'
    vals = 'l f N_A'
    value = '(1. - sin(2.*pi*f*t)/5.) / N_A'
  [../]

  [./em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = '(1.) / N_A'
  [../]
[]

[BCs]
  [./potential_left_BC]
    type = FunctionDirichletBC
    variable = potential
    function = 'potential_left_BC'
    boundary = 'left'
  [../]
  [./potential_right_BC]
    type = FunctionDirichletBC
    variable = potential
    function = 'potential_right_BC'
    boundary = 'right'
  [../]

  [./em_left_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_left_BC'
    boundary = 'left'
  [../]
  [./em_right_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_right_BC'
    boundary = 'right'
  [../]
[]

[Materials]
  [./Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e  diffpotential diffem muem N_A'
    prop_values = 'ee diffpotential diffem muem N_A'
  [../]
  [./Material_Coeff_Deriv]
    type = GenericConstantMaterial
    prop_names =  'd_muem_d_actual_mean_en  d_diffem_d_actual_mean_en'
    prop_values = '0.0                      0.0'
  [../]
  [./Charge_Signs]
    type = GenericConstantMaterial
    prop_names =  'sgnem  sgnion'
    prop_values = '-1.0   1.0'
  [../]
[]

[Postprocessors]
  [./em_l2Error]
    type = ElementL2Error
    variable = em
    function = em_fun
  [../]
  [./potential_l2Error]
    type = ElementL2Error
    variable = potential
    function = potential_fun
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
  end_time = 5
  dt = 0.0075
  automatic_scaling = true
  compute_scaling_once = false
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  line_search = none
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  scheme = bdf2
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
