"""
Tokamak Magnetic Field Calculator with Psi-Based Boundaries

Calculates magnetic field in Cartesian coordinates and exports two plasma boundaries
defined by specific psi (flux) values.

References:
1. Y. J. Hu, "Notes on tokamak equilibrium"
   https://youjunhu.github.io/research_notes/tokamak_equilibrium_htlatex/tokamak_equilibrium.html
2. Freidberg, J.P. (2014), "Ideal MHD", Cambridge University Press
"""

import netCDF4
import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import RectBivariateSpline, interp1d


class TokamakMagneticField:
    """Calculate magnetic field in Cartesian coordinates."""

    def __init__(self, R_grid, Z_grid, psi_grid, B_phi0, R0):
        self.R_grid = R_grid
        self.Z_grid = Z_grid
        self.psi_grid = psi_grid
        self.B_phi0 = B_phi0
        self.R0 = R0
        self.g0 = B_phi0 * R0

        R_1d = R_grid[0, :]
        Z_1d = Z_grid[:, 0]
        self.psi_interp = RectBivariateSpline(Z_1d, R_1d, psi_grid)

    def compute_psi_derivatives(self, R, Z):
        dpsi_dR = self.psi_interp(Z, R, dx=0, dy=1, grid=False)
        dpsi_dZ = self.psi_interp(Z, R, dx=1, dy=0, grid=False)
        grad_psi_mag = np.sqrt(dpsi_dR**2 + dpsi_dZ**2)
        return dpsi_dR, dpsi_dZ, grad_psi_mag

    def compute_cylindrical_field(self, R, Z):
        dpsi_dR, dpsi_dZ, grad_psi_mag = self.compute_psi_derivatives(R, Z)
        B_R = dpsi_dZ / R
        B_Z = -dpsi_dR / R
        B_pol = grad_psi_mag / R
        B_phi = self.g0 / R
        return B_R, B_phi, B_Z, B_pol

    def get_cartesian_field(self, x, y, z):
        R = np.sqrt(x**2 + y**2)
        phi = np.arctan2(y, x)
        Z = z

        B_R, B_phi, B_Z, _ = self.compute_cylindrical_field(R, Z)

        B_x = B_R * np.cos(phi) - B_phi * np.sin(phi)
        B_y = B_R * np.sin(phi) + B_phi * np.cos(phi)
        B_z = B_Z

        B_mag = np.sqrt(B_x**2 + B_y**2 + B_z**2)

        return B_x, B_y, B_z, B_mag


# def create_example_circular_flux(R0=3.0, a=1.0, B0=5.0, nR=100, nZ=100):
#     R_min, R_max = R0 - 1.5*a, R0 + 1.5*a
#     Z_min, Z_max = -1.5*a, 1.5*a
#
#     R_1d = np.linspace(R_min, R_max, nR)
#     Z_1d = np.linspace(Z_min, Z_max, nZ)
#     R_grid, Z_grid = np.meshgrid(R_1d, Z_1d)
#
#     r = np.sqrt((R_grid - R0)**2 + Z_grid**2)
#     psi_grid = 0.5 * B0 * a**2 * (r/a)**2
#     psi_grid = np.where(r <= a, psi_grid, 0.5 * B0 * a**2)
#
#     return R_grid, Z_grid, psi_grid

def poloidal_flux_from_netCDF4():

    fp='reference_equilibrium.nc'
    nc = netCDF4.Dataset(fp)
    mg_Z = nc.groups['Magnetic_geometry'].variables['Z'][:]
    mg_R = nc.groups['Magnetic_geometry'].variables['R'][:]
    mg_psi = nc.groups['Magnetic_geometry'].variables['psi'][:]

    R, Z = np.meshgrid(mg_R, mg_Z)

    R_grid = R
    Z_grid = Z
    psi_grid = mg_psi

    return R_grid, Z_grid, psi_grid


if __name__ == "__main__":
    print("Tokamak Magnetic Field Calculator - Psi-Based Boundaries")
    print("=" * 60)

    # Tokamak parameters
    R0 = 0.9         # Major radius (m)
    a = 0.125          # Minor radius (m)
    B_phi0 = 0.9286  # On-axis toroidal field (T)

    # Magnetic axis offset (if your psi profile has axis at different location)
    R_axis_offset = 0.0  # Change to 2.0 if axis at R=1, want at R=3
    Z_axis_offset = 0.0

    print(f"\nTokamak parameters:")
    print(f"  Major radius R0 = {R0:.2f} m")
    print(f"  Minor radius a = {a:.2f} m")
    print(f"  On-axis toroidal field B_φ0 = {B_phi0:.2f} T")
    if R_axis_offset != 0.0 or Z_axis_offset != 0.0:
        print(f"\nMagnetic axis offset:")
        print(f"  R offset = {R_axis_offset:.3f} m")
        print(f"  Z offset = {Z_axis_offset:.3f} m")

    # Generate flux function
    R_grid, Z_grid, psi_grid = poloidal_flux_from_netCDF4()

    # Apply magnetic axis offset
    if R_axis_offset != 0.0 or Z_axis_offset != 0.0:
        print(f"  Applying offset to coordinate grids...")
        R_grid = R_grid + R_axis_offset
        Z_grid = Z_grid + Z_axis_offset
        R0 = R0 + R_axis_offset

    mag_field = TokamakMagneticField(R_grid, Z_grid, psi_grid, B_phi0, R0)

    # Export magnetic field data
    print("\n" + "=" * 60)
    print("Exporting magnetic field data...")
    print("=" * 60)

    R_range = (2.0, 4.0)
    Z_range = (-1.0, 1.0)
    phi_range = (0.0, np.pi/2)
    n_R, n_Z, n_phi = 20, 20, 10

    R_export = np.linspace(R_range[0], R_range[1], n_R)
    Z_export = np.linspace(Z_range[0], Z_range[1], n_Z)
    phi_export = np.linspace(phi_range[0], phi_range[1], n_phi)

    data_list = []
    for phi_val in phi_export:
        for Z_val in Z_export:
            for R_val in R_export:
                x_val = R_val * np.cos(phi_val)
                y_val = R_val * np.sin(phi_val)
                z_val = Z_val

                try:
                    B_x_val, B_y_val, B_z_val, _ = mag_field.get_cartesian_field(
                        x_val, y_val, z_val
                    )
                    psi_val = mag_field.psi_interp(Z_val, R_val, grid=False)
                    data_list.append([x_val, y_val, z_val, psi_val,
                                    B_x_val, B_y_val, B_z_val])
                except:
                    continue

    data_array = np.array(data_list)
    filename = 'magnetic_field_data.csv'
    np.savetxt(filename, data_array, delimiter=',',
               header="x(m),y(m),z(m),psi(Wb),Bx(T),By(T),Bz(T)", comments='')
    print(f"Field data exported: {filename} ({len(data_list)} points)")

    # Export plasma boundaries
    print("\n" + "=" * 60)
    print("Defining plasma boundaries from psi values...")
    print("=" * 60)

    # Define psi values for boundaries
    psi_separatrix = 0.0003633184655948718
    psi_axis = psi_grid.min()
    psi_edge = psi_grid.max()

    # X-point location (required for divertor boundary)
    # For circular tokamak, estimate X-point location
    # In real equilibria, find where |∇ψ| = 0 on separatrix
    x_point_R = R0  # Estimate
    x_point_Z = -a  # Bottom of plasma for lower single null

    print(f"\nX-point location (estimated/provided):")
    print(f"  R_X = {x_point_R:.4f} m")
    print(f"  Z_X = {x_point_Z:.4f} m")

    # Define boundary psi values
    flux_range = psi_separatrix - psi_axis
    # psi_inner = psi_axis + 0.85 * flux_range  # Core boundary
    # psi_outer_wall = psi_separatrix + 0.1 * flux_range  # Wall boundary (full contour)
    # psi_outer_div = psi_separatrix + 0.05 * flux_range  # Divertor boundary (below X-point)

    # Alternative: define as absolute psi values
    psi_inner = 0.03  # Wb
    psi_outer_wall = -0.02  # Wb
    psi_outer_div = 0.015  # Wb

    print(f"\nFlux values:")
    print(f"  ψ_axis = {psi_axis:.6f} Wb")
    print(f"  ψ_separatrix = {psi_separatrix:.6f} Wb")
    print(f"  ψ_edge = {psi_edge:.6f} Wb")
    print(f"\nBoundary psi values:")
    print(f"  ψ_inner = {psi_inner:.6f} Wb (core)")
    print(f"  ψ_outer_wall = {psi_outer_wall:.6f} Wb (wall)")
    print(f"  ψ_outer_div = {psi_outer_div:.6f} Wb (divertor region)")

    # Validate
    if psi_inner <= psi_axis or psi_inner >= psi_separatrix:
        print(f"Warning: psi_inner should be between axis and separatrix")
    if psi_outer_wall <= psi_separatrix or psi_outer_wall >= psi_edge:
        print(f"Warning: psi_outer_wall should be between separatrix and edge")
    if psi_outer_div <= psi_separatrix or psi_outer_div >= psi_edge:
        print(f"Warning: psi_outer_div should be between separatrix and edge")

    # Extract contours
    print("\nExtracting boundary contours...")

    # Number of points to use for each boundary (for resampling)
    n_points_boundary = 100  # Adjust this to control boundary resolution

    print(f"Boundary discretization: {n_points_boundary} points per contour")

    def extract_contour(psi_level):
        contour = plt.contour(R_grid, Z_grid, psi_grid, levels=[psi_level])
        contours = []
        if hasattr(contour, 'allsegs'):
            for level_segs in contour.allsegs:
                for seg in level_segs:
                    if len(seg) > 10:
                        contours.append(seg)
        else:
            for collection in contour.collections:
                for path in collection.get_paths():
                    if len(path.vertices) > 10:
                        contours.append(path.vertices)
        plt.close()
        return contours

    def resample_contour(R_contour, Z_contour, n_points):
        """
        Resample contour to have exactly n_points uniformly distributed.

        Parameters:
        -----------
        R_contour, Z_contour : arrays
            Original contour points
        n_points : int
            Desired number of points

        Returns:
        --------
        R_resampled, Z_resampled : arrays
            Resampled contour with n_points
        """
        # Calculate cumulative arc length along contour
        dR = np.diff(R_contour)
        dZ = np.diff(Z_contour)
        ds = np.sqrt(dR**2 + dZ**2)
        s = np.concatenate([[0], np.cumsum(ds)])

        # Create uniform arc length sampling
        s_uniform = np.linspace(0, s[-1], n_points, endpoint=False)

        # Interpolate to get uniform points
        R_resampled = np.interp(s_uniform, s, R_contour)
        Z_resampled = np.interp(s_uniform, s, Z_contour)

        return R_resampled, Z_resampled

    def filter_contour_by_region(contours, x_point_R, x_point_Z, region='below'):
        """
        Filter contour segments by region relative to X-point.

        Parameters:
        -----------
        contours : list of arrays
            List of contour segments
        x_point_R, x_point_Z : float
            X-point coordinates
        region : str
            'below' for divertor region (Z < Z_X)
            'above' for main plasma region (Z > Z_X)

        Returns:
        --------
        filtered_contours : list
            Contours in specified region
        """
        filtered = []
        for contour in contours:
            Z_vals = contour[:, 1]
            if region == 'below':
                # Keep contours mostly below X-point (divertor region)
                if np.mean(Z_vals) < x_point_Z:
                    filtered.append(contour)
            elif region == 'above':
                # Keep contours mostly above X-point (main plasma)
                if np.mean(Z_vals) > x_point_Z:
                    filtered.append(contour)
        return filtered

    contours_inner = extract_contour(psi_inner)
    contours_sep = extract_contour(psi_separatrix)
    contours_outer_wall = extract_contour(psi_outer_wall)
    contours_outer_div_all = extract_contour(psi_outer_div)

    # Filter divertor boundary to only include region below X-point
    contours_outer_div = filter_contour_by_region(
        contours_outer_div_all, x_point_R, x_point_Z, region='below'
    )

    # Filter wall boundary to only include region above X-point (optional)
    # contours_outer_wall = filter_contour_by_region(
    #     contours_outer_wall, x_point_R, x_point_Z, region='above'
    # )

    print(f"\nContours found:")
    print(f"  Inner: {len(contours_inner)} contour(s)")
    print(f"  Separatrix: {len(contours_sep)} contour(s)")
    print(f"  Outer (wall): {len(contours_outer_wall)} contour(s)")
    print(f"  Outer (divertor, below X-point): {len(contours_outer_div)} contour(s)")

    if not contours_inner:
        print(f"Warning: No contour at ψ_inner={psi_inner:.6f}")
    if not contours_sep:
        print(f"Warning: No contour at ψ_separatrix={psi_separatrix:.6f}")
    if not contours_outer_wall:
        print(f"Warning: No contour at ψ_outer_wall={psi_outer_wall:.6f}")
    if not contours_outer_div:
        print(f"Warning: No contour at ψ_outer_div={psi_outer_div:.6f} below X-point")

    if contours_inner and contours_outer_wall and contours_sep:
        # Get largest contours
        R_inner_raw = max(contours_inner, key=len)[:, 0]
        Z_inner_raw = max(contours_inner, key=len)[:, 1]

        R_outer_wall_raw = max(contours_outer_wall, key=len)[:, 0]
        Z_outer_wall_raw = max(contours_outer_wall, key=len)[:, 1]

        R_sep_raw = max(contours_sep, key=len)[:, 0]
        Z_sep_raw = max(contours_sep, key=len)[:, 1]

        # Resample to uniform number of points
        print(f"\nResampling contours to {n_points_boundary} points...")
        R_inner, Z_inner = resample_contour(R_inner_raw, Z_inner_raw, n_points_boundary)
        R_outer_wall, Z_outer_wall = resample_contour(R_outer_wall_raw, Z_outer_wall_raw,
                                                       n_points_boundary)
        R_sep, Z_sep = resample_contour(R_sep_raw, Z_sep_raw, n_points_boundary)

        # Get divertor boundary if it exists
        if contours_outer_div:
            R_outer_div_raw = max(contours_outer_div, key=len)[:, 0]
            Z_outer_div_raw = max(contours_outer_div, key=len)[:, 1]
            R_outer_div, Z_outer_div = resample_contour(R_outer_div_raw, Z_outer_div_raw,
                                                        n_points_boundary)
            has_divertor = True
        else:
            R_outer_div = np.array([])
            Z_outer_div = np.array([])
            has_divertor = False
            print("\nNote: No divertor boundary below X-point found")

        # Define wall bounding box (before clipping boundaries)
        R_wall_min = 0.69  # Minimum R coordinate of wall (m)
        R_wall_max = 1.25  # Maximum R coordinate of wall (m)
        Z_wall_min = -0.83  # Minimum Z coordinate of wall (m)
        Z_wall_max = 0.84   # Maximum Z coordinate of wall (m)

        print(f"\nTokamak wall bounding box:")
        print(f"  R: {R_wall_min:.2f} to {R_wall_max:.2f} m")
        print(f"  Z: {Z_wall_min:.2f} to {Z_wall_max:.2f} m")

        # Clip boundaries to stay within wall domain
        def clip_boundary_to_walls(R_bound, Z_bound, R_min, R_max, Z_min, Z_max):
            """
            Clip boundary points to stay within wall domain.
            Points outside walls are moved to wall boundaries.
            """
            R_clipped = np.clip(R_bound, R_min, R_max)
            Z_clipped = np.clip(Z_bound, Z_min, Z_max)

            # Count clipped points
            n_clipped_R = np.sum((R_bound < R_min) | (R_bound > R_max))
            n_clipped_Z = np.sum((Z_bound < Z_min) | (Z_bound > Z_max))

            return R_clipped, Z_clipped, n_clipped_R, n_clipped_Z

        print("\nClipping boundaries to wall domain...")

        R_inner, Z_inner, nR_i, nZ_i = clip_boundary_to_walls(
            R_inner, Z_inner, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max
        )
        if nR_i > 0 or nZ_i > 0:
            print(f"  Inner: clipped {nR_i + nZ_i} points to walls")

        R_outer_wall, Z_outer_wall, nR_ow, nZ_ow = clip_boundary_to_walls(
            R_outer_wall, Z_outer_wall, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max
        )
        if nR_ow > 0 or nZ_ow > 0:
            print(f"  Outer (wall): clipped {nR_ow + nZ_ow} points to walls")

        R_sep, Z_sep, nR_s, nZ_s = clip_boundary_to_walls(
            R_sep, Z_sep, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max
        )
        if nR_s > 0 or nZ_s > 0:
            print(f"  Separatrix: clipped {nR_s + nZ_s} points to walls")

        if has_divertor:
            R_outer_div, Z_outer_div, nR_od, nZ_od = clip_boundary_to_walls(
                R_outer_div, Z_outer_div, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max
            )
            if nR_od > 0 or nZ_od > 0:
                print(f"  Outer (divertor): clipped {nR_od + nZ_od} points to walls")

        print(f"\nFinal contour points:")
        print(f"  Inner: {len(R_inner)} points")
        print(f"  Separatrix: {len(R_sep)} points")
        print(f"  Outer (wall): {len(R_outer_wall)} points")
        if has_divertor:
            print(f"  Outer (divertor): {len(R_outer_div)} points")

        # Export boundaries
        print("\nExporting boundary files...")

        # Inner boundary (core)
        np.savetxt('plasma_boundary_inner_RZ.csv',
                   np.column_stack([R_inner, Z_inner]),
                   delimiter=',', header="R(m),Z(m)", comments='')

        np.savetxt('plasma_boundary_inner_xyz.csv',
                   np.column_stack([R_inner, np.zeros_like(R_inner), Z_inner]),
                   delimiter=',', header="x(m),y(m),z(m)", comments='')

        phi_angles = np.linspace(0, 2*np.pi, 36, endpoint=False)
        inner_3D = []
        for phi in phi_angles:
            for R_val, Z_val in zip(R_inner, Z_inner):
                inner_3D.append([R_val*np.cos(phi), R_val*np.sin(phi),
                               Z_val, phi, R_val, Z_val])

        np.savetxt('plasma_boundary_inner_3D.csv', np.array(inner_3D),
                   delimiter=',', header="x(m),y(m),z(m),phi(rad),R(m),Z(m)",
                   comments='')

        # Outer boundary - wall side
        np.savetxt('plasma_boundary_outer_wall_RZ.csv',
                   np.column_stack([R_outer_wall, Z_outer_wall]),
                   delimiter=',', header="R(m),Z(m)", comments='')

        np.savetxt('plasma_boundary_outer_wall_xyz.csv',
                   np.column_stack([R_outer_wall, np.zeros_like(R_outer_wall), Z_outer_wall]),
                   delimiter=',', header="x(m),y(m),z(m)", comments='')

        outer_wall_3D = []
        for phi in phi_angles:
            for R_val, Z_val in zip(R_outer_wall, Z_outer_wall):
                outer_wall_3D.append([R_val*np.cos(phi), R_val*np.sin(phi),
                               Z_val, phi, R_val, Z_val])

        np.savetxt('plasma_boundary_outer_wall_3D.csv', np.array(outer_wall_3D),
                   delimiter=',', header="x(m),y(m),z(m),phi(rad),R(m),Z(m)",
                   comments='')

        # Outer boundary - divertor side
        if has_divertor:
            np.savetxt('plasma_boundary_outer_div_RZ.csv',
                       np.column_stack([R_outer_div, Z_outer_div]),
                       delimiter=',', header="R(m),Z(m)", comments='')

            np.savetxt('plasma_boundary_outer_div_xyz.csv',
                       np.column_stack([R_outer_div, np.zeros_like(R_outer_div), Z_outer_div]),
                       delimiter=',', header="x(m),y(m),z(m)", comments='')

            outer_div_3D = []
            for phi in phi_angles:
                for R_val, Z_val in zip(R_outer_div, Z_outer_div):
                    outer_div_3D.append([R_val*np.cos(phi), R_val*np.sin(phi),
                                   Z_val, phi, R_val, Z_val])

            np.savetxt('plasma_boundary_outer_div_3D.csv', np.array(outer_div_3D),
                       delimiter=',', header="x(m),y(m),z(m),phi(rad),R(m),Z(m)",
                       comments='')

            print("  Outer boundary (divertor) files created")
        else:
            print("  Outer boundary (divertor) - skipped (no contour below X-point)")

        # Statistics
        print("\nBoundary statistics:")
        print(f"  Inner boundary (core):")
        print(f"    R: {R_inner.min():.4f} to {R_inner.max():.4f} m")
        print(f"    Z: {Z_inner.min():.4f} to {Z_inner.max():.4f} m")
        print(f"  Outer boundary (wall):")
        print(f"    R: {R_outer_wall.min():.4f} to {R_outer_wall.max():.4f} m")
        print(f"    Z: {Z_outer_wall.min():.4f} to {Z_outer_wall.max():.4f} m")
        if has_divertor:
            print(f"  Outer boundary (divertor, below X-point):")
            print(f"    R: {R_outer_div.min():.4f} to {R_outer_div.max():.4f} m")
            print(f"    Z: {Z_outer_div.min():.4f} to {Z_outer_div.max():.4f} m")

        # Visualization
        print("\nCreating visualization...")
        fig, axes = plt.subplots(1, 2, figsize=(14, 6))

        # Poloidal plane
        ax = axes[0]
        levels = np.linspace(psi_grid.min(), psi_grid.max(), 20)
        ax.contour(R_grid, Z_grid, psi_grid, levels=levels,
                  colors='lightblue', alpha=0.3)
        ax.plot(R_inner, Z_inner, 'b-', linewidth=2.5,
               label=f'Inner (ψ={psi_inner:.4f} Wb)')
        ax.plot(R_sep, Z_sep, 'g--', linewidth=2,
               label=f'Separatrix (ψ={psi_separatrix:.4f} Wb)')
        ax.plot(R_outer_wall, Z_outer_wall, 'r-', linewidth=2.5,
               label=f'Outer-Wall (ψ={psi_outer_wall:.4f} Wb)')
        if has_divertor:
            ax.plot(R_outer_div, Z_outer_div, 'm-', linewidth=2.5,
                   label=f'Outer-Div (ψ={psi_outer_div:.4f} Wb, below X-point)')

        # Mark X-point
        ax.plot(x_point_R, x_point_Z, 'kx', markersize=12, markeredgewidth=3,
               label='X-point')

        ax.set_xlabel('R (m)', fontsize=12)
        ax.set_ylabel('Z (m)', fontsize=12)
        ax.set_title('Plasma Boundaries', fontsize=14)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=9)

        # 3D view
        ax = fig.add_subplot(122, projection='3d')

        theta = np.linspace(0, 2*np.pi, max(len(R_inner), len(R_outer_wall), len(R_outer_div)))
        phi = np.linspace(0, 2*np.pi, 30)
        theta_mesh, phi_mesh = np.meshgrid(theta, phi)

        # Inner surface
        R_interp_i = interp1d(np.linspace(0, 2*np.pi, len(R_inner)), R_inner,
                             kind='linear', fill_value='extrapolate')
        Z_interp_i = interp1d(np.linspace(0, 2*np.pi, len(Z_inner)), Z_inner,
                             kind='linear', fill_value='extrapolate')
        R_surf_i = R_interp_i(theta_mesh)
        Z_surf_i = Z_interp_i(theta_mesh)
        ax.plot_surface(R_surf_i * np.cos(phi_mesh),
                       R_surf_i * np.sin(phi_mesh),
                       Z_surf_i, alpha=0.3, color='blue', label='Inner')

        # Outer surface - wall
        R_interp_w = interp1d(np.linspace(0, 2*np.pi, len(R_outer_wall)), R_outer_wall,
                             kind='linear', fill_value='extrapolate')
        Z_interp_w = interp1d(np.linspace(0, 2*np.pi, len(Z_outer_wall)), Z_outer_wall,
                             kind='linear', fill_value='extrapolate')
        R_surf_w = R_interp_w(theta_mesh)
        Z_surf_w = Z_interp_w(theta_mesh)
        ax.plot_surface(R_surf_w * np.cos(phi_mesh),
                       R_surf_w * np.sin(phi_mesh),
                       Z_surf_w, alpha=0.3, color='red', label='Outer-Wall')

        # Outer surface - divertor (only if exists)
        if has_divertor:
            R_interp_d = interp1d(np.linspace(0, 2*np.pi, len(R_outer_div)), R_outer_div,
                                 kind='linear', fill_value='extrapolate')
            Z_interp_d = interp1d(np.linspace(0, 2*np.pi, len(Z_outer_div)), Z_outer_div,
                                 kind='linear', fill_value='extrapolate')
            R_surf_d = R_interp_d(theta_mesh)
            Z_surf_d = Z_interp_d(theta_mesh)
            ax.plot_surface(R_surf_d * np.cos(phi_mesh),
                           R_surf_d * np.sin(phi_mesh),
                           Z_surf_d, alpha=0.3, color='magenta', label='Outer-Div')

        # Mark X-point in 3D
        ax.scatter([x_point_R], [0], [x_point_Z], color='black', s=100,
                  marker='x', linewidths=3, label='X-point')

        ax.set_xlabel('X (m)')
        ax.set_ylabel('Y (m)')
        ax.set_zlabel('Z (m)')
        ax.set_title('3D Plasma Boundaries')
        ax.view_init(elev=20, azim=45)

        plt.tight_layout()
        plt.savefig('plasma_boundaries.png', dpi=150, bbox_inches='tight')
        print("Visualization saved: plasma_boundaries.png")
        plt.close()
    else:
        print("\nError: Could not find all required contours")

    print("\n" + "=" * 60)
    print("All exports complete!")
    print("=" * 60)
    print("\nFiles created:")
    print(f"  Magnetic field data:")
    print(f"    1. {filename}")
    if contours_inner and contours_outer_wall and contours_sep:
        print(f"  Inner boundary (core):")
        print(f"    2. plasma_boundary_inner_RZ.csv")
        print(f"    3. plasma_boundary_inner_xyz.csv")
        print(f"    4. plasma_boundary_inner_3D.csv")
        print(f"  Outer boundary (wall):")
        print(f"    5. plasma_boundary_outer_wall_RZ.csv")
        print(f"    6. plasma_boundary_outer_wall_xyz.csv")
        print(f"    7. plasma_boundary_outer_wall_3D.csv")
        if has_divertor:
            print(f"  Outer boundary (divertor, below X-point):")
            print(f"    8. plasma_boundary_outer_div_RZ.csv")
            print(f"    9. plasma_boundary_outer_div_xyz.csv")
            print(f"    10. plasma_boundary_outer_div_3D.csv")
            print(f"  Visualization:")
            print(f"    11. plasma_boundaries.png")
        else:
            print(f"  Visualization:")
            print(f"    8. plasma_boundaries.png")

        # =====================================================================
        # Generate Gmsh geometry file
        # =====================================================================
        print("\n" + "=" * 60)
        print("Generating Gmsh geometry file...")
        print("=" * 60)

        # Wall bounding box already defined above
        print(f"\nUsing wall bounding box:")
        print(f"  R: {R_wall_min:.2f} to {R_wall_max:.2f} m")
        print(f"  Z: {Z_wall_min:.2f} to {Z_wall_max:.2f} m")

        # Mesh parameters
        lc_boundary = 0.05  # Characteristic length at plasma boundaries (m)
        lc_wall = 0.2       # Characteristic length at walls (m)

        print(f"\nMesh parameters:")
        print(f"  Characteristic length at boundaries: {lc_boundary:.3f} m")
        print(f"  Characteristic length at walls: {lc_wall:.3f} m")

        # Generate Gmsh .geo file
        geo_filename = 'tokamak_mesh.geo'

        with open(geo_filename, 'w') as f:
            f.write("// Tokamak geometry for Gmsh\n")
            f.write("// Generated by Tokamak Magnetic Field Calculator\n")
            f.write("//\n")
            f.write("// Boundaries defined by poloidal flux surfaces\n")
            f.write(f"// Inner boundary: psi = {psi_inner:.6f} Wb\n")
            f.write(f"// Separatrix: psi = {psi_separatrix:.6f} Wb\n")
            f.write(f"// Outer (wall): psi = {psi_outer_wall:.6f} Wb\n")
            if has_divertor:
                f.write(f"// Outer (divertor): psi = {psi_outer_div:.6f} Wb\n")
            f.write("//\n\n")

            f.write("// Mesh characteristic lengths\n")
            f.write(f"lc_boundary = {lc_boundary};\n")
            f.write(f"lc_wall = {lc_wall};\n\n")

            # Write points for bounding box (walls)
            f.write("// Tokamak wall bounding box\n")
            point_id = 1

            # Wall corners
            wall_corners = [
                (R_wall_min, Z_wall_min),
                (R_wall_max, Z_wall_min),
                (R_wall_max, Z_wall_max),
                (R_wall_min, Z_wall_max)
            ]

            wall_point_ids = []
            for R, Z in wall_corners:
                f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_wall}};\n")
                wall_point_ids.append(point_id)
                point_id += 1

            f.write("\n// Wall boundary lines\n")
            line_id = 1
            wall_line_ids = []
            for i in range(4):
                p1 = wall_point_ids[i]
                p2 = wall_point_ids[(i+1) % 4]
                f.write(f"Line({line_id}) = {{{p1}, {p2}}};\n")
                wall_line_ids.append(line_id)
                line_id += 1

            # Write points for inner boundary
            f.write("\n// Inner plasma boundary (core)\n")
            inner_point_ids = []
            for R, Z in zip(R_inner, Z_inner):
                f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_boundary}};\n")
                inner_point_ids.append(point_id)
                point_id += 1

            f.write("\n// Inner boundary spline\n")
            inner_point_ids_closed = inner_point_ids + [inner_point_ids[0]]
            f.write(f"Spline({line_id}) = {{{', '.join(map(str, inner_point_ids_closed))}}};\n")
            inner_loop_id = line_id
            line_id += 1

            # Write points for outer wall boundary
            f.write("\n// Outer plasma boundary (wall)\n")
            outer_wall_point_ids = []
            for R, Z in zip(R_outer_wall, Z_outer_wall):
                f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_boundary}};\n")
                outer_wall_point_ids.append(point_id)
                point_id += 1

            f.write("\n// Outer wall boundary spline\n")
            outer_wall_point_ids_closed = outer_wall_point_ids + [outer_wall_point_ids[0]]
            f.write(f"Spline({line_id}) = {{{', '.join(map(str, outer_wall_point_ids_closed))}}};\n")
            outer_wall_loop_id = line_id
            line_id += 1

            # Write points for outer divertor boundary (if exists)
            if has_divertor:
                f.write("\n// Outer plasma boundary (divertor, below X-point)\n")
                outer_div_point_ids = []
                for R, Z in zip(R_outer_div, Z_outer_div):
                    f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_boundary}};\n")
                    outer_div_point_ids.append(point_id)
                    point_id += 1

                f.write("\n// Outer divertor boundary spline\n")
                outer_div_point_ids_closed = outer_div_point_ids + [outer_div_point_ids[0]]
                f.write(f"Spline({line_id}) = {{{', '.join(map(str, outer_div_point_ids_closed))}}};\n")
                outer_div_loop_id = line_id
                line_id += 1

            # Create curve loops and surfaces
            f.write("\n// Curve loops\n")
            f.write(f"Curve Loop(1) = {{{', '.join(map(str, wall_line_ids))}}};\n")
            f.write(f"Curve Loop(2) = {{-{outer_wall_loop_id}}};\n")  # Negative for hole
            f.write(f"Curve Loop(3) = {{-{inner_loop_id}}};\n")

            surface_id = 1

            # Region 1: Between wall and outer plasma boundary
            f.write("\n// Surfaces\n")
            f.write(f"Plane Surface({surface_id}) = {{1, 2}}; // Wall to outer boundary\n")
            surface_id += 1

            # Region 2: Between outer and inner plasma boundaries
            f.write(f"Plane Surface({surface_id}) = {{2, 3}}; // Outer to inner boundary\n")
            surface_id += 1

            # Physical groups for boundary conditions
            f.write("\n// Physical groups\n")
            phys_id = 1

            f.write(f"Physical Curve(\"wall\", {phys_id}) = {{{', '.join(map(str, wall_line_ids))}}};\n")
            phys_id += 1

            f.write(f"Physical Curve(\"inner_boundary\", {phys_id}) = {{{inner_loop_id}}};\n")
            phys_id += 1

            f.write(f"Physical Curve(\"outer_wall_boundary\", {phys_id}) = {{{outer_wall_loop_id}}};\n")
            phys_id += 1

            if has_divertor:
                f.write(f"Physical Curve(\"outer_div_boundary\", {phys_id}) = {{{outer_div_loop_id}}};\n")
                phys_id += 1

            f.write(f"\nPhysical Surface(\"SOL\", 1) = {{1}}; // Scrape-off layer\n")
            f.write(f"Physical Surface(\"core\", 2) = {{2}}; // Core plasma\n")

            f.write("\n// Mesh options\n")
            f.write("Mesh.Algorithm = 6; // Frontal-Delaunay\n")
            f.write("Mesh.CharacteristicLengthExtendFromBoundary = 1;\n")

        print(f"\nGmsh geometry file created: {geo_filename}")
        print(f"\nTo generate mesh, run:")
        print(f"  gmsh {geo_filename} -2 -format msh2")
        print(f"\nPhysical groups defined:")
        print(f"  Curves: wall, inner_boundary, outer_wall_boundary", end="")
        if has_divertor:
            print(f", outer_div_boundary")
        else:
            print()
        print(f"  Surfaces: SOL (scrape-off layer), core (core plasma)")

        print("\n" + "=" * 60)
        print("Gmsh export complete!")
        print("=" * 60)
