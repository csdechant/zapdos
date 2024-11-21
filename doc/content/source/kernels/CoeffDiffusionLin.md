# CoeffDiffusionLin

!syntax description /Kernels/CoeffDiffusionLin

## Overview

`CoeffDiffusionLin` is the diffusion term used for variables not in log form.

The strong form for `CoeffDiffusionLin` is defined as

\begin{equation}
\nabla \cdot (D_{j} \nabla (n_{j})) / l_{c})
\end{equation}

Where $D_{j}$ is the diffusion coefficient, $n_{j}$ is the density, and
$l_{c}$ is the scaling factor of the mesh. In the case for the electrostatic approximation,
$n_{j}$ is replace with the potential and $D_{j}$ is replace with the permittivity of free space.

## Example Input File Syntax

An example of how to use `CoeffDiffusionLin` can be found in the
test file `Lymberopoulos_with_argon_metastables.i`.

!listing test/tests/Lymberopoulos_rf_discharge/Lymberopoulos_with_argon_metastables.i block=Kernels/potential_diffusion_dom0

!syntax parameters /Kernels/CoeffDiffusionLin

!syntax inputs /Kernels/CoeffDiffusionLin

!syntax children /Kernels/CoeffDiffusionLin
