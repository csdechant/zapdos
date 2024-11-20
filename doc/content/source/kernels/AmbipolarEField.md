# AmbipolarEField

!alert construction title=Undocumented Class
The AmbipolarEField has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /Kernels/AmbipolarEField

## Overview

`AmbipolarEField` calculates the ambipolar electic field. 

By assuming quasi-neutrality (i.e. that the electron and ion densities are approximately equal) and that the electron and ion fluxes are equal, then the electric field is defined as:

\begin{equation}
\vec{E} = \frac{D_{i} - D_{e}}{\mu_{i} - \mu_{e}} \frac{\nabla n_{e}}{n_{e}}
\end{equation}

where

- $\vec{E}$ is the electic field,
- $n_{e}$ is the electron density,
- $D_{e}$ is the electron diffusion coefficient,
- $\nu_{e}$ is the electron mobility coefficient,
- $D_{i}$ is the ion diffusion coefficient, and
- $\nu_{i}$ is the ion mobility coefficient.

When converting the density to logarithmic form, `AmbipolarEField` is defined as

\begin{equation}
\vec{E} = \frac{D_{i} - D_{e}}{\mu_{i} - \mu_{e}} \nabla N_{e}
\end{equation}

where $N_{e}$ is the molar density of the electrons in logarithmic form.

## Example Input File Syntax

!! Describe and include an example of how to use the AmbipolarEField object.

!syntax parameters /Kernels/AmbipolarEField

!syntax inputs /Kernels/AmbipolarEField

!syntax children /Kernels/AmbipolarEField
