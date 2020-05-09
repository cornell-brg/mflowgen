#-------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------

# Set up paths and libraries
# search path
set_app_var search_path      ". $ptpx_additional_search_path $search_path"

# target lib
set cmd "set target_lib \$ptpx_target_libraries${corners}"
eval $cmd
set cmd "set_app_var target_library   $target_lib"
eval $cmd

# link lib
set cmd "set extra_link_lib \$ptpx_extra_link_libraries${corners}"
eval $cmd
set cmd "set_app_var link_library     \"* $target_lib $extra_link_lib\" "
eval $cmd

#-------------------------------------------------------------------------
# Read design
#-------------------------------------------------------------------------

# Read and link the design
read_verilog   $ptpx_gl_netlist
current_design $ptpx_design_name

if {![info exists linked]} {
    puts "\n  > Info: Linking design\n"
    link_design
    set linked 1
} else {
    puts "\n  > Info: Design is already linked\n"
}

#-------------------------------------------------------------------------
# Read in the SDC and parasitics
#-------------------------------------------------------------------------

# Try to read the sdc constraints files

set cmd "set sdc_file \"\$ptpx${corners}_sdc\""
eval $cmd

if {[ file exists $sdc_file ]} {
    puts "\n  > Info: Sourcing $sdc_file\n"
    set cmd "read_sdc -echo $sdc_file"
    eval $cmd
}  else {
    puts "\n  > Warn: No sdc constraint file found\n"
}

# Try to read the spef parasitic files

set cmd "set spef_file \"\$ptpx${corners}_spef\""
eval $cmd

if {[ file exists $spef_file]} {
    puts "\n  > Info: Sourcing $spef_file\n"
    set cmd "read_parasitics -format spef $spef_file"
    eval $cmd
}  else {
     puts "\n  > Warn: No spef parasitic file found\n"
}
