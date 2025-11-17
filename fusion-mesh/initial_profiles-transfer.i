[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'tokamak_mesh-edit-hard.msh'
  []
[]

[MultiApps]
  [sub]
    type = FullSolveMultiApp
    input_files = magnetic_profile.i
    execute_on = 'INITIAL'
  []
[]

[Transfers]
  [fromsub_x]
    type = MultiAppGeometricInterpolationTransfer
    from_multi_app = sub
    source_variable = ux
    variable = ux
  []
  [fromsub_y]
    type = MultiAppGeometricInterpolationTransfer
    from_multi_app = sub
    source_variable = uy
    variable = uy
  []
  [fromsub_z]
    type = MultiAppGeometricInterpolationTransfer
    from_multi_app = sub
    source_variable = uz
    variable = uz
  []
[]

[Variables]
  [density]
  []
  [electron_velocity]
  []
  [ion_velocity]
  []
  [electron_temp]
  []
  [vorticity]
  []
  [potential]
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
[]

[Kernels]
  [diff_01]
    type = Diffusion
    variable = density
  []
  [diff_02]
    type = Diffusion
    variable = electron_velocity
  []
  [diff_03]
    type = Diffusion
    variable = ion_velocity
  []
  [diff_04]
    type = Diffusion
    variable = electron_temp
  []
  [diff_05]
    type = Diffusion
    variable = vorticity
  []
  [diff_06]
    type = Diffusion
    variable = potential
  []
[]

[Problem]
  solve = false
[]

[Executioner]
  type = Transient
  end_time = 0.1
[]

[Outputs]
  exodus = true
[]
