charge = '${units 1 C}'
perp_diffdensity_value = '${fparse 0}'
electron_mass = '${fparse 9.1094e-31}'
ion_mass = '${fparse 1.6726e-27}'

perp_diffelectron_velocity_value = '${fparse 0}'
perp_diffion_velocity_value = '${fparse 0}'

[GlobalParams]
  position_units = 1.0
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'tokamak_mesh-edit-hard.msh'
  []
[]

[Variables]
  [density]
    initial_condition = 1
  []
  [electron_velocity]
  []
  [ion_velocity]
  []
  # [vorticity]
  # []
  # [potential]
  # []
[]

[AuxVariables]
  [Bfield]
    family = LAGRANGE_VEC
  []
  [electron_temp]
    initial_condition = 100
  []
  [vorticity]
  []
  [potential]
  []
[]

[ICs]
  [nearest]
    type = VectorFunctionIC
    variable = 'Bfield'
    function_x = 1
    function_y = 1
    function_z = 1
  []
[]

[Materials]
  # Magnetic Unit Vector
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = Bfield
  []

  # Div(n V_ExB) Coeff.
  [B_mag_inverse]
    type = ADParsedMaterial
    material_property_names = 'mag_magnetic_field'
    expression = '1/mag_magnetic_field'
    property_name = B_mag_inverse
  []
  [density_2_div_B_mag]
    type = ADParsedMaterial
    coupled_variables = 'density'
    material_property_names = 'mag_magnetic_field'
    expression = '2*density/mag_magnetic_field'
    property_name = density_2_div_B_mag
  []

  # Div(n V_dia) Coeff.
  [density_2_div_B_mag_charge]
    type = ADParsedMaterial
    coupled_variables = 'density'
    material_property_names = 'mag_magnetic_field'
    expression = '2*density/(mag_magnetic_field * ${charge})'
    property_name = density_2_div_B_mag_charge
  []
  [elec_Temp_2_div_B_mag_charge]
    type = ADParsedMaterial
    coupled_variables = 'electron_temp'
    material_property_names = 'mag_magnetic_field'
    expression = '2*electron_temp/(mag_magnetic_field * ${charge})'
    property_name = elec_Temp_2_div_B_mag_charge
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
  [ion_velocity_mat]
    type = ADParsedMaterial
    coupled_variables = 'ion_velocity'
    expression = 'ion_velocity'
    property_name = ion_velocity_mat
  []

  # Perp. Density Diffusion Coeff
  [perp_diffdensity]
    type = ADParsedMaterial
    expression = '${perp_diffdensity_value}'
    property_name = perp_diffdensity
  []

  # Grad electron pressure Coeff.
  [electron_temp_mat_div_mass_density]
    type = ADParsedMaterial
    coupled_variables = 'electron_temp density'
    expression = 'electron_temp / (density * ${electron_mass})'
    property_name = electron_temp_mat_div_mass_density
  []
  [electron_temp_mat_div_ion_mass_density]
    type = ADParsedMaterial
    coupled_variables = 'electron_temp density'
    expression = 'electron_temp / (density * ${ion_mass})'
    property_name = electron_temp_mat_div_ion_mass_density
  []

  # Momentum Transfer: Friction Coeff.
  [coulomb_logarithm]
    type = ADParsedMaterial
    coupled_variables = 'density electron_temp'
    expression = 'if(electron_temp < 50, 23.4 - 1.15 * log(density) + 3.45 * log(electron_temp), 25.3 - 1.15 * log(density) + 2.3 * log(electron_temp))'
    property_name = coulomb_logarithm
  []
  [ion_current_coeff]
    type = ADParsedMaterial
    material_property_names = 'coulomb_logarithm'
    expression = '1/(1.96 * coulomb_logarithm)'
    property_name = ion_current_coeff
  []
  [electron_current_coeff]
    type = ADParsedMaterial
    material_property_names = 'coulomb_logarithm'
    expression = '-1/(1.96 * coulomb_logarithm)'
    property_name = electron_current_coeff
  []

  # Perp. Electron Velocity Diffusion Coeff
  [perp_diffelectron_velocity]
    type = ADParsedMaterial
    expression = '${perp_diffelectron_velocity_value}'
    property_name = perp_diffelectron_velocity
  []
  # Perp. Ion Velocity Diffusion Coeff
  [perp_diffion_velocity]
    type = ADParsedMaterial
    expression = '${perp_diffion_velocity_value}'
    property_name = perp_diffion_velocity
  []
[]

[Kernels]
  ### Continuity Equation ###
  # Density Time Derivative
  [d_density_dt]
    type = TimeDerivative
    variable = density
  []

  # Div(n V_ExB)
  [ExB_bracket]
    type = MatBracketOperatorLin
    variable = density
    mat_coeff = B_mag_inverse
    v = potential
    w = density
  []
  [ExB_curvature]
    type = MatCurvatureOperator
    variable = density
    mat_coeff = density_2_div_B_mag
    v = potential
  []

  # Div(n V_dia)
  # Bracket for V_dia cancels out
  [V_dia_curvature_on_Te]
    type = MatCurvatureOperator
    variable = density
    mat_coeff = density_2_div_B_mag_charge
    v = electron_temp
  []
  [V_dia_curvature_on_density]
    type = MatCurvatureOperator
    variable = density
    mat_coeff = elec_Temp_2_div_B_mag_charge
    v = density
  []

  # Div(n V_||)
  [density_parallel_grad_V_e]
    type = CoeffParallelDiffusion
    variable = density
    mat_coeff = density_mat
    v = electron_velocity
  []
  [V_e_parallel_grad_density]
    type = CoeffParallelDiffusion
    variable = density
    mat_coeff = electron_velocity_mat
    v = density
  []

  # Perp. Density Diffusion
  [perpendicular_diffusion]
    type = CoeffPerpendicularDiffusionLin
    variable = density
  []

  ### Electron Momentum Equation ###
  # Elec. Velocity Time Derivative
  [d_electron_velocity_dt]
    type = TimeDerivative
    variable = electron_velocity
  []

  # V_ExB Div(V_||)
  [ExB_bracket_V_elec]
    type = MatBracketOperatorLin
    variable = electron_velocity
    mat_coeff = B_mag_inverse
    v = potential
    w = electron_velocity
  []

  # V_|| Div(V_||)
  [V_elec_parallel_grad_V_elec]
    type = CoeffParallelDiffusion
    variable = electron_velocity
    mat_coeff = electron_velocity_mat
    v = electron_velocity
  []

  # Grad electron pressure
  [electron_temp_parallel_grad_density]
    type = CoeffParallelDiffusion
    variable = electron_velocity
    mat_coeff = electron_temp_mat_div_mass_density
    v = density
  []
  [density_parallel_grad_electron_temp]
    type = CoeffParallelDiffusion
    variable = electron_velocity
    mat_coeff = '${fparse 1 / electron_mass}'
    v = electron_temp
  []

  # Gyroviscou : Add Later

  # Electric Field Advection
  [parallel_potential]
    type = CoeffParallelDiffusion
    variable = electron_velocity
    mat_coeff = '${fparse charge / electron_mass}'
    v = potential
  []

  # Momentum Transfer: Friction Force
  [current_from_ions_velocity]
    type = ADMatReaction
    variable = electron_velocity
    reaction_rate = ion_current_coeff
    v = ion_velocity
  []
  [current_from_electrons_velocity]
    type = ADMatReaction
    variable = electron_velocity
    reaction_rate = electron_current_coeff
    v = electron_velocity
  []

  # Momentum Transfer: Thermal Force
  [coeff_density_parallel_grad_electron_temp]
    type = CoeffParallelDiffusion
    variable = electron_velocity
    mat_coeff = '${fparse 0.71 / electron_mass}'
    v = electron_temp
  []

  # Perp. electron velocity Diffusion
  [perpendicular_electron_velocity]
    type = CoeffPerpendicularDiffusionLin
    variable = electron_velocity
  []

  ### Ion Momentum Equation ###
  # Ion Velocity Time Derivative
  [d_ion_velocity_dt]
    type = TimeDerivative
    variable = ion_velocity
  []

  # V_ExB Div(V_||)
  [ExB_bracket_V_ion]
    type = MatBracketOperatorLin
    variable = ion_velocity
    mat_coeff = B_mag_inverse
    v = potential
    w = ion_velocity
  []

  # V_|| Div(V_||)
  [V_ion_parallel_grad_V_ion]
    type = CoeffParallelDiffusion
    variable = ion_velocity
    mat_coeff = ion_velocity_mat
    v = ion_velocity
  []

  # Grad electron pressure for Ion Momentum
  [electron_temp_parallel_grad_density_for_Ion_Momentum]
    type = CoeffParallelDiffusion
    variable = ion_velocity
    mat_coeff = electron_temp_mat_div_ion_mass_density
    v = density
  []
  [density_parallel_grad_electron_temp_for_Ion_Momentum]
    type = CoeffParallelDiffusion
    variable = ion_velocity
    mat_coeff = '${fparse 1 / ion_mass}'
    v = electron_temp
  []

  # Perp. ion velocity Diffusion
  [perpendicular_ion_velocity]
    type = CoeffPerpendicularDiffusionLin
    variable = ion_velocity
  []

  # ### Electron Temperature Equation ###
  # # Electron Temp Time Derivative
  # [d_electron_temp_dt]
  #   type = TimeDerivative
  #   variable = electron_temp
  # []
[]

[BCs]
  [density_core]
    type = PenaltyDirichletBC
    variable = density
    value = 2
    penalty = 1e8
    boundary = core
  []
  # [electron_temp_core]
  #   type = PenaltyDirichletBC
  #   variable = electron_temp
  #   value = 100
  #   penalty = 1e8
  #   boundary = core
  # []
[]

# [Problem]
#   solve = false
# []

[Preconditioning]
  active = 'smp'
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  dt = 1e-9
  end_time = 0.1

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu superlu_dist NONZERO 1.e-10'

  automatic_scaling = true
  compute_scaling_once = false

  l_max_its = 20
[]

[Outputs]
  exodus = true
[]
