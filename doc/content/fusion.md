# Notes Regarding Zapdos and magnetized fluids for fusion applications

## Moments of the Boltzmann Equations

!style halign=left
Similar to most fluid approaches of plasmas, one needs to convert the kinetic equations of
charged particles (in this case the Boltzmann equations) into a continuous form. This is
done by taking the $0^{\text{th}}$ - $2^{\text{nd}}$ moments of the Boltzmann equations, which
results in the following:


$\textbf{0}^{\textbf{th}}$ $\textbf{Moment - Continuity}$

\begin{equation}
\frac{\partial n}{\partial t} + \nabla \cdot \left( n \vec{v} \right) = S_{n}
\end{equation}

Where:

- $n$ is the number density of a species,
- $\vec{v}$ is the velocity of a species, and
- $S_{n}$ is the source term for the species.

$\textbf{1}^{\textbf{th}}$ $\textbf{Moment - Momentum}$

\begin{equation}
\frac{\partial}{\partial t} \left( mn\vec{v} \right) + \nabla \cdot \left( mn\vec{v} \otimes \vec{v} \right) = -\nabla p -\nabla \Pi + Zen\left( \vec{E} + \vec{v} \times \vec{B} \right) + \vec{R} + \vec{S}_{m\vec{v}}
\end{equation}

Where:

- $m$ is the mass of the species,
- $p$ is the pressure,
- $\Pi$ is the stress tensor,
- $Z$ is the charge of the species,
- $e$ is the elemental charge,
- $\vec{E}$ is the electric field,
- $\vec{B}$ is the magnetic field,
- $\vec{R}$ is the momentum transfer between species, and
- $\vec{S}_{m\vec{v}}$ is the momentum source term.

$\textbf{2}^{\textbf{th}}$ $\textbf{Moment - Energy}$

\begin{equation}
\frac{\partial \varepsilon}{\partial t} + \nabla \cdot \left( \varepsilon \vec{v} + \Pi \cdot \vec{v} + \vec{q} \right) = Zen\vec{E} \cdot \vec{v} + \vec{R} \cdot \vec{v} + Q + S_{\varepsilon}
\end{equation}

Where:

- $\vec{q}$ is the heat flux,
- $Q$ is the energy exchange between species, and
- $S_{\varepsilon}$ is the energy source term.

## Decomposition of the Velocity

!style halign=left
To reduce computational cost, the full magnetic velocity profile is not solved.
Instead, the velocity is decomposed into a magnetic parallel and perpendicular components,
where only lower orders of the perpendicular velocity are considered. The form of
the velocity is:

\begin{equation}
\vec{v} = \vec{b}v_{\parallel} + \vec{v}_{\perp}
\end{equation}

Where:

- $\vec{b}$ is the magnetic unit vector: $\vec{b} = \frac{\vec{B}}{\lvert B \rvert}$,
- $v_{\parallel}$ is the the scalar magnitude of the parallel velocity, and
- $\vec{v}_{\perp}$ is the perpendicular velocity.

The perpendicular velocity is a summation of terms, which is truncated based on assuming that
higher order term are negligible. The three common perpendicular velocity terms are:

- $\vec{E} \times \vec{B}$ Drift: $\vec{v}_{E} = \frac{\vec{E} \times \vec{B}}{B^{2}}$
- Diamagnetic Drift: $\vec{v}^{*} = \frac{\vec{B} \times \nabla p}{ZenB^{2}}$
- Anomalous Diffusion: $\vec{v}_{D} = -D_{\perp} \frac{\nabla_{\perp} n}{n}$

The last term, $\vec{v}_{D}$, is to capture the cross field turbulent effects observed in
experiments and turbulent models that are not directly captured in transport models (the
difference between turbulent and transport model will be explained later).

Other perpendicular velocity terms that are often include are:

- Polarization Velocity: $\vec{v}_{p} = -\frac{1}{n} \left( \frac{\partial \vec{\omega}}{\partial t} + \nabla \cdot \left( \vec{v} \otimes \vec{\omega} \right) \right)$
- Collisional Drift: $\vec{v}_{\text{fric}} = \frac{\vec{S}_{v} \times \vec{B}}{ZenB^{2}}$
- Curvature Drift: $\vec{v}_{\nabla B} = \frac{2 T_{j}}{ZeB} \frac{\vec{B} \times \nabla B}{B^{2}}$

Where:

- $\vec{\omega}$ is the vorticity,
- $\vec{S}_{v}$ is the momentum transfer due to collisions, and
- $T_{j}$ is the temperature of the species

!alert note
The formulation of $\vec{v}_{\nabla B}$ is slightly different from code-to-code based
on assumption and implementation. Please check formulation before including curvature drift.

The polarization velocity and vorticity, $\vec{v}_{p}$ and $\vec{\omega}$, are often solved
due to their contribution to the total current flux. The collisional drift, $\vec{v}_{\text{fric}}$,
is rarely used in current fluid models due to it being small term compared to the other drift components.
Finally, the curvature drift, $\vec{v}_{\nabla B}$, can be replace the diamagnetic drift ,$\vec{v}^{*}$, within
the Braginskii closure to account for the diamagnetic cancellation.

## Implementing Velocity Decomposition Through the Material System and MMS Verification

To effectively supply the magnetic unit vector, the velocity terms, divergences of those terms, and Jacobian information to multiple calculations (i.e., multiple MOOSE objects), Zapdos computes the magnetic unit vector and velocity decomposition as [Material objects](syntax/Materials/index.html). The following are those material objects and their verification through MMS (Method of Manufactured Solutions):

[MagneticUnitVector](xxx): $\vec{b} = \frac{\vec{B}}{\lvert B \rvert}$

The manufactured solutions used were:

- $\vec{B} = \sin \left( xyz \right)*\hat{\textbf{\i}} - \cos \left( xyz \right)*\hat{\textbf{\j}} + \cos \left( xyz \right)*\hat{\textbf{k}}$

!media magnetic-unit-vector-website-plot.py
       image_name=magnetic_unit_vector_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-magnetic-unit-vector
       caption=Spatial convergence plot for the outputs of the object `MagneticUnitVector`: the magnitude of the magnetic field, ($\lvert B \rvert$), the gradient of the magnitude of the magnetic field ($\nabla \lvert B \rvert$), the magnetic unit vector
       ($\vec{b}$), the divergence of the unit vector ($\nabla \cdot \vec{b}$), and the curl of the unit vector ($\nabla \times \vec{b}$). Ideal convergence slope for first order variable types is 2, and the gradient for first order variable types is 1.

[MagneticParallelVelocity](xxx): $\vec{v}_\parallel = \vec{b} v_\parallel$

The manufactured solutions used were:

- $\vec{B} = \sin \left( xyz \right)*\hat{\textbf{\i}} - \cos \left( xyz \right)*\hat{\textbf{\j}} + \cos \left( xyz \right)*\hat{\textbf{k}}$
- $\vec{v}_\parallel = 2x + 3y +4z$

!media parallel-velocity-website-plot.py
       image_name=parallel_velocity_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-parallel-velocity
       caption=Spatial convergence plot for the outputs of the object `MagneticParallelVelocity`: the parallel velocity
       ($\vec{v}_\parallel$) and the divergence of the parallel velocity ($\nabla \cdot \vec{v}_\parallel$). Ideal convergence slope for first order variable types is 2.

[EcrossBDriftVelocity](xxx): $\vec{v}_{E} = \frac{\vec{E} \times \vec{B}}{B^{2}}$

The manufactured solutions used were:

- $\vec{B} = \sin \left( xyz \right)*\hat{\textbf{\i}} - \cos \left( xyz \right)*\hat{\textbf{\j}} + \cos \left( xyz \right)*\hat{\textbf{k}}$
- $\vec{E} = \cos \left( xyz \right)*\hat{\textbf{\i}} + \sin \left( xyz \right)*\hat{\textbf{\j}} + \sin \left( xyz \right)*\hat{\textbf{k}}$

!media EcrossB-velocity-website-plot.py
       image_name=EcrossB_velocity_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-EcrossB-velocity
       caption=Spatial convergence plot for the outputs of the object `EcrossBDriftVelocity`: the $\vec{E} \times \vec{B}$ velocity
       ($\vec{v}_{E}$) and the divergence of the $\vec{E} \times \vec{B}$ velocity ($\nabla \cdot \vec{v}_{E}$). Ideal convergence slope for first order variable types is 2.

[DiamagneticDriftVelocity](xxx): $\vec{v}^{*} = \frac{\vec{B} \times \nabla p}{ZenB^{2}}$

The manufactured solutions used were:

- $\vec{B} = \sin \left( xyz \right)*\hat{\textbf{\i}} - \cos \left( xyz \right)*\hat{\textbf{\j}} + \cos \left( xyz \right)*\hat{\textbf{k}}$
- $n = \sin \left(\pi xyz + 2 \right)$
- $p = x^{2} + 1.5y^{2} + 2z^{2}$
- $e = 3$
- $Z = 0.5$

!alert note
In Zapdos, the logarithmic expression of the density is used, defined as:
\begin{equation}
N = \ln \left( n \right)
\end{equation}
This results in the calculation of the diamagnetic drift in Zapdos being:
\begin{equation}
\vec{v}^{*} = \frac{\vec{B} \times \nabla p}{Ze \exp \left( N \right) B^{2}}
\end{equation}

!media diamagnetic-velocity-website-plot.py
       image_name=diamagnetic_velocity_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-diamagnetic-velocity
       caption=Spatial convergence plot for the outputs of the object `DiamagneticDriftVelocity`: the diamagnetic velocity
       ($\vec{v}^{*}$) and the divergence of the diamagnetic velocity ($\nabla \cdot \vec{v}^{*}$). Ideal convergence slope for the gradient for first order variable types is 1 (this is due to $\nabla p$).

## New Coupled Divergence Operators Using Material Vectors

As seen in the above equations for the $0^{\text{th}}$ - $2^{\text{nd}}$ moments of the Boltzmann equations, the divergences of fluxes will
need to be calculated. In order to streamline the coupling of the new material velocity objects to the necessary variables
(such as with density for species flux and temperature for energy flux), two new [Kernel objects](syntax/Kernels/index.html) where created.
These objects were based on the product rule for a scalar-vector coupled divergence, defined as:
\begin{equation}
\nabla \cdot \left(f \vec{C}\right) = f \nabla \cdot \vec{C} + \vec{C} \cdot \nabla f
\end{equation}

Where:

- $f$ is a scalar variable, and
- $\vec{C}$ is a vector variable.

!alert note
In Zapdos, the logarithmic expression of the density is used, defined as:
\begin{equation}
N = \ln \left( n \right)
\end{equation}
This results in the calculation of the divergence of the density flux in Zapdos being:
\begin{equation}
\nabla \cdot \left(n \vec{v}\right) =  \exp \left( N \right) \nabla \cdot \vec{v} + \vec{v} \cdot \nabla N \exp \left( N \right)
\end{equation}

The following are those kernel objects and their verification through MMS (Method of Manufactured Solutions):

[ScalarDivergenceMatVelocityProduct](xxx): $f \nabla \cdot \vec{C}$ (Labeled as first term)
Or
[ScalarLogDivergenceMatVelocityProduct](xxx): $\exp \left( N \right) \nabla \cdot \vec{v}$ (Labeled as first term)

[MatVectorGradientScalarProduct](xxx): $\vec{C} \cdot \nabla f$ (Labeled as second term)
Or
[ScalarLogDivergenceMatVelocityProduct](xxx): $\vec{v} \cdot \nabla N \exp \left( N \right)$ (Labeled as first term)


The manufactured solutions used were:

- $f = \sin \left( \pi xyz \right) + 2.0$
- $N = \ln \left( \sin \left( \pi xyz \right) + 2.0 \right)$
- $\vec{C} = \cos \left( xyz \right)*\hat{\textbf{\i}} + \sin \left( xyz \right)*\hat{\textbf{\j}} + \sin \left( xyz \right)*\hat{\textbf{k}}$

!media divergence-of-flux-website-plot.py
       image_name=divergence_of_flux_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-divergence-of-flux
       caption=Spatial convergence plot the variable $f$ solving with the objects `ScalarDivergenceMatVelocityProduct` (first term) and `MatVectorGradientScalarProduct` (second term). Ideal convergence slope for first order variable types is 2.

!media divergence-of-flux-log-website-plot.py
       image_name=divergence_of_flux_log_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-divergence-of-flux-log
       caption=Spatial convergence plot the variable $N$ solving with the objects `ScalarLogDivergenceMatVelocityProduct` (first term) and `MatVectorGradientScalarLogProduct` (second term). Ideal convergence slope for first order variable types is 2.

## Magnetic Perpendicular Diffusion Object

As mentioned above in the section `Decomposition of the Velocity`, there is an anomalous diffusion which is the diffusion across the
magnetic field lines. This is represented by a perpendicular gradient, $\nabla_{\perp}$. This perpendicular gradient is defined as:

\begin{equation}
\nabla_{\perp} f = \nabla f - \vec{b} \left( \vec{b} \cdot \nabla f \right)
\end{equation}

!alert note
In Zapdos, the logarithmic expression of the density is used, defined as:
\begin{equation}
N = \ln \left( n \right)
\end{equation}
This results in the calculation of the perpendicular diffusion in Zapdos being:
\begin{equation}
\nabla \cdot \nabla_{\perp} n =  \nabla \cdot D_{\perp} \left( \nabla N \exp \left( N \right) - \vec{b} \left( \vec{b} \cdot \nabla N \exp \left( N \right) \right) \right)
\end{equation}

The following is the perpendicular diffusion kernel and its verification through MMS (Method of Manufactured Solutions):

[CoeffPerpendicularDiffusionLin](xxx): $\nabla \cdot D_{\perp} \left( \nabla f - \vec{b} \left( \vec{b} \cdot \nabla f \right) \right)$
Or
[CoeffPerpendicularDiffusion](xxx): $\nabla \cdot D_{\perp} \left( \nabla N \exp \left( N \right) - \vec{b} \left( \vec{b} \cdot \nabla N \exp \left( N \right) \right) \right)$

The manufactured solutions used were:

- $f = \sin \left( \pi xyz \right) + 2.0$
- $N = \ln \left( \sin \left( \pi xyz \right) + 2.0 \right)$
- $\vec{B} = \sin \left( xyz \right)*\hat{\textbf{\i}} - \cos \left( xyz \right)*\hat{\textbf{\j}} + \cos \left( xyz \right)*\hat{\textbf{k}}$
- $D_{\perp} = 2.0$

!media perpendicular-diffusion-website-plot.py
       image_name=perpendicular_diffusion_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-perpendicular-diffusion
       caption=Spatial convergence plot the variable $f$ solving with the `CoeffPerpendicularDiffusion` object. Ideal convergence slope for first order variable types is 2.

!media perpendicular-diffusion-log-website-plot.py
       image_name=perpendicular_diffusion_log_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-perpendicular-diffusion-log
       caption=Spatial convergence plot the variable $N$ solving with the `CoeffPerpendicularDiffusionLin` object. Ideal convergence slope for first order variable types is 2.

## Verification of First Plasma Edge Model: The Hasegawa-Wakatani Model

The first plasma edge model that will be verified is the Hasegawa-Wakatani model. This is a simple but powerful 2D model for simulating
the plasma edge of fusion devices. It is a good starting point because it uses all of the operators mentioned so far, with an exception
for the diamagnetic drift. Before review the whole model, there are two new source terms that need to be introduced that are exclusive to the
Hasegawa-Wakatani model that accounts of the reduction in dimensions; an adiabatic turbulence term, $S_{1}$ and a directional potential gradient, $S_{2}$.

\begin{equation}
S_{1} = \alpha \left( \phi - n \right)
\end{equation}

\begin{equation}
S_{2} = - k \frac{\partial \phi}{\partial y}
\end{equation}

Where:

- $\phi$ is the potential,
- $n$ is the density,
- $\alpha$ is the density's adiabaticity coefficient, and
- $k$ is the equilibrium density profile parameter

!alert note
In Zapdos, the logarithmic expression of the density is used, defined as:
\begin{equation}
N = \ln \left( n \right)
\end{equation}
This results in the calculation of the adiabatic turbulence term in Zapdos being:
\begin{equation}
\alpha \left( \phi - \exp \left( N \right) \right)
\end{equation}

!alert note
While these MMS have the $\alpha$ and $k$ terms constant, in a physical case study these terms would
depend on the equilibrium electron temperature and density.

The following is the Hasegawa-Wakatani model source terms and their verification through MMS (Method of Manufactured Solutions):

The manufactured solutions used were:

- $n = \sin \left( \pi xyz \right) + 2.0$
- $\phi = x^2 + 1.5*y^2 + 2.0*z^2$
- $\alpha = 2.0$
- $k = 2.0$


[AdiabaticTurbulence](xxx): $\alpha \left( \phi - n \right)$

!media adiabatic-term-website-plot.py
       image_name=adiabatic_term_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-adiabatic-term
       caption=Spatial convergence plot the variable $n$ solving with the `AdiabaticTurbulence` object. Ideal convergence slope for first order variable types is 2.

[DirectionalPotentialGradient](xxx): $k \frac{\partial \phi}{\partial y}$

!media directional-potential-gradient-website-plot.py
       image_name=directional_potential_gradient_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-directional-potential-gradient
       caption=Spatial convergence plot the variable $n$ solving with the `DirectionalPotentialGradient` object. Ideal convergence slope for first order variable types is 2.

The whole Hasegawa-Wakatani model involves solving for the plasma density ($n$), the vorticity ($\omega$), and the potential ($\phi$) using
the following equation set:

\begin{equation}
\frac{\partial n}{\partial t} = -\frac{1}{|B|} \vec{b} \times \nabla \phi \cdot \nabla n + \alpha \left( \phi - n \right) - k \frac{\partial \phi}{\partial y} + \nabla \cdot \left( D_{\perp n} \nabla _{\perp} n \right)
\end{equation}
\begin{equation}
\frac{\partial \omega}{\partial t} = -\frac{1}{|B|} \vec{b} \times \nabla \phi \cdot \nabla \omega + \alpha \left( \phi - n \right) + \nabla \cdot \left( D_{\perp \omega} \nabla _{\perp} \omega \right)
\end{equation}
\begin{equation}
\nabla \cdot \left( \nabla _{\perp} \phi \right) = \omega
\end{equation}

Where:

- $\omega$ is the vorticity.

The following is the verification of the Hasegawa-Wakatani model in Zapdos through MMS (Method of Manufactured Solutions):

The manufactured solutions used were:

- $n = 0.9x + 0.2 \sin \left( 5.0x^2 - 2.0y \right) * \cos \left( 10t \right) + 0.9$
- $\omega = 0.7x + 0.2 \sin \left( 2.0x^2 - 3.0y \right) * \cos \left( 7t \right) + 0.9$
- $\phi = \left( 0.5x - \sin \left( 3.0x^2 - 3.0y \right) * \cos \left( 7t \right) \right)* \sin \left( x \pi \right)$

!media 2D-Hasegawa-Wakatani-website-plot.py
       image_name=2D_Hasegawa_Wakatani_convergence.png
       style=width:50%;margin-bottom:2%;margin-left:auto;margin-right:auto
       id=ver-2D-Hasegawa-Wakatani
       caption=Spatial convergence plot the density ($n$), vorticity ($\omega$), and potential ($\phi$) solving with the Hasegawa-Wakatani. Ideal convergence slope for first order variable types is 2.
