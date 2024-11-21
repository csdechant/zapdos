# ChargeSourceMoles_KV

!syntax description /Kernels/ChargeSourceMoles_KV

## Overview

`ChargeSourceMoles_KV` add the charge contribution to the Poisson equation of the
electrostatic approximation of the potential.

The strong form for `ChargeSourceMoles_KV` is defined as right side of

\begin{equation}
-\nabla^{2} V = \frac{\Sigma q_{j} \exp(N_{j}) N_{A}}{\varepsilon_{0}}
\end{equation}

where $V$ is the electrostatic potential, $q_{j}$ is the charge of the species, $N_{j}$ is
the molar density of the specie in log form, $N_{A}$ is Avogadro's number, and $\varepsilon_{0}$ is the permittivity of free space.

## Example Input File Syntax

An example of how to use `ChargeSourceMoles_KV` can be found in the
test file `Lymberopoulos_with_argon_metastables.i`.

!listing test/tests/Lymberopoulos_rf_discharge/Lymberopoulos_with_argon_metastables.i block=Kernels/Ar+_charge_source

!listing test/tests/Lymberopoulos_rf_discharge/Lymberopoulos_with_argon_metastables.i block=Kernels/em_charge_source


!syntax parameters /Kernels/ChargeSourceMoles_KV

!syntax inputs /Kernels/ChargeSourceMoles_KV

!syntax children /Kernels/ChargeSourceMoles_KV
