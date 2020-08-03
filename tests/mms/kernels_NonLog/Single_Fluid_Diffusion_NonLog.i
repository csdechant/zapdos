#This MMS test was designed to test the non-log version of Zapdos'
#time derivative and diffusion kernels.

#Note: Diffusion coefficient is constant.

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
  [./N_A]
    type = ConstantFunction
    value = 1.0
  [../]


#Manufactured Solutions
  #The manufactured electron density solution
  [./em_fun]
    type = ParsedFunction
    vars = 'l f N_A'
    vals = 'l f N_A'
    value = '(x*(1.-x/l) + 0.2*sin(2.*pi*f*t)*cos(pi*x/l) + 1.) / N_A'
  [../]

#Source Terms in moles
  #The electron source term.
  [./em_source]
    type = ParsedFunction
    vars = 'l f diffem N_A'
    vals = 'l f diffem N_A'
    value = '(diffem*(2./l + (pi^2.*cos((pi*x)/l)*sin(2.*pi*f*t))/(5.*l^2.)) +
             (2.*f*pi*cos((pi*x)/l)*cos(2.*pi*f*t))/5.) / N_A'
  [../]

  #The left BC dirichlet function
  [./em_left_BC]
    type = ParsedFunction
    vars = 'l f N_A'
    vals = 'l f N_A'
    value = '(sin(2.*pi*f*t)/5. + 1.) / N_A'
  [../]
  #The right BC dirichlet function
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
    prop_names =  'diffem N_A'
    prop_values = 'diffem N_A'
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
