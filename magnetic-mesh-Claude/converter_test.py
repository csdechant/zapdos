"""
Tokamak Magnetic Field Calculator - Cartesian Coordinates

Converts toroidal and poloidal magnetic field components to Cartesian coordinates
given only the poloidal flux function ψ(R,Z) in Weber and on-axis toroidal field B_φ0.

References:
1. Y. J. Hu, "Notes on tokamak equilibrium", Eq. (5), (6), (9)
   https://youjunhu.github.io/research_notes/tokamak_equilibrium_htlatex/tokamak_equilibrium.html
2. Freidberg, J.P. (2014), "Ideal MHD", Cambridge University Press
3. Wesson, J. & Campbell, D.J. (2011), "Tokamaks", 4th ed., Oxford
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import RectBivariateSpline


class TokamakMagneticField:
    """
    Calculate magnetic field in Cartesian coordinates from poloidal flux and
    on-axis toroidal field.
    """

    def __init__(self, R_grid, Z_grid, psi_grid, B_phi0, R0):
        """
        Initialize the magnetic field calculator.

        Parameters:
        -----------
        R_grid : 2D array
            Major radius grid (m), shape (nZ, nR)
        Z_grid : 2D array
            Vertical coordinate grid (m), shape (nZ, nR)
        psi_grid : 2D array
            Poloidal flux function ψ(R,Z) in Weber, shape (nZ, nR)
        B_phi0 : float
            On-axis toroidal magnetic field (T)
        R0 : float
            Major radius of magnetic axis (m)
        """
        self.R_grid = R_grid
        self.Z_grid = Z_grid
        self.psi_grid = psi_grid
        self.B_phi0 = B_phi0
        self.R0 = R0
        self.g0 = B_phi0 * R0  # Toroidal field function (constant approximation)

        # Create interpolation function for psi
        # Note: RectBivariateSpline expects 1D arrays for coordinates
        R_1d = R_grid[0, :]
        Z_1d = Z_grid[:, 0]
        self.psi_interp = RectBivariateSpline(Z_1d, R_1d, psi_grid)

    def compute_psi_derivatives(self, R, Z):
        """
        Compute gradients of poloidal flux function.

        Parameters:
        -----------
        R : float or array
            Major radius position(s) (m)
        Z : float or array
            Vertical position(s) (m)

        Returns:
        --------
        dpsi_dR : float or array
            ∂ψ/∂R
        dpsi_dZ : float or array
            ∂ψ/∂Z
        grad_psi_mag : float or array
            |∇ψ| = sqrt((∂ψ/∂R)² + (∂ψ/∂Z)²)
        """
        # Compute derivatives using the interpolation function
        dpsi_dR = self.psi_interp(Z, R, dx=0, dy=1, grid=False)
        dpsi_dZ = self.psi_interp(Z, R, dx=1, dy=0, grid=False)

        grad_psi_mag = np.sqrt(dpsi_dR**2 + dpsi_dZ**2)

        return dpsi_dR, dpsi_dZ, grad_psi_mag

    def compute_cylindrical_field(self, R, Z):
        """
        Compute magnetic field in cylindrical coordinates (R, φ, Z).

        Based on equations:
        B_R = (1/R) ∂ψ/∂Z           [Ref 1, Eq. 5]
        B_Z = -(1/R) ∂ψ/∂R          [Ref 1, Eq. 6]
        B_φ = g/R ≈ B_φ0·R0/R       [Ref 1, Eq. 9]

        Parameters:
        -----------
        R : float or array
            Major radius position(s) (m)
        Z : float or array
            Vertical position(s) (m)

        Returns:
        --------
        B_R : float or array
            Radial magnetic field component (T)
        B_phi : float or array
            Toroidal magnetic field component (T)
        B_Z : float or array
            Vertical magnetic field component (T)
        B_pol : float or array
            Poloidal field magnitude (T)
        """
        dpsi_dR, dpsi_dZ, grad_psi_mag = self.compute_psi_derivatives(R, Z)

        # Poloidal field components (Eq. 5, 6 from Ref 1)
        B_R = dpsi_dZ / R
        B_Z = -dpsi_dR / R

        # Poloidal field magnitude
        B_pol = grad_psi_mag / R

        # Toroidal field (vacuum approximation, Eq. 9 from Ref 1)
        B_phi = self.g0 / R

        return B_R, B_phi, B_Z, B_pol

    def cylindrical_to_cartesian(self, R, phi, Z, B_R, B_phi, B_Z):
        """
        Convert magnetic field from cylindrical to Cartesian coordinates.

        Coordinate transformation:
        x = R cos(φ)
        y = R sin(φ)
        z = Z

        Field transformation:
        B_x = B_R cos(φ) - B_φ sin(φ)
        B_y = B_R sin(φ) + B_φ cos(φ)
        B_z = B_Z

        Parameters:
        -----------
        R : float or array
            Major radius (m)
        phi : float or array
            Toroidal angle (radians)
        Z : float or array
            Vertical coordinate (m)
        B_R : float or array
            Radial field component (T)
        B_phi : float or array
            Toroidal field component (T)
        B_Z : float or array
            Vertical field component (T)

        Returns:
        --------
        x, y, z : float or array
            Cartesian position coordinates (m)
        B_x, B_y, B_z : float or array
            Cartesian magnetic field components (T)
        """
        # Position transformation
        x = R * np.cos(phi)
        y = R * np.sin(phi)
        z = Z

        # Field transformation
        B_x = B_R * np.cos(phi) - B_phi * np.sin(phi)
        B_y = B_R * np.sin(phi) + B_phi * np.cos(phi)
        B_z = B_Z

        return x, y, z, B_x, B_y, B_z

    def get_cartesian_field(self, x, y, z):
        """
        Get magnetic field in Cartesian coordinates at position (x, y, z).

        Parameters:
        -----------
        x, y, z : float or array
            Cartesian position coordinates (m)

        Returns:
        --------
        B_x, B_y, B_z : float or array
            Cartesian magnetic field components (T)
        B_mag : float or array
            Total magnetic field magnitude (T)
        """
        # Convert Cartesian to cylindrical position
        R = np.sqrt(x**2 + y**2)
        phi = np.arctan2(y, x)
        Z = z

        # Get cylindrical field components
        B_R, B_phi, B_Z, _ = self.compute_cylindrical_field(R, Z)

        # Convert to Cartesian
        _, _, _, B_x, B_y, B_z = self.cylindrical_to_cartesian(
            R, phi, Z, B_R, B_phi, B_Z
        )

        # Total field magnitude
        B_mag = np.sqrt(B_x**2 + B_y**2 + B_z**2)

        return B_x, B_y, B_z, B_mag


def create_example_circular_flux(R0=3.0, a=1.0, B0=5.0, nR=100, nZ=100):
    """
    Create an example circular poloidal flux function for testing.

    For circular flux surfaces: ψ ∝ r² where r = sqrt((R-R0)² + Z²)
    This is a simplified Solov'ev-type equilibrium.

    Parameters:
    -----------
    R0 : float
        Major radius (m)
    a : float
        Minor radius (m)
    B0 : float
        Characteristic field strength (T)
    nR, nZ : int
        Grid resolution

    Returns:
    --------
    R_grid, Z_grid : 2D arrays
        Position grids
    psi_grid : 2D array
        Poloidal flux in Weber
    """
    # Create grid
    R_min, R_max = R0 - 1.5*a, R0 + 1.5*a
    Z_min, Z_max = -1.5*a, 1.5*a

    R_1d = np.linspace(R_min, R_max, nR)
    Z_1d = np.linspace(Z_min, Z_max, nZ)
    R_grid, Z_grid = np.meshgrid(R_1d, Z_1d)

    # Calculate minor radius from magnetic axis
    r = np.sqrt((R_grid - R0)**2 + Z_grid**2)

    # Poloidal flux function (normalized to give reasonable field values)
    # ψ = (1/2) B0 a² (r/a)² for r < a (simplified)
    psi_grid = 0.5 * B0 * a**2 * (r/a)**2

    # Set flux to constant outside plasma edge
    psi_grid = np.where(r <= a, psi_grid, 0.5 * B0 * a**2)

    return R_grid, Z_grid, psi_grid


# Example usage
if __name__ == "__main__":
    print("Tokamak Magnetic Field Calculator")
    print("=" * 50)

    # Create example poloidal flux function (circular tokamak)
    R0 = 3.0      # Major radius (m)
    a = 1.0       # Minor radius (m)
    B_phi0 = 5.0  # On-axis toroidal field (T)

    print(f"\nTokamak parameters:")
    print(f"  Major radius R0 = {R0:.2f} m")
    print(f"  Minor radius a = {a:.2f} m")
    print(f"  On-axis toroidal field B_φ0 = {B_phi0:.2f} T")

    # Generate flux function
    R_grid, Z_grid, psi_grid = create_example_circular_flux(R0, a, B_phi0)

    # Initialize magnetic field calculator
    mag_field = TokamakMagneticField(R_grid, Z_grid, psi_grid, B_phi0, R0)

    # Test at a specific point
    print("\n" + "=" * 50)
    print("Example calculation at a test point:")
    print("=" * 50)

    # Test point in cylindrical coordinates
    R_test = 3.5  # m
    phi_test = np.pi / 4  # 45 degrees
    Z_test = 0.5  # m

    print(f"\nCylindrical coordinates:")
    print(f"  R = {R_test:.2f} m")
    print(f"  φ = {phi_test:.4f} rad ({np.degrees(phi_test):.1f}°)")
    print(f"  Z = {Z_test:.2f} m")

    # Compute cylindrical field
    B_R, B_phi, B_Z, B_pol = mag_field.compute_cylindrical_field(R_test, Z_test)

    print(f"\nCylindrical field components:")
    print(f"  B_R = {B_R:.4f} T")
    print(f"  B_φ = {B_phi:.4f} T")
    print(f"  B_Z = {B_Z:.4f} T")
    print(f"  B_pol = {B_pol:.4f} T")

    # Convert to Cartesian
    x_test = R_test * np.cos(phi_test)
    y_test = R_test * np.sin(phi_test)
    z_test = Z_test

    B_x, B_y, B_z, B_mag = mag_field.get_cartesian_field(x_test, y_test, z_test)

    print(f"\nCartesian coordinates:")
    print(f"  x = {x_test:.4f} m")
    print(f"  y = {y_test:.4f} m")
    print(f"  z = {z_test:.4f} m")

    print(f"\nCartesian field components:")
    print(f"  B_x = {B_x:.4f} T")
    print(f"  B_y = {B_y:.4f} T")
    print(f"  B_z = {B_z:.4f} T")
    print(f"  |B| = {B_mag:.4f} T")

    # Verify field magnitude is conserved
    B_mag_cyl = np.sqrt(B_R**2 + B_phi**2 + B_Z**2)
    print(f"\nVerification:")
    print(f"  |B| from cylindrical: {B_mag_cyl:.4f} T")
    print(f"  |B| from Cartesian:   {B_mag:.4f} T")
    print(f"  Difference: {abs(B_mag - B_mag_cyl):.2e} T")

    # Create visualization
    print("\n" + "=" * 50)
    print("Creating visualization...")
    print("=" * 50)

    fig = plt.figure(figsize=(18, 12))

    # Create subplot layout: 2x2 for main plots, plus 3D plot
    gs = fig.add_gridspec(2, 3, width_ratios=[1, 1, 1.2])
    axes = [
        fig.add_subplot(gs[0, 0]),
        fig.add_subplot(gs[0, 1]),
        fig.add_subplot(gs[1, 0]),
        fig.add_subplot(gs[1, 1]),
        fig.add_subplot(gs[:, 2], projection='3d')
    ]

    # Plot 1: Poloidal flux contours
    ax = axes[0]
    levels = np.linspace(psi_grid.min(), psi_grid.max(), 20)
    contour = ax.contour(R_grid, Z_grid, psi_grid, levels=levels, colors='blue')
    ax.clabel(contour, inline=True, fontsize=8)
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Poloidal Flux ψ(R,Z) [Wb]')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 2: Poloidal field magnitude
    ax = axes[1]
    R_plot = R_grid[::5, ::5]
    Z_plot = Z_grid[::5, ::5]
    B_R_plot, _, B_Z_plot, B_pol_plot = mag_field.compute_cylindrical_field(R_plot, Z_plot)

    contourf = ax.contourf(R_grid, Z_grid,
                           mag_field.compute_cylindrical_field(R_grid, Z_grid)[3],
                           levels=20, cmap='viridis')
    ax.quiver(R_plot, Z_plot, B_R_plot, B_Z_plot, alpha=0.6, color='white')
    plt.colorbar(contourf, ax=ax, label='B_pol (T)')
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Poloidal Field Magnitude and Direction')
    ax.set_aspect('equal')

    # Plot 3: Toroidal field
    ax = axes[2]
    B_phi_grid = mag_field.g0 / R_grid
    contourf = ax.contourf(R_grid, Z_grid, B_phi_grid, levels=20, cmap='plasma')
    plt.colorbar(contourf, ax=ax, label='B_φ (T)')
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Toroidal Field B_φ(R) = B_φ0·R_0/R')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 4: Total field magnitude
    ax = axes[3]
    B_R_grid, B_phi_grid, B_Z_grid, _ = mag_field.compute_cylindrical_field(R_grid, Z_grid)
    B_total_grid = np.sqrt(B_R_grid**2 + B_phi_grid**2 + B_Z_grid**2)
    contourf = ax.contourf(R_grid, Z_grid, B_total_grid, levels=20, cmap='hot')
    plt.colorbar(contourf, ax=ax, label='|B| (T)')
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Total Magnetic Field Magnitude')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 5: 3D helical magnetic field lines
    ax = axes[4]

    print("\nTracing helical field lines in 3D...")

    # Trace several field lines starting from different poloidal positions
    n_fieldlines = 6
    n_points = 1000  # Points along each field line
    toroidal_turns = 3  # Number of toroidal turns to trace

    # Starting positions (in poloidal plane)
    r_start_values = np.linspace(0.3, 0.9, n_fieldlines) * a  # Minor radius positions
    theta_start = np.linspace(0, 2*np.pi, n_fieldlines, endpoint=False)  # Poloidal angles

    colors = plt.cm.rainbow(np.linspace(0, 1, n_fieldlines))

    for i, (r_start, theta_s, color) in enumerate(zip(r_start_values, theta_start, colors)):
        # Initial position in cylindrical coordinates
        R_start = R0 + r_start * np.cos(theta_s)
        Z_start = r_start * np.sin(theta_s)
        phi_start = 0.0

        # Arrays to store field line
        phi_line = np.linspace(phi_start, phi_start + 2*np.pi*toroidal_turns, n_points)
        R_line = np.zeros(n_points)
        Z_line = np.zeros(n_points)

        R_line[0] = R_start
        Z_line[0] = Z_start

        # Trace field line using simple Euler method
        # ds = dl_phi / B_phi where dl is line element
        for j in range(1, n_points):
            dphi = phi_line[j] - phi_line[j-1]

            # Get field at current position
            B_R_curr, B_phi_curr, B_Z_curr, _ = mag_field.compute_cylindrical_field(
                R_line[j-1], Z_line[j-1]
            )

            # Avoid division by zero
            if abs(B_phi_curr) < 1e-10:
                break

            # Step along field line
            # dR/dphi = R * B_R / B_phi
            # dZ/dphi = R * B_Z / B_phi
            R_line[j] = R_line[j-1] + R_line[j-1] * (B_R_curr / B_phi_curr) * dphi
            Z_line[j] = Z_line[j-1] + R_line[j-1] * (B_Z_curr / B_phi_curr) * dphi

        # Convert to Cartesian for 3D plotting
        x_line = R_line * np.cos(phi_line)
        y_line = R_line * np.sin(phi_line)
        z_line = Z_line

        # Plot field line
        ax.plot(x_line, y_line, z_line, color=color, linewidth=1.5,
                label=f'r/a = {r_start/a:.2f}')

    # Add tokamak surface (simplified torus outline)
    # Outer surface at r = a
    theta_surface = np.linspace(0, 2*np.pi, 50)
    phi_surface = np.linspace(0, 2*np.pi, 50)
    theta_surf, phi_surf = np.meshgrid(theta_surface, phi_surface)

    R_surf = R0 + a * np.cos(theta_surf)
    Z_surf = a * np.sin(theta_surf)
    X_surf = R_surf * np.cos(phi_surf)
    Y_surf = R_surf * np.sin(phi_surf)

    ax.plot_surface(X_surf, Y_surf, Z_surf, alpha=0.1, color='gray')

    # Set labels and title
    ax.set_xlabel('X (m)')
    ax.set_ylabel('Y (m)')
    ax.set_zlabel('Z (m)')
    ax.set_title('3D Helical Magnetic Field Lines\n(Toroidal + Poloidal Fields)')

    # Set equal aspect ratio
    max_range = 1.5 * (R0 + a)
    ax.set_xlim([-max_range, max_range])
    ax.set_ylim([-max_range, max_range])
    ax.set_zlim([-1.5*a, 1.5*a])

    # Add legend
    ax.legend(loc='upper left', fontsize=8, framealpha=0.9)

    # Better viewing angle
    ax.view_init(elev=20, azim=45)

    plt.tight_layout()
    plt.savefig('tokamak_magnetic_field.png', dpi=150, bbox_inches='tight')
    print("\nVisualization saved as 'tokamak_magnetic_field.png'")

    print("\n" + "=" * 50)
    print("Calculation complete!")
    print("=" * 50)
