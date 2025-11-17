!alert construction title=Unfinished Webpage
This is a new, but unfinished webpage for the Zapdos website. A PR with this page should $\textbf{NOT}$ be merged until this page is finished and the warning removed!

# Braginskii Model


## Moments of the Boltzmann Equations

!style halign=left

### Decomposition of the Velocity

$\textbf{Decomposition of the Velocity}$

\begin{equation}
\vec{v} = \vec{b}v_{\parallel} + \vec{v}_{\perp}
\end{equation}

Where:

- $\vec{b}$ is the magnetic unit vector: $\vec{b} = \frac{\vec{B}}{\lvert B \rvert}$,
- $v_{\parallel}$ is the the scalar magnitude of the parallel velocity, and
- $\vec{v}_{\perp}$ is the perpendicular velocity.

The definition perpendicular velocity is:

- $\vec{E} \times \vec{B}$ Drift: $\vec{v}_{E} = \frac{\vec{E} \times \vec{B}}{B^{2}}$
- Diamagnetic Drift: $\vec{v}^{*} = \frac{\vec{B} \times \nabla p}{ZenB^{2}}$
- Anomalous Diffusion: $\vec{v}_{D} = -D_{\perp} \frac{\nabla_{\perp} n}{n}$
- Polarization Velocity: $\vec{v}_{p} = -\frac{1}{n} \left( \frac{\partial \vec{\omega}}{\partial t} + \nabla \cdot \left( \vec{v} \otimes \vec{\omega} \right) \right)$

Where:

- $\vec{\omega}$ is the vorticity

### Continuity

!style halign=left

$\textbf{0}^{\textbf{th}}$ $\textbf{Moment - Continuity}$

\begin{equation}
\frac{\partial n}{\partial t} + \nabla \cdot \left( n \vec{u} \right) = S_{n}
\end{equation}

Where:

- $S_{n}$ is the source term for the species.

Assuming quasi-neutrality, only the electron velocities are used in the continuity equation. Charge conservation with be uphold through the Poisson and vorticity equations.

\begin{equation}
\frac{\partial n}{\partial t} + \nabla \cdot \left( n \left( \vec{b}v_{\parallel} + \vec{v}_{E} + \vec{v}^{*} + \vec{v}_{D} \right) \right) - S_{n} = 0
\end{equation}

Below are the objects for continuity equation the MMS input file [braginskii-model.i]:

\begin{equation}
\frac{\partial n}{\partial t}
\end{equation}

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/d_density_dt

\\

\begin{equation}
\nabla \cdot \left( n \ \vec{b} \ v_{\parallel} \right) = n \nabla \cdot \left(\vec{b} \ v_{\parallel} \right) + \left( \vec{b} \ v_{\parallel} \right) \cdot \nabla n
\end{equation}

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Materials/magnetic_unit_vector

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Materials/magnetic_parallel_velocity

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/n_times_div_parallel_vel

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/parallel_vel_times_grad_n

\\

\begin{equation}
\nabla \cdot \left( n \ \vec{v}_{E} \right) = n \nabla \cdot \vec{v}_{E} + \vec{v}_{E} \cdot \nabla n
\end{equation}

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Materials/electric_field_solver

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Materials/EcrossB_Drift

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/n_times_div_EcrossB_Drift

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/EcrossB_Drift_times_grad_n

\\

\begin{equation}
\nabla \cdot \left( n \ \vec{v}^{*} \right) = n \nabla \cdot \vec{v}^{*} + \vec{v}^{*} \cdot \nabla n
\end{equation}

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Materials/magnetic_diamagnetic_drift

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/n_times_div_diamagnetic_drift

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/diamagnetic_drift_times_grad_n

\\

\begin{equation}
\nabla \cdot \left( n \ \vec{v}_{D} \right) = \nabla \cdot \left( D_{\perp} \nabla_{\perp} n \right)
\end{equation}

Where:

\begin{equation}
\nabla_{\perp} f = \nabla f - \vec{b} \left( \vec{b} \cdot \nabla f \right)
\end{equation}

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/perpendicular_diffusion

\\

\begin{equation}
- S_{n}
\end{equation}

!listing test/tests/mms/magnetized_plasma/model_verification/braginskii_model/braginskii-model.i block=Kernels/continuity_forcing_term

### Momentum

!style halign=left

$\textbf{1}^{\textbf{th}}$ $\textbf{Moment - Momentum}$

\begin{equation}
\frac{\partial}{\partial t} \left( mn\vec{v} \right) + \nabla \cdot \left( mn\vec{v} \otimes \vec{v} \right) + \nabla \cdot \Psi - Zen\left( \vec{E} + \vec{v} \times \vec{B} \right) = \vec{S}_{m\vec{v}}
\end{equation}

Where:

- $m$ is the mass of the species,
- $\Psi$ is the pressure tensor,
- $Z$ is the charge of the species,
- $e$ is the elemental charge,
- $\vec{E}$ is the electric field,
- $\vec{B}$ is the magnetic field, and
- $\vec{S}_{m\vec{v}}$ is the momentum source term.

Neglecting the time and spatial derivatives contribution of the density (i.e., incompressible flow), and expending the pressure tensor into a pressure gradient ($\nabla p$) and stress tensor ($\nabla \cdot \Pi$), the momentum equation results in:

\begin{equation}
m \ n \ \left( \frac{\partial \vec{v}}{\partial t} + \vec{v} \nabla \vec{v} \right) + \nabla p + \nabla \cdot \Pi - Zen \left( \vec{E} + \vec{v} \times \vec{B} \right) - R - S_{m\vec{v}} = 0
\end{equation}

Since we calculate the perpendicular velocity as a sum of drift components, the momentum equation only applies to the parallel velocity:

\begin{equation}
\frac{\partial v_{\parallel}}{\partial t} + \left( \vec{b}v_{\parallel} + \vec{v}_{E} \right) \nabla v_{\parallel} - \nabla \cdot \left( D_{\perp, v_{\parallel}} \nabla_{\perp} v_{\parallel} \right) + \frac{1}{m \ n}\left( \nabla_{\parallel} p + \nabla_{\parallel} G - Zen\vec{E}_{\parallel} - R - S_{m\vec{v}} \right) = 0
\end{equation}

Where:

- $G$ is the parallel stress term $\left( G = \frac{2}{3} \eta \nabla \cdot \vec{v} \right)$
- $\nabla_{\parallel}$ is the parallel magnetic gradient $\left( \nabla_{\parallel} f = \vec{b} \cdot \nabla f \right)$
- $D_{\perp, v_{\parallel}}$ is the anomalous momentum diffusion coefficient.

The momentum equation for both electrons and ions are calculated, such that:

\begin{equation}
\frac{\partial v_{\parallel,e}}{\partial t} + \left( \vec{b}v_{\parallel,e} + \vec{v}_{E} \right) \nabla v_{\parallel,e} - \nabla \cdot \left( D_{\perp, v_{\parallel,e}} \nabla_{\perp} v_{\parallel,e} \right) + \frac{1}{m_{e} \ n}\left( \nabla_{\parallel} p_{e} + \nabla_{\parallel} G_{e} + e\vec{E}_{\parallel} - R_{e} - S_{m\vec{v_{e}}} \right) = 0
\end{equation}

Where:

- $G_{e} = \frac{2}{3} \eta_{0, e} \nabla \cdot \left( \vec{b}v_{\parallel} + \vec{v}_{E} + \vec{v}^{*} \right)$
- $\eta_{0, e} = 0.73 n T_{e} \tau_{e}$
- $R_{e} = e \ n \frac{j_{\parallel}}{\sigma_{\parallel}} - 0.71 n \nabla_{\parallel} T_{e}$
- $j_{\parallel} = e \ n \left( v_{\parallel, i} - v_{\parallel, e} \right)$
- $\sigma_{\parallel} = 1.96 \frac{e^{2}n \tau_{e}}{m_{e}}$

\\

\begin{equation}
\frac{\partial v_{\parallel,i}}{\partial t} + \left( \vec{b}v_{\parallel,i} + \vec{v}_{E} \right) \nabla v_{\parallel,i} - \nabla \cdot \left( D_{\perp, v_{\parallel,i}} \nabla_{\perp} v_{\parallel,i} \right) + \frac{1}{m_{i} \ n}\left( \nabla_{\parallel} p_{e} + \nabla_{\parallel} G_{i} - S_{m\vec{v_{i}}} \right) = 0
\end{equation}

Where:

- Neglecting ion advection and ion momentum transfer
- $G_{e} = \frac{2}{3} \eta_{0, e} \nabla \cdot \left( \vec{b}v_{\parallel} + \vec{v}_{E} + \vec{v}^{*} \right)$
- $\eta_{0, e} = 0.96 n T_{i} \tau_{i}$

Below are the objects for electron momentum equation the MMS input file [braginskii-model.i]:

XXXXXXXXXXXXXX

The drift-diffusion model is the primary model used in Zadpos for industrial applications of plasmas. Instead of solving for the species velocity directly, the drift-diffusion model redefines the species density flux into a diffusion and an electric field driven advection term. From the $1^{\text{th}}$ moment of the Boltzmann equation, the momentum equation, the following assumptions are applied:

- acceleration, inertial forces, and the magnetic fields are neglectable,
- the momentum source term is dominated by collisions with neutrals, and
- the pressure is isotropic, which converts the pressure tensor into a scalar value.

This leads to a momentum equation of:

\begin{equation}
Z e n \vec{E} - \nabla p - m n \nu_{m} \vec{u} = 0
\end{equation}

where:

- $Z$ is the charge of the species,
- $e$ is the elemental charge,
- $n$ is the species density,
- $\vec{E}$ is the electric field,
- $p$ is the pressure scalar,
- $m$ is the mass of the species,
- $\nu_{m}$ is the species collision frequency with neutrals, and
- $\vec{u}$ is the velocity.

With the addition of assuming the ideal gas law for the pressure, the species velocity is redefined as:

\begin{equation}
\vec{u} = \frac{Z e}{m \nu_{m}} \vec{E} - \frac{k_{\text{B}} T}{m \nu_{m}} \frac{\nabla n}{n}
\end{equation}

where:

- $k_{\text{B}}$ is the Boltzmann constant, and
- $T$ is the species temperature.

From this definition of velocity, two new transport coefficients can be defined: the mobility, $\mu$, and diffusivity, $D$.

\begin{equation}
\mu = \frac{Z e}{m \nu_{m}} \\[10pt]
D = \frac{k_{\text{B} T}}{m \nu_{m}}
\end{equation}

In combination with the $0^{\text{th}}$ moment of the Boltzmann equation, the continuity equation, the drift-diffusion model is:

\begin{equation}
\frac{d n}{d t} + \nabla \cdot \vec{\Gamma} = S_{n} \\[10pt]
\vec{\Gamma} = \text{sign} \mu \vec{E} n - D \nabla n
\end{equation}

Where:

- $\text{sign}$ indicates the advection behavior ($\text{+}1$ for positively charged species, $\text{-}1$ for negatively charged species, and $0$ for neutral species),
- $\Gamma$ is the species flux, and
- $S_{n}$ is the source term.

A similar approach is taken with the electron energy flux in the $2^{\text{th}}$ moment of the Boltzmann, the energy equation, where:

\begin{equation}
\frac{\partial n_{\epsilon}}{\partial t} + \nabla \cdot \vec{\Gamma_{\epsilon}} - \vec{E} \cdot \vec{\Gamma_{e}} = S_{\epsilon} \\[10pt]
\vec{\Gamma}_{\epsilon} = - \mu_{\epsilon} \vec{E} n_{\epsilon} - D_{\epsilon} \nabla n_{\epsilon}
\end{equation}

Where:

- the subscript $e$ represents properties of the electrons,
- $n_{\epsilon}$ is the electron mean energy density (defined as $n_{\epsilon} = \epsilon n_{e}$)
- $\epsilon$ is the electron mean energy in units of eV,
- $\mu_{\epsilon}$ is the electron mean energy density mobility coefficient,
- $D_{\epsilon}$ is the electron mean energy density diffusion coefficient, and
- $S_{\epsilon}$ is the electron mean energy source term.

## Transport Coefficients

!style halign=left
The transport coefficients used in the drift-diffusion model need to be determine, either through experiments or a simplified Boltzmann solver. The Boltzmann solver of choice that has been used in several Zapdos simulations is [BOLSIG+](https://www.bolsig.laplace.univ-tlse.fr/). More on how these transport coefficients are calculated, please refer to [!cite](hagelaar2005solving).

## Source Terms

!style halign=left
The source terms depend on the chemistry reaction network of interest. This often require networks that are defined using rate coefficients or Townsend coefficients. The general form of the source terms defined by rate coefficients are:

\begin{equation}
S_{n} = \sum_{i}{\left( \nu_{i} k_{i} \prod_{j}{n_{j}} \right)} \\[10pt]
S_{\epsilon} = \sum_{i}{\left( E_{i} \nu_{i} k_{i} \prod_{j}{n_{j}} \right)}
\end{equation}

where:

- subscript $i$ represents a reaction within the reaction network,
- subscript $j$ represents the reactants within a reaction,
- $\nu$ is the stoichiometric coefficient,
- $k$ is the rate coefficient, and
- $E$ is the energy threshold of the reaction.

The general form of the source terms defined by Townsend coefficients are:

\begin{equation}
S_{n} = \lvert \Gamma_{e} \rvert \sum_{i}{\alpha_{i}} \\[10pt]
S_{\epsilon} = \lvert \Gamma_{e} \rvert \sum_{i}{\left( E_{i} \alpha_{i} \right)}
\end{equation}

where:

- $\alpha$ is the Townsend coefficient.

The rate and Townsend can also be provide from a simplified Boltzmann solver, such as [BOLSIG+](https://www.bolsig.laplace.univ-tlse.fr/).
