# TotalFlux

!alert construction title=Undocumented Class
The TotalFlux has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /AuxKernels/TotalFlux

## Overview

`TotalFlux` returns the total flux of a species in log form. `TotalFlux`
assumes the electrostatic approximation for the electric field.

The electrostatic flux is usually defined as

\begin{equation}
\mu_{j} \ \text{-} \nabla (V) n_{j} - D_{j} \nabla (n_{j})
\end{equation}

Where $\mu_{j}$ is the mobility coefficient,
$V$ is the potential, $n_{j}$ is the density, and $D_{j}$ is the diffusion coefficient.
When converting the density to log form and applying a scaling factor of the mesh,
`TotalFlux` is defined as

\begin{equation}
\mu_{j} \frac{\text{-} \nabla (V)}{l_{c}} \exp(N_{j}) - D_{j} \exp(N_{j}) \frac{\text{-} \nabla (N_{j})}{l_{c}}
\end{equation}

Where $N_{j}$ is the molar density of the specie in log form and $l_{c}$ is the scaling factor of the mesh.

## Example Input File Syntax

An example of how to use `TotalFlux` can be found in the
test file `mean_en.i`.

!listing test/tests/1d_dc/mean_en.i block=AuxKernels/tot_flux_OHm

!syntax parameters /AuxKernels/TotalFlux

!syntax inputs /AuxKernels/TotalFlux

!syntax children /AuxKernels/TotalFlux
