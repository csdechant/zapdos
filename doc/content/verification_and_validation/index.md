!alert construction title=Unfinished Webpage
This is a new, but unfinished webpage for the Zapdos website. A PR with this page should $\textbf{NOT}$ be merged until this page is finished and the warning removed!

# Verification & Validation (V&V)

Zapdos undergoes an extensive verification and validation process when including new additions. As defined by the American Institute of Aeronautics and Astronautics (AIAA):

- Verification is the process of determining that a model implementation accurately represents the developer’s conceptual description of, and solution to, the model.
- Validation is the process of determining the degree to which a model accurately represents the real world—from the perspective of the model’s intended uses.

In addition to verification and validation, Zapdos has undergone code-to-code comparison, commonly referred to as "benchmarking".

Below are the current verification, benchmarking, and validation cases of Zapdos, which observes the following categorization nomenclature:

`(Testing Category).(Application Category).(Case Number).(Sub-case Number)`

`Testing Category` consist of the following abbreviations:

- ver: verification
- ben: benchmarking (code-to-code comparison)
- val: validation

`Application Category` consist of a numerical syntax:

- 1: Industrial Plasmas (e.g. low-temperature plasmas for microchip manufacturing, biomedical, agriculture, etc.)
- 2: Magnetic Fusion Plasmas (strictly magnetically confident fusion plasmas)
- 3: Space Plasmas (e.g. astrophysics and ion propulsion)

# List of verification cases

| Case          | Title          |
| ------------- | -------------- |
| ver-1.001.001 | [MMS: Diffusion](verification_and_validation/verification/ver-1-001-001.md) |
| ver-1.001.002 | [MMS: Drift-Diffusion](verification_and_validation/verification/ver-1-001-002.md) |
| ver-1.001.003 | [MMS: Two-Fluid & Potential](verification_and_validation/verification/ver-1-001-003.md) |
| ver-1.001.004 | [MMS: Energy Dependent Two-Fluid & Potential](verification_and_validation/verification/ver-1-001-004.md) |
| ver-1.001.005 | [MMS: Energy Dependent Two-Fluid & Potential with Chemistry](verification_and_validation/verification/ver-1-001-005.md) |
| ver-1.002.001 | [Analytical Solution: Poisson’s Equation](verification_and_validation/verification/ver-1-002-001.md) |
| ver-1.003.001 | [Analytical Solution: Ambipolar Diffusion](verification_and_validation/verification/ver-1-003-001.md) |

# List of benchmarking cases

| Case          | Title                   |
| ------------- | ----------------------- |
| ben-1.001.001 | [Argon CCP Discharge: 1D](verification_and_validation/benchmarking/ben-1-001-001.md) |
| ben-1.001.002 | [Argon CCP Discharge: 2D](verification_and_validation/benchmarking/ben-1-001-002.md) |
| ben-1.002.001 | [Oxygen CCP Discharge: 1D](verification_and_validation/benchmarking/ben-1-002-001.md) |

# List of validation cases

| Case          | Title   |
| ------------- | ------- |
| val-1.001.001 | [GEC Reference Cell: Microwave Interferometry of Argon](verification_and_validation/validation/val-1-001-001.md) |
| val-1.002.001 | [GEC Reference Cell: Planar Laser Induced Fluorescence of Argon](verification_and_validation/validation/val-1-002-001.md) |
