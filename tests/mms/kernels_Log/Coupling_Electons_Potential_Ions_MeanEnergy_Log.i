#This MMS test was designed to test the log version of Zapdos'
#kernels with coupling between electrons, ions, potential, and
#the mean electron energy density.

#Note: Diffusion and mobility coefficients are constant.

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
  [./ion]
  [../]
  [./mean_en]
  [../]
[]

[ICs]
  [./em_IC]
    type = FunctionIC
    variable = em
    function = 'em_ICs'
  [../]
  [./ion_IC]
    type = FunctionIC
    variable = ion
    function = 'ion_ICs'
  [../]
  [./mean_en_IC]
    type = FunctionIC
    variable = mean_en
    function = 'mean_en_ICs'
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
    mean_en = mean_en
    position_units = 1.0
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    mean_en = mean_en
    potential = 'potential'
    position_units = 1.0
  [../]
  [./em_source]
    type = BodyForce
    variable = em
    function = 'em_source'
  [../]

#Ion Equations
  [./ion_time_derivative]
    type = ElectronTimeDerivative
    variable = ion
  [../]
  [./ion_diffusion]
    type = CoeffDiffusion
    variable = ion
    position_units = 1.0
  [../]
  [./ion_advection]
    type = EFieldAdvection
    variable = ion
    potential = 'potential'
    position_units = 1.0
  [../]
  [./ion_source]
    type = BodyForce
    variable = ion
    function = 'ion_source'
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

#Electron Energy Equations
  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    position_units = 1.0
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    position_units = 1.0
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = 1.0
    potential_units = V
  [../]
  [./mean_en_source]
    type = BodyForce
    variable = mean_en
    function = 'energy_source'
  [../]
[]

[AuxVariables]
  [./potential_sol]
  [../]

  [./energy_sol]
  [../]

  [./em_sol]
  [../]

  [./ion_sol]
  [../]
[]

[AuxKernels]
  [./potential_sol]
    type = FunctionAux
    variable = potential_sol
    function = potential_fun
  [../]

  [./energy_sol]
    type = FunctionAux
    variable = energy_sol
    function = energy_fun
  [../]

  [./em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_fun
  [../]

  [./ion_sol]
    type = FunctionAux
    variable = ion_sol
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
  #Electron energy diffusion coeff.
  [./diffmean_en]
    type = ParsedFunction
    vars = 'diffem'
    vals = 'diffem'
    value = '5.0 / 3.0 * diffem'
  [../]
  #Electron energy mobility coeff.
  [./mumean_en]
    type = ParsedFunction
    vars = 'muem'
    vals = 'muem'
    value = '5.0 / 3.0 * muem'
  [../]
  #Ion diffusion coeff.
  [./diffion]
    type = ConstantFunction
    value = 1.0
  [../]
  #Ion mobility coeff.
  [./muion]
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
    value = 'log((x*(1.-x/l) + 0.2*sin(2.*pi*f*t)*cos(pi*x/l) + 1.) / N_A)'
  [../]
  #The manufactured ion density solution
  [./ion_fun]
    type = ParsedFunction
    vars = 'l N_A'
    vals = 'l N_A'
    value = 'log((x*(1.-x/l) + 1.) / N_A)'
  [../]
  #The manufactured electron density solution
  [./potential_fun]
    type = ParsedFunction
    vars = 'l f ee diffpotential'
    vals = 'l f ee diffpotential'
    value = '-(ee*l^2.*cos((pi*x)/l)*sin(2.*pi*f*t))/(5.*diffpotential*pi^2.)'
  [../]
  #The manufactured electron energy solution
  [./energy_fun]
    type = ParsedFunction
    vars = 'l f em_fun'
    vals = 'l f em_fun'
    value = 'log((x*(1.-x/l) + sin(2.*pi*f*t)*cos(pi*x/l)*x*(1.-x/l) + 0.75)) + em_fun'
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
  #The ion source term.
  [./ion_source]
    type = ParsedFunction
    vars = 'l f ee diffpotential diffion muion N_A'
    vals = 'l f ee diffpotential diffion muion N_A'
    value = '((2.*diffion)/l -
              (ee*muion*cos((pi*x)/l)*sin(2.*pi*f*t)*(- x^2. + l*x + l))/(5.*diffpotential*l) -
              (ee*muion*sin((pi*x)/l)*sin(2.*pi*f*t)*(l - 2.*x))/(5.*diffpotential*pi)) / N_A'
  [../]
  #The electron energy source term.
  [./energy_source]
    type = ParsedFunction
    vars = 'l f ee diffpotential diffem muem N_A'
    vals = 'l f ee diffpotential diffem muem N_A'
    value = '(-((5.*x*(x/l - 1.))/3. +
              (5.*x*cos((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.))/3. - 5./4.)*(diffem*(2./l + (pi^2.*cos((pi*x)/l)*sin(2.*pi*f*t))/(5.*l^2.)) +
              (ee*muem*cos((pi*x)/l)*sin(2.*pi*f*t)*((cos((pi*x)/l)*sin(2.*pi*f*t))/5. - x*(x/l - 1.) + 1.))/(5.*diffpotential) -
              (ee*l*muem*sin((pi*x)/l)*sin(2.*pi*f*t)*((2.*x)/l +
              (pi*sin((pi*x)/l)*sin(2.*pi*f*t))/(5.*l) - 1.))/(5.*diffpotential*pi)) -
              (diffem*((2.*x)/l + (pi*sin((pi*x)/l)*sin(2.*pi*f*t))/(5.*l) - 1.) +
              (ee*l*muem*sin((pi*x)/l)*sin(2.*pi*f*t)*((cos((pi*x)/l)*sin(2.*pi*f*t))/5. - x*(x/l - 1.) + 1.))/(5.*diffpotential*pi))*((10.*x)/(3.*l) +
              (5.*cos((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.))/3. +
              (5.*x*cos((pi*x)/l)*sin(2.*pi*f*t))/(3.*l) -
              (5.*x*pi*sin((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.))/(3.*l) - 5./3.) -
              diffem*((cos((pi*x)/l)*sin(2.*pi*f*t))/3. -
              (5.*x*(x/l - 1.))/3. + 5./3.)*((2.*x*pi*sin((pi*x)/l)*sin(2.*pi*f*t))/l^2. -
              (2.*cos((pi*x)/l)*sin(2.*pi*f*t))/l - 2./l + (2.*pi*sin((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.))/l +
              (x*pi^2.*cos((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.))/l^2.) - diffem*((10.*x)/(3.*l) +
              (pi*sin((pi*x)/l)*sin(2.*pi*f*t))/(3.*l) - 5./3.)*((2.*x)/l + cos((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.) +
              (x*cos((pi*x)/l)*sin(2.*pi*f*t))/l - (x*pi*sin((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.))/l - 1.) -
              (2.*f*pi*cos((pi*x)/l)*cos(2.*pi*f*t)*(x*(x/l - 1.) + x*cos((pi*x)/l)*sin(2.*pi*f*t)*(x/l - 1.) - 3./4.))/5. -
              (ee*l*sin((pi*x)/l)*sin(2.*pi*f*t)*(diffem*((2.*x)/l + (pi*sin((pi*x)/l)*sin(2.*pi*f*t))/(5.*l) - 1.) +
              (ee*l*muem*sin((pi*x)/l)*sin(2.*pi*f*t)*((cos((pi*x)/l)*sin(2.*pi*f*t))/5. - x*(x/l - 1.) + 1.))/(5.*diffpotential*pi)))/(5.*diffpotential*pi) -
              2.*f*x*pi*cos((pi*x)/l)*cos(2.*pi*f*t)*(x/l - 1.)*((cos((pi*x)/l)*sin(2.*pi*f*t))/5. - x*(x/l - 1.) + 1.)) / N_A'
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
    value = 'log((sin(2.*pi*f*t)/5. + 1.) / N_A)'
  [../]
  [./ion_left_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((1.) / N_A)'
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
    value = 'log((1. - sin(2.*pi*f*t)/5.) / N_A)'
  [../]
  [./ion_right_BC]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((1.) / N_A)'
  [../]

  [./em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((1.) / N_A)'
  [../]
  [./ion_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((1.) / N_A)'
  [../]
  [./mean_en_ICs]
    type = ParsedFunction
    vars = 'em_ICs'
    vals = 'em_ICs'
    value = 'log((3./2.)) + em_ICs'
  [../]
[]

[BCs]
  [./potential_left_BC]
    type = FunctionDirichletBC
    variable = potential
    function = 'potential_left_BC'
    boundary = 'left'
    preset = true
  [../]
  [./potential_right_BC]
    type = FunctionDirichletBC
    variable = potential
    function = 'potential_right_BC'
    boundary = 'right'
    preset = true
  [../]

  [./em_left_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_left_BC'
    boundary = 'left'
    preset = true
  [../]
  [./em_right_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_right_BC'
    boundary = 'right'
    preset = true
  [../]

  [./ion_left_BC]
    type = FunctionDirichletBC
    variable = ion
    function = 'ion_left_BC'
    boundary = 'left'
    preset = true
  [../]
  [./ion_right_BC]
    type = FunctionDirichletBC
    variable = ion
    function = 'ion_right_BC'
    boundary = 'right'
    preset = true
  [../]

  [./mean_en_right_BC]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'right'
  [../]
  [./mean_en_left_BC]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'left'
  [../]
[]

[Materials]
  [./Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e  diffpotential diffem muem diffion muion diffmean_en mumean_en N_A'
    prop_values = 'ee diffpotential diffem muem diffion muion diffmean_en mumean_en N_A'
  [../]
  [./Material_Coeff_Deriv]
    type = GenericConstantMaterial
    prop_names =  'd_mumean_en_d_actual_mean_en  d_diffmean_en_d_actual_mean_en  d_muem_d_actual_mean_en  d_diffem_d_actual_mean_en'
    prop_values = '0.0                           0.0                             0.0                      0.0'
  [../]
  [./Charge_Signs]
    type = GenericConstantMaterial
    prop_names =  'sgnem  sgnion  sgnmean_en'
    prop_values = '-1.0   1.0     -1.0'
  [../]
[]

[Postprocessors]
  [./em_l2Error]
    type = ElementL2Error
    variable = em
    function = em_fun
  [../]
  [./ion_l2Error]
    type = ElementL2Error
    variable = ion
    function = ion_fun
  [../]
  [./potential_l2Error]
    type = ElementL2Error
    variable = potential
    function = potential_fun
  [../]
  [./mean_en_l2Error]
    type = ElementL2Error
    variable = mean_en
    function = energy_fun
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
