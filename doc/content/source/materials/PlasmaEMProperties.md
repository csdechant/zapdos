# PlasmaEMProperties

!alert construction title=Undocumented Class
The PlasmaEMProperties has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /Materials/PlasmaEMProperties

## Overview

`PlasmaEMProperties` provides the real and complex components of several plasma electromagnetic properties. This includes the plasma conductivity coefficient and dielectric coefficient. Along with the dielectric coefficient, the spatial gradient, the first time derivative, and second time derivative of the plasma dielectric coefficient is also calculated.

The plasma dielectic coefficient is defined as:

\begin{equation}
\varepsilon_{p} = \varepsilon_{0} \left[ 1 - \frac{\omega_{pe}^{2}}{\omega \left( \omega - j \nu_{m} \right)} \right] \\[10pt]
\omega_{pe} = \sqrt{\frac{e^{2} n_{e}}{\varepsilon_{0} m_{e}}}
\end{equation}

where

- $\varepsilon_{p}$ is the plasma dielectric coefficient,
- $\varepsilon_{0}$ is the permittivity of free space,
- $\omega_{pe}$ is the plasma frequency,
- $\omega$ is the drive frequency of the wave propagation,
- $\nu_{m}$ is the electron-neutral collision frequency,
- $e$ is the elementary charge,
- $n_{e}$ is the electron density, and 
- $m_{e}$ is the electron mass.

The plasma conductivity coefficient is defined as:

\begin{equation}
\sigma_{p} = \frac{\varepsilon_{0} \omega_{pe}^{2}}{j \omega + \nu_{m}}
\end{equation}

where

- $\sigma_{p}$ is the plasma conductivity coefficient.

## Example Input File Syntax

!! Describe and include an example of how to use the PlasmaEMProperties object.

!syntax parameters /Materials/PlasmaEMProperties

!syntax inputs /Materials/PlasmaEMProperties

!syntax children /Materials/PlasmaEMProperties
