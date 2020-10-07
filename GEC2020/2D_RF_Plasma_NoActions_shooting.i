dom0Scale=1.0

[GlobalParams]
  potential_units = V
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'GEC_mesh_NoScale_Coarse_Structured.msh'
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [./Ar*]
  [../]
[]

[AuxVariables]
  [./em]
  [../]
  [./Ar+]
  [../]
  [./mean_en]
  [../]
  [./potential]
  [../]

  [./Ar*S]
  [../]
  [./Ar*T]
  [../]

  [./SM_Ar*]
  [../]
  [./SM_Ar*Reset]
    initial_condition = 1.0
  [../]
[]

[Kernels]
  [./Shoot_Method]
    type = ShootMethodLogNew
    variable = Ar*
    density_at_start_cycle = Ar*S
    density_at_end_cycle = Ar*T
    sensitivity_variable = SM_Ar*
    growth_limit = 100.0
  [../]
[]

[BCs]
  #New Boundary conditions for ions, should be the same as in paper
  #(except the metastables are not set to zero, since Zapdos uses log form)
    [./Ar*_physical_diffusion]
      type = DirichletBC
      variable = Ar*
      boundary = 'Top_Electrode Bottom_Electrode Top_Insulator Bottom_Insulator Walls'
      value = -50.0
    [../]
[]

[MultiApps]
  [./SensitivityMatrix]
    type = FullSolveMultiApp
    input_files = '2D_RF_Plasma_NoActions_SensitivityMatrix.i'
    execute_on = 'TIMESTEP_BEGIN'
  [../]
[]

[Transfers]
  [./em_to_sub]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = SensitivityMatrix
    source_variable = em
    variable = em
  [../]
  [./Ar+_to_sub]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = SensitivityMatrix
    source_variable = Ar+
    variable = Ar+
  [../]
  [./mean_en_to_sub]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = SensitivityMatrix
    source_variable = mean_en
    variable = mean_en
  [../]
  [./potential_to_sub]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = SensitivityMatrix
    source_variable = potential
    variable = potential
  [../]
  [./Ar*_to_sub]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = SensitivityMatrix
    source_variable = Ar*
    variable = Ar*
  [../]


  [./SM_Ar*Reset_to_sub]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = SensitivityMatrix
    source_variable = SM_Ar*Reset
    variable = SM_Ar*
  [../]


  [./Ar*T_from_sub]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = SensitivityMatrix
    source_variable = Ar*
    variable = Ar*T
  [../]
  [./Deriv_from_sub]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = SensitivityMatrix
    source_variable = SM_Ar*
    variable = SM_Ar*
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Steady

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  #line_search = none
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'

  l_tol = 1e-07
  nl_rel_tol = 1e-10
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
  [../]
[]
