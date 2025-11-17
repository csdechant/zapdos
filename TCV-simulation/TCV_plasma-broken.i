charge = '${units 1 C}'
perp_diffdensity_value = '${fparse 1}'
#electron_mass = '${fparse 1}'

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
    initial_condition = 1e19
  []
  # [electron_velocity]
  # []
  # [ion_velocity]
  # []
  # [electron_temp]
  # []
  # [vorticity]
  # []
  # [potential]
  # []
[]

[AuxVariables]
  [Bfield]
    family = LAGRANGE_VEC
  []
  [electron_velocity]
  []
  [ion_velocity]
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

  # Perp. Density Diffusion Coeff
  [perp_diffdensity]
    type = ADParsedMaterial
    expression = '${perp_diffdensity_value}'
    property_name = perp_diffdensity
  []

  # # Grad electron pressure Coeff.
  # [electron_temp_mat_div_mass_density]
  #   type = ADParsedMaterial
  #   coupled_variables = 'electron_temp density'
  #   expression = 'electron_temp / (density * ${electron_mass})'
  #   property_name = electron_temp_mat_div_mass_density
  # []
  #
  # # Momentum Transfer: Friction Coeff.
  # # [coulomb_logarithm]
  # #   type = ADParsedMaterial
  # #   coupled_variables = 'density electron_temp'
  # #   expression = 'if(electron_temp < 50, 23.4 - 1.15 * log(density) + 3.45 * log(electron_temp), 25.3 - 1.15 * log(density) + 2.3 * log(electron_temp))'
  # #   property_name = coulomb_logarithm
  # # []
  # [ion_current_coeff]
  #   type = ADParsedMaterial
  #   # material_property_names = 'coulomb_logarithm'
  #   expression = '1/(1.96)'
  #   property_name = ion_current_coeff
  # []
  # [electron_current_coeff]
  #   type = ADParsedMaterial
  #   # material_property_names = 'coulomb_logarithm'
  #   expression = '-1/(1.96)'
  #   property_name = electron_current_coeff
  # []
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

  # ### Electron Momentum Equation ###
  # # Elec. Velocity Time Derivative
  # [d_electron_velocity_dt]
  #   type = TimeDerivative
  #   variable = electron_velocity
  # []
  #
  # # V_ExB Div(V_||)
  # [ExB_bracket_V_elec]
  #   type = MatBracketOperatorLin
  #   variable = electron_velocity
  #   mat_coeff = B_mag_inverse
  #   v = potential
  #   w = electron_velocity
  # []
  #
  # # V_|| Div(V_||)
  # [V_elec_parallel_grad_V_elec]
  #   type = CoeffParallelDiffusion
  #   variable = electron_velocity
  #   mat_coeff = electron_velocity_mat
  #   v = electron_velocity
  # []
  #
  # # Grad electron pressure
  # [electron_temp_parallel_grad_density]
  #   type = CoeffParallelDiffusion
  #   variable = electron_velocity
  #   mat_coeff = electron_temp_mat_div_mass_density
  #   v = density
  # []
  # [density_parallel_grad_electron_temp]
  #   type = CoeffParallelDiffusion
  #   variable = electron_velocity
  #   mat_coeff = '${fparse 1 / electron_mass}'
  #   v = electron_temp
  # []
  #
  # # Gyroviscou : Add Later
  #
  # # # Electric Field Advection
  # # [coeff_density_parallel_grad_electron_temp]
  # #   type = CoeffParallelDiffusion
  # #   variable = electron_velocity
  # #   mat_coeff = coeff_density_mat
  # #   v = electron_temp
  # # []
  #
  # # Momentum Transfer: Friction Force
  # [current_from_ions_velocity]
  #   type = ADMatReaction
  #   variable = electron_velocity
  #   reaction_rate = ion_current_coeff
  #   v = ion_velocity
  # []
  # [current_from_electrons_velocity]
  #   type = ADMatReaction
  #   variable = electron_velocity
  #   reaction_rate = electron_current_coeff
  #   v = electron_velocity
  # []
  #
  # # Momentum Transfer: Thermal Force
  # [coeff_density_parallel_grad_electron_temp]
  #   type = CoeffParallelDiffusion
  #   variable = electron_velocity
  #   mat_coeff = '${fparse 0.71 / electron_mass}'
  #   v = electron_temp
  # []
[]

# [Problem]
#   solve = false
# []

[Executioner]
  type = Transient
  end_time = 0.1
[]

[Outputs]
  exodus = true
[]
