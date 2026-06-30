# This tutorial is of a 1-D transient decay of the potential and ion profile between grounded plates in the presents of an ion-only plasma.
# This problem is about on Section 2.2 of "Principles of Plasma Discharges and Materials Processing" by Lieberman and Lichtenberg

# Global variables can be defined at the top of input files using 'Brace Expressions'
# The two most common functions of 'Brace Expressions' is:
#      - 'units' for unit conversions, and
#      - 'fparse' for function expressions
# Below at the constant variable used through this tutorial.

# The plasma length
plasma_length = '${units 10 cm -> m}'

# The pressure
pressure = '${units 1.33322 pa}'

# The initial value of the ion density
initial_ion_density = '${units 1e10 1/cm^3 -> 1/m^3}'

# The initial ion molar density (Zapdos solves in molar density)
initial_ion_molar_density = '${units ${fparse initial_ion_density/6.022e23} moles/m^3}'

# A scaling factor, for a scaled mesh is used
# For example, if set to 1.0, there is no scaling and if set to 0.010, the mesh was scaled up by a cm
dom0Scale = 1.0

# This block defines the parameter inputs that are common between multiple objects.
# This is used to avoid defining these parameters multiple time throughout the input file.
# In Zapdos, this is usually the scaling parameters
[GlobalParams]
  potential_units = V # Scales the potential by V or kV
  use_moles = true # Converts density from #/m^3 to moles/m^3
  position_units = ${dom0Scale} # Scales gradient operators when utilizing a scaled mesh
[]

# This block is generation a mesh and labeling the mesh boundaries
[Mesh]
  #Sets up a 1-D mesh
  [geo]
    type = GeneratedMeshGenerator
    xmin = 0 # Start the mesh a point 0
    xmax = ${plasma_length} # Defining the other end of the mesh
    nx = 100 # Defining number of elements
    dim = 1 # Restricting the mesh to 1D
  []
  #Renames all sides with the specified normal
  #For 1D, this is used to rename the end points of the mesh
  [left]
    type = SideSetsFromNormalsGenerator
    input = geo # Name of previous meshing block to apply changes.
    normals = '-1 0 0' # Calling the outward facing normal that defines a boundary (for a 1D mesh, this is the left most point)
    new_boundary = 'left' # Defining the boundary label
  []
  [right]
    type = SideSetsFromNormalsGenerator
    input = left # Name of previous meshing block to apply changes.
    normals = '1 0 0' # Calling the outward facing normal that defines a boundary (for a 1D mesh, this is the right most point)
    new_boundary = 'right' # Defining the boundary label
  []
[]

# This block defines the problem type (such as FE, eigenvalue problem, etc.)
[Problem]
  type = FEProblem
[]

# This block is Zapdos's Drift-Diffusion Action that inputs the drift-diffusion for species and Poisson's equation for potential
[DriftDiffusionAction]
  [Plasma]
    ions = Ar_ion # User define name for ions
    field = potential # User define name for potential
    is_field_unique = true # True if the potential is only applied to these plasma species
  []
[]

# This block defines additional volume integrated physics terms not declared by the Actions System
[Kernels]
  # Including a stabilization to the ions
  [art_diff]
    type = EFieldArtDiff
    variable = Ar_ion
  []
[]

# This block defines the boundary conditions of each declared variable
# If a boundary condition is not defined, the default condition is a zero flux boundary condition
[BCs]
  # Voltage Boundary Condition
  [potential_left]
    type = DirichletBC
    variable = potential
    boundary = 'left right'
    value = 0
  []

  # Boundary conditions for ions
  [Arp_physical_left_advection]
    type = DriftDiffusionDoNothingBC
    variable = Ar_ion
    boundary = 'right left'
  []
[]

# This block defines coefficients that exist within the simulation domain (most commonly used for material properties)
[Materials]
  # The dielectric coefficient of the gas (defaulted to the permittivity of free space)
  [gas_permittivity]
    type = ElectrostaticPermittivity
    potential = potential
  []
  #The material properties of the ion
  [gas_species_0]
    type = ADHeavySpecies
    heavy_species_name = Ar_ion
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    heavy_species_p = ${pressure}
  []
[]

# This block defines the initial conditions of the nonlinear variables
# If not included in the input file, the default initial condition is zero
[ICs]
  [Ar_ion_ic]
    type = FunctionIC
    variable = Ar_ion
    function = 'log(${initial_ion_molar_density})'
  []

  [potential_ic]
    type = FunctionIC
    variable = potential
    function = '0.5 * (${initial_ion_density} * 1.6e-19) / 8.85e-12 * ((${plasma_length}/2)^2. - (x-${plasma_length}/2)^2.)'
  []
[]

# This block defines the auxiliary variables (e.g., variable that are not required to solve the main set of PDEs)
# Similar to 'Variables', the default family and order of the shape function is Lagrange and First Order
[AuxVariables]
  # Declaring a variable to represent the known solution for the ions
  [ion_solution]
    family = MONOMIAL
  []

  # Declaring a variable to represent the known solution for the potential
  [potential_solution]
    family = MONOMIAL
  []
[]

# This block defines the operators that defines the auxiliary variables
[AuxKernels]
  # Object that calculates the known solution for the ions from the analytical function
  [ion_solution]
    type = ParsedAux
    variable = ion_solution
    ad_material_properties = 'muAr_ion'
    expression = '1/( (muAr_ion * 1.6e-19/8.85e-12)*t + (1/${initial_ion_density}) )'
    use_xyzt = true
  []

  # Object that calculates the known solution for the potential from the analytical function
  [potential_solution]
    type = ParsedAux
    variable = potential_solution
    coupled_variables = 'ion_solution'
    expression = '0.5 * (ion_solution * 1.6e-19) / 8.85e-12 * ((${plasma_length}/2)^2. - (x-${plasma_length}/2)^2.)'
    use_xyzt = true
  []
[]

# This block defines preconditioning methods and options
[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

# This block defines type of solver (such as steady or transient), solve type (Newton, PJFNK, etc.), and tolerances
[Executioner]
  type = Transient
  end_time = 1e-10
  dt = 1e-12
  dtmin = 1e-14
  solve_type = NEWTON

  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

# This block defines the output type of the file (multiple output files can be define per run)
[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]
