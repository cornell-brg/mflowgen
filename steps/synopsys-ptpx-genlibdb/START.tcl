#=========================================================================
# START.tcl
#=========================================================================
# Runs the scripts for this step.
#
# This script does the following:
#
# 1  Designer interface -- Read the PT interface
# 2. Execute -- Execute scripts from "scripts" or "inputs" dir
#
# The order of the scripts can specified from an mflowgen parameter. This
# creates a highly flexible node where you can rearrange the internal
# scripts or add new scripts. For example, with a default order of:
#
#     order = step1.tcl step2.tcl step3.tcl
#
# After adding a new input called "new.tcl", you can re-parameterize as:
#
#     order = step1.tcl new.tcl step2.tcl step3.tcl
#
# and the scripts will execute in that order.
#
# Author : Christopher Torng
# Date   : January 14, 2020
#-------------------------------------------------------------------------
# Version History
#-------------------------------------------------------------------------
#
# - 03/30/2020 -- Guénolé Lallement
#     - Add the designer interface sourcing for corners definition
#
# - 01/14/2020 -- Christopher Torng
#     - Original version
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Designer interface
#-------------------------------------------------------------------------
# Source the designer interface script, which sets up variables from the
# build system, sets up ASIC design kit variables, etc.

source -echo -verbose designer_interface.tcl

#-------------------------------------------------------------------------
# Execute
#-------------------------------------------------------------------------

# Order is a comma-separated string containing scripts to run

set order [split $::env(order) ","]

foreach corners $ptpx_extra_corners {
    foreach tcl $order {
        # Try to find the script in the "inputs" directory first
        if {[ file exists inputs/$tcl ]} {
            puts "\n  > Info: Sourcing \"inputs/$tcl\"\n"
            source -verbose inputs/$tcl
            # Try to find the script in the "scripts" directory
        } elseif {[ file exists scripts/$tcl ]} {
            puts "\n  > Info: Sourcing \"scripts/$tcl\"\n"
            source -verbose scripts/$tcl
            # Failed to find the script anywhere...
        } else {
            echo "Warn: Did not find $tcl"
            exit 1
        }
    }
}

exit
