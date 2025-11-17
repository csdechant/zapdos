
# perp_diffdensity_value = '${fparse 0}'
# ion_mass = '${fparse 1.6726e-27}'
#
# perp_diffelectron_velocity_value = '${fparse 0}'
# perp_diffion_velocity_value = '${fparse 0}'

# charge = '${units 1.6022e-19 C}'
# # electron_mass = '${units 9.1094e-31 kg}'
# ion_mass = '${units 3.3211e-27 kg}'

electron_thermal_velocity = '${fparse 1}'

[GlobalParams]
  position_units = 1.0
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'tokamak_mesh-edit-hard-quarter.msh'
  []
[]

[MultiApps]
  [sub]
    type = FullSolveMultiApp
    input_files = magnetic_profile-from-output-file.i
    execute_on = 'INITIAL'
  []
[]

[Transfers]
  [fromsub_x]
    type = MultiAppGeometricInterpolationTransfer
    from_multi_app = sub
    source_variable = Bx
    variable = Bx
  []
  [fromsub_y]
    type = MultiAppGeometricInterpolationTransfer
    from_multi_app = sub
    source_variable = By
    variable = By
  []
  [fromsub_z]
    type = MultiAppGeometricInterpolationTransfer
    from_multi_app = sub
    source_variable = Bz
    variable = Bz
  []
[]

[Variables]
  [density]
    initial_condition = 1
  []
  [electron_temp]
    initial_condition = 1
  []
[]

[AuxVariables]
  [Bx]
  []
  [By]
  []
  [Bz]
  []

  [Bfield]
    family = LAGRANGE_VEC
  []

  [electron_velocity]
    initial_condition = ${electron_thermal_velocity}
  []
[]

[AuxKernels]
  [Bfield_calc]
    type = ParsedVectorAux
    variable = Bfield
    coupled_variables = 'Bx By Bz'
    expression_x = Bx
    expression_y = By
    expression_z = Bz
    execute_on = 'INITIAL'
  []

  # [electron_thermal_velocity]
  #   type = ParsedAux
  #   variable = electron_velocity
  #   coupled_variables = electron_temp
  #   # expression = 'sqrt(8*${charge}*electron_temp/(3.14*${electron_mass}))'
  #   expression = 'sqrt(${charge}*electron_temp/(${ion_mass}))'
  # []
[]

[Materials]
  # Magnetic Unit Vector
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = Bfield
    outputs = exodus
  []

  # Div(n V_||)
  [density_mat]
    type = ADParsedMaterial
    coupled_variables = 'density'
    expression = 'density'
    property_name = density_mat
  []
  [electron_velocity_mat]
    type = ADParsedMaterial
    coupled_variables = 'electron_velocity'
    expression = 'electron_velocity'
    property_name = electron_velocity_mat
  []

  # Div(n V_dia) Coeff.
  [minus_2_density_div_B_mag]
    type = ADParsedMaterial
    coupled_variables = 'density'
    material_property_names = 'mag_magnetic_field'
    expression = '-2*density/(mag_magnetic_field)'
    property_name = minus_2_density_div_B_mag
  []
  [minus_2_elec_temp_div_B_mag]
    type = ADParsedMaterial
    coupled_variables = 'electron_temp'
    material_property_names = 'mag_magnetic_field'
    expression = '-2*electron_temp/(mag_magnetic_field)'
    property_name = minus_2_elec_temp_div_B_mag
  []

  [electron_temp_2div3_mat]
    type = ADParsedMaterial
    coupled_variables = 'electron_temp'
    expression = '2/3 * electron_temp'
    property_name = electron_temp_2div3_mat
  []
[]

[Kernels]
  ### Continuity Equation ###
  # Density Time Derivative
  [d_density_dt]
    type = TimeDerivative
    variable = density
  []

  # Div(n V_||)
  [density_parallel_grad_V_e]
    type = CoeffParallelDiffusionLin
    variable = density
    mat_coeff = density_mat
    v = electron_velocity
  []
  [V_e_parallel_grad_density]
    type = CoeffParallelDiffusionLin
    variable = density
    mat_coeff = electron_velocity_mat
    v = density
  []

  # # Div(n V_dia)
  # # Bracket for V_dia cancels out
  # [V_dia_curvature_on_Te]
  #   type = MatCurvatureOperatorLin
  #   variable = density
  #   mat_coeff = minus_2_density_div_B_mag
  #   v = electron_temp
  # []
  # [V_dia_curvature_on_density]
  #   type = MatCurvatureOperatorLin
  #   variable = density
  #   mat_coeff = minus_2_elec_temp_div_B_mag
  #   v = density
  # []

  # [Artificial_Source]
  #   type = BodyForce
  #   variable = density
  #   value = 10
  # []

  ### Electron Temperature Equation ###
  # Electron Temp Time Derivative
  [d_electron_temp_dt]
    type = TimeDerivative
    variable = electron_temp
  []

  # V_|| Grad Te
  [V_e_parallel_grad_Te]
    type = CoeffParallelDiffusionLin
    variable = electron_temp
    mat_coeff = electron_velocity_mat
    v = electron_temp
  []

  # Te Grad V_||
  [Te_parallel_grad_V_e]
    type = CoeffParallelDiffusionLin
    variable = electron_temp
    mat_coeff = electron_temp_2div3_mat
    v = electron_velocity
  []

  # # Electron Temp Artificial Diffusion
  # [electron_temp_diffusion]
  #   type = MatDiffusion
  #   variable = electron_temp
  #   diffusivity = 1e2
  # []
[]

[BCs]
  # [density_core]
  #   type = PenaltyDirichletBC
  #   variable = density
  #   value = 2
  #   penalty = 1e8
  #   boundary = core
  # []
  [density_core]
    type = DirichletBC
    variable = density
    value = 2
    boundary = core
    preset = false
  []
  [electron_temp_core]
    type = DirichletBC
    variable = electron_temp
    value = 5
    boundary = core
    # preset = false
  []
  [electron_temp_wall]
    type = DirichletBC
    variable = electron_temp
    value = 0.5
    boundary = walls
    # preset = false
  []
[]

[Preconditioning]
  active = 'smp'
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  dt = 1e-2
  num_steps = 10

  steady_state_detection = true

  scheme = newmark-beta
  solve_type = 'NEWTON'
  line_search = 'NONE'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu superlu_dist NONZERO 1.e-10'

  automatic_scaling = true
  compute_scaling_once = false

  l_max_its = 20
  nl_abs_tol = 1e-12
[]

[Outputs]
  exodus = true
[]
