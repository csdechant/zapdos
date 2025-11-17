"""
Tokamak Magnetic Field Calculator with Psi-Based Boundaries

Calculates magnetic field in Cartesian coordinates and exports plasma boundaries
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


def poloidal_flux_from_netCDF4():
    fp='reference_equilibrium.nc'
    nc = netCDF4.Dataset(fp)
    mg_Z = nc.groups['Magnetic_geometry'].variables['Z'][:]
    mg_R = nc.groups['Magnetic_geometry'].variables['R'][:]
    mg_psi = nc.groups['Magnetic_geometry'].variables['psi'][:]
    R, Z = np.meshgrid(mg_R, mg_Z)
    return R, Z, mg_psi


def extract_contour(R_grid, Z_grid, psi_grid, psi_level):
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
    dR = np.diff(R_contour)
    dZ = np.diff(Z_contour)
    ds = np.sqrt(dR**2 + dZ**2)
    s = np.concatenate([[0], np.cumsum(ds)])
    s_uniform = np.linspace(0, s[-1], n_points, endpoint=False)
    R_resampled = np.interp(s_uniform, s, R_contour)
    Z_resampled = np.interp(s_uniform, s, Z_contour)
    return R_resampled, Z_resampled


def filter_contour_by_region(contours, x_point_R, x_point_Z, region='below'):
    filtered = []
    for contour in contours:
        Z_vals = contour[:, 1]
        if region == 'below' and np.mean(Z_vals) < x_point_Z:
            filtered.append(contour)
        elif region == 'above' and np.mean(Z_vals) > x_point_Z:
            filtered.append(contour)
    return filtered


def clip_boundary_to_walls(R_bound, Z_bound, R_min, R_max, Z_min, Z_max):
    """
    Keep all points inside walls and add intersection points at wall crossings.
    Creates segments with endpoints on walls where boundary crosses.
    """
    inside_R = (R_bound >= R_min) & (R_bound <= R_max)
    inside_Z = (Z_bound >= Z_min) & (Z_bound <= Z_max)
    inside = inside_R & inside_Z

    if np.all(inside):
        # All points inside
        return R_bound, Z_bound, 0

    # Build new boundary with wall intersection points
    R_new = []
    Z_new = []
    n_removed = 0

    for i in range(len(R_bound)):
        if inside[i]:
            # Point is inside - add it
            R_new.append(R_bound[i])
            Z_new.append(Z_bound[i])

            # Check if next point is outside (crossing out)
            if i < len(R_bound) - 1 and not inside[i+1]:
                # Add intersection point where we exit
                R_in, Z_in = R_bound[i], Z_bound[i]
                R_out, Z_out = R_bound[i+1], Z_bound[i+1]
                R_int, Z_int = compute_wall_intersection(R_in, Z_in, R_out, Z_out,
                                                         R_min, R_max, Z_min, Z_max)
                R_new.append(R_int)
                Z_new.append(Z_int)
        else:
            # Point is outside
            n_removed += 1

            # Check if next point is inside (crossing in)
            if i < len(R_bound) - 1 and inside[i+1]:
                # Add intersection point where we enter
                R_out, Z_out = R_bound[i], Z_bound[i]
                R_in, Z_in = R_bound[i+1], Z_bound[i+1]
                R_int, Z_int = compute_wall_intersection(R_in, Z_in, R_out, Z_out,
                                                         R_min, R_max, Z_min, Z_max)
                R_new.append(R_int)
                Z_new.append(Z_int)

    return np.array(R_new), np.array(Z_new), n_removed


def compute_wall_intersection(R_in, Z_in, R_out, Z_out, R_min, R_max, Z_min, Z_max):
    """
    Compute intersection point between segment (R_in, Z_in) -> (R_out, Z_out) and wall.
    """
    R_int, Z_int = R_out, Z_out

    # Check R boundaries
    if R_out < R_min:
        t = (R_min - R_in) / (R_out - R_in + 1e-10)
        R_int = R_min
        Z_int = Z_in + t * (Z_out - Z_in)
    elif R_out > R_max:
        t = (R_max - R_in) / (R_out - R_in + 1e-10)
        R_int = R_max
        Z_int = Z_in + t * (Z_out - Z_in)

    # Check Z boundaries
    if Z_out < Z_min:
        t = (Z_min - Z_in) / (Z_out - Z_in + 1e-10)
        Z_int = Z_min
        R_int = R_in + t * (R_out - R_in)
    elif Z_out > Z_max:
        t = (Z_max - Z_in) / (Z_out - Z_in + 1e-10)
        Z_int = Z_max
        R_int = R_in + t * (R_out - R_in)

    # Ensure within bounds
    R_int = np.clip(R_int, R_min, R_max)
    Z_int = np.clip(Z_int, Z_min, Z_max)

    return R_int, Z_int


if __name__ == "__main__":
    print("Tokamak Magnetic Field Calculator")
    print("=" * 60)

    # Parameters
    R0 = 0.9
    a = 0.125
    B_phi0 = 0.9286
    R_axis_offset = 0.0
    Z_axis_offset = 0.0

    print(f"\nParameters: R0={R0:.2f}m, a={a:.3f}m, B_φ0={B_phi0:.4f}T")

    # Load data
    R_grid, Z_grid, psi_grid = poloidal_flux_from_netCDF4()

    if R_axis_offset != 0.0 or Z_axis_offset != 0.0:
        R_grid = R_grid + R_axis_offset
        Z_grid = Z_grid + Z_axis_offset
        R0 = R0 + R_axis_offset

    mag_field = TokamakMagneticField(R_grid, Z_grid, psi_grid, B_phi0, R0)

    # Export field data
    print("\n" + "=" * 60)
    print("Exporting magnetic field data...")
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
                    B_x_val, B_y_val, B_z_val, _ = mag_field.get_cartesian_field(x_val, y_val, z_val)
                    psi_val = mag_field.psi_interp(Z_val, R_val, grid=False)
                    data_list.append([x_val, y_val, z_val, psi_val, B_x_val, B_y_val, B_z_val])
                except:
                    continue

    np.savetxt('magnetic_field_data.csv', np.array(data_list), delimiter=',',
               header="x(m),y(m),z(m),psi(Wb),Bx(T),By(T),Bz(T)", comments='')
    print(f"Exported: magnetic_field_data.csv ({len(data_list)} points)")

    # Define boundaries
    print("\n" + "=" * 60)
    print("Defining plasma boundaries...")

    psi_separatrix = 0.0003633184655948718
    psi_axis = psi_grid.min()
    x_point_R = R0
    x_point_Z = -a

    psi_inner = 0.03
    psi_outer_wall = -0.02
    psi_outer_div = 0.015

    n_points_inner = 100
    n_points_outer = 100
    n_points_sep = 20

    print(f"ψ_axis={psi_axis:.6f}, ψ_sep={psi_separatrix:.6f}")
    print(f"ψ_inner={psi_inner:.6f}, ψ_outer_wall={psi_outer_wall:.6f}, ψ_outer_div={psi_outer_div:.6f}")

    # Extract contours
    contours_inner = extract_contour(R_grid, Z_grid, psi_grid, psi_inner)
    contours_sep = extract_contour(R_grid, Z_grid, psi_grid, psi_separatrix)
    contours_outer_wall = extract_contour(R_grid, Z_grid, psi_grid, psi_outer_wall)
    contours_outer_div_all = extract_contour(R_grid, Z_grid, psi_grid, psi_outer_div)
    contours_outer_div = filter_contour_by_region(contours_outer_div_all, x_point_R, x_point_Z, 'below')

    print(f"\nFound: Inner={len(contours_inner)}, Sep={len(contours_sep)}, Wall={len(contours_outer_wall)}, Div={len(contours_outer_div)}")

    if contours_inner and contours_outer_wall and contours_sep:
        # Resample
        R_inner, Z_inner = resample_contour(max(contours_inner, key=len)[:, 0],
                                           max(contours_inner, key=len)[:, 1], n_points_inner)
        R_outer_wall, Z_outer_wall = resample_contour(max(contours_outer_wall, key=len)[:, 0],
                                                      max(contours_outer_wall, key=len)[:, 1], n_points_outer)
        R_sep, Z_sep = resample_contour(max(contours_sep, key=len)[:, 0],
                                       max(contours_sep, key=len)[:, 1], n_points_sep)

        has_divertor = False
        if contours_outer_div:
            R_outer_div, Z_outer_div = resample_contour(max(contours_outer_div, key=len)[:, 0],
                                                        max(contours_outer_div, key=len)[:, 1], n_points_sep)
            has_divertor = True
        else:
            R_outer_div, Z_outer_div = np.array([]), np.array([])

        # Wall bounds
        R_wall_min, R_wall_max = 0.69, 1.25
        Z_wall_min, Z_wall_max = -0.83, 0.84

        print(f"\nWall: R=[{R_wall_min:.2f}, {R_wall_max:.2f}], Z=[{Z_wall_min:.2f}, {Z_wall_max:.2f}]")

        # Clip with intersection points
        print("\nClipping to walls (adding intersection points)...")
        R_inner, Z_inner, n_i = clip_boundary_to_walls(R_inner, Z_inner, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)
        R_outer_wall, Z_outer_wall, n_ow = clip_boundary_to_walls(R_outer_wall, Z_outer_wall, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)
        R_sep, Z_sep, n_s = clip_boundary_to_walls(R_sep, Z_sep, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)

        if n_i > 0:
            print(f"  Inner: {n_i} removed, added wall intersection")
        if n_ow > 0:
            print(f"  Outer (wall): {n_ow} removed, added wall intersection")
        if n_s > 0:
            print(f"  Separatrix: {n_s} removed, added wall intersection")

        if has_divertor:
            R_outer_div, Z_outer_div, n_od = clip_boundary_to_walls(R_outer_div, Z_outer_div, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)
            if n_od > 0:
                print(f"  Outer (divertor): {n_od} removed, added wall intersection")
            if len(R_outer_div) == 0:
                has_divertor = False

        print(f"\nFinal: Inner={len(R_inner)}, Wall={len(R_outer_wall)}, Div={len(R_outer_div) if has_divertor else 0}")

        # Export
        if len(R_inner) > 0:
            np.savetxt('plasma_boundary_inner_RZ.csv', np.column_stack([R_inner, Z_inner]),
                      delimiter=',', header="R(m),Z(m)", comments='')
        if len(R_outer_wall) > 0:
            np.savetxt('plasma_boundary_outer_wall_RZ.csv', np.column_stack([R_outer_wall, Z_outer_wall]),
                      delimiter=',', header="R(m),Z(m)", comments='')
        if has_divertor and len(R_outer_div) > 0:
            np.savetxt('plasma_boundary_outer_div_RZ.csv', np.column_stack([R_outer_div, Z_outer_div]),
                      delimiter=',', header="R(m),Z(m)", comments='')

        # Visualization
        fig, ax = plt.subplots(1, 1, figsize=(10, 8))
        levels = np.linspace(psi_grid.min(), psi_grid.max(), 20)
        ax.contour(R_grid, Z_grid, psi_grid, levels=levels, colors='lightblue', alpha=0.3)

        if len(R_inner) > 0:
            ax.plot(R_inner, Z_inner, 'b-', linewidth=2.5, label='Inner')
        if len(R_sep) > 0:
            ax.plot(R_sep, Z_sep, 'g--', linewidth=2, label='Separatrix')
        if len(R_outer_wall) > 0:
            ax.plot(R_outer_wall, Z_outer_wall, 'r-', linewidth=2.5, label='Outer-Wall')
        if has_divertor and len(R_outer_div) > 0:
            ax.plot(R_outer_div, Z_outer_div, 'm-', linewidth=2.5, label='Outer-Div')

        ax.plot(x_point_R, x_point_Z, 'kx', markersize=12, markeredgewidth=3, label='X-point')
        wall_rect = plt.Rectangle((R_wall_min, Z_wall_min), R_wall_max - R_wall_min,
                                  Z_wall_max - Z_wall_min, fill=False, edgecolor='black',
                                  linewidth=2, linestyle=':', label='Wall')
        ax.add_patch(wall_rect)
        ax.set_xlabel('R (m)')
        ax.set_ylabel('Z (m)')
        ax.set_title('Plasma Boundaries')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=9)
        plt.savefig('plasma_boundaries.png', dpi=150)
        plt.close()
        print("\nVisualization: plasma_boundaries.png")

        # Gmsh file
        print("\n" + "=" * 60)
        print("Generating Gmsh file...")

        geo_filename = 'tokamak_mesh.geo'
        lc_boundary = 0.05

        with open(geo_filename, 'w') as f:
            f.write("// Tokamak Gmsh Geometry - Plasma Boundaries Only\n")
            f.write("// Inner: CLOSED, Outer: OPEN splines\n\n")
            f.write(f"lc_boundary = {lc_boundary};\n\n")

            point_id = 1
            line_id = 1

            # Inner boundary - CLOSED
            has_inner = len(R_inner) > 0
            if has_inner:
                f.write("// Inner boundary - CLOSED\n")
                inner_pt_ids = []
                for R, Z in zip(R_inner, Z_inner):
                    f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_boundary}};\n")
                    inner_pt_ids.append(point_id)
                    point_id += 1

                inner_closed = inner_pt_ids + [inner_pt_ids[0]]
                f.write(f"Spline({line_id}) = {{{', '.join(map(str, inner_closed))}}};\n")
                inner_loop_id = line_id
                line_id += 1

            # Outer wall - OPEN
            has_outer_wall = len(R_outer_wall) > 0
            if has_outer_wall:
                f.write("\n// Outer wall boundary - OPEN\n")
                outer_wall_pt_ids = []
                for R, Z in zip(R_outer_wall, Z_outer_wall):
                    f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_boundary}};\n")
                    outer_wall_pt_ids.append(point_id)
                    point_id += 1

                # OPEN - no closing
                f.write(f"Spline({line_id}) = {{{', '.join(map(str, outer_wall_pt_ids))}}};\n")
                outer_wall_spline_id = line_id
                line_id += 1

            # Outer divertor - OPEN
            has_outer_div = has_divertor and len(R_outer_div) > 0
            if has_outer_div:
                f.write("\n// Outer divertor boundary - OPEN\n")
                outer_div_pt_ids = []
                for R, Z in zip(R_outer_div, Z_outer_div):
                    f.write(f"Point({point_id}) = {{{R}, {Z}, 0, lc_boundary}};\n")
                    outer_div_pt_ids.append(point_id)
                    point_id += 1

                # OPEN - no closing
                f.write(f"Spline({line_id}) = {{{', '.join(map(str, outer_div_pt_ids))}}};\n")
                outer_div_spline_id = line_id
                line_id += 1

            # Physical groups (no curve loops or surfaces - just boundaries)
            f.write("\n// Physical groups\n")
            phys_id = 1

            if has_inner:
                f.write(f"Physical Curve(\"inner_boundary\", {phys_id}) = {{{inner_loop_id}}};\n")
                phys_id += 1
            if has_outer_wall:
                f.write(f"Physical Curve(\"outer_wall_boundary\", {phys_id}) = {{{outer_wall_spline_id}}};\n")
                phys_id += 1
            if has_outer_div:
                f.write(f"Physical Curve(\"outer_div_boundary\", {phys_id}) = {{{outer_div_spline_id}}};\n")
                phys_id += 1

            f.write("\n// Mesh options\n")
            f.write("Mesh.Algorithm = 6;\n")

        print(f"\nGmsh file: {geo_filename}")
        print(f"  Contains only plasma boundaries (no wall geometry)")
        print(f"  Inner: {'CLOSED spline' if has_inner else 'none'}")
        print(f"  Outer wall: {'OPEN spline' if has_outer_wall else 'none'}")
        print(f"  Outer div: {'OPEN spline' if has_outer_div else 'none'}")
        print(f"\nNote: Wall bounding box NOT included in .geo file")
        print(f"      Only plasma boundary curves are exported")
        print(f"\nTo view geometry: gmsh {geo_filename}")
        print("\n" + "=" * 60)
        print("Complete!")
        print("=" * 60)
