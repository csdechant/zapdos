# PowerDep

!alert construction title=Undocumented Class
The PowerDep has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /AuxKernels/PowerDep

## Overview

`PowerDep` returns the amount of power deposited into a user specified specie by
Joule Heating. `PowerDep`
assumes the electrostatic approximation for the electric field.

The power deposited by Joule Heating is usually defined as

\begin{equation}
q_{j} (\mu_{j} \ \text{-} \nabla (V) n_{j} - D_{j} \nabla (n_{j})) \cdot \text{-} \nabla (V)
\end{equation}

Where $q_{j}$ is the charge of the species, $\mu_{j}$ is the mobility coefficient,
$V$ is the potential, $n_{j}$ is the density, and $D_{j}$ is the diffusion coefficient.
When converting the density to log form and applying a scaling factor of the mesh,
`PowerDep` is defined as

\begin{equation}
q_{j} (\mu_{j} \frac{\text{-} \nabla (V)}{l_{c}} \exp(N_{j}) - D_{j} \exp(N_{j}) \frac{\text{-} \nabla (N_{j})}{l_{c}}) \cdot \frac{\text{-} \nabla (V) V_{c}}{l_{c}}
\end{equation}

Where $N_{j}$ is the molar density of the specie in log form, $N_{A}$ is Avogadro's
number, $l_{c}$ is the scaling factor of the mesh, and $V_{c}$ is the scaling factor
of the potential.

## Example Input File Syntax

An example of how to use `PowerDep` can be found in the
test file `mean_en.i`.

!listing test/tests/1d_dc/mean_en.i block=AuxKernels/PowerDep_em

!syntax parameters /AuxKernels/PowerDep

!syntax inputs /AuxKernels/PowerDep

!syntax children /AuxKernels/PowerDep
