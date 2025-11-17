[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'TCV-magnetic-mesh.msh'
  []
[]

[UserObjects]
  [reader_nearest]
    type = PropertyReadFile
    prop_file_name = 'magnetic_field_data_test.csv'
    read_type = 'voronoi'
    nprop = 7 # number of columns in CSV
    nvoronoi = 3200 # number of rows that are considered
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
  [u]
    family = LAGRANGE_VEC
  []
[]

[ICs]
  [nearest]
    type = VectorFunctionIC
    variable = 'u'
    function_x = Bx_func
    function_y = By_func
    function_z = Bz_func
  []
[]

[Kernels]
  [diff]
    type = VectorDiffusion
    variable = u
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
