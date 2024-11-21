#This MMS test was designed to test TimeDerivativeLog, CoeffDiffusion, EFieldAdvection,
#CoeffDiffusionLin, ChargeSourceMoles_KV, and JouleHeating.

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
  [./potential]
  [../]
  [./ion]
  [../]
  [./mean_en]
  [../]
[]

[Kernels]
#Electron Equations
  [./em_time_derivative]
    type = TimeDerivativeLog
    variable = em
  [../]
  [./em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = 1.0
  [../]
  [./em_advection]
    type = EFieldAdvection
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
    type = TimeDerivativeLog
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
    type = TimeDerivativeLog
    variable = mean_en
  [../]
  [./mean_en_advection]
    type = EFieldAdvection
    variable = mean_en
    potential = potential
    position_units = 1.0
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusion
    variable = mean_en
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

  [./mean_en_sol]
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

  [./mean_en_sol]
    type = FunctionAux
    variable = mean_en_sol
    function = mean_en_fun
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
  #Electron mobility coeff.
  [./muem_coeff]
    type = ConstantFunction
    value = 0.01
  [../]
  #Electron energy diffusion coeff.
  [./diffmean_en_coeff]
    type = ParsedFunction
    vars = 'diffem_coeff'
    vals = 'diffem_coeff'
    value = '5.0 / 3.0 * diffem_coeff'
  [../]
  #Electron energy mobility coeff.
  [./mumean_en_coeff]
    type = ParsedFunction
    vars = 'muem_coeff'
    vals = 'muem_coeff'
    value = '5.0 / 3.0 * muem_coeff'
  [../]
  #Ion diffusion coeff.
  [./diffion]
    type = ConstantFunction
    value = 0.1
  [../]
  #Ion mobility coeff.
  [./muion]
    type = ConstantFunction
    value = 0.025
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
  #Permittivity of Free Space - "Potential diffusion coeff."
  [./diffpotential]
    type = ConstantFunction
    value = 0.01
  [../]


#Manufactured Solutions
  #The manufactured electron density solution
  [./em_fun]
    type = ParsedFunction
    vars = 'N_A x_max y_max f'
    vals = 'N_A x_max y_max f'
    value = 'log((sin(pi*(y/y_max)) + 0.2*sin(2*pi*t*f)*cos(pi*(y/y_max)) + 1.0 + cos(pi/2*(x/x_max))) / N_A)'
  [../]
  #The manufactured ion density solution
  [./ion_fun]
    type = ParsedFunction
    vars = 'N_A x_max y_max f'
    vals = 'N_A x_max y_max f'
    value = 'log((sin(pi*(y/y_max)) + 1.0 + 0.9*cos(pi/2*(x/x_max))) / N_A)'
  [../]
  #The manufactured electron density solution
  [./potential_fun]
    type = ParsedFunction
    vars = 'ee diffpotential x_max y_max f'
    vals = 'ee diffpotential x_max y_max f'
    value = '-(ee*(2*x_max^2*cos((pi*x)/(2*x_max)) + y_max^2*cos((pi*y)/y_max)*sin(2*pi*f*t)))/(5*diffpotential*pi^2)'
  [../]
  #The manufactured electron energy solution
  [./energy_fun]
    type = ParsedFunction
    vars = 'N_A x_max y_max f'
    vals = 'N_A x_max y_max f'
    value = 'sin(pi*(y/y_max)) + sin(2*pi*t*f)*cos(pi*(y/y_max))*sin(pi*(y/y_max)) + 0.75 + cos(pi/2*(x/x_max))'
  [../]
  [./mean_en_fun]
    type = ParsedFunction
    vars = 'energy_fun em_fun'
    vals = 'energy_fun em_fun'
    value = 'log(energy_fun) + em_fun'
  [../]

  #Electron diffusion coeff.
  [./diffem]
    type = ParsedFunction
    vars = 'diffem_coeff energy_fun'
    vals = 'diffem_coeff energy_fun'
    value = 'diffem_coeff * energy_fun'
  [../]
  #Electron mobility coeff.
  [./muem]
    type = ParsedFunction
    vars = 'muem_coeff energy_fun'
    vals = 'muem_coeff energy_fun'
    value = 'muem_coeff * energy_fun'
  [../]
  #Electron energy diffusion coeff.
  [./diffmean_en]
    type = ParsedFunction
    vars = 'diffmean_en_coeff energy_fun'
    vals = 'diffmean_en_coeff energy_fun'
    value = 'diffmean_en_coeff * energy_fun'
  [../]
  #Electron energy mobility coeff.
  [./mumean_en]
    type = ParsedFunction
    vars = 'mumean_en_coeff energy_fun'
    vals = 'mumean_en_coeff energy_fun'
    value = 'mumean_en_coeff * energy_fun'
  [../]

#Source Terms in moles
  #The electron source term.
  [em_source]
    type = ParsedFunction
    value = '-diffem_coeff*(-pi^2*sin(y*pi/y_max)/y_max^2 - 0.2*pi^2*sin(2*pi*f*t)*cos(y*pi/y_max)/y_max^2)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)/N_A - diffem_coeff*(-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*(-pi*sin(y*pi/y_max)^2*sin(2*pi*f*t)/y_max + pi*sin(2*pi*f*t)*cos(y*pi/y_max)^2/y_max + pi*cos(y*pi/y_max)/y_max)/N_A + (1/4)*pi^2*diffem_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) - 1/4*pi^2*diffem_coeff*sin((1/2)*x*pi/x_max)^2/(N_A*x_max^2) + 0.4*pi*f*cos(y*pi/y_max)*cos(2*pi*f*t)/N_A + (1/5)*ee*muem_coeff*y_max*(-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*sin(y*pi/y_max)*sin(2*pi*f*t)/(pi*N_A*diffpotential) + (1/5)*ee*muem_coeff*y_max*(-pi*sin(y*pi/y_max)^2*sin(2*pi*f*t)/y_max + pi*sin(2*pi*f*t)*cos(y*pi/y_max)^2/y_max + pi*cos(y*pi/y_max)/y_max)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin(y*pi/y_max)*sin(2*pi*f*t)/(pi*N_A*diffpotential) + (1/5)*ee*muem_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential) + (1/10)*ee*muem_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*cos((1/2)*x*pi/x_max)/(N_A*diffpotential) - 1/10*ee*muem_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential) - 1/10*ee*muem_coeff*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential)'
    vars = 'diffem_coeff y_max N_A muem_coeff ee x_max diffpotential f'
    vals = 'diffem_coeff y_max N_A muem_coeff ee x_max diffpotential f'
  []

  #The ion source term.
  [ion_source]
    type = ParsedFunction
    value = 'pi^2*diffion*sin(y*pi/y_max)/(N_A*y_max^2) + 0.225*pi^2*diffion*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) - 1/5*ee*muion*(sin(y*pi/y_max) + 0.9*cos((1/2)*x*pi/x_max) + 1.0)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential) - 1/10*ee*muion*(sin(y*pi/y_max) + 0.9*cos((1/2)*x*pi/x_max) + 1.0)*cos((1/2)*x*pi/x_max)/(N_A*diffpotential) + 0.09*ee*muion*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential) - 1/5*ee*muion*sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential)'
    vars = 'y_max muion N_A ee x_max diffpotential diffion f'
    vals = 'y_max muion N_A ee x_max diffpotential diffion f'
  []

  #The mean energy density source term.
  [energy_source]
    type = ParsedFunction
    value = 'diffem_coeff*((1/5)*ee*y_max*(-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*sin(y*pi/y_max)*sin(2*pi*f*t)/(pi*N_A*diffpotential) - 1/10*ee*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential))*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75) - diffmean_en_coeff*((-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)/N_A + (-pi*sin(y*pi/y_max)^2*sin(2*pi*f*t)/y_max + pi*sin(2*pi*f*t)*cos(y*pi/y_max)^2/y_max + pi*cos(y*pi/y_max)/y_max)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)/N_A)*(-pi*sin(y*pi/y_max)^2*sin(2*pi*f*t)/y_max + pi*sin(2*pi*f*t)*cos(y*pi/y_max)^2/y_max + pi*cos(y*pi/y_max)/y_max) - diffmean_en_coeff*((-pi^2*sin(y*pi/y_max)/y_max^2 - 0.2*pi^2*sin(2*pi*f*t)*cos(y*pi/y_max)/y_max^2)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)/N_A + 2*(-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*(-pi*sin(y*pi/y_max)^2*sin(2*pi*f*t)/y_max + pi*sin(2*pi*f*t)*cos(y*pi/y_max)^2/y_max + pi*cos(y*pi/y_max)/y_max)/N_A + (-4*pi^2*sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max)/y_max^2 - pi^2*sin(y*pi/y_max)/y_max^2)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)/N_A)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75) - diffmean_en_coeff*(-1/4*pi^2*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) - 1/4*pi^2*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*cos((1/2)*x*pi/x_max)/(N_A*x_max^2) + (1/2)*pi^2*sin((1/2)*x*pi/x_max)^2/(N_A*x_max^2))*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75) + (1/2)*pi*diffmean_en_coeff*(-1/2*pi*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*sin((1/2)*x*pi/x_max)/(N_A*x_max) - 1/2*pi*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin((1/2)*x*pi/x_max)/(N_A*x_max))*sin((1/2)*x*pi/x_max)/x_max + 0.4*pi*f*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*cos(y*pi/y_max)*cos(2*pi*f*t)/N_A + 2*pi*f*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin(y*pi/y_max)*cos(y*pi/y_max)*cos(2*pi*f*t)/N_A - muem_coeff*((1/25)*ee^2*x_max^2*sin((1/2)*x*pi/x_max)^2/(pi^2*diffpotential^2) + (1/25)*ee^2*y_max^2*sin(y*pi/y_max)^2*sin(2*pi*f*t)^2/(pi^2*diffpotential^2))*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)/N_A + (1/5)*ee*mumean_en_coeff*y_max*(-0.2*pi*sin(y*pi/y_max)*sin(2*pi*f*t)/y_max + pi*cos(y*pi/y_max)/y_max)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)^2*sin(y*pi/y_max)*sin(2*pi*f*t)/(pi*N_A*diffpotential) + (1/5)*ee*mumean_en_coeff*y_max*(-2*pi*sin(y*pi/y_max)^2*sin(2*pi*f*t)/y_max + 2*pi*sin(2*pi*f*t)*cos(y*pi/y_max)^2/y_max + 2*pi*cos(y*pi/y_max)/y_max)*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin(y*pi/y_max)*sin(2*pi*f*t)/(pi*N_A*diffpotential) + (1/5)*ee*mumean_en_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)^2*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin(2*pi*f*t)*cos(y*pi/y_max)/(N_A*diffpotential) + (1/10)*ee*mumean_en_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)^2*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*cos((1/2)*x*pi/x_max)/(N_A*diffpotential) - 1/10*ee*mumean_en_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)^2*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential) - 1/5*ee*mumean_en_coeff*(sin(y*pi/y_max)*sin(2*pi*f*t)*cos(y*pi/y_max) + sin(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 0.75)*(sin(y*pi/y_max) + 0.2*sin(2*pi*f*t)*cos(y*pi/y_max) + cos((1/2)*x*pi/x_max) + 1.0)*sin((1/2)*x*pi/x_max)^2/(N_A*diffpotential)'
    vars = 'diffem_coeff mumean_en_coeff y_max diffmean_en_coeff N_A muem_coeff ee x_max diffpotential f'
    vals = 'diffem_coeff mumean_en_coeff y_max diffmean_en_coeff N_A muem_coeff ee x_max diffpotential f'
  []

  [./em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + cos(pi/2*x)) / N_A)'
  [../]
  [./ion_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + 0.9*cos(pi/2*x)) / N_A)'
  [../]
  [./mean_en_ICs]
    type = ParsedFunction
    vars = 'em_ICs'
    vals = 'em_ICs'
    value = 'log(3./2. + cos(pi/2*x)) + em_ICs'
  [../]
[]

[ICs]
  [./em_ICs]
    type = FunctionIC
    variable = em
    function = em_ICs
  [../]
  [./ion_ICs]
    type = FunctionIC
    variable = ion
    function = ion_ICs
  [../]
  [./mean_en_ICs]
    type = FunctionIC
    variable = mean_en
    function = mean_en_ICs
  [../]
[]

[BCs]
  [./potential_BC]
    type = FunctionDirichletBC
    variable = potential
    function = 'potential_fun'
    boundary = '0 1 2 3'
  [../]

  [./em_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_fun'
    boundary = '0 1 2 3'
  [../]

  [./ion_BC]
    type = FunctionDirichletBC
    variable = ion
    function = 'ion_fun'
    boundary = '0 1 2 3'
  [../]

  [./energy_BC]
    type = FunctionDirichletBC
    variable = mean_en
    function = 'mean_en_fun'
    boundary = '0 1 2 3'
  [../]
[]

[Materials]
  [./Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e N_A'
    prop_values = 'ee N_A'
  [../]
  [./ADMaterial_Coeff_Set1]
    type = ADGenericFunctionMaterial
    prop_names =  'diffpotential diffion muion'
    prop_values = 'diffpotential diffion muion'
  [../]
  [./Material_Coeff_Set2]
    type = ADMMSEEDFRates
    electrons = em
    mean_energy = mean_en
    prop_names =              'diffem        muem        diffmean_en        mumean_en'
    prop_values =             'diffem        muem        diffmean_en        mumean_en'
    d_prop_d_actual_mean_en = 'diffem_coeff  muem_coeff  diffmean_en_coeff  mumean_en_coeff'
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
    function = mean_en_fun
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
