[Mesh]
  allow_renumbering = false
  [cmg]
    type = CartesianMeshGenerator
    dim = 2
    dx = '1.5 2.4 0.1'
    dy = '1.3 0.9'
    ix = '2 1 1'
    iy = '1 3'
    subdomain_id = '0 1 1
                    2 2 2'
  []
[]

[Variables]
  [u]
  []
[]

[UserObjects]
  [reader_nearest]
    type = PropertyReadFile
    prop_file_name = 'magnetic_field_data_test.csv'
    # prop_file_name = 'data_nearest.csv'
    read_type = 'voronoi'
    nprop = 4 # number of columns in CSV
    nvoronoi = 4 # number of rows that are considered
    # load_first_file_on_construction = false
  []
[]

[Functions]
  [nearest]
    type = PiecewiseConstantFromCSV
    read_prop_user_object = 'reader_nearest'
    read_type = 'voronoi'
    # 0-based indexing
    column_number = '4'
  []
[]

[ICs]
  [nearest]
    type = FunctionIC
    variable = 'u'
    function = 'nearest'
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = u
  []
[]

[BCs]
  [unity]
    type = DirichletBC
    variable = u
    boundary = 'left bottom'
    value = 1
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
