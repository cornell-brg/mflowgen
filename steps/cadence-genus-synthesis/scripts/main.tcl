#=========================================================================
# main.tcl
#=========================================================================
# Main Genus script.
#
# Author : Alex Carsello, James Thomas
# Date   : July 14, 2020

set design_name                $::env(design_name)
set clock_period               $::env(clock_period)
set gate_clock                 $::env(gate_clock)
set uniquify_with_design_name  $::env(uniquify_with_design_name)

set_db common_ui false

if { $gate_clock == True } {
  set_attr lp_insert_clock_gating true
}
 
# ------------------------------------------------------------------------
# (begin compiling library and lef lists)
# ------------------------------------------------------------------------

# OLD/BAD
# set_attr library    [join "
#                       [glob -nocomplain inputs/adk/*.lib]
#                       [glob -nocomplain inputs/*.lib]
#                     "]
# 
# set_attr lef_library [join "
#                        inputs/adk/rtk-tech.lef
#                        [glob -nocomplain inputs/adk/*.lef]
#                        [glob -nocomplain inputs/*.lef]
#                      "]

########################################################################
# Library sets
# 
# Steveri update Aug 2020: fixed library load ordering.
# For consistency, using code similar to what I found in
# existing step 'cadence-innovus-flowsetup/setup.tcl'
#
# Also, added "lsort" to "glob" for better determinacy.
# 
# Note, genus at the moment only uses typical libraries;
# I'm leaving the best/worst lists for consistency with flowsetup step,
# plus maybe someday someone would want to design to one of these cases...?
# 
# FIXME This could maybe could/should be wrapped up as a separate common
# script somewhere? For use by both genus and flowsetup etc?
# Better: Could be an executable bash script in e.g. "adks/bin"...?

global vars
set vars(adk_dir) inputs/adk

########################################################################
# Typical-case libraries
set vars(libs_typical,timing) \
    [join "
        $vars(adk_dir)/stdcells.lib
        [lsort [glob -nocomplain $vars(adk_dir)/stdcells-lvt.lib]]
        [lsort [glob -nocomplain $vars(adk_dir)/stdcells-ulvt.lib]]
        [lsort [glob -nocomplain $vars(adk_dir)/stdcells-pm.lib]]
        [lsort [glob -nocomplain $vars(adk_dir)/iocells.lib]]
        [lsort [glob -nocomplain inputs/*tt*.lib]]
        [lsort [glob -nocomplain inputs/*TT*.lib]]
        "]
puts "INFO: Found typical-typical libraries $vars(libs_typical,timing)"
foreach L $vars(libs_typical,timing) { echo "L_TT    $L" }

########################################################################
# Best-case libraries
# - Process: ff
# - Voltage: highest
# - Temperature: highest (temperature inversion at 28nm and below)
# FIXME note this code repeats all the bc libraries in the list at
# least twice, because of the extra '*-bc-*' pattern...

if {[file exists $vars(adk_dir)/stdcells-bc.lib]} {
    set vars(libs_bc,timing) \
        [join "
            $vars(adk_dir)/stdcells-bc.lib
            [lsort [glob -nocomplain $vars(adk_dir)/stdcells-lvt-bc.lib]]
            [lsort [glob -nocomplain $vars(adk_dir)/stdcells-ulvt-bc.lib]]
            [lsort [glob -nocomplain $vars(adk_dir)/stdcells-pm-bc.lib]]
            [lsort [glob -nocomplain $vars(adk_dir)/iocells-bc.lib]]
            [lsort [glob -nocomplain $vars(adk_dir)/*-bc*.lib]]
            [lsort [glob -nocomplain inputs/*ff*.lib]]
            [lsort [glob -nocomplain inputs/*FF*.lib]]
        "]
  puts "INFO: Found fast-fast libraries $vars(libs_bc,timing)"
  foreach L $vars(libs_bc,timing) { echo "L_FF    $L" }
}

########################################################################
# Worst-case libraries
# - Process: ss
# - Voltage: lowest
# - Temperature: lowest (temperature inversion at 28nm and below)
# FIXME is there a reason this only looks for iocells???

if {[file exists $vars(adk_dir)/stdcells-wc.lib]} {
    set vars(libs_wc,timing) \
        [join "
            $vars(adk_dir)/stdcells-wc.lib
            [lsort [glob -nocomplain $vars(adk_dir)/iocells-wc.lib]]
            [lsort [glob -nocomplain inputs/*ss*.lib]]
            [lsort [glob -nocomplain inputs/*SS*.lib]]
      "]
  puts "INFO: Found slow-slow libraries $vars(libs_wc,timing)"
  foreach L $vars(libs_wc,timing) { echo "L_SS    $L" }
}

########################################################################
# LEF files
set vars(lef_files) \
[join "
    $vars(adk_dir)/rtk-tech.lef
    $vars(adk_dir)/stdcells.lef
    [lsort [glob -nocomplain $vars(adk_dir)/stdcells-pm.lef]]
    [lsort [glob -nocomplain $vars(adk_dir)/*.lef]]
    [lsort [glob -nocomplain inputs/*.lef]]
"]

puts "INFO: Found LEF files $vars(lef_files)"
foreach L $vars(lef_files) { echo "LEF    $L" }

# ------------------------------------------------------------------------
# (done compiling library and lef lists)
# ------------------------------------------------------------------------

set_attr library     $vars(libs_typical,timing)
set_attr lef_library $vars(lef_files)

set_attr qrc_tech_file [list inputs/adk/pdk-typical-qrcTechFile]

read_hdl -sv [lsort [glob -directory inputs -type f *.v *.sv]]
elaborate $design_name

source "inputs/adk/adk.tcl"

source -verbose "inputs/constraints.tcl"

if { $uniquify_with_design_name == True } {
  set_attr uniquify_naming_style "${design_name}_%s_%d"
  uniquify $design_name
}

# FIXME technology specific
set_attribute avoid true [get_lib_cells {*/E* */G* *D16* *D20* *D24* *D28* *D32* SDF* *DFM*}]
# don't use Scan enable D flip flops
set_attribute avoid true [get_lib_cells {*SEDF*}]

syn_gen
set_attr syn_map_effort high
syn_map
syn_opt 

