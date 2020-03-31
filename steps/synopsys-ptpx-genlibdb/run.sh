#! /usr/bin/env bash
#=========================================================================
# run.sh
#=========================================================================
# Author : Guénolé Lallement
# Date   : March 31, 2020
#
#-------------------------------------------------------------------------

# Build log directory

mkdir -p logs

# Run PT shell

pt_shell -file START.tcl -output_log_file logs/pt.log

# Create outputs

mkdir -p outputs && cd outputs
ln -sf ../$design_name.db  design.db
ln -sf ../$design_name.lib design.lib
