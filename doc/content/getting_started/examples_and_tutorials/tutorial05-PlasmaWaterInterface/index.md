!alert construction title=Unfinished Webpage
This is a new, but unfinished webpage for the Zapdos website. A PR with this page should $\textbf{NOT}$ be merged until this page is finished and the warning removed!

# Tutorial 5: Plasma Water Interface









This tutorial introduces providing the drift-diffusion equations and the Poisson's equation for electrostatic potential via the Zapdos [DriftDiffusionAction](AddDriftDiffusionAction.md). This tutorial is focus on the decay of a preestablished potential profile between grounded plates in the presents of an ion-only plasma. Calculating the evolution of the potential profile starts with the Gauss's law:

\begin{equation} \label{eq:Gauss-law}
\nabla \cdot \vec{E} = \frac{\rho}{\varepsilon_{0}}
\end{equation}

Where:

- $\vec{E}$ is the electric field,
- $\rho$ is the charge density, and
- $\varepsilon_{0}$ is the permittivity of free space.

This tutorial will assume the electrostatic approximation and that only positive ions contribute to the charge density, such that:

\begin{equation} \label{eq:electrostatic-approximation}
\vec{E} = - \nabla \Phi
\end{equation}

Where:

- $\Phi$ is the electrostatic potential.

\begin{equation} \label{eq:ion-only-charge-density}
  \rho = e n_{i}
\end{equation}

Where:

- $e$ is the elementary charge, and
- $n_{i}$ is the ion density.

Applying [eq:electrostatic-approximation] and [eq:ion-only-charge-density] to [eq:Gauss-law] results in the ion-only Poisson's equation in the form of:

\begin{equation} \label{eq:poisson-equation}
  \nabla ^{2} \Phi = - \frac{e n_{i}}{\varepsilon_{0}}
\end{equation}

For determining the ion density, this tutorial utilizes the drift-diffusion approximation with a zero source term:

\begin{equation} \label{eq:drift-diffusion-approximation}
\frac{d n_{i}}{d t} + \nabla \cdot \left( \mu_{i} \vec{E} n_{i} - D_{i} \nabla n_{i} \right) = 0
\end{equation}

Where:

- $\mu_{i}$ is the ion mobility coefficient, and
- $D_{i}$ is the diffusion coefficient.
