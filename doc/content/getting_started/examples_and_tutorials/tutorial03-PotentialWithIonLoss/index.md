# Tutorial 3: Potential With Ion Loss

## Problem Statement

!style halign=left
This tutorial introduces providing the drift-diffusion equations and the Poisson's equation for electrostatic potential via the Zapdos [DriftDiffusionAction](AddDriftDiffusionAction.md). This tutorial is focus on the decay of a preestablished potential profile between grounded plates in the presents of an ion-only plasma. Calculating the evolution of the potential profile starts with the Gauss's law:

\begin{equation} \label{eq:Gauss-law}
\nabla \cdot \vec{E} = \frac{\rho}{\varepsilon_{0}}
\end{equation}

Where:

- $\vec{E}$ is the electric field,
- $\rho$ is the charge density, and
- $\varepsilon_{0}$ is the permittivity of free space.

This tutorial will assume the electrostatic approximation and that only positive ions contribute to the charge density, such that:

\begin{equation} \label{eq:electrostatic-approximation}
\vec{E} = - \nabla \Phi
\end{equation}

Where:

- $\Phi$ is the electrostatic potential.

\begin{equation} \label{eq:ion-only-charge-density}
  \rho = e n_{i}
\end{equation}

Where:

- $e$ is the elementary charge, and
- $n_{i}$ is the ion density.

Applying [eq:electrostatic-approximation] and [eq:ion-only-charge-density] to [eq:Gauss-law] results in the ion-only Poisson's equation in the form of:

\begin{equation} \label{eq:poisson-equation}
  \nabla ^{2} \Phi = - \frac{e n_{i}}{\varepsilon_{0}}
\end{equation}

For determining the ion density, this tutorial utilizes the drift-diffusion approximation with a zero source term:

\begin{equation} \label{eq:drift-diffusion-approximation}
\frac{d n_{i}}{d t} + \nabla \cdot \left( \mu_{i} \vec{E} n_{i} - D_{i} \nabla n_{i} \right) = 0
\end{equation}

Where:

- $\mu_{i}$ is the ion mobility coefficient, and
- $D_{i}$ is the diffusion coefficient.

## Analytical Solution

!style halign=left
For a plasma domain of $x\in\left[0, l \right]$ (where $l$ is the length of between plates), a grounded boundary condition for the potential is imposed:

\begin{equation} \label{eq:grounded-BC}
  \Phi \left( 0,l \right) = 0
\end{equation}

By assuming that the ion density is uniform in space (which will be imposed through the ion boundary condition) and applying the boundary condition of [eq:grounded-BC] to [eq:poisson-equation], the analytical solution for the electrostatic potential is:

\begin{equation} \label{eq:potential-solution}
\Phi = \frac{1}{2} \frac{e n_{i}}{\varepsilon_{0}} \left[ \left( \frac{l}{2} \right)^{2} - \left( x - \frac{l}{2} \right)^{2} \right]
\end{equation}

For ion density, a "do nothing" boundary condition is applied, such that the fluxes normal at the boundary is defined by the bulk flux:

\begin{equation} \label{eq:do-nothing-BC}
\vec{\Gamma} _{S} \cdot \vec{n} = \left( \mu_{i} \vec{E} n_{i} - D_{i} \nabla n_{i} \right) \cdot \vec{n}
\end{equation}

Where:

- $\vec{\Gamma} _{S}$ is the surface flux of the ions, and
- $\vec{n}$ is the outward facing normal on the boundary surface.

With the assumption of an uniform ion density, imposed by [eq:do-nothing-BC], the diffusion term of the ion flux is zero (i.e., $\nabla n_{i} = 0$). Applying this zero diffusion condition and the analytical potential profile to [eq:drift-diffusion-approximation] results in the analytical ion profile of:

\begin{equation}
n_{i} = 1/\left( \frac{\mu_{i}e}{\varepsilon_{0}}t + \frac{1}{n_{i_{0}}} \right)
\end{equation}

Where:

- $n_{i_{0}}$ is the initial ion density value.

## Running Simulation and Results

!style halign=left
To run this tutorial, input the following commands into the terminal, where `projects_dir_name` is the name of the directory you cloned Zapdos into (should be labeled `projects` if following the [Zapdos installation guide](getting_started/installation.md)):

```bash
conda activate moose
cd ~/projects_dir_name/zapdos/tutorial/tutorial03-PotentialWithIonLoss/
~/projects_dir_name/zapdos/zapdos-opt -i potential-with-ion-drain.i
```

This will result in an exodus output file labeled `potential-with-ion-drain_out.e`, which can be view with any exodus compatible visualization tool, such as [ParaView](https://www.paraview.org/).

[tutorial03-potential_and_ion_decay_plot] displays the comparison between Zapdos and the analytical solutions for the decay of the potential and ion profiles until $1\text{e-}10$ seconds. The following coefficient and initial values were used:

- $l = 10 \text{cm}$
- pressure, $p =1.33322 \ \text{pa}$
- $p \ \mu_{i} = 0.1444 \ \text{m}^{2} \ \text{Torr} \ \text{V}^{-1} \ \text{s}^{-1}$, based on [!cite](richards1987continuum)
- $p \ D_{i} = 0.004 \ \text{m}^{2} \ \text{Torr} \ \text{s}^{-1}$, based on [!cite](richards1987continuum)
- $n_{i_{0}} 1e16 \ \text{m}^{-3}$

!media potential_and_ion_decay.gif
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=tutorial03-potential_and_ion_decay_plot
       caption=Comparison Between Zapdos results and the analytical solutions for the decay of the potential and ion profiles between two grounded plates in the presents of an ion-only plasma. Result from the input file: [/potential-with-ion-drain.i].

## Input files

!style halign=left
Zapdos input files, and MOOSE input files as a whole, as divided into sections called blocks (this should not be confused with sections of a mesh domain, which are also referred to as blocks in MOOSE). The syntax for these blocks usually follows the pattern of:

```
[System Name]
  [User Custom Reference Name]
    type = Object Name
  []
[]
```

Below is the tutorial input file, [/potential-with-ion-drain.i], broken up by input blocks. These windows have interactive links, which by clicking on the `System Name` or `Object Name` will open the description page for the system or object, respectively.

### [Brace Expressions](https://mooseframework.inl.gov/application_usage/input_syntax.html)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# Global variables end=dom0Scale = 1.0 include-end=true

### [GlobalParams](https://mooseframework.inl.gov/syntax/GlobalParams/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the parameter inputs that are common end=# This block is generation a mesh and labeling the mesh boundaries

### [Mesh](https://mooseframework.inl.gov/syntax/Mesh/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block is generation a mesh and labeling the mesh boundaries end=# This block defines the problem type

### [Problem](https://mooseframework.inl.gov/syntax/Problem/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the problem type end=# This block is Zapdos's Drift-Diffusion Action

### [DriftDiffusionAction](AddDriftDiffusionAction.md)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block is Zapdos's Drift-Diffusion Action end=# This block defines additional volume integrated physics

### [Kernels](https://mooseframework.inl.gov/syntax/Kernels/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines additional volume integrated physics terms end=# This block defines the boundary conditions

### [BCs](https://mooseframework.inl.gov/syntax/BCs/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the boundary conditions end=# This block defines coefficients that

### [Materials](https://mooseframework.inl.gov/syntax/Materials/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines coefficients that end=# This block defines the initial conditions

### [ICs](https://mooseframework.inl.gov/syntax/ICs/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the initial conditions end=# This block defines the auxiliary variables

### [AuxVariables](https://mooseframework.inl.gov/syntax/AuxVariables/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the auxiliary variables end=# This block defines the operators

### [AuxKernels](https://mooseframework.inl.gov/syntax/AuxKernels/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the operators end=# This block defines preconditioning


### [Preconditioning](https://mooseframework.inl.gov/syntax/Preconditioning/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines preconditioning end=# This block defines type of solver

### [Executioner](https://mooseframework.inl.gov/syntax/Executioner/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines type of solver end=# This block defines the output type

### [Outputs](https://mooseframework.inl.gov/syntax/Outputs/)

!listing tutorial/tutorial03-PotentialWithIonLoss/potential-with-ion-drain.i start=# This block defines the output type
