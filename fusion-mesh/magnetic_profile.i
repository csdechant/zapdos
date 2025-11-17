[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'magnetic-mesh.msh'
  []
[]

[UserObjects]
  [reader_nearest]
    type = PropertyReadFile
    prop_file_name = 'magnetic_field_data-edit.csv'
    read_type = 'voronoi'
    nprop = 7 # number of columns in CSV
    nvoronoi = 211200 # number of rows that are considered
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
  [Bx]
  []
  [By]
  []
  [Bz]
  []
[]

[ICs]
  [nearest_x]
    type = FunctionIC
    variable = 'Bx'
    function = 'Bx_func'
  []
  [nearest_y]
    type = FunctionIC
    variable = 'By'
    function = 'By_func'
  []
  [nearest_z]
    type = FunctionIC
    variable = 'Bz'
    function = 'Bz_func'
  []
[]

[Kernels]
  [diffx]
    type = Diffusion
    variable = Bx
  []
  [diffy]
    type = Diffusion
    variable = By
  []
  [diffz]
    type = Diffusion
    variable = Bz
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
