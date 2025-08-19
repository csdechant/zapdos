[Mesh]
  # Note: Need to replace with tokamak mesh
  #
  # [gmg]
  #   type = GeneratedMeshGenerator
  #   dim = 3
  #   nx = 5
  #   ny = 5
  #   nz = 5
  #   zmax = 0.1
  # []
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [n]
  []
  [omega]
  []
  [potential]
  []
[]

[Kernels]
  [d_density_dt]
    type = TimeDerivativeLog
    variable = n
  []
  [bracket_operator_density]
    type = MatVectorGradientScalarLogProduct
    variable = n
    mat_vector = E_cross_B_drift
  []
  [adiabatic_density]
    type = AdiabaticTurbulence
    variable = n
    density = n
    potential = potential
    adiabaticity = adiabaticity
  []
  [directional_Efield]
    type = DirectionalPotentialGradient
    variable = n
    potential = potential
    k = k
    component = 1
  []
  [perpendicular_diffusion_density]
    type = CoeffPerpendicularDiffusion
    variable = n
  []
  [forcing_term_density]
    type = ADBodyForce
    variable = n
    function = n_forcing_fun
  []

  [d_vorticity_dt]
    type = TimeDerivative
    variable = omega
  []
  [bracket_operator_vorticity]
    type = MatVectorGradientScalarProduct
    variable = omega
    mat_vector = E_cross_B_drift
  []
  [adiabatic_vorticity]
    type = AdiabaticTurbulence
    variable = omega
    density = n
    potential = potential
    adiabaticity = adiabaticity
  []
  [perpendicular_diffusion_vorticity]
    type = CoeffPerpendicularDiffusionLin
    variable = omega
  []
  [forcing_term_vorticity]
    type = ADBodyForce
    variable = omega
    function = omega_forcing_fun
  []

  [perpendicular_diffusion_potential]
    type = CoeffPerpendicularDiffusionLin
    variable = potential
  []
  [coupled_force_potential]
    type = ADCoupledForce
    variable = potential
    v = omega
    coef = -1.0
  []
  [forcing_term_potential]
    type = ADBodyForce
    variable = potential
    function = potential_forcing_fun
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
  [density_DirichletBC]
    type = ADFunctionDirichletBC
    variable = n
    function = density_solution
    boundary = 'bottom top left right'
  []
  [vorticity_DirichletBC]
    type = ADFunctionDirichletBC
    variable = omega
    function = vorticity_solution
    boundary = 'bottom top left right'
  []
  [potential_DirichletBC]
    type = ADFunctionDirichletBC
    variable = potential
    function = potential_solution
    boundary = 'bottom top left right'
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '0.0'
    expression_y = '0.0'
    expression_z = '1.0'
  []

  [density_solution]
    type = ParsedFunction
    expression = 'log(0.9*x + 0.2*sin(5.0*x^2 - 2*y)*cos(10*t) + 0.9)'
  []
  [n_forcing_fun]
    type = ParsedFunction
    expression = '20.0*x^2*sin(5.0*x^2 - 2*y)*cos(10*t) + 0.9*x - 1.0*(0.5*x - sin(3.0*x^2 - 3.0*y)*cos(7*t))*sin(x*pi) - 3.0*(2.0*x*cos(10*t)*cos(5.0*x^2 - 2*y) + 0.9)*sin(x*pi)*cos(7*t)*cos(3.0*x^2 - 3.0*y) - 0.4*(pi*(0.5*x - sin(3.0*x^2 - 3.0*y)*cos(7*t))*cos(x*pi) - (6.0*x*cos(7*t)*cos(3.0*x^2 - 3.0*y) - 0.5)*sin(x*pi))*cos(10*t)*cos(5.0*x^2 - 2*y) - 2.0*sin(10*t)*sin(5.0*x^2 - 2*y) + 1.5*sin(x*pi)*cos(7*t)*cos(3.0*x^2 - 3.0*y) + 1.0*sin(5.0*x^2 - 2*y)*cos(10*t) - 2.0*cos(10*t)*cos(5.0*x^2 - 2*y) + 0.9'
  []

  [vorticity_solution]
    type = ParsedFunction
    expression = '0.7*x + 0.2*sin(2.0*x^2 - 3*y)*cos(7*t) + 0.9'
  []
  [omega_forcing_fun]
    type = ParsedFunction
    expression = '3.2*x^2*sin(2.0*x^2 - 3*y)*cos(7*t) + 0.9*x - 1.0*(0.5*x - sin(3.0*x^2 - 3.0*y)*cos(7*t))*sin(x*pi) - 3.0*(0.8*x*cos(7*t)*cos(2.0*x^2 - 3*y) + 0.7)*sin(x*pi)*cos(7*t)*cos(3.0*x^2 - 3.0*y) - 0.6*(pi*(0.5*x - sin(3.0*x^2 - 3.0*y)*cos(7*t))*cos(x*pi) - (6.0*x*cos(7*t)*cos(3.0*x^2 - 3.0*y) - 0.5)*sin(x*pi))*cos(7*t)*cos(2.0*x^2 - 3*y) - 1.4*sin(7*t)*sin(2.0*x^2 - 3*y) + 1.8*sin(2.0*x^2 - 3*y)*cos(7*t) + 0.2*sin(5.0*x^2 - 2*y)*cos(10*t) - 0.8*cos(7*t)*cos(2.0*x^2 - 3*y) + 0.9'
  []

  [potential_solution]
    type = ParsedFunction
    expression = '(0.5*x - sin(3.0*x^2 - 3.0*y)*cos(7*t))*sin(x*pi)'
  []
  [potential_forcing_fun]
    type = ParsedFunction
    expression = '0.7*x + pi^2*(0.5*x - sin(3.0*x^2 - 3.0*y)*cos(7*t))*sin(x*pi) - (36.0*x^2*sin(3.0*x^2 - 3.0*y) - 6.0*cos(3.0*x^2 - 3.0*y))*sin(x*pi)*cos(7*t) + 2*pi*(6.0*x*cos(7*t)*cos(3.0*x^2 - 3.0*y) - 0.5)*cos(x*pi) - 9*sin(x*pi)*sin(3.0*x^2 - 3.0*y)*cos(7*t) + 0.2*sin(2.0*x^2 - 3*y)*cos(7*t) + 0.9'
  []
[]

[Materials]
  [electric_field_solver]
    type = FieldSolverMaterial
    solver = ELECTROSTATIC
    potential = potential
  []
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []
  [EcrossB_Drift]
    type = EcrossBDriftVelocity
  []

  [constant_coefficients]
    type = ADGenericFunctionMaterial
    prop_names = 'adiabaticity k   perp_diffn perp_diffomega perp_diffpotential'
    prop_values = '1.0         0.5 1.0              1.0            1.0'
  []
[]

[Postprocessors]
  [density_l2Error]
    type = ElementL2Error
    variable = n
    function = density_solution
  []
  [vorticity_l2Error]
    type = ElementL2Error
    variable = omega
    function = vorticity_solution
  []
  [potential_l2Error]
    type = ElementL2Error
    variable = potential
    function = potential_solution
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
  scheme = newmark-beta
  dt = 0.01
  end_time = 1.0
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
[]

[Outputs]
  exodus = true
  csv = true
[]
