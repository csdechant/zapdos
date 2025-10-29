# Tutorial 2: Reaction Network

## Problem Statement

!style halign=left
This tutorial introduces providing chemistry reaction networks into Zapdos input file via the MOOSE-based chemistry solver [CRANE](https://crane-plasma-chemistry.readthedocs.io/en/latest/). CRANE is automatically coupled to Zapdos, if following the [Zapdos installation guide](getting_started/installation.md). This results in Zapdos having access to all of CRANE's capabilities, and only one input file is required to run Zapdos with CRANE objects. This tutorial will assume the user as no prior knowledge using CRANE.

!alert! note title=CRANE As a Standalone Solver
When using CRANE as a standalone solver and following it [tutorials](https://crane-plasma-chemistry.readthedocs.io/en/latest/tutorials.html), CRANE relates on MOOSE's [ScalarKernels System](https://mooseframework.inl.gov/syntax/ScalarKernels/) to solve a set of of ordinary differential equations (ODEs).

When using CRANE with Zapdos, as in this tutorial, CRANE relates on MOOSE's [Kernels System](https://mooseframework.inl.gov/syntax/Kernels/) to supply the partial differential equation (PDE) terms in the finite element (FE) weak form. This means when using CRANE with Zapdos, the simulation is $\textbf{NOT}$ coupling a PDE and ODE solver, but is solving a set of equations within one solver.
!alert-end!

Consider a system of 3 species (species $A$, $B$, and $C$) in which one species decays into the next species at a constant rate. In chemical reaction syntax, this reaction network looks like:

\begin{equation}
  A \xrightarrow{k_{A}} B \\[10pt]
  B \xrightarrow{k_{B}} C \\[10pt]
\end{equation}

Where:

- $k_{A}$ is the decay rate of species $A$, and
- $k_{B}$ is the decay rate of species $B$.

Converting this reaction network into a set of rate equations results in the following syntax:

\begin{equation} \label{eq:reaction-A}
  \frac{d n_{A}}{d t} = - k_{A} n_{A}
\end{equation}
\begin{equation} \label{eq:reaction-B}
  \frac{d n_{B}}{d t} = k_{A} n_{A} - k_{B} n_{B}
\end{equation}
\begin{equation} \label{eq:reaction-C}
  \frac{d n_{C}}{d t} = k_{B} n_{B}
\end{equation}

Where:

- $n_{A}$ is the number density of species $A$,
- $n_{B}$ is the number density of species $B$, and
- $n_{c}$ is the number density of species $C$.

## Analytical Solution

!style halign=left
A set of initial conditions for species $A$, $B$, and $C$ are defined, such that species $A$ has an initial value of $n_{A_{0}}$ and species $B$ and $C$ has an initial value of zero. By applying these sets of initial conditions to [eq:reaction-A], [eq:reaction-B], and [eq:reaction-C], the analytical solution takes the form of:

\begin{equation} \label{eq:reaction-A-analytical-solution}
  n_{A} = n_{A_{0}} e^{-k_{A} t}
\end{equation}

\begin{equation} \label{eq:reaction-B-analytical-solution}
  n_{B} = n_{A_{0}} \frac{k_{A}}{k_{B} - k_{A}} \left( e^{-k_{A} t} - e^{-k_{B} t} \right)
\end{equation}


\begin{equation} \label{eq:reaction-C-analytical-solution}
  n_{C} = n_{A_{0}} \left[ 1 + \frac{1}{k_{A} - k_{B}} \left( k_{B} e^{-k_{A} t} - k_{A} e^{-k_{B} t} \right) \right]
\end{equation}


## Running Simulation and Results

!style halign=left
To run this tutorial, input the following commands into the terminal, where `projects_dir_name` is the name of the directory you cloned Zapdos into (should be labeled `projects` if following the [Zapdos installation guide](getting_started/installation.md)):

```bash
conda activate moose
cd ~/projects_dir_name/zapdos/tutorial/tutorial02-ReactionNetwork/
~/projects_dir_name/zapdos/zapdos-opt -i transient-kinetics.i
```

This will result in an exodus output file labeled `transient-kinetics_out.e`, which can be view with any exodus compatible visualization tool, such as [ParaView](https://www.paraview.org/).

[tutorial02-ReactionNetwork_plot] displays the comparison between Zapdos and the analytical solutions of [eq:reaction-A-analytical-solution], [eq:reaction-B-analytical-solution], and [eq:reaction-C-analytical-solution]. The following coefficient and initial values were used:

- $k_{A} = 1 \ \text{s}^{-1}$
- $k_{B} = 5 \ \text{s}^{-1}$
- $n_{A_{0}} = 1 \ \text{m}^{-3}$

!media reaction_evolution.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=tutorial02-ReactionNetwork_plot
       caption=Comparison between Zapdos results and the analytical solutions for three species decay problem as described in [eq:reaction-A], [eq:reaction-B], and [eq:reaction-C]. Result from the input file: [/transient-kinetics.i].

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

Below is the tutorial input file, [/transient-kinetics.i], broken up by input blocks. These windows have interactive links, which by clicking on the `System Name` or `Object Name` will open the description page for the system or object, respectively.

### [Brace Expressions](https://mooseframework.inl.gov/application_usage/input_syntax.html)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# Global variables end=initial_density_species_A = '${units 1 1/m^3}' include-end=true

### [Mesh](https://mooseframework.inl.gov/syntax/Mesh/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block is generation a mesh and labeling the mesh boundaries end=# This block defines the problem type

### [Problem](https://mooseframework.inl.gov/syntax/Problem/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the problem type end=# This block defines the nonlinear variables

### [Variables](https://mooseframework.inl.gov/syntax/Variables/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the nonlinear variables end=# This block defines the initial conditions

### [ICs](https://mooseframework.inl.gov/syntax/ICs/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the initial conditions end=# This block defines the volume integrated physics

### [Kernels](https://mooseframework.inl.gov/syntax/Kernels/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the volume integrated physics end=# This block is CRANE's Reactions Action

### [Reactions](../../../zapdos/crane/doc/content/syntax/Reactions/index.html)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block is CRANE's Reactions Action end=# This block defines the auxiliary variables

### [AuxVariables](https://mooseframework.inl.gov/syntax/AuxVariables/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the auxiliary variables end=# This block defines the operators

### [AuxKernels](https://mooseframework.inl.gov/syntax/AuxKernels/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the operators end=# This block defines preconditioning

### [Preconditioning](https://mooseframework.inl.gov/syntax/Preconditioning/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines preconditioning end=# This block defines type of solver

### [Executioner](https://mooseframework.inl.gov/syntax/Executioner/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines type of solver end=# This block defines the output type

### [Outputs](https://mooseframework.inl.gov/syntax/Outputs/)

!listing tutorial/tutorial02-ReactionNetwork/transient-kinetics.i start=# This block defines the output type
