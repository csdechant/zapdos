# Tutorial 1: Ambipolar Diffusion

## Problem Statement

!style halign=left
For the first tutorial problem, a simple 1-D ambipolar diffusion problem will be considered. The equation for an ambipolar diffusion takes the form of:

\begin{equation} \label{eq:ambipolar-diffusion}
  -\nabla \cdot \left(D_{a} \nabla n \right) = S_{n}
\end{equation}

Where:

- $n$ is the quasi-neutral plasma density
- $D_{a}$ is the ambipolar diffusion coefficient, and
- $S_{n}$ is the density source term.

For the source term, this tutorial assumes that the production of plasma species purely depends on the background gas density $\left( n_g \right)$ and an effective reaction coefficient $\left( k_{eff} \right)$ in the form of a first-order reaction:

\begin{equation} \label{eq:source-term}
  S_{n} = k_{eff} n_{g}
\end{equation}

!alert! note title=Definition of the Ambipolar Diffusion Coefficient
The ambipolar diffusion is defined as:
\begin{equation}
  D_{a} = \frac{\mu_{i} D_{e} + \mu_{e} D_{i}}{\mu_{i} + \mu_{e}}
\end{equation}

Where:

- $\mu_{i}$ is the ion mobility coefficient,
- $\mu_{e}$ is the electron mobility coefficient,
- $D_{i}$ is the ion diffusion coefficient, and
- $D_{e}$ is the electron diffusion coefficient.

In this tutorial, the ambipolar diffusion coefficient is assumed to be a constant value.
!alert-end!

## Analytical Solution

!style halign=left
For a plasma domain of $x\in\left[-\frac{l}{2}, \frac{l}{2}\right]$ (where $l$ is the length of the discharge), a zero-density boundary condition is imposed:

\begin{equation} \label{eq:zero-density-BC}
  n \left( \pm \frac{l}{2} \right) = 0
\end{equation}

Applying the boundary condition of [eq:zero-density-BC] to the ambipolar diffusion problem, [eq:ambipolar-diffusion] and [eq:source-term], the analytical solution takes the form of:

\begin{equation} \label{eq:ambipolar-diffusion-analytical-solution}
  n \left( x \right) = \frac{k_{i} n_{g} l^2}{8 D_{a}} \left[ 1  - \left( \frac{2x}{l} \right)^2 \right]
\end{equation}

## Running Simulation and Results

!style halign=left
To run this tutorial, input the following commands into the terminal, where `projects_dir_name` is the name of the directory you cloned Zapdos into (should be labeled `projects` if following the [Zapdos installation guide](getting_started/installation.md)):

```bash
conda activate moose
cd ~/projects_dir_name/zapdos/tutorial/tutorial01-Diffusion/
~/projects_dir_name/zapdos/zapdos-opt -i ambipolar-diffusion.i
```

This will result in an exodus output file labeled `ambipolar-diffusion_out.e`, which can be view with any exodus compatible visualization tool, such as [ParaView](https://www.paraview.org/).

[tutorial01-diffusion_plot] displays the comparison between Zapdos and the analytical solution, [eq:ambipolar-diffusion-analytical-solution]. The following coefficient values were used:

- $D_{a} = 0.579 \ \text{m}^2/\text{s}$

  - Defined using the electron and ion transport properties of $\mu_{i} = 1.44\text{e-}1  \ \text{m}^2 \text{V}^{-1} \text{s}^{-1}$, $\mu_{e} = 30.0 \ \text{m}^2 \text{V}^{-1} \text{s}^{-1}$, $D_{i} = 6.42\text{e-}3  \ \text{m}^2/\text{s}$, and $D_{e} = 119.87  \ \text{m}^2/\text{s}$. These values are based on an argon plasma at 1 Torr (~133.322 Pa).

- $k_{eff} = 5.584\text{e-}3 \ \text{s}^{-1}$
- $n_{g} = 1\text{e}16 \ \text{m}^{-3}$
- $l = 2.54 \ \text{cm}$

!media ambipolar_diffusion.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=tutorial01-diffusion_plot
       caption=Comparison between Zapdos results and the analytical solution for an ambipolar diffusion problem with a constant source term and zero-density boundary condition. Result from the input file: [/ambipolar-diffusion.i].

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

Below is the tutorial input file, [/ambipolar-diffusion.i], broken up by input blocks. These windows have interactive links, which by clicking on the `System Name` or `Object Name` will open the description page for the system or object, respectively.

### [Brace Expressions](https://mooseframework.inl.gov/application_usage/input_syntax.html)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# Global variables end=dom0Scale = 1.0 include-end=true

### [GlobalParams](https://mooseframework.inl.gov/syntax/GlobalParams/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the parameter inputs that are common end=# This block is generation a mesh and labeling the mesh boundaries

### [Mesh](https://mooseframework.inl.gov/syntax/Mesh/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block is generation a mesh and labeling the mesh boundaries end=# This block defines the problem type

### [Problem](https://mooseframework.inl.gov/syntax/Problem/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the problem type end=# This block defines the nonlinear variables

### [Variables](https://mooseframework.inl.gov/syntax/Variables/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the nonlinear variables end=# This block defines coefficients that

### [Materials](https://mooseframework.inl.gov/syntax/Materials/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines coefficients that end=# This block defines the initial conditions

### [ICs](https://mooseframework.inl.gov/syntax/ICs/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the initial conditions end=# This block defines the volume integrated physics

### [Kernels](https://mooseframework.inl.gov/syntax/Kernels/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the volume integrated physics end=# This block defines the boundary conditions

### [BCs](https://mooseframework.inl.gov/syntax/BCs/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the boundary conditions end=# This block defines the auxiliary variables

### [AuxVariables](https://mooseframework.inl.gov/syntax/AuxVariables/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the auxiliary variables end=# This block defines the operators

### [AuxKernels](https://mooseframework.inl.gov/syntax/AuxKernels/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the operators end=# This block defines preconditioning

### [Preconditioning](https://mooseframework.inl.gov/syntax/Preconditioning/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines preconditioning end=# This block defines type of solver

### [Executioner](https://mooseframework.inl.gov/syntax/Executioner/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines type of solver end=# This block defines the output type

### [Outputs](https://mooseframework.inl.gov/syntax/Outputs/)

!listing tutorial/tutorial01-Diffusion/ambipolar-diffusion.i start=# This block defines the output type

## Independent Exercise

!style halign=left
Try changing the transport coefficient or reactions rates to see how the density profiles changes! Based on [eq:ambipolar-diffusion-analytical-solution], one would expect increasing the transport coefficient would decrease the center density, while increasing the reaction rate would increase the center density. Be careful of numerical instabilities when changing these coefficients to unrealistic values.
