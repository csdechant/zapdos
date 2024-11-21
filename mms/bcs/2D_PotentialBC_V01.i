#This MMS test was designed to test the log version of Zapdos'
#kernels with coupling between electrons, ions, potential, and
#the mean electron energy density.

#The mean electron energy density has a "correction" term that assumes
#an thermal conductivity coefficient of K=3/2*D_e*n_e (this is based on
#using the assumption of Einstein Relation)

#Note: The electron/mean energy's diffusion and mobility coefficients are
#directly proportional to the energy function.


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
  [./ion]
  [../]
  [./mean_en]
  [../]

  [./Ex]
  [../]
  [./Ey]
  [../]

  [./potential]
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
    type = EffectiveEFieldAdvection
    variable = ion
    u = Ex
    v = Ey
    position_units = 1.0
  [../]
  [./ion_source]
    type = BodyForce
    variable = ion
    function = 'ion_source'
  [../]


#Eff. Efield
  [./EffEfield_X_time_deriv]
    type = TimeDerivative
    variable = Ex
  [../]
  [./EffEfield_X_diffusion]
    type = CoeffDiffusionLin
    variable = Ex
    position_units = 1.0
  [../]
  [./EffEfield_X_source]
    type = BodyForce
    variable = Ex
    function = 'Ex_source'
  [../]
  [./EffEfield_Y_time_deriv]
    type = TimeDerivative
    variable = Ey
  [../]
  [./EffEfield_Y_diffusion]
    type = CoeffDiffusionLin
    variable = Ey
    position_units = 1.0
  [../]
  [./EffEfield_Y_source]
    type = BodyForce
    variable = Ey
    function = 'Ey_source'
  [../]

  #Potential
  [./Potential_time_deriv]
    type = TimeDerivative
    variable = potential
  [../]
  [./Potential_diffusion]
    type = CoeffDiffusionLin
    variable = potential
    position_units = 1.0
  [../]
  [./Potential_source]
    type = BodyForce
    variable = potential
    function = 'potential_source'
  [../]

#Electron Energy Equations
  [./mean_en_time_deriv]
    type = TimeDerivativeLog
    variable = mean_en
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusion
    variable = mean_en
    position_units = 1.0
  [../]
  [./mean_en_source]
    type = BodyForce
    variable = mean_en
    function = 'energy_source'
  [../]
[]

[AuxVariables]
  [./mean_en_sol]
  [../]

  [./em_sol]
  [../]

  [./ion_sol]
  [../]

  [./Ex_sol]
  [../]
  [./Ey_sol]
  [../]

  [./potential_sol]
  [../]

  [./potential_grad]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./potential_sol_grad]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
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

  [./Ex_sol]
    type = FunctionAux
    variable = Ex_sol
    function = Ex_fun
  [../]
  [./Ey_sol]
    type = FunctionAux
    variable = Ey_sol
    function = Ey_fun
  [../]

  [./potential_sol]
    type = FunctionAux
    variable = potential_sol
    function = potential_fun
  [../]

  [./potential_grad]
    type = DiffusionFluxAux
    variable = potential_grad
    diffusion_variable = potential
    diffusivity = diffpotential
    component = normal
    boundary = 0
  [../]
  [./potential_sol_grad]
    type = DiffusionFluxAux
    variable = potential_sol_grad
    diffusion_variable = potential_sol
    diffusivity = diffpotential
    component = normal
    boundary = 0
  [../]
[]

[Functions]
#Material Variables
  [./massem]
    type = ConstantFunction
    value = 2.0
  [../]
  #Electron diffusion coeff.
  [./diffem]
    type = ConstantFunction
    value = 0.05
  [../]
  [./muem]
    type = ConstantFunction
    value = 0.01
  [../]
  #Electron energy mobility coeff.
  [./diffmean_en]
    type = ConstantFunction
    value = 0.05
  [../]
  #Ion diffusion coeff.
  [./diffion]
    type = ParsedFunction
    vars = diffem
    vals = diffem
    value = diffem
  [../]
  [./muion]
    type = ParsedFunction
    vars = muem
    vals = muem
    value = muem
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
    value = 0.05
  [../]


#Manufactured Solutions
  #The manufactured electron density solution
  [./em_fun]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((sin(pi*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 2.0 + sin(pi*x)) / N_A)'
  [../]
  #The manufactured ion density solution
  [./ion_fun]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((sin(pi*y) + 0.2*sin(2*pi*t)*cos(pi*y) + 2.0 + sin(pi*x)) / N_A)'
  [../]
  #The manufactured electron energy solution
  [./mean_en_fun]
    type = ParsedFunction
    vars = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    vals = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    value = 'log(((3*massem*pi*((diffpotential*pi*cos(pi*t) - cos(pi*t)*(sin(pi*x) + sin(pi*y)) + 4)/ee + 8*muion*pi*(sin(pi*t) + 1)*(sin(pi*x) + sin(pi*y) + (cos(pi*y)*sin(2*pi*t))/5 + 2))^2)/(16*ee*(sin(pi*x) + sin(pi*y) + (cos(pi*y)*sin(2*pi*t))/5 + 2))) / N_A)'
  [../]
  #The manufactured eff. Efield solution
  [./Ex_fun]
    type = ParsedFunction
    vars = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    vals = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    value = '-pi*cos(pi*x)*(sin(pi*t) + 1)'
  [../]
  [./Ey_fun]
    type = ParsedFunction
    vars = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    vals = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    value = '-pi*cos(pi*y)*(sin(pi*t) + 1)'
  [../]
  #The manufactured potential solution
  [./potential_fun]
    type = ParsedFunction
    vars = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    vals = 'ee N_A diffpotential diffem muem massem diffmean_en diffion muion'
    value = '0.25*(sin(pi*t)/pi + 1.0)*(sin(pi*y) + sin(pi*x)) - t'
  [../]

#Source Terms in moles
  #The electron source term.
  [./em_source]
    type = ParsedFunction
    value = '-diffem*(-pi^2*sin(y*pi) - 0.2*pi^2*sin(2*pi*t)*cos(y*pi))/N_A + pi^2*diffem*sin(x*pi)/N_A + pi*muem*(0.25*sin(pi*t)/pi + 0.25)*(-0.2*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*cos(y*pi)/N_A - pi^2*muem*(0.25*sin(pi*t)/pi + 0.25)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*sin(x*pi)/N_A - pi^2*muem*(0.25*sin(pi*t)/pi + 0.25)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*sin(y*pi)/N_A + pi^2*muem*(0.25*sin(pi*t)/pi + 0.25)*cos(x*pi)^2/N_A + 0.4*pi*cos(y*pi)*cos(2*pi*t)/N_A'
    vars = 'N_A muem diffem'
    vals = 'N_A muem diffem'
  [../]
  #The ion source term.
  [./ion_source]
    type = ParsedFunction
    value = '-diffion*(-pi^2*sin(y*pi) - 0.2*pi^2*sin(2*pi*t)*cos(y*pi))/N_A + pi^2*diffion*sin(x*pi)/N_A - pi*muion*(-0.2*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*(sin(pi*t) + 1)*cos(y*pi)/N_A + pi^2*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*sin(x*pi)/N_A + pi^2*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*sin(y*pi)/N_A - pi^2*muion*(sin(pi*t) + 1)*cos(x*pi)^2/N_A + 0.4*pi*cos(y*pi)*cos(2*pi*t)/N_A'
    vars = 'N_A diffion muion'
    vals = 'N_A diffion muion'
  [../]
  [./energy_source]
    type = ParsedFunction
    value = '-diffmean_en*((3/16)*pi*massem*(-pi^2*sin(y*pi) - 0.2*pi^2*sin(2*pi*t)*cos(y*pi))*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) + (3/16)*pi*massem*(2*pi^2*sin(y*pi) + (2/5)*pi^2*sin(2*pi*t)*cos(y*pi))*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) + (3/8)*pi*massem*(-0.2*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*((2/5)*pi*sin(y*pi)*sin(2*pi*t) - 2*pi*cos(y*pi))*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) + (3/8)*pi*massem*(-0.2*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*(16*pi*muion*(-1/5*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*(sin(pi*t) + 1) - 2*pi*cos(y*pi)*cos(pi*t)/ee)*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) + (3/16)*pi*massem*((2/5)*pi*sin(y*pi)*sin(2*pi*t) - 2*pi*cos(y*pi))*((3/5)*pi*sin(y*pi)*sin(2*pi*t) - 3*pi*cos(y*pi))*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^4) + (3/8)*pi*massem*((2/5)*pi*sin(y*pi)*sin(2*pi*t) - 2*pi*cos(y*pi))*(16*pi*muion*(-1/5*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*(sin(pi*t) + 1) - 2*pi*cos(y*pi)*cos(pi*t)/ee)*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) + (3/16)*pi*massem*(16*pi*muion*(-pi^2*sin(y*pi) - 1/5*pi^2*sin(2*pi*t)*cos(y*pi))*(sin(pi*t) + 1) + 2*pi^2*sin(y*pi)*cos(pi*t)/ee)*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) + (3/16)*pi*massem*(8*pi*muion*(-1/5*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*(sin(pi*t) + 1) - pi*cos(y*pi)*cos(pi*t)/ee)*(16*pi*muion*(-1/5*pi*sin(y*pi)*sin(2*pi*t) + pi*cos(y*pi))*(sin(pi*t) + 1) - 2*pi*cos(y*pi)*cos(pi*t)/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2)) - diffmean_en*(-3/16*pi^3*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*sin(x*pi)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) + (3/8)*pi^3*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*sin(x*pi)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) - 3/4*pi^3*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*cos(x*pi)^2/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) + (9/8)*pi^3*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*cos(x*pi)^2/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^4) + (3/8)*pi^2*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)*(16*pi^2*muion*(sin(pi*t) + 1)*cos(x*pi) - 2*pi*cos(x*pi)*cos(pi*t)/ee)*cos(x*pi)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) - 3/4*pi^2*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)*(16*pi^2*muion*(sin(pi*t) + 1)*cos(x*pi) - 2*pi*cos(x*pi)*cos(pi*t)/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*cos(x*pi)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) + (3/16)*pi*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)*(-16*pi^3*muion*(sin(pi*t) + 1)*sin(x*pi) + 2*pi^2*sin(x*pi)*cos(pi*t)/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) + (3/16)*pi*massem*(8*pi^2*muion*(sin(pi*t) + 1)*cos(x*pi) - pi*cos(x*pi)*cos(pi*t)/ee)*(16*pi^2*muion*(sin(pi*t) + 1)*cos(x*pi) - 2*pi*cos(x*pi)*cos(pi*t)/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2)) + 0.075*pi^2*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*cos(y*pi)*cos(2*pi*t)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2) - 3/20*pi^2*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)^2*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)*cos(y*pi)*cos(2*pi*t)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^3) + (3/16)*pi*massem*(8*pi*muion*(sin(pi*t) + 1)*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2) + (pi*diffpotential*cos(pi*t) - (sin(x*pi) + sin(y*pi))*cos(pi*t) + 4)/ee)*((32/5)*pi^2*muion*(sin(pi*t) + 1)*cos(y*pi)*cos(2*pi*t) + 16*pi^2*muion*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)*cos(pi*t) + 2*(-pi^2*diffpotential*sin(pi*t) - pi*(-sin(x*pi) - sin(y*pi))*sin(pi*t))/ee)*(sin(x*pi) + sin(y*pi) + 0.2*sin(2*pi*t)*cos(y*pi) + 2.0)/(N_A*ee*(sin(x*pi) + sin(y*pi) + (1/5)*sin(2*pi*t)*cos(y*pi) + 2)^2)'
    vars = 'N_A ee muion diffmean_en diffpotential massem'
    vals = 'N_A ee muion diffmean_en diffpotential massem'
  [../]

  #The Ex source term.
  [./Ex_source]
    type = ParsedFunction
    value = '-pi^3*diffpotential*(sin(pi*t) + 1)*cos(x*pi) - pi^2*cos(x*pi)*cos(pi*t)'
    vars = 'diffpotential'
    vals = 'diffpotential'
  [../]
  [./Ey_source]
    type = ParsedFunction
    value = '-pi^3*diffpotential*(sin(pi*t) + 1)*cos(y*pi) - pi^2*cos(y*pi)*cos(pi*t)'
    vars = 'diffpotential'
    vals = 'diffpotential'
  [../]

  [./potential_source]
    type = ParsedFunction
    value = 'pi^2*diffpotential*(0.25*sin(pi*t)/pi + 0.25)*sin(x*pi) + pi^2*diffpotential*(0.25*sin(pi*t)/pi + 0.25)*sin(y*pi) + 0.25*(sin(x*pi) + sin(y*pi))*cos(pi*t) - 1'
    vars = 'diffpotential'
    vals = 'diffpotential'
  [../]

  [./em_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + sin(pi/2*x)) / N_A)'
  [../]
  [./ion_ICs]
    type = ParsedFunction
    vars = 'N_A'
    vals = 'N_A'
    value = 'log((3.0 + sin(pi/2*x)) / N_A)'
  [../]
  [./mean_en_ICs]
    type = ParsedFunction
    vars = 'em_ICs'
    vals = 'em_ICs'
    value = 'log(3./2.) + em_ICs'
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
  [./em_BC]
    type = FunctionDirichletBC
    variable = em
    function = 'em_fun'
    boundary = '0 1 2 3'
    preset = true
  [../]

  [./ion_BC]
    type = FunctionDirichletBC
    variable = ion
    function = 'ion_fun'
    boundary = '0 1 2 3'
    preset = true
  [../]

  [./energy_BC]
    type = FunctionDirichletBC
    variable = mean_en
    function = 'mean_en_fun'
    boundary = '0 1 2 3'
    preset = true
  [../]

  [./Ex_BC]
    type = FunctionDirichletBC
    variable = Ex
    function = 'Ex_fun'
    boundary = '0 1 2 3'
    preset = true
  [../]

  [./Ey_BC]
    type = FunctionDirichletBC
    variable = Ey
    function = 'Ey_fun'
    boundary = '0 1 2 3'
    preset = true
  [../]

  [./potential_BC]
    type = FunctionDirichletBC
    variable = potential
    function = 'potential_fun'
    boundary = '1 2 3'
    preset = true
  [../]

  #[./potential_left_dielectric_BC]
  #  type = DielectricBCWithEffEfield
  #  variable = potential
  #  em = em
  #  ip = ion
  #  mean_en = mean_en
  #  Ex = Ex
  #  Ey = Ey
  #  boundary = 3
  #  thickness = 1.0
  #  dielectric_constant = 1.0
  #  potential_units = 'V'
  #  position_units = 1.0
  #  users_gamma = 1.0
  #[../]


  #[./Potential_down_GradientNeumann]
  #  type = FunctionGradientNeumannBC
  #  variable = potential
  #  exact_solution = potential_fun
  #  coeff = 0.05
  #  boundary = 0
  #[../]

  [./potential_down_dielectric_BC]
    type = DielectricBCWithEffEfield
    variable = potential
    em = em_sol
    ip = ion_sol
    mean_en = mean_en_sol
    Ex = Ex_sol
    Ey = Ey_sol
    boundary = 0
    thickness = 8.8542e-12
    dielectric_constant = 1.0
    potential_units = 'V'
    position_units = 1.0
    users_gamma = 1.0
  [../]
[]

[Materials]
  [./Material_Coeff]
    type = GenericFunctionMaterial
    prop_names =  'e  N_A  massem'
    prop_values = 'ee N_A  massem'
  [../]
  [./ADMaterial_Coeff_Set1]
    type = ADGenericFunctionMaterial
    prop_names =  'diffion  muion  diffem  muem  diffmean_en diffpotential  diffEx         diffEy'
    prop_values = 'diffion  muion  diffem  muem  diffmean_en diffpotential  diffpotential  diffpotential'
  [../]
  [./Charge_Signs]
    type = GenericConstantMaterial
    prop_names =  'sgnem  sgnion  sgnmean_en'
    prop_values = '-1.0   1.0     -1.0'
  [../]

  [./Material_Coeff_A]
    type = GenericFunctionMaterial
    prop_names =  'massem_sol'
    prop_values = 'massem'
  [../]
  [./ADMaterial_Coeff_Set1_A]
    type = ADGenericFunctionMaterial
    prop_names =  'diffion_sol  muion_sol  diffem_sol  muem_sol  diffmean_en_sol diffpotential_sol  diffEx_sol     diffEy_sol'
    prop_values = 'diffion      muion      diffem      muem      diffmean_en     diffpotential      diffpotential  diffpotential'
  [../]
  [./Charge_Signs_A]
    type = GenericConstantMaterial
    prop_names =  'sgnem_sol  sgnion_sol  sgnmean_en_sol'
    prop_values = '-1.0       1.0         -1.0'
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
  [./mean_en_l2Error]
    type = ElementL2Error
    variable = mean_en
    function = mean_en_fun
  [../]

  [./Ex_l2Error]
    type = ElementL2Error
    variable = Ex
    function = Ex_fun
  [../]
  [./Ey_l2Error]
    type = ElementL2Error
    variable = Ey
    function = Ey_fun
  [../]

  [./potential_l2Error]
    type = ElementL2Error
    variable = potential
    function = potential_fun
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
