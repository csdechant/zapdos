# Position

!alert construction title=Undocumented Class
The Position has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /AuxKernels/Position

## Overview

`Position` returns the characteristic scaling length for a given component. Zapdos
users can uniformly scale the position units for a given set of equations. This means
a user can construct a normalized mesh of some factor and scale all equations to
that same factor. `Position` is then used to plot against the any spatial results.

## Example Input File Syntax

An example of how to use `Position` can be found in the
test file `Lymberopoulos_with_argon_metastables.i`.

!listing test/tests/Lymberopoulos_rf_discharge/Lymberopoulos_with_argon_metastables.i block=AuxKernels/Te

!syntax parameters /AuxKernels/Position

!syntax inputs /AuxKernels/Position

!syntax children /AuxKernels/Position
