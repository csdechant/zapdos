[Mesh]
  [file]
    type = FileMeshGenerator
    file = 'magnetic_profile_out.e'
    use_for_exodus_restart = true
  []
[]

[Variables]
  [Bx]
    initial_from_file_var = Bx
  []
  [By]
    initial_from_file_var = By
  []
  [Bz]
    initial_from_file_var = Bz
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
