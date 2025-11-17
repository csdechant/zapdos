[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 25
    ny = 25
    nz = 25
    elem_type = HEX20
  []
[]

[GlobalParams]
  position_units = 1.0
[]

[Problem]
  type = FEProblem
[]

[Variables]
  # [density]
  # []
  # [electron_velocity]
  #   initial_condition = 1
  # []
  # [ion_velocity]
  #   initial_condition = 1
  # []
  # [electron_temp]
  #   initial_condition = 1
  # []

  [potential]
    initial_condition = 1
  []
  # [vorticity]
  #   initial_condition = 1
  # []
[]

[Materials]
  [magnetic_unit_vector]
    type = MagneticUnitVector
    magnetic_field = B_field
  []

  # ### Material for Cont. Equation ###
  # Div(n V_ExB) Coeff.
  # [B_mag_inverse]
  #   # Also used for V_ExB Div(V_||) for both Elec. & Ion
  #   # Also for electron temp equation
  #   type = ADParsedMaterial
  #   material_property_names = 'mag_magnetic_field'
  #   expression = '1/mag_magnetic_field'
  #   property_name = B_mag_inverse
  # []
  # [density_2_div_B_mag]
  #   type = ADParsedMaterial
  #   coupled_variables = 'density'
  #   material_property_names = 'mag_magnetic_field'
  #   expression = '2*density/mag_magnetic_field'
  #   property_name = density_2_div_B_mag
  # []
  #
  # # Div(n V_dia) Coeff.
  # [minus_2_density_div_B_mag]
  #   type = ADParsedMaterial
  #   coupled_variables = 'density'
  #   material_property_names = 'mag_magnetic_field'
  #   expression = '-2*density/(mag_magnetic_field)'
  #   property_name = minus_2_density_div_B_mag
  # []
  # [minus_2_elec_temp_div_B_mag]
  #   type = ADParsedMaterial
  #   coupled_variables = 'electron_temp'
  #   material_property_names = 'mag_magnetic_field'
  #   expression = '-2*electron_temp/(mag_magnetic_field)'
  #   property_name = minus_2_elec_temp_div_B_mag
  # []
  #
  # # Div(n V_||)
  # [density_mat]
  #   type = ADParsedMaterial
  #   coupled_variables = 'density'
  #   expression = 'density'
  #   property_name = density_mat
  # []
  # [electron_velocity_mat]
  #   # Also used for V_|| Div(V_||)
  #   # Also used of electron energy equation
  #   type = ADParsedMaterial
  #   coupled_variables = 'electron_velocity'
  #   expression = 'electron_velocity'
  #   property_name = electron_velocity_mat
  # []
  #
  # ### Material for Momentum Equation ###
  # # Grad electron pressure Coeff.
  # [electron_temp_div_density_mat]
  #   # Also for ion momentum
  #   type = ADParsedMaterial
  #   coupled_variables = 'electron_temp density'
  #   expression = 'electron_temp / density'
  #   property_name = electron_temp_div_density_mat
  # []
  # [ion_velocity_mat]
  #   type = ADParsedMaterial
  #   coupled_variables = 'ion_velocity'
  #   expression = 'ion_velocity'
  #   property_name = ion_velocity_mat
  # []
  #
  # # Electron Temp. Curvature Operator Coeff.s
  # [curv_coeff]
  #   type = ADParsedMaterial
  #   coupled_variables = 'electron_temp'
  #   material_property_names = 'mag_magnetic_field'
  #   expression = '4/3 * electron_temp/mag_magnetic_field'
  #   property_name = 'curv_coeff'
  # []
  # [minus_curv_coeff_times_7_div_2]
  #   type = ADParsedMaterial
  #   material_property_names = 'curv_coeff'
  #   expression = '-7/2 * curv_coeff'
  #   property_name = 'minus_curv_coeff_times_7_div_2'
  # []
  # [minus_curv_coeff_times_electron_temp_div_density]
  #   type = ADParsedMaterial
  #   material_property_names = 'curv_coeff'
  #   coupled_variables = 'electron_temp density'
  #   expression = '-1.0*curv_coeff * electron_temp/density'
  #   property_name = 'minus_curv_coeff_times_electron_temp_div_density'
  # []
  #
  # # Electron Temp. Parallel Operator Coeff.s
  # [parallel_coeff]
  #   type = ADParsedMaterial
  #   coupled_variables = 'electron_temp'
  #   expression = '2/3 * electron_temp'
  #   property_name = 'parallel_coeff'
  # []
  # [minus_parallel_coeff_times0d71]
  #   type = ADParsedMaterial
  #   material_property_names = 'parallel_coeff'
  #   expression = '-0.71*parallel_coeff'
  #   property_name = 'minus_parallel_coeff_times0d71'
  # []
  # [tparallel_coeff_times1d71]
  #   type = ADParsedMaterial
  #   material_property_names = 'parallel_coeff'
  #   expression = '1.71*parallel_coeff'
  #   property_name = 'parallel_coeff_times1d71'
  # []
  # [parallel_coeff_times0d71_J_div_density]
  #   type = ADParsedMaterial
  #   material_property_names = 'parallel_coeff'
  #   coupled_variables = 'density electron_velocity ion_velocity'
  #   expression = '-1.0*parallel_coeff*(ion_velocity - electron_velocity)/density'
  #   property_name = 'parallel_coeff_times0d71_J_div_density'
  # []

  [potential_perpendicular_diffusion]
    type = ADParsedMaterial
    expression = '1.0'
    property_name = 'perp_diffpotential'
  []
[]

[Kernels]
  # ### Continuity Equation ###
  # # Div(n V_ExB)
  # [density_bracket_operator]
  #   type = MatBracketOperatorLin
  #   variable = density
  #   mat_coeff = B_mag_inverse
  #   v = potential
  #   w = density
  # []
  # [density_curvature_operator_on_potential]
  #   type = MatCurvatureOperatorLin
  #   variable = density
  #   mat_coeff = density_2_div_B_mag
  #   v = potential
  # []
  #
  # # Div(n V_dia)
  # [density_curvature_operator_on_temp]
  #   type = MatCurvatureOperatorLin
  #   variable = density
  #   mat_coeff = minus_2_density_div_B_mag
  #   v = electron_temp
  # []
  # [density_curvature_operator_density]
  #   type = MatCurvatureOperatorLin
  #   variable = density
  #   mat_coeff = minus_2_elec_temp_div_B_mag
  #   v = density
  # []
  #
  # # Div(n V_||)
  # [density_parallel_grad_V_e]
  #   type = CoeffParallelDiffusionLin
  #   variable = density
  #   mat_coeff = density_mat
  #   v = electron_velocity
  # []
  # [V_e_parallel_grad_density]
  #   type = CoeffParallelDiffusionLin
  #   variable = density
  #   mat_coeff = electron_velocity_mat
  #   v = density
  # []
  #
  # [density_forcing_term]
  #   type = BodyForce
  #   variable = density
  #   function = density_source_term
  # []

  # ### Electron Momentum Equation ###
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
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_velocity
  #   mat_coeff = electron_velocity_mat
  #   v = electron_velocity
  # []
  #
  # # Momentum Transfer: Friction Force
  # # Note: MatReaction includes a negative sign...
  # [current_from_electrons_velocity]
  #   type = ADMatReaction
  #   variable = electron_velocity
  #   reaction_rate = '-1.0'
  #   v = electron_velocity
  # []
  # [current_from_ions_velocity]
  #   type = ADMatReaction
  #   variable = electron_velocity
  #   reaction_rate = '1.0'
  #   v = ion_velocity
  # []
  #
  # # E-field Advection
  # [parallel_grad_potential]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_velocity
  #   mat_coeff = '-1.0'
  #   v = potential
  # []
  #
  # # Grad electron pressure
  # [electron_temp_parallel_grad_density]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_velocity
  #   mat_coeff = electron_temp_div_density_mat
  #   v = density
  # []
  # [density_parallel_grad_electron_temp]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_velocity
  #   mat_coeff = '1.0'
  #   v = electron_temp
  # []
  #
  # # Momentum Transfer: Thermal Force
  # [coeff_density_parallel_grad_electron_temp]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_velocity
  #   mat_coeff = '0.71'
  #   v = electron_temp
  # []
  #
  # [electron_velocity_forcing_term]
  #   type = BodyForce
  #   variable = electron_velocity
  #   function = electron_velocity_source_term
  # []

  # ### Ion Momentum Equation ###
  # [d_ion_velocity_dt]
  #   type = TimeDerivative
  #   variable = ion_velocity
  # []
  #
  # # Ion: V_ExB Div(V_||)
  # [ExB_bracket_V_ion]
  #   type = MatBracketOperatorLin
  #   variable = ion_velocity
  #   mat_coeff = B_mag_inverse
  #   v = potential
  #   w = ion_velocity
  # []
  #
  # # Ion: V_|| Div(V_||)
  # [V_ion_parallel_grad_V_ion]
  #   type = CoeffParallelDiffusionLin
  #   variable = ion_velocity
  #   mat_coeff = ion_velocity_mat
  #   v = ion_velocity
  # []
  #
  # # Grad electron pressure
  # [electron_temp_parallel_grad_density]
  #   type = CoeffParallelDiffusionLin
  #   variable = ion_velocity
  #   mat_coeff = electron_temp_div_density_mat
  #   v = density
  # []
  # [density_parallel_grad_electron_temp]
  #   type = CoeffParallelDiffusionLin
  #   variable = ion_velocity
  #   mat_coeff = '1.0'
  #   v = electron_temp
  # []
  #
  # [ion_velocity_forcing_term]
  #   type = BodyForce
  #   variable = ion_velocity
  #   function = ion_velocity_source_term
  # []

  # ### Electron Energy Equation ###
  # # V_ExB Grad Te
  # [ExB_bracket_electron_temp]
  #   type = MatBracketOperatorLin
  #   variable = electron_temp
  #   mat_coeff = B_mag_inverse
  #   v = potential
  #   w = electron_temp
  # []
  #
  # # V_|| Grad Te
  # [V_elec_parallel_grad_electron_temp]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_temp
  #   mat_coeff = electron_velocity_mat
  #   v = electron_temp
  # []
  #
  # # Curvature Operator for Electron Temp.
  # [temp_curvature_operator_on_temp]
  #   type = MatCurvatureOperatorLin
  #   variable = electron_temp
  #   mat_coeff = 'minus_curv_coeff_times_7_div_2'
  #   v = electron_temp
  # []
  # [temp_curvature_operator_on_density]
  #   type = MatCurvatureOperatorLin
  #   variable = electron_temp
  #   mat_coeff = 'minus_curv_coeff_times_electron_temp_div_density'
  #   v = density
  # []
  # [temp_curvature_operator_on_potential]
  #   type = MatCurvatureOperatorLin
  #   variable = electron_temp
  #   mat_coeff = 'curv_coeff'
  #   v = potential
  # []
  #
  # # Parallel OPerators for Electron Temp.
  # [temp_parallel_grad_ion_velocity]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_temp
  #   mat_coeff = 'minus_parallel_coeff_times0d71'
  #   v = ion_velocity
  # []
  # [temp_parallel_grad_elec_velocity]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_temp
  #   mat_coeff = 'parallel_coeff_times1d71'
  #   v = electron_velocity
  # []
  # [temp_parallel_grad_density]
  #   type = CoeffParallelDiffusionLin
  #   variable = electron_temp
  #   mat_coeff = 'parallel_coeff_times0d71_J_div_density'
  #   v = density
  # []
  # [ion_velocity_forcing_term]
  #   type = BodyForce
  #   variable = electron_temp
  #   function = electron_temp_source_term
  # []

  ### Potential Equation ###
  [potential_perpendicular_diffusion]
    type = CoeffPerpendicularDiffusionLin
    variable = potential
  []
  [potential_forcing_term]
    type = ADBodyForce
    variable = potential
    value = '-1.0'
    function = vorticity_solution
  []
[]

[BCs]
  # [density_DirichletBC]
  #   type = ADFunctionDirichletBC
  #   variable = density
  #   function = density_solution
  #   boundary = 'bottom top left right front back'
  # []

  # [electron_velocity_DirichletBC]
  #   type = ADFunctionDirichletBC
  #   variable = electron_velocity
  #   function = electron_velocity_solution
  #   boundary = 'bottom top left right front back'
  # []

  # [ion_velocity_DirichletBC]
  #   type = ADFunctionDirichletBC
  #   variable = ion_velocity
  #   function = ion_velocity_solution
  #   boundary = 'bottom top left right front back'
  # []

  # [electron_temp_DirichletBC]
  #   type = ADFunctionDirichletBC
  #   variable = electron_temp
  #   function = electron_temp_solution
  #   boundary = 'bottom top left right front back'
  # []

  [electron_temp_DirichletBC]
    type = ADFunctionDirichletBC
    variable = potential
    function = potential_solution
    boundary = 'bottom top left right front back'
  []
  # [vorticity_DirichletBC]
  #   type = ADFunctionDirichletBC
  #   variable = vorticity
  #   function = vorticity_solution
  #   boundary = 'bottom top left right front back'
  # []
[]

[AuxVariables]
  [B_field]
    family = LAGRANGE_VEC
  []

  [density]
  []
  # [density_solution]
  # []
  [electron_velocity]
  []
  # [electron_velocity_solution]
  # []
  [ion_velocity]
  []
  # [ion_velocity_solution]
  # []
  [electron_temp]
  []
  # [electron_temp_solution]
  # []

  [potential_solution]
  []
  [vorticity_solution]
  []
[]

[AuxKernels]
  [B_field_calc]
    type = VectorFunctionAux
    variable = B_field
    function = B_field_fun
  []

  [density_solution_calc]
    type = FunctionAux
    variable = density
    # variable = density_solution
    function = density_solution
  []
  [electron_velocity_solution_calc]
    type = FunctionAux
    # variable = electron_velocity_solution
    variable = electron_velocity
    function = electron_velocity_solution
  []
  [ion_velocity_solution_calc]
    type = FunctionAux
    # variable = ion_velocity_solution
    variable = ion_velocity
    function = ion_velocity_solution
  []
  [electron_temp_solution_calc]
    type = FunctionAux
    # variable = electron_temp_solution
    variable = electron_temp
    function = electron_temp_solution
  []

  [potential_solution_calc]
    type = FunctionAux
    variable = potential_solution
    function = potential_solution
  []
  [vorticity_solution_calc]
    type = FunctionAux
    variable = vorticity_solution
    function = vorticity_solution
  []
[]

[Functions]
  [B_field_fun]
    type = ParsedVectorFunction
    expression_x = '(sin(x*y*z))'
    expression_y = '(-cos(x*y*z))'
    expression_z = '(cos(x*y*z))'
  []

  [density_solution]
    type = ParsedFunction
    expression = '0.9*x + 0.01*sin(y - z) + 0.9'
  []
  [electron_velocity_solution]
    type = ParsedFunction
    expression = '2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z)'
  []
  [ion_velocity_solution]
    type = ParsedFunction
    # expression = '-0.01*cos(3*x^2 + 2*y - 2*z)'
    expression = ' 2*sin(z + (x - 0.5)^2)'
  []
  [electron_temp_solution]
    type = ParsedFunction
    expression = '0.5*cos(3*x^2 - 2*z) + 1'
  []

  [potential_solution]
    type = ParsedFunction
    expression = '-(sin(x - z) - 0.001*cos(y - z))*sin(6.28*x)'
  []
  [vorticity_solution]
    type = ParsedFunction
    expression = '((x*y*(-(0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*cos(x*y*z) + (-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*sin(6.28*x)*sin(y - z)*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (cos(x*y*z)^2 + 1)*(x*y*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*sin(x*y*z) + x*y*(-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*cos(x*y*z) + 0.001*x*y*sin(6.28*x)*sin(x*y*z)*sin(y - z) - (sin(x - z) - 0.001*cos(y - z))*sin(6.28*x)*cos(x*y*z) - (-0.00314*sin(6.28*x - y + z) + 0.00314*sin(6.28*x + y - z) + 2.64*cos(5.28*x + z) + 3.64*cos(7.28*x - z))*sin(x*y*z) + 0.001*sin(6.28*x)*cos(x*y*z)*cos(y - z)))*cos(x*y*z) - (x*z*(-(0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*cos(x*y*z) + (-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*sin(6.28*x)*sin(y - z)*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (cos(x*y*z)^2 + 1)*(x*z*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*sin(x*y*z) + x*z*(-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*cos(x*y*z) + 0.001*x*z*sin(6.28*x)*sin(x*y*z)*sin(y - z) - 0.002*sin(6.28*x)*cos(x*y*z)*cos(y - z) + 0.00628*sin(x*y*z)*sin(y - z)*cos(6.28*x)))*cos(x*y*z) + (y*z*(-(0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*cos(x*y*z) + (-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*sin(6.28*x)*sin(y - z)*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (cos(x*y*z)^2 + 1)*(y*z*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*sin(x*y*z) + y*z*(-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*cos(x*y*z) + 0.001*y*z*sin(6.28*x)*sin(x*y*z)*sin(y - z) - 6.28*(0.001*sin(y - z) + cos(x - z))*cos(6.28*x)*cos(x*y*z) + (0.0197192*sin(6.28*x - y + z) + 0.0197192*sin(6.28*x + y - z) - 13.9392*cos(5.28*x + z) + 26.4992*cos(7.28*x - z))*sin(x*y*z) + sin(6.28*x)*sin(x - z)*cos(x*y*z) - 0.00628*sin(y - z)*cos(6.28*x)*cos(x*y*z)))*sin(x*y*z) + (cos(x*y*z)^2 + 1)^2*(-0.0207192*sin(6.28*x - y + z) - 0.0207192*sin(6.28*x + y - z) + 14.4392*cos(5.28*x + z) - 26.9992*cos(7.28*x - z)) + (cos(x*y*z)^2 + 1)*(x*y*sin(x*y*z) - x*z*sin(x*y*z) - y*z*cos(x*y*z))*((0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*cos(x*y*z) - (-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) + 0.001*sin(6.28*x)*sin(y - z)*cos(x*y*z)) + (-x*y*cos(x*y*z) + x*z*cos(x*y*z) - y*z*sin(x*y*z))*((0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*cos(x*y*z) - (-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) + 0.001*sin(6.28*x)*sin(y - z)*cos(x*y*z))*sin(x*y*z)*cos(x*y*z))/(cos(x*y*z)^2 + 1)^2'
  []

  ### Note: Ion Velocity has changed. Density and Electron Velocity Source Needs to change
  # [density_source_term]
  #   type = ParsedFunction
  #
  #   # Div(n V_||) + Div(n V_ExB) + Div(n V_dia)
  #   expression = '(((0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))*(2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z)) + (0.9*x + 0.01*sin(y - z) + 0.9)*(-(0.3*x*sin(3*x^2 + 2*y - 2*z) + (2.0 - 4*x)*cos(z + (x - 0.5)^2))*sin(x*y*z) + (0.1*sin(3*x^2 + 2*y - 2*z) + 2*cos(z + (x - 0.5)^2))*cos(x*y*z) + 0.1*sin(3*x^2 + 2*y - 2*z)*cos(x*y*z)))*(cos(x*y*z)^2 + 1)^(19/2)*(0.9*x + 0.01*sin(y - z) + 0.9) + (-x*(0.5*cos(3*x^2 - 2*z) + 1)*(0.01125*y*cos(x*y*z - y + z) + 0.01125*y*cos(x*y*z + y - z) - 0.00125*y*cos(3*x*y*z - y + z) - 0.00125*y*cos(3*x*y*z + y - z) + 0.01125*z*cos(x*y*z - y + z) + 0.01125*z*cos(x*y*z + y - z) - 0.00125*z*cos(3*x*y*z - y + z) - 0.00125*z*cos(3*x*y*z + y - z) - 0.9*(y + z)*(cos(x*y*z)^2 + 1)*sin(x*y*z) + 1.8*(y + z)*sin(x*y*z)*cos(x*y*z)^2) + (0.9*x + 0.01*sin(y - z) + 0.9)*(-3.0*x^2*(1 - cos(x*y*z)^2)*(y + z)*sin(x*y*z)*sin(3*x^2 - 2*z) + x*(1 - cos(x*y*z)^2)*(y + z)*(-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*y*(2*(x*sin(x*y*z) - z*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) + z*sin(x*y*z))*(cos(x*y*z)^2 + 1))*sin(6.28*x)*sin(y - z) - z*(2*(x*sin(x*y*z) + y*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) - y*sin(x*y*z))*(cos(x*y*z)^2 + 1))*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x) + 1.0*z*(2*(x*sin(x*y*z) + y*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) - y*sin(x*y*z))*(cos(x*y*z)^2 + 1))*sin(3*x^2 - 2*z)))*(cos(x*y*z)^2 + 1)^8*(1.8*x + 0.02*sin(y - z) + 1.8)/2 + (cos(x*y*z)^2 + 1)^9*(0.9*x + 0.01*sin(y - z) + 0.9)*(-0.225*sin(-x*y*z + 5.28*x + z) + 0.225*sin(x*y*z - 7.28*x + z) - 0.225*sin(x*y*z + 5.28*x + z) - 0.225*sin(x*y*z + 7.28*x - z) - 0.00125*cos(-x*y*z + 5.28*x + y) - 0.00125*cos(x*y*z - 7.28*x + y) + 0.00125*cos(x*y*z + 5.28*x + y) + 0.00125*cos(x*y*z + 7.28*x - y) - 0.00125*cos(x*y*z - 7.28*x - y + 2*z) - 0.00125*cos(x*y*z - 5.28*x + y - 2*z) + 0.00125*cos(x*y*z + 5.28*x - y + 2*z) + 0.00125*cos(x*y*z + 7.28*x + y - 2*z)))/((cos(x*y*z)^2 + 1)^10*(0.9*x + 0.01*sin(y - z) + 0.9))'
  # []

  # [electron_velocity_source_term]
  #   type = ParsedFunction
  #
  #   # V_ExB Div(V_||) + V_|| Div(V_||) + J_|| + grad(p) + E + R_friction + R_thermal
  #   expression = '((0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))*(cos(x*y*z)^2 + 1)^(3/2)*(0.5*cos(3*x^2 - 2*z) + 1) + (2*sin(z + (x - 0.5)^2) + 0.06*cos(3*x^2 + 2*y - 2*z))*(cos(x*y*z)^2 + 1)^2*(0.9*x + 0.01*sin(y - z) + 0.9) + (cos(x*y*z)^2 + 1)^(3/2)*(0.9*x + 0.01*sin(y - z) + 0.9)*(-5.13*x*sin(x*y*z)*sin(3*x^2 - 2*z) - (0.001*sin(y - z) + cos(x - z))*sin(6.28*x)*cos(x*y*z) + (2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z))*(-(0.3*x*sin(3*x^2 + 2*y - 2*z) + (2.0 - 4*x)*cos(z + (x - 0.5)^2))*sin(x*y*z) + (0.1*sin(3*x^2 + 2*y - 2*z) + 2*cos(z + (x - 0.5)^2))*cos(x*y*z) + 0.1*sin(3*x^2 + 2*y - 2*z)*cos(x*y*z)) + (-2.64*sin(5.28*x + z) + 3.64*sin(7.28*x - z) - 0.00314*cos(6.28*x - y + z) - 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*sin(6.28*x)*sin(y - z)*cos(x*y*z) + 1.71*sin(3*x^2 - 2*z)*cos(x*y*z)) + (cos(x*y*z)^2 + 1)*(0.9*x + 0.01*sin(y - z) + 0.9)*(((0.3*x*sin(3*x^2 + 2*y - 2*z) + (2.0 - 4*x)*cos(z + (x - 0.5)^2))*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x) + (0.1*sin(3*x^2 + 2*y - 2*z) + 2*cos(z + (x - 0.5)^2))*(2.64*sin(5.28*x + z) - 3.64*sin(7.28*x - z) + 0.00314*cos(6.28*x - y + z) + 0.00314*cos(6.28*x + y - z)))*cos(x*y*z) - (0.001*(0.3*x*sin(3*x^2 + 2*y - 2*z) + (2.0 - 4*x)*cos(z + (x - 0.5)^2))*sin(6.28*x)*sin(y - z) + 0.1*(2.64*sin(5.28*x + z) - 3.64*sin(7.28*x - z) + 0.00314*cos(6.28*x - y + z) + 0.00314*cos(6.28*x + y - z))*sin(3*x^2 + 2*y - 2*z))*cos(x*y*z) + (-0.001*sin(y + (x - 0.5)^2) + 0.001*sin(-y + 2*z + (x - 0.5)^2) + 0.05*sin(3*x^2 - x + 2*y - z) + 0.05*sin(3*x^2 + x + 2*y - 3*z))*sin(6.28*x)*sin(x*y*z)))/((cos(x*y*z)^2 + 1)^2*(0.9*x + 0.01*sin(y - z) + 0.9))'
  # []

  # [ion_velocity_source_term]
  #   type = ParsedFunction
  #
  #   # V_ExB Div(V_||) + V_|| Div(V_||) + grad(p)
  #   expression = '((0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))*(cos(x*y*z)^2 + 1)^(3/2)*(0.5*cos(3*x^2 - 2*z) + 1) + (cos(x*y*z)^2 + 1)^(3/2)*(0.9*x + 0.01*sin(y - z) + 0.9)*(-3.0*x*sin(x*y*z)*sin(3*x^2 - 2*z) + 4*((2*x - 1.0)*sin(x*y*z) + cos(x*y*z))*sin(z + (x - 0.5)^2)*cos(z + (x - 0.5)^2) + 1.0*sin(3*x^2 - 2*z)*cos(x*y*z)) + (cos(x*y*z)^2 + 1)*(0.9*x + 0.01*sin(y - z) + 0.9)*((0.004*x - 0.002)*sin(6.28*x)*sin(y - z)*cos(x*y*z) - ((4*x - 2.0)*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x) + 12.56*(sin(x - z) - 0.001*cos(y - z))*cos(6.28*x) + 2*sin(6.28*x)*cos(x - z))*cos(x*y*z) - 0.002*sin(6.28*x)*sin(x*y*z)*sin(y - z))*cos(z + (x - 0.5)^2))/((cos(x*y*z)^2 + 1)^2*(0.9*x + 0.01*sin(y - z) + 0.9))'
  # []

  # [electron_temp_source_term]
  #   type = ParsedFunction
  #
  #   expression = '(-(3.0*x*sin(x*y*z) - 1.0*cos(x*y*z))*(2*sin(z + (x - 0.5)^2) + 0.05*cos(3*x^2 + 2*y - 2*z))*(cos(x*y*z)^2 + 1)^(21/2)*(0.9*x + 0.01*sin(y - z) + 0.9)*sin(3*x^2 - 2*z) - (-0.0355*(0.9*sin(x*y*z) - 0.02*cos(x*y*z)*cos(y - z))*cos(3*x^2 + 2*y - 2*z) + (0.9*x + 0.01*sin(y - z) + 0.9)*(2.0*x*sin(-x*y*z + z + (x - 0.5)^2) - 2.0*x*sin(x*y*z + z + (x - 0.5)^2) + 0.2565*x*cos(3*x^2 - x*y*z + 2*y - 2*z) - 0.2565*x*cos(3*x^2 + x*y*z + 2*y - 2*z) - 1.0*sin(-x*y*z + z + (x - 0.5)^2) + 1.0*sin(x*y*z + z + (x - 0.5)^2) - 0.171*sin(3*x^2 - x*y*z + 2*y - 2*z) - 0.171*sin(3*x^2 + x*y*z + 2*y - 2*z) - 1.0*cos(-x*y*z + z + (x - 0.5)^2) - 1.0*cos(x*y*z + z + (x - 0.5)^2)))*(cos(x*y*z)^2 + 1)^(21/2)*(0.333333333333333*cos(3*x^2 - 2*z) + 0.666666666666667) + (x*(0.5*cos(3*x^2 - 2*z) + 1)*(-0.01125*y*cos(x*y*z - y + z) - 0.01125*y*cos(x*y*z + y - z) + 0.00125*y*cos(3*x*y*z - y + z) + 0.00125*y*cos(3*x*y*z + y - z) - 0.01125*z*cos(x*y*z - y + z) - 0.01125*z*cos(x*y*z + y - z) + 0.00125*z*cos(3*x*y*z - y + z) + 0.00125*z*cos(3*x*y*z + y - z) + 0.9*(y + z)*(cos(x*y*z)^2 + 1)*sin(x*y*z) - 1.8*(y + z)*sin(x*y*z)*cos(x*y*z)^2) + (0.9*x + 0.01*sin(y - z) + 0.9)*(-10.5*x^2*(1 - cos(x*y*z)^2)*(y + z)*sin(x*y*z)*sin(3*x^2 - 2*z) - x*(1 - cos(x*y*z)^2)*(y + z)*(2.64*sin(5.28*x + z) - 3.64*sin(7.28*x - z) + 0.00314*cos(6.28*x - y + z) + 0.00314*cos(6.28*x + y - z))*sin(x*y*z) - 0.001*y*(2*(x*sin(x*y*z) - z*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) + z*sin(x*y*z))*(cos(x*y*z)^2 + 1))*sin(6.28*x)*sin(y - z) - z*(2*(x*sin(x*y*z) + y*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) - y*sin(x*y*z))*(cos(x*y*z)^2 + 1))*(0.001*sin(y - z) + cos(x - z))*sin(6.28*x) + 3.5*z*(2*(x*sin(x*y*z) + y*cos(x*y*z))*sin(x*y*z)*cos(x*y*z) + (x*cos(x*y*z) - y*sin(x*y*z))*(cos(x*y*z)^2 + 1))*sin(3*x^2 - 2*z)))*(cos(x*y*z)^2 + 1)^9*(0.666666666666667*cos(3*x^2 - 2*z) + 1.33333333333333)/2 + (cos(x*y*z)^2 + 1)^10*(0.9*x + 0.01*sin(y - z) + 0.9)*(-0.006*x*sin(6.28*x)*sin(y - z)*cos(x*y*z) + 2*(x*(0.003*sin(y - z) + 3.0*cos(x - z))*sin(6.28*x) + 6.28*(-sin(x - z) + 0.001*cos(y - z))*cos(6.28*x) - 1.0*sin(6.28*x)*cos(x - z))*cos(x*y*z) - 0.002*sin(6.28*x)*sin(x*y*z)*sin(y - z))*sin(3*x^2 - 2*z)/2)/((cos(x*y*z)^2 + 1)^11*(0.9*x + 0.01*sin(y - z) + 0.9))'
  # []

  #[vorticity_source_term]
  #  type = ParsedFunction
  #
  #  expression = ''
  #[]
[]

[Postprocessors]
  # [density_l2Error]
  #   type = ElementL2Error
  #   variable = density
  #   function = density_solution
  # []
  # [electron_velocity_l2Error]
  #   type = ElementL2Error
  #   variable = electron_velocity
  #   function = electron_velocity_solution
  # []
  # [ion_velocity_l2Error]
  #   type = ElementL2Error
  #   variable = ion_velocity
  #   function = ion_velocity_solution
  # []
  # [electron_temp_l2Error]
  #   type = ElementL2Error
  #   variable = electron_temp
  #   function = electron_temp_solution
  # []

  [potential_l2Error]
    type = ElementL2Error
    variable = potential
    function = potential_solution
  []
  # [vorticity_l2Error]
  #   type = ElementL2Error
  #   variable = vorticity
  #   function = vorticity_solution
  # []

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
  type = Steady
  # type = Transient
  # scheme = newmark-beta
  # dt = 0.05
  # end_time = 10

  solve_type = 'NEWTON'
  line_search = 'NONE'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu superlu_dist NONZERO 1.e-10'

  nl_forced_its = 3
[]

[Outputs]
  exodus = true
  csv = true
[]
