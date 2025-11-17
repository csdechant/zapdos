"""
Tokamak Magnetic Field Calculator - Complete Version

Includes:
- Magnetic field calculation in Cartesian coordinates
- Comprehensive magnetic field visualization (5 panels)
- Plasma boundary export with wall intersection
- Gmsh geometry file generation (boundaries only, no wall)

Made with Claude, Need to clean up.
"""

import netCDF4
import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import RectBivariateSpline, interp1d


class TokamakMagneticField:
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


def compute_wall_intersection(R_in, Z_in, R_out, Z_out, R_min, R_max, Z_min, Z_max):
    R_int, Z_int = R_out, Z_out
    if R_out < R_min:
        t = (R_min - R_in) / (R_out - R_in + 1e-10)
        R_int = R_min
        Z_int = Z_in + t * (Z_out - Z_in)
    elif R_out > R_max:
        t = (R_max - R_in) / (R_out - R_in + 1e-10)
        R_int = R_max
        Z_int = Z_in + t * (Z_out - Z_in)
    if Z_out < Z_min:
        t = (Z_min - Z_in) / (Z_out - Z_in + 1e-10)
        Z_int = Z_min
        R_int = R_in + t * (R_out - R_in)
    elif Z_out > Z_max:
        t = (Z_max - Z_in) / (Z_out - Z_in + 1e-10)
        Z_int = Z_max
        R_int = R_in + t * (R_out - R_in)
    R_int = np.clip(R_int, R_min, R_max)
    Z_int = np.clip(Z_int, Z_min, Z_max)
    return R_int, Z_int


def clip_boundary_to_walls(R_bound, Z_bound, R_min, R_max, Z_min, Z_max):
    inside_R = (R_bound >= R_min) & (R_bound <= R_max)
    inside_Z = (Z_bound >= Z_min) & (Z_bound <= Z_max)
    inside = inside_R & inside_Z

    R_new = []
    Z_new = []
    n_removed = 0

    for i in range(len(R_bound)):
        if inside[i]:
            R_new.append(R_bound[i])
            Z_new.append(Z_bound[i])
            if i < len(R_bound) - 1 and not inside[i+1]:
                R_int, Z_int = compute_wall_intersection(R_bound[i], Z_bound[i],
                                                         R_bound[i+1], Z_bound[i+1],
                                                         R_min, R_max, Z_min, Z_max)
                R_new.append(R_int)
                Z_new.append(Z_int)
        else:
            n_removed += 1
            if i < len(R_bound) - 1 and inside[i+1]:
                R_int, Z_int = compute_wall_intersection(R_bound[i+1], Z_bound[i+1],
                                                         R_bound[i], Z_bound[i],
                                                         R_min, R_max, Z_min, Z_max)
                R_new.append(R_int)
                Z_new.append(Z_int)

    return np.array(R_new), np.array(Z_new), n_removed


if __name__ == "__main__":
    print("Tokamak Magnetic Field Calculator")
    print("=" * 60)

    R0 = 0.9
    a = 0.2
    B_phi0 = 0.9286
    # R_axis_offset = (0.9083228005831631) - 1
    # Z_axis_offset = (-0.00789782087664592) - 0
    R_axis_offset = 0
    Z_axis_offset = 0

    print(f"\nParameters: R0={R0}m, a={a}m, B_φ0={B_phi0}T")

    R_grid, Z_grid, psi_grid = poloidal_flux_from_netCDF4()

    if R_axis_offset != 0.0 or Z_axis_offset != 0.0:
        R_grid += R_axis_offset
        Z_grid += Z_axis_offset
        R0 += R_axis_offset

    mag_field = TokamakMagneticField(R_grid, Z_grid, psi_grid, B_phi0, R0)

    # Export field data
    print("\n" + "=" * 60)
    print("Exporting magnetic field data...")

    # R_range = (0.7, 1.2)
    # Z_range = (-0.8, 0.8)
    # phi_range = (0.0, np.pi/2)
    # n_R, n_Z, n_phi = 20, 20, 10

    #R_wall_min, R_wall_max = 0.69, 1.25
    #Z_wall_min, Z_wall_max = -0.83, 0.84

    R_range = (0.6, 1.25)
    Z_range = (-0.9, 0.8)
    phi_range = (0.0, 2*np.pi)
    n_R, n_Z, n_phi = 80, 110, 24
    #n_R, n_Z, n_phi = 50, 50, 16

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
                    B_x, B_y, B_z, _ = mag_field.get_cartesian_field(x_val, y_val, z_val)
                    psi_val = mag_field.psi_interp(Z_val, R_val, grid=False)
                    data_list.append([x_val, y_val, z_val, psi_val, B_x, B_y, B_z])
                except:
                    continue

    np.savetxt('magnetic_field_data.csv', np.array(data_list), delimiter=',',
               header="x(m),y(m),z(m),psi(Wb),Bx(T),By(T),Bz(T)", comments='')
    print(f"Saved: magnetic_field_data.csv ({len(data_list)} points)")

    # Magnetic field visualization
    print("\n" + "=" * 60)
    print("Creating magnetic field visualization...")

    fig = plt.figure(figsize=(18, 12))
    gs = fig.add_gridspec(2, 3, width_ratios=[1, 1, 1.2])
    axes = [fig.add_subplot(gs[0, 0]), fig.add_subplot(gs[0, 1]),
            fig.add_subplot(gs[1, 0]), fig.add_subplot(gs[1, 1]),
            fig.add_subplot(gs[:, 2], projection='3d')]

    # Flux contours
    ax = axes[0]
    levels = np.linspace(psi_grid.min(), psi_grid.max(), 20)
    contour = ax.contour(R_grid, Z_grid, psi_grid, levels=levels, colors='blue')
    ax.clabel(contour, inline=True, fontsize=8)
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Poloidal Flux ψ(R,Z) [Wb]')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Poloidal field
    ax = axes[1]
    R_p = R_grid[::5, ::5]
    Z_p = Z_grid[::5, ::5]
    B_R_p, _, B_Z_p, B_pol_p = mag_field.compute_cylindrical_field(R_p, Z_p)
    B_pol_grid = mag_field.compute_cylindrical_field(R_grid, Z_grid)[3]
    cf = ax.contourf(R_grid, Z_grid, B_pol_grid, levels=20, cmap='viridis')
    ax.quiver(R_p, Z_p, B_R_p, B_Z_p, alpha=0.6, color='white')
    plt.colorbar(cf, ax=ax, label='B_pol (T)')
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Poloidal Field')
    ax.set_aspect('equal')

    # Toroidal field
    ax = axes[2]
    B_phi_grid = mag_field.g0 / R_grid
    cf = ax.contourf(R_grid, Z_grid, B_phi_grid, levels=20, cmap='plasma')
    plt.colorbar(cf, ax=ax, label='B_φ (T)')
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Toroidal Field')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Total field
    ax = axes[3]
    B_R_g, B_phi_g, B_Z_g, _ = mag_field.compute_cylindrical_field(R_grid, Z_grid)
    B_tot = np.sqrt(B_R_g**2 + B_phi_g**2 + B_Z_g**2)
    cf = ax.contourf(R_grid, Z_grid, B_tot, levels=20, cmap='hot')
    plt.colorbar(cf, ax=ax, label='|B| (T)')
    ax.set_xlabel('R (m)')
    ax.set_ylabel('Z (m)')
    ax.set_title('Total Field Magnitude')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # 3D helical field lines
    ax = axes[4]
    print("  Tracing 3D field lines...")

    n_lines = 6
    n_pts = 1000
    n_turns = 3
    r_starts = np.linspace(0.3, 0.9, n_lines) * a
    theta_starts = np.linspace(0, 2*np.pi, n_lines, endpoint=False)
    colors = plt.cm.rainbow(np.linspace(0, 1, n_lines))

    for r_s, th_s, col in zip(r_starts, theta_starts, colors):
        R_s = R0 + r_s * np.cos(th_s)
        Z_s = r_s * np.sin(th_s)
        x, y, z = R_s, 0.0, Z_s
        x_arr, y_arr, z_arr = [x], [y], [z]
        total_phi = 0

        for j in range(1, n_pts):
            try:
                Bx, By, Bz, Bmag = mag_field.get_cartesian_field(x, y, z)
            except:
                break
            if Bmag < 1e-10:
                break

            ds = 0.01
            x += (Bx/Bmag) * ds
            y += (By/Bmag) * ds
            z += (Bz/Bmag) * ds

            phi_curr = np.arctan2(y, x)
            phi_prev = np.arctan2(y_arr[-1], x_arr[-1])
            dphi = phi_curr - phi_prev
            if dphi < -np.pi:
                dphi += 2*np.pi
            elif dphi > np.pi:
                dphi -= 2*np.pi
            total_phi += dphi

            x_arr.append(x)
            y_arr.append(y)
            z_arr.append(z)

            if abs(total_phi) > 2*np.pi*n_turns:
                break

        ax.plot(x_arr, y_arr, z_arr, color=col, linewidth=1.5, label=f'r/a={r_s/a:.2f}')

    # Tokamak surface
    th = np.linspace(0, 2*np.pi, 50)
    ph = np.linspace(0, 2*np.pi, 50)
    th_m, ph_m = np.meshgrid(th, ph)
    R_s = R0 + a * np.cos(th_m)
    Z_s = a * np.sin(th_m)
    ax.plot_surface(R_s * np.cos(ph_m), R_s * np.sin(ph_m), Z_s, alpha=0.1, color='gray')

    ax.set_xlabel('X (m)')
    ax.set_ylabel('Y (m)')
    ax.set_zlabel('Z (m)')
    ax.set_title('3D Helical Field Lines')
    ax.legend(loc='upper left', fontsize=8)
    ax.view_init(elev=20, azim=45)

    max_r = 1.5 * (R0 + a)
    ax.set_xlim([-max_r, max_r])
    ax.set_ylim([-max_r, max_r])
    ax.set_zlim([-1.5*a, 1.5*a])

    plt.tight_layout()
    plt.savefig('tokamak_magnetic_field.png', dpi=150, bbox_inches='tight')
    print("Saved: tokamak_magnetic_field.png")
    plt.close()

    # Boundaries
    print("\n" + "=" * 60)
    print("Defining plasma boundaries...")

    psi_separatrix = 0.0003633184655948718
    psi_axis = psi_grid.min()
    x_point_R = R0
    x_point_Z = -a

    psi_inner = 0.03
    psi_outer_wall = -0.02
    psi_outer_div = 0.015

    n_points_inner = 50
    n_points_outer = 50
    n_points_sep = 100
    n_points_diverter = 15

    print(f"ψ_sep={psi_separatrix:.6f}, ψ_inner={psi_inner:.4f}, ψ_outer_wall={psi_outer_wall:.4f}")

    contours_inner = extract_contour(R_grid, Z_grid, psi_grid, psi_inner)
    contours_sep = extract_contour(R_grid, Z_grid, psi_grid, psi_separatrix)
    contours_outer_wall = extract_contour(R_grid, Z_grid, psi_grid, psi_outer_wall)
    contours_outer_div_all = extract_contour(R_grid, Z_grid, psi_grid, psi_outer_div)
    contours_outer_div = filter_contour_by_region(contours_outer_div_all, x_point_R, x_point_Z, 'below')

    if contours_inner and contours_outer_wall and contours_sep:
        R_inner, Z_inner = resample_contour(max(contours_inner, key=len)[:, 0],
                                           max(contours_inner, key=len)[:, 1], n_points_inner)
        R_outer_wall, Z_outer_wall = resample_contour(max(contours_outer_wall, key=len)[:, 0],
                                                      max(contours_outer_wall, key=len)[:, 1], n_points_outer)
        R_sep, Z_sep = resample_contour(max(contours_sep, key=len)[:, 0],
                                       max(contours_sep, key=len)[:, 1], n_points_sep)

        has_divertor = False
        if contours_outer_div:
            R_outer_div, Z_outer_div = resample_contour(max(contours_outer_div, key=len)[:, 0],
                                                        max(contours_outer_div, key=len)[:, 1], n_points_diverter)
            has_divertor = True
        else:
            R_outer_div, Z_outer_div = np.array([]), np.array([])

        # Wall bounds
        R_wall_min, R_wall_max = 0.69, 1.25
        Z_wall_min, Z_wall_max = -0.83, 0.84

        print(f"Wall: R=[{R_wall_min}, {R_wall_max}], Z=[{Z_wall_min}, {Z_wall_max}]")

        # Clip
        R_inner, Z_inner, n_i = clip_boundary_to_walls(R_inner, Z_inner, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)
        R_outer_wall, Z_outer_wall, n_ow = clip_boundary_to_walls(R_outer_wall, Z_outer_wall, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)
        R_sep, Z_sep, n_s = clip_boundary_to_walls(R_sep, Z_sep, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)

        if has_divertor:
            R_outer_div, Z_outer_div, n_od = clip_boundary_to_walls(R_outer_div, Z_outer_div, R_wall_min, R_wall_max, Z_wall_min, Z_wall_max)
            if len(R_outer_div) == 0:
                has_divertor = False

        print(f"Clipped: Inner={len(R_inner)}, Wall={len(R_outer_wall)}, Div={len(R_outer_div) if has_divertor else 0}")

        # Export CSV
        if len(R_inner) > 0:
            np.savetxt('plasma_boundary_inner_RZ.csv', np.column_stack([R_inner, Z_inner]),
                      delimiter=',', header="R(m),Z(m)", comments='')
        if len(R_outer_wall) > 0:
            np.savetxt('plasma_boundary_outer_wall_RZ.csv', np.column_stack([R_outer_wall, Z_outer_wall]),
                      delimiter=',', header="R(m),Z(m)", comments='')
        if has_divertor and len(R_outer_div) > 0:
            np.savetxt('plasma_boundary_outer_div_RZ.csv', np.column_stack([R_outer_div, Z_outer_div]),
                      delimiter=',', header="R(m),Z(m)", comments='')

        # Boundary visualization
        fig, ax = plt.subplots(figsize=(10, 8))
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
        print("Saved: plasma_boundaries.png")

        # Gmsh file - plasma boundaries only
        print("\n" + "=" * 60)
        print("Generating Gmsh file (plasma boundaries only)...")

        geo_filename = 'tokamak_mesh.geo'
        lc = 0.05

        with open(geo_filename, 'w') as f:
            f.write("// Tokamak Plasma Boundaries\n")
            f.write("// Inner: CLOSED, Outer: OPEN\n\n")
            f.write(f"lc = {lc};\n\n")

            pt_id = 1
            ln_id = 1

            # Inner - CLOSED
            has_inner = len(R_inner) > 0
            if has_inner:
                f.write("// Inner boundary - CLOSED\n")
                inner_pts = []
                for R, Z in zip(R_inner, Z_inner):
                    f.write(f"Point({pt_id}) = {{{R}, 0, {Z}, lc}};\n")
                    inner_pts.append(pt_id)
                    pt_id += 1
                f.write(f"Spline({ln_id}) = {{{', '.join(map(str, inner_pts + [inner_pts[0]]))}}};\n")
                inner_id = ln_id
                ln_id += 1

            # Outer wall - OPEN
            has_outer_wall = len(R_outer_wall) > 0
            if has_outer_wall:
                f.write("\n// Outer wall - OPEN\n")
                outer_wall_pts = []
                for R, Z in zip(R_outer_wall, Z_outer_wall):
                    f.write(f"Point({pt_id}) = {{{R}, 0, {Z}, lc}};\n")
                    outer_wall_pts.append(pt_id)
                    pt_id += 1
                f.write(f"Spline({ln_id}) = {{{', '.join(map(str, outer_wall_pts))}}};\n")
                outer_wall_id = ln_id
                ln_id += 1

            # Outer div - OPEN
            has_outer_div = has_divertor and len(R_outer_div) > 0
            if has_outer_div:
                f.write("\n// Outer divertor - OPEN\n")
                outer_div_pts = []
                for R, Z in zip(R_outer_div, Z_outer_div):
                    f.write(f"Point({pt_id}) = {{{R}, 0, {Z}, lc}};\n")
                    outer_div_pts.append(pt_id)
                    pt_id += 1
                f.write(f"Spline({ln_id}) = {{{', '.join(map(str, outer_div_pts))}}};\n")
                outer_div_id = ln_id
                ln_id += 1

            # Physical groups
            f.write("\n// Physical groups\n")
            ph = 1
            if has_inner:
                f.write(f"Physical Curve(\"inner\", {ph}) = {{{inner_id}}};\n")
                ph += 1
            if has_outer_wall:
                f.write(f"Physical Curve(\"outer_wall\", {ph}) = {{{outer_wall_id}}};\n")
                ph += 1
            if has_outer_div:
                f.write(f"Physical Curve(\"outer_div\", {ph}) = {{{outer_div_id}}};\n")

        print(f"Saved: {geo_filename} (boundaries only, no wall)")
        print(f"  Inner: {'YES' if has_inner else 'NO'}")
        print(f"  Outer wall: {'YES' if has_outer_wall else 'NO'}")
        print(f"  Outer div: {'YES' if has_outer_div else 'NO'}")

    print("\n" + "=" * 60)
    print("Complete!")
    print("=" * 60)
