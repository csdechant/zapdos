# DependentCollisionFreq

!alert construction title=Undocumented Class
The DependentCollisionFreq has not been documented. The content listed below should be used as a starting point for
documenting the class, which includes the typical automatic documentation associated with a
MooseObject; however, what is contained is ultimately determined by what is necessary to make the
documentation clear for users.

!syntax description /Materials/DependentCollisionFreq

## Overview

`DependentCollisionFreq` supplies the electron momentum-transfer collision frequency. The collision frequency is interpolated from a used supplied text file (.txt). This text file is usually generated from a Boltzmann solver, such as [BOLSIG+](https://www.bolsig.laplace.univ-tlse.fr/). The collision frequency can be interpolated as a function of electron mean energy or reduce electric field.

## Example Input File Syntax

!! Describe and include an example of how to use the DependentCollisionFreq object.

!syntax parameters /Materials/DependentCollisionFreq

!syntax inputs /Materials/DependentCollisionFreq

!syntax children /Materials/DependentCollisionFreq
