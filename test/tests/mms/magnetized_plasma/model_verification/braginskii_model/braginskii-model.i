# This input file tests the MMS for the Braginskii Model in Zapdos

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
  [density]
  []
  [electron_velocity]
  []
[]

[Kernels]
  ### Continuity Equation ###
  # Density Time Derivative
  [d_density_dt]
    type = TimeDerivativeLog
    variable = density
  []

  # Div (n v_||)
  [n_times_div_parallel_vel]
    type = ScalarLogDivergenceMatVelocityProduct
    variable = density
    mat_vector = parallel_velocity
  []
  [parallel_vel_times_grad_n]
    type = MatVectorGradientScalarLogProduct
    variable = density
    mat_vector = parallel_velocity
  []

  # Div (n v_ExB)
  [n_times_div_EcrossB_Drift]
    type = ScalarLogDivergenceMatVelocityProduct
    variable = density
    mat_vector = E_cross_B_drift
  []
  [EcrossB_Drift_times_grad_n]
    type = MatVectorGradientScalarLogProduct
    variable = density
    mat_vector = E_cross_B_drift
  []

  # Div (n v_dia)
  [n_times_div_diamagnetic_drift]
    type = ScalarLogDivergenceMatVelocityProduct
    variable = density
    mat_vector = diamagnetic_drift
  []
  [diamagnetic_drift_times_grad_n]
    type = MatVectorGradientScalarLogProduct
    variable = density
    mat_vector = diamagnetic_drift
  []

  # Perp. Density Diffusion
  [perpendicular_diffusion]
    type = CoeffPerpendicularDiffusionLin
    variable = density
  []

  # Source Term
  [continuity_forcing_term]
    type = ADBodyForce
    variable = density
    function = density_forcing_fun
  []

  ###############################################

  ### Momentum Equation for Electrons ###
  # Ele. Vel. Time Derivative
  [d_electron_velocity_dt]
    type = TimeDerivativeLog
    variable = electron_velocity
  []

  # b * V_||,e * Grad V_||,e
  [electron_parallel_v_dot_grad_ve]
    type = MatVectorGradientScalarProduct
    variable = electron_velocity
    mat_vector = parallel_velocity
  []

  # v_ExB * Grad V_||,e
  [EcrossB_Drift_dot_grad_ve]
    type = MatVectorGradientScalarProduct
    variable = electron_velocity
    mat_vector = parallel_velocity
  []

  # Ele. Vel. Perp.  Diffusion
  [electron_velocity_perpendicular_diffusion]
    type = CoeffPerpendicularDiffusionLin
    variable = electron_velocity
  []

  # grad_|| p_e
  [pressure_parallel_gradient]
    type = CoeffParallelDiffusion
    variable = electron_velocity
    coeff = 1.0
    v = pressure
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
    expression_x = ''
    expression_y = ''
    expression_z = ''
  []

  [density_solution]
    type = ParsedFunction
    expression = ''
  []
  [n_forcing_fun]
    type = ParsedFunction
    expression = ''
  []

  [vorticity_solution]
    type = ParsedFunction
    expression = ''
  []
  [omega_forcing_fun]
    type = ParsedFunction
    expression = ''
  []

  [potential_solution]
    type = ParsedFunction
    expression = ''
  []
  [potential_forcing_fun]
    type = ParsedFunction
    expression = ''
  []
[]

[Materials]
  # Electrostatic Electric Field
  [electric_field_solver]
    type = FieldSolverMaterial
    solver = ELECTROSTATIC
    potential = potential
  []

  # Magnetic Unit Vector
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []

  # Velocities
  [magnetic_parallel_velocity]
    type = MagneticParallelVelocity
    scalar_parallel_vel = electron_velocity
  []
  [EcrossB_Drift]
    type = EcrossBDriftVelocity
  []
  [magnetic_diamagnetic_drift]
    type = DiamagneticDriftVelocity
    density = density
    pressure = pressure
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
