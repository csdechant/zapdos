# Examples & Tutorials

This page includes links to examples and tutorials for Zapdos and its dependencies. For in-depth examples of Zapdos, please refer the the [Verification & Validation (V&V) page](verification_and_validation/index.md). While the tutorials in Zapdos are design to be stand-alone cases, so that new users do not need prior knowledge of Zapdos' dependencies, it is still recommended to utilize the `Supplemental References` at the bottom of this page if one would like to start developing within Zapdos.

## Tutorials

!style halign=left
This is a list of the Zapdos tutorials. New tutorials are constantly being developed. If one would like to suggest a new tutorial, please visit the [discussion forum](https://github.com/shannon-lab/zapdos/discussions) to submit new ideas.

- [Tutorial 1: Diffusion](getting_started/examples_and_tutorials/tutorial01-Diffusion/index.md)
- [Tutorial 2: Reaction Networks](getting_started/examples_and_tutorials/tutorial02-ReactionNetwork/index.md)
- [Tutorial 3: Potential With Ion Loss](getting_started/examples_and_tutorials/tutorial03-PotentialWithIonLoss/index.md)
- [Tutorial 4: Pressure Vs Electron Temperature](getting_started/examples_and_tutorials/tutorial04-PressureVsTe/index.md)
- [Tutorial 5: Plasma Water Interface](getting_started/examples_and_tutorials/tutorial05-PlasmaWaterInterface/index.md)
- [Tutorial 6: Building an Input File](getting_started/examples_and_tutorials/tutorial06-Building-InputFile/index.md)

!alert! note title=Slides of Workshops
Provide is the link to the [tutorials slides](tutorial/index.md). It should be noted that these slides are designed for a workshop format, and are not intended for stand-alone use.
!alert-end!

# Supplemental References

## MOOSE Framework

!style halign=left
Zapdos is built upon Idaho National Laboratory's [!ac](MOOSE) Framework. The MOOSE Framework act as the backbone to couple different physics domains in a straightforward manner for high performance computing. For additional information on how to utilize the framework, visit the [MOOSE's Example & Tutorials page](https://mooseframework.inl.gov/getting_started/examples_and_tutorials/index.html).

## CRANE

!style halign=left
For plasma chemistry, Zapdos is coupled to the MOOSE application CRANE (Chemical ReAction NEtworks). When coupled to Zapdos, CRANE provides the chemistry source terms for the fluid description of plasma, in a PDE formulation. CRANE can be used separately to solve for global chemistry networks, in an ODE formulation. For additional information on how to utilize the CRANE independently, visit the [CRANE Examples page](examples/crane_examples.md).
