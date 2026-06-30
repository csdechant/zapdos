!alert construction title=Unfinished Webpage
This is a new, but unfinished webpage for the Zapdos website. A PR with this page should $\textbf{NOT}$ be merged until this page is finished and the warning removed!

# Tutorial 4: Pressure Vs Electron Temperature

## Problem Statement

!style halign=left
This tutorial combines the [DriftDiffusionAction](AddDriftDiffusionAction.md) and [Reactions](../../../zapdos/crane/doc/content/syntax/Reactions/index.html) object blocks to simulate a argon CCP (Capacitively Coupled Plasma) discharge. In addition to modeling a CCP, this tutorial will track the center point electron temperature for different pressures and compare it to an global model.

The global model in question is a simple particle balance to equations the surface losses to the volume ionization in the form of:

\begin{equation} \label{eq:particle-balance}
n_{0} u_{B} A_{eff} = K_{iz} n_{g} n_{0} V
\end{equation}

Where:

- $n_{0}$ is the plasma density,
- $u_{B}$ is the Bohm velocity,
- $A_{eff}$ is the effective plasma surface area,
- $k_{iz}$ is the ionization rate coefficient,
- $n_g$ is the background gas density, and
- $V$ is the plasma volume.

Rearranging [eq:particle-balance] and substituting in an effective plasma length (i.e., $d_{eff} = \frac{V}{A_{eff}}$), gives the relationship:

\begin{equation} [eq:pressure-vs-electron-temperature]
n_{g} d_{eff} = \frac{u_{B}}{K_{iz}}
\end{equation}

The right hand side of [eq:pressure-vs-electron-temperature] is purely a function of the electron temperature. This means for a given $n_{g} d_{eff}$ term, there





XXXXXXXXXXXXXXXXXXXXXXXXXXXX


## Analytical Solution

!style halign=left
For a plasma domain...




XXXXXXXXXXX

If this tutorial, $k_{iz}$ and $u_{B}$ are defined as:

\begin{equation}
k_{iz} = 2.34e\text{-}14 * T_{e}^{0.59} * \exp \left( \frac{-17.44}{T_{e}} \right)
\end{equation}

\begin{equation}
u_{B} = \sqrt{\frac{e T_{e}}{M}}
\end{equation}

Where:

- $T_{e}$ is the electron temperature,
- $e$ is the elementary charge, and
- $M$ is the ion mass.

XXXXXXX




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



XXXXXXXXXXXXXXXXXXXX

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

Below is the tutorial input file, [/RF_Plasma.i], broken up by input blocks. These windows have interactive links, which by clicking on the `System Name` or `Object Name` will open the description page for the system or object, respectively.

### [Brace Expressions](https://mooseframework.inl.gov/application_usage/input_syntax.html)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# Global variables end=dom0Scale = 1.0 include-end=true

### [GlobalParams](https://mooseframework.inl.gov/syntax/GlobalParams/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the parameter inputs that are common end=# This block is generation a mesh and labeling the mesh boundaries

### [Mesh](https://mooseframework.inl.gov/syntax/Mesh/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block is generation a mesh and labeling the mesh boundaries end=# This block defines the problem type

### [Problem](https://mooseframework.inl.gov/syntax/Problem/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the problem type end=# This block is Zapdos's Drift-Diffusion Action

### [DriftDiffusionAction](AddDriftDiffusionAction.md)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block is Zapdos's Drift-Diffusion Action end=# This block is CRANE's Reactions Action

### [Reactions](../../../zapdos/crane/doc/content/syntax/Reactions/index.html)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block is CRANE's Reactions Action end=# This block defines the auxiliary variables

### [AuxVariables](https://mooseframework.inl.gov/syntax/AuxVariables/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the auxiliary variables end=# This block defines the operators

### [AuxKernels](https://mooseframework.inl.gov/syntax/AuxKernels/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the operators end=# This block defines the boundary conditions

### [BCs](https://mooseframework.inl.gov/syntax/BCs/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the boundary conditions end=# This block defines coefficients that

### [Materials](https://mooseframework.inl.gov/syntax/Materials/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines coefficients that end=# This block defines the initial conditions

### [ICs](https://mooseframework.inl.gov/syntax/ICs/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the initial conditions end=# Define function used throughout the input file

### [Functions](https://mooseframework.inl.gov/syntax/Functions/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# Define function used throughout the input file end=# This block defines several postprocessing calculations

### [Postprocessors](https://mooseframework.inl.gov/syntax/Postprocessors/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines several postprocessing calculations end=# This block defines preconditioning

### [Preconditioning](https://mooseframework.inl.gov/syntax/Preconditioning/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines preconditioning end=# This block defines type of solver

### [Executioner](https://mooseframework.inl.gov/syntax/Executioner/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines type of solver end=# This block defines the output type

### [Outputs](https://mooseframework.inl.gov/syntax/Outputs/)

!listing tutorial/tutorial03-PotentialWithIonLoss/RF_Plasma.i start=# This block defines the output type
