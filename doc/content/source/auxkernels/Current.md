# Current

!alert construction title=Undocumented Class
The Current has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /AuxKernels/Current

## Overview

`Current` returns the electric current of a species in log form. `Current`
assumes the electrostatic approximation for the electric field.

The electrostatic current is usually defined as

\begin{equation}
q_{j} (\mu_{j} \ \text{-} \nabla (V) n_{j} - D_{j} \nabla (n_{j}))
\end{equation}

Where $q_{j}$ is the charge of the species, $\mu_{j}$ is the mobility coefficient,
$V$ is the potential, $n_{j}$ is the density, and $D_{j}$ is the diffusion coefficient.
When converting the density to log form and applying a scaling factor of the mesh,
`Current` is defined as

\begin{equation}
q_{j} (\mu_{j} \frac{\text{-} \nabla (V)}{l_{c}} \exp(N_{j}) - D_{j} \exp(N_{j}) \frac{\text{-} \nabla (N_{j})}{l_{c}})
\end{equation}

Where $N_{j}$ is the molar density of the specie in log form, $N_{A}$ is Avogadro's
number, $l_{c}$ is the scaling factor of the mesh.

## Example Input File Syntax

An example of how to use `Current` can be found in the
test file `Lymberopoulos_with_argon_metastables.i`.

!listing test/tests/Lymberopoulos_rf_discharge/Lymberopoulos_with_argon_metastables.i block=AuxKernels/Current_em


!syntax parameters /AuxKernels/Current

!syntax inputs /AuxKernels/Current

!syntax children /AuxKernels/Current
