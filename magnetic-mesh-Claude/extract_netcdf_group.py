#!/usr/bin/env python3
"""
This code was generated with Claude
"""

"""
Script to extract a single group from an existing netCDF file
and create a new netCDF file containing only that group.
"""

import netCDF4 as nc
import numpy as np
import argparse
import sys
from pathlib import Path

def copy_attributes(src_obj, dst_obj):
    """Copy all attributes from source to destination object."""
    for attr_name in src_obj.ncattrs():
        attr_value = getattr(src_obj, attr_name)
        setattr(dst_obj, attr_name, attr_value)

def copy_dimensions(src_group, dst_group):
    """Copy dimensions from source group to destination group."""
    for dim_name, dim in src_group.dimensions.items():
        if dim.isunlimited():
            dst_group.createDimension(dim_name, None)
        else:
            dst_group.createDimension(dim_name, len(dim))

def copy_variables(src_group, dst_group):
    """Copy variables from source group to destination group."""
    for var_name, var in src_group.variables.items():
        # Create variable in destination
        dst_var = dst_group.createVariable(
            var_name,
            var.dtype,
            var.dimensions,
            zlib=True,  # Enable compression
            complevel=4,
            shuffle=True,
            fill_value=var._FillValue if hasattr(var, '_FillValue') else None
        )

        # Copy variable data
        dst_var[:] = var[:]

        # Copy variable attributes
        copy_attributes(var, dst_var)

def copy_subgroups(src_group, dst_group):
    """Recursively copy subgroups from source to destination."""
    for subgroup_name in src_group.groups.keys():
        src_subgroup = src_group.groups[subgroup_name]
        dst_subgroup = dst_group.createGroup(subgroup_name)

        # Copy subgroup attributes
        copy_attributes(src_subgroup, dst_subgroup)

        # Copy dimensions, variables, and nested subgroups
        copy_dimensions(src_subgroup, dst_subgroup)
        copy_variables(src_subgroup, dst_subgroup)
        copy_subgroups(src_subgroup, dst_subgroup)

def extract_group_to_new_file(input_file, output_file, group_name):
    """
    Extract a specific group from input netCDF file and save to new file.

    Parameters:
    -----------
    input_file : str
        Path to input netCDF file
    output_file : str
        Path to output netCDF file
    group_name : str
        Name of the group to extract
    """

    try:
        # Open input file
        with nc.Dataset(input_file, 'r') as src_nc:

            # Check if group exists
            if group_name not in src_nc.groups:
                available_groups = list(src_nc.groups.keys())
                raise ValueError(f"Group '{group_name}' not found. Available groups: {available_groups}")

            # Get the source group
            src_group = src_nc.groups[group_name]

            # Create output file
            with nc.Dataset(output_file, 'w', format='NETCDF4') as dst_nc:

                # Copy global attributes from the source group to root of new file
                copy_attributes(src_group, dst_nc)

                # Copy dimensions from the group to root level
                copy_dimensions(src_group, dst_nc)

                # Copy variables from the group to root level
                copy_variables(src_group, dst_nc)

                # Copy any subgroups
                copy_subgroups(src_group, dst_nc)

                # Add metadata about the extraction
                dst_nc.setncattr('source_file', str(input_file))
                dst_nc.setncattr('extracted_group', group_name)
                dst_nc.setncattr('extraction_software', 'netCDF4-python')

        print(f"Successfully extracted group '{group_name}' to '{output_file}'")

    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

def list_groups(input_file):
    """List all groups in the netCDF file."""
    try:
        with nc.Dataset(input_file, 'r') as nc_file:
            def print_groups(group, indent=0):
                prefix = "  " * indent
                if hasattr(group, 'groups'):
                    for group_name in group.groups.keys():
                        print(f"{prefix}{group_name}")
                        print_groups(group.groups[group_name], indent + 1)

            print(f"Groups in '{input_file}':")
            if len(nc_file.groups) == 0:
                print("  No groups found (file may have variables at root level only)")
            else:
                print_groups(nc_file)

    except Exception as e:
        print(f"Error reading file: {str(e)}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Extract a single group from a netCDF file to create a new netCDF file",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python extract_netcdf_group.py input.nc output.nc group1
  python extract_netcdf_group.py --list input.nc
        """
    )

    parser.add_argument('input_file', help='Input netCDF file path')
    parser.add_argument('output_file', nargs='?', help='Output netCDF file path')
    parser.add_argument('group_name', nargs='?', help='Name of group to extract')
    parser.add_argument('--list', '-l', action='store_true',
                       help='List all groups in the input file')

    args = parser.parse_args()

    if not Path(args.input_file).exists():
        print(f"Error: Input file '{args.input_file}' does not exist.")
        sys.exit(1)

    if args.list:
        list_groups(args.input_file)
    else:
        if not args.output_file or not args.group_name:
            parser.error("output_file and group_name are required when not using --list")

        extract_group_to_new_file(args.input_file, args.output_file, args.group_name)

if __name__ == "__main__":
    main()
