# Run vivado -mode batch -source scripts/create_project.tcl
set repo_dir [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $repo_dir vivado rsa]

if {[file exists $project_dir]} {
    error "Move vivado/rsa aside before regenerating; the existing project will not be overwritten."
}

# PYNQ-Z1 FPGA
create_project rsa $project_dir -part xc7z020clg400-1
set_property target_language VHDL [current_project]

# Setup reference structure
foreach {folder fileset} {rtl sources_1 sim sim_1} {
    set files [lsort [glob -nocomplain -directory [file join $repo_dir $folder] *.vhd *.vhdl]]
    if {[llength $files]} {
        add_files -norecurse -fileset $fileset $files
        set_property file_type {VHDL 2008} [get_files $files]
    }
}

# Empty for now
set constraints [lsort [glob -nocomplain -directory [file join $repo_dir constraints] *.xdc]]
if {[llength $constraints]} {
    add_files -norecurse -fileset constrs_1 $constraints
}

set_property top rsa_core [get_filesets sources_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Project ready: [file join $project_dir rsa.xpr]"
