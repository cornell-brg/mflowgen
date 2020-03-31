#=========================================================================
# ptpx.tcl
#=========================================================================
# Use Synopsys PrimeTime to generate interface timing report
#
# Author : Christopher Torng
# Date   : November 22, 2019
#

write_interface_timing ${ptpx_design_name}${corners}_etm_netlist_interface_timing.report
