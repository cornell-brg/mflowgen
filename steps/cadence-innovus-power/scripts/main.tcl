#=========================================================================
# main.tcl
#=========================================================================
# A generic power strategy that should work for most designs
#
# Author : Christopher Torng
# Date   : January 13, 2020

#-------------------------------------------------------------------------
# Implement power strategy
#-------------------------------------------------------------------------
# Older technologies use a single coarse power mesh, but more advanced
# technologies often use a combination of a fine+coarse power mesh.
#
# Here we check the direction of M2 to decide which power strategy to use.

set M2_direction [dbGet [dbGet head.layers.name 2 -p].direction]

if { $M2_direction == "Vertical" } {
  # Vertical M2 -- Use single power mesh strategy
  puts "Info: Using coarse-only power mesh because M2 is vertical"
  if {[ file exists inputs/power-strategy-singlemesh.tcl ]} {
    source -verbose inputs/power-strategy-singlemesh.tcl
  } else {
    source -verbose scripts/power-strategy-singlemesh.tcl
  }
} else {
  # Horizontal M2 -- Use dual power mesh strategy
  puts "Info: Using fine+coarse power mesh because M2 is horizontal"
  if {[ file exists inputs/power-strategy-dualmesh.tcl ]} {
    source -verbose inputs/power-strategy-dualmesh.tcl
  } else {
    source -verbose scripts/power-strategy-dualmesh.tcl
  }
}


