#This MMS test was designed to test the log version of Zapdos'
#kernels with coupling between electrons, ions, potential, and
#the mean electron energy density and CRANE's kernels "EEDFReactionLog"
#for electron and ions and "EEDFEnergyLog" for mean electron energy density.

#Note: The electron/mean energy's diffusion and mobility coefficients are
#directly proportional to the energy function.

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
  [./em_EEDF_Reaction]
    type = EEDFReactionLog
    variable = em
    electrons = em
    mean_energy = mean_en
    target = ion
    reaction = reaction_rate
    coefficient = -1.0
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
  [./ion_EEDF_Reaction]
    type = EEDFReactionLog
    variable = ion
    electrons = em
    mean_energy = mean_en
    target = ion
    reaction = reaction_rate
    coefficient = -1.0
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
  [./mean_en_EEDF_Reaction]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = ion
    reaction = reaction_rate
    threshold_energy = -1.0
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
  [./diffem_coeff]
    type = ConstantFunction
    value = 1.0
  [../]
  #Electron mobility coeff.
  [./muem_coeff]
    type = ConstantFunction
    value = 0.1
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
  #Rate coeff.
  [./rate_coeff]
    type = ConstantFunction
    value = 1.0
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
    vars = 'l f N_A'
    vals = 'l f N_A'
    value = '(x*(1.-x/l) + sin(2.*pi*f*t)*cos(pi*x/l)*x*(1.-x/l) + 0.75) / N_A'
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
  #Rate coeff.
  [./k_reaction_rate]
    type = ParsedFunction
    vars = 'rate_coeff energy_fun'
    vals = 'rate_coeff energy_fun'
    value = 'rate_coeff * energy_fun'
  [../]

#Source Terms in moles
  #The electron source term.
  [./em_source]
    type = ParsedFunction
    vars = 'l f ee diffpotential diffem_coeff muem_coeff N_A'
    vals = 'l f ee diffpotential diffem_coeff muem_coeff N_A'
    value = '((2*f*pi*cos((pi*x)/l)*cos(2*pi*f*t))/5 + (diffem_coeff*(pi^2*cos((pi*x)/l)*sin(2*pi*f*t) + 10)*((x*(l - x))/l^2 +
              (x*cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + 3/4))/(5*l^2) + (((x*(l - x))/l^2 +
              (x*cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + 3/4)*(l^2 + l*x - x^2)*(5*l*x + 5*l^2 - 5*x^2 +
              l^2*cos((pi*x)/l)*sin(2*pi*f*t)))/(5*l^4) - (diffem_coeff*(10*x - 5*l + l*pi*sin((pi*x)/l)*sin(2*pi*f*t))*(x/l^2 - (l - x)/l^2 -
              (cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + (x*cos((pi*x)/l)*sin(2*pi*f*t))/l +
              (x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l^2))/(5*l^2) + (ee*muem_coeff*cos((pi*x)/l)*sin(2*pi*f*t)*((x*(l - x))/l^2 +
              (x*cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + 3/4)*(5*l*x + 5*l^2 - 5*x^2 +
              l^2*cos((pi*x)/l)*sin(2*pi*f*t)))/(25*diffpotential*l^2) -
              (ee*muem_coeff*sin((pi*x)/l)*sin(2*pi*f*t)*(5*l*x + 5*l^2 - 5*x^2 + l^2*cos((pi*x)/l)*sin(2*pi*f*t))*(x/l^2 -
              (l - x)/l^2 - (cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + (x*cos((pi*x)/l)*sin(2*pi*f*t))/l +
              (x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l^2))/(25*diffpotential*l*pi) - (ee*muem_coeff*sin((pi*x)/l)*sin(2*pi*f*t)*((x*(l - x))/l^2 +
              (x*cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + 3/4)*(10*x - 5*l + l*pi*sin((pi*x)/l)*sin(2*pi*f*t)))/(25*diffpotential*l*pi)) / N_A'
  [../]
  #The ion source term.
  [./ion_source]
    type = ParsedFunction
    vars = 'l f ee diffpotential diffion muion N_A'
    vals = 'l f ee diffpotential diffion muion N_A'
    value = '((2*diffion)/l^2 + (((x*(l - x))/l^2 +
              (x*cos((pi*x)/l)*sin(2*pi*f*t)*(l - x))/l + 3/4)*(l^2 + l*x - x^2)*(5*l*x + 5*l^2 - 5*x^2 +
              l^2*cos((pi*x)/l)*sin(2*pi*f*t)))/(5*l^4) - (ee*muion*cos((pi*x)/l)*sin(2*pi*f*t)*(l^2 + l*x - x^2))/(5*diffpotential*l^2) -
              (ee*muion*sin((pi*x)/l)*sin(2*pi*f*t)*(l - 2*x))/(5*diffpotential*l*pi)) / N_A'
  [../]
  #The electron energy source term.
  [./energy_source]
    type = ParsedFunction
    vars = 'l f ee diffpotential diffem_coeff muem_coeff N_A'
    vals = 'l f ee diffpotential diffem_coeff muem_coeff N_A'
    value = '((diffem_coeff*((x/l - 1)/l + x/l^2 + (pi*sin((pi*x)/l)*sin(2*pi*f*t))/(5*l))*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4) + (ee*l*muem_coeff*sin((pi*x)/l)*sin(2*pi*f*t)*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4)*((cos((pi*x)/l)*sin(2*pi*f*t))/5 -
              (x*(x/l - 1))/l + 1))/(5*diffpotential*pi))*((5*(x/l - 1))/(3*l) + (5*x)/(3*l^2) +
              (5*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/3 + (5*x*cos((pi*x)/l)*sin(2*pi*f*t))/(3*l) -
              (5*x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/(3*l)) + ((5*x*(x/l - 1))/(3*l) +
              (5*x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/3 - 5/4)*(diffem_coeff*((x/l - 1)/l + x/l^2 +
              (pi*sin((pi*x)/l)*sin(2*pi*f*t))/(5*l))*((x/l - 1)/l + x/l^2 + cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) +
              (x*cos((pi*x)/l)*sin(2*pi*f*t))/l - (x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/l) +
              diffem_coeff*(2/l^2 + (pi^2*cos((pi*x)/l)*sin(2*pi*f*t))/(5*l^2))*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4) + (ee*muem_coeff*cos((pi*x)/l)*sin(2*pi*f*t)*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4)*((cos((pi*x)/l)*sin(2*pi*f*t))/5 - (x*(x/l - 1))/l + 1))/(5*diffpotential) +
              (ee*l*muem_coeff*sin((pi*x)/l)*sin(2*pi*f*t)*((cos((pi*x)/l)*sin(2*pi*f*t))/5 - (x*(x/l - 1))/l + 1)*((x/l - 1)/l + x/l^2 +
              cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) + (x*cos((pi*x)/l)*sin(2*pi*f*t))/l -
              (x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/l))/(5*diffpotential*pi) - (ee*l*muem_coeff*sin((pi*x)/l)*sin(2*pi*f*t)*((x/l - 1)/l + x/l^2 +
              (pi*sin((pi*x)/l)*sin(2*pi*f*t))/(5*l))*((x*(x/l - 1))/l + x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4))/(5*diffpotential*pi)) -
              diffem_coeff*((cos((pi*x)/l)*sin(2*pi*f*t))/3 - (5*x*(x/l - 1))/(3*l) + 5/3)*((x/l - 1)/l + x/l^2 +
              cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) + (x*cos((pi*x)/l)*sin(2*pi*f*t))/l -
              (x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/l)^2 + ((x*(x/l - 1))/l - 1)*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4)*((cos((pi*x)/l)*sin(2*pi*f*t))/5 - (x*(x/l - 1))/l + 1) +
              diffem_coeff*((5*(x/l - 1))/(3*l) + (5*x)/(3*l^2) + (pi*sin((pi*x)/l)*sin(2*pi*f*t))/(3*l))*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4)*((x/l - 1)/l + x/l^2 + cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) +
              (x*cos((pi*x)/l)*sin(2*pi*f*t))/l - (x*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/l) + diffem_coeff*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4)*((cos((pi*x)/l)*sin(2*pi*f*t))/3 -
              (5*x*(x/l - 1))/(3*l) + 5/3)*((2*x*pi*sin((pi*x)/l)*sin(2*pi*f*t))/l^2 - (2*cos((pi*x)/l)*sin(2*pi*f*t))/l - 2/l^2 +
              (2*pi*sin((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/l + (x*pi^2*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1))/l^2) -
              (2*f*pi*cos((pi*x)/l)*cos(2*pi*f*t)*((x*(x/l - 1))/l + x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4))/5 -
              2*f*x*pi*cos((pi*x)/l)*cos(2*pi*f*t)*(x/l - 1)*((cos((pi*x)/l)*sin(2*pi*f*t))/5 - (x*(x/l - 1))/l + 1) +
              (ee*l*sin((pi*x)/l)*sin(2*pi*f*t)*(diffem_coeff*((x/l - 1)/l + x/l^2 + (pi*sin((pi*x)/l)*sin(2*pi*f*t))/(5*l))*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4) + (ee*l*muem_coeff*sin((pi*x)/l)*sin(2*pi*f*t)*((x*(x/l - 1))/l +
              x*cos((pi*x)/l)*sin(2*pi*f*t)*(x/l - 1) - 3/4)*((cos((pi*x)/l)*sin(2*pi*f*t))/5 -
              (x*(x/l - 1))/l + 1))/(5*diffpotential*pi)))/(5*diffpotential*pi)) / N_A'
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
    value = 'log((1.0) / N_A)'
  [../]
  [./ion_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((1.0) / N_A)'
  [../]
  [./mean_en_ICs]
    type = ParsedFunction
    vars = 'em_ICs'
    vals = 'em_ICs'
    value = 'log(3./2.) + em_ICs'
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
    prop_names =  'e  diffpotential diffem muem diffion muion diffmean_en mumean_en N_A k_reaction_rate'
    prop_values = 'ee diffpotential diffem muem diffion muion diffmean_en mumean_en N_A k_reaction_rate'
  [../]
  [./Material_Coeff_Deriv]
    type = GenericFunctionMaterial
    prop_names =  'd_mumean_en_d_actual_mean_en  d_diffmean_en_d_actual_mean_en  d_muem_d_actual_mean_en  d_diffem_d_actual_mean_en  d_k_d_en_reaction_rate'
    prop_values = 'mumean_en_coeff               diffmean_en_coeff               muem_coeff               diffem_coeff               rate_coeff'
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
