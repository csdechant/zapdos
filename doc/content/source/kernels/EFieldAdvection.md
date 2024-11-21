# EFieldAdvection

!syntax description /Kernels/EFieldAdvection

## Overview

`EFieldAdvection` is the electric field driven advection term used for variables in log form.
`EFieldAdvection` assumes the electrostatic approximation for the electric field.

The strong form for an electrostatic advection term is usually defined as

\begin{equation}
\nabla \cdot (\mu_{j} n_{j} \ \text{-} \nabla (V))
\end{equation}

Where $\mu_{j}$ is the mobility coefficient, $n_{j}$ is the density, and $V$ is
the potential. When converting the density to log form and applying a scaling
factor of the mesh, the strong form for `EFieldAdvection` is defined as

\begin{equation}
\nabla \cdot (\mu_{j} \exp(N_{j}) \ \text{-} \nabla (V)) / l_{c}
\end{equation}

Where $N_{j}$ is the molar density of the specie in log form and
$l_{c}$ is the scaling factor of the mesh.

## Example Input File Syntax

An example of how to use `EFieldAdvection` can be found in the
test file `Lymberopoulos_with_argon_metastables.i`.

!listing test/tests/Lymberopoulos_rf_discharge/Lymberopoulos_with_argon_metastables.i block=Kernels/em_advection

!syntax parameters /Kernels/EFieldAdvection

!syntax inputs /Kernels/EFieldAdvection

!syntax children /Kernels/EFieldAdvection
