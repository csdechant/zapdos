# DensityNormalization

!alert construction title=Undocumented Class
The DensityNormalization has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /AuxKernels/DensityNormalization

## Overview

`DensityNormalization` is similar to `NormalizationAux`, except it normalizes a variable in log form based on a Postprocessor value.

The formulation of `DensityNormalization` is defined as

\begin{equation}
\frac{\exp(variable)*normal_{factor}}{normalization} - shift
\end{equation}

## Example Input File Syntax

!! Describe and include an example of how to use the DensityNormalization object.

!syntax parameters /AuxKernels/DensityNormalization

!syntax inputs /AuxKernels/DensityNormalization

!syntax children /AuxKernels/DensityNormalization
