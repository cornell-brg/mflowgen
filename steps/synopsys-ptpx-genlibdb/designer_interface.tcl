#=========================================================================
# designer_interface.tcl
#=========================================================================
# The designer_interface.tcl file is the first script run by PTPX (see the
# top of ptpx.tcl). It is the interface that connects the scripts with
# the following:
#
# - ASIC design kit
# - Build system variables
#
# Author : Christopher Torng
# Date   : May 20, 2019
#-------------------------------------------------------------------------
# Version History
#-------------------------------------------------------------------------
#
# - 03/30/2020 -- Guénolé Lallement
#     - Add target libraries for worst and best corner cases
#     - Complete with the sdc and spef files for these corners
#
# - 05/20/2019 -- Christopher Torng
#     - Original version
#
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
# Interface to the ASIC design kit
#-------------------------------------------------------------------------

set ptpx_additional_search_path   inputs/adk

# Typical

set ptpx_target_libraries         inputs/adk/stdcells.db
set ptpx_extra_link_libraries     [join "
									[glob -nocomplain inputs/adk/*.db]
                                  "]

set ptpx_extra_corners [list "" "_bc" "_wc"]

# Best case

set ptpx_target_libraries_bc      inputs/adk/stdcells-bc.db
set ptpx_extra_link_libraries_bc  [join "
									[glob -nocomplain inputs/adk/*-bc.db]
                                  "]

# Worst case

set ptpx_target_libraries_wc      inputs/adk/stdcells-wc.db
set ptpx_extra_link_libraries_wc  [join "
									[glob -nocomplain inputs/adk/*-wc.db]
                                  "]


#-------------------------------------------------------------------------
# Interface to the build system
#-------------------------------------------------------------------------

set ptpx_design_name              $::env(design_name)

set ptpx_flow_dir                 .
set ptpx_plugins_dir              .
set ptpx_logs_dir                 logs
set ptpx_reports_dir              reports
set ptpx_results_dir              results

set ptpx_gl_netlist               [glob -nocomplain inputs/*.vcs.v]

set ptpx_sdc                      [glob -nocomplain inputs/design.pt.sdc]
set ptpx_bc_sdc                   [glob -nocomplain inputs/design-bc.pt.sdc]
set ptpx_wc_sdc                   [glob -nocomplain inputs/design-wc.pt.sdc]

set ptpx_spef                     [glob -nocomplain inputs/design.spef.gz]
set ptpx_bc_spef                  [glob -nocomplain inputs/design-bc.spef.gz]
set ptpx_wc_spef                  [glob -nocomplain inputs/design-wc.spef.gz]


puts "done"
