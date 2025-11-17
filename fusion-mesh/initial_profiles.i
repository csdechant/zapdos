[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'tokamak_mesh-edit-hard.msh'
  []
[]

[UserObjects]
  [reader_nearest]
    type = PropertyReadFile
    prop_file_name = 'magnetic_field_data-edit.csv'
    read_type = 'voronoi'
    nprop = 7 # number of columns in CSV
    nvoronoi = 40000 # number of rows that are considered
    # load_first_file_on_construction = false
  []
[]

[Functions]
  [Bx_func]
    type = PiecewiseConstantFromCSV
    read_prop_user_object = 'reader_nearest'
    read_type = 'voronoi'
    # 0-based indexing
    column_number = '4'
  []
  [By_func]
    type = PiecewiseConstantFromCSV
    read_prop_user_object = 'reader_nearest'
    read_type = 'voronoi'
    # 0-based indexing
    column_number = '5'
  []
  [Bz_func]
    type = PiecewiseConstantFromCSV
    read_prop_user_object = 'reader_nearest'
    read_type = 'voronoi'
    # 0-based indexing
    column_number = '6'
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
  [Bfield]
    family = LAGRANGE_VEC
  []
[]

[ICs]
  [nearest]
    type = VectorFunctionIC
    variable = 'Bfield'
    function_x = Bx_func
    function_y = By_func
    function_z = Bz_func
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
