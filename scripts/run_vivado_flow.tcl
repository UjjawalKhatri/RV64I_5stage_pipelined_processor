# ============================================================================
# Tcl Script: run_vivado_flow.tcl
# Description: Automated Vivado Batch Flow (Project Creation, Sim, Synthesis, Impl)
# Usage in Vivado Tcl Console or Command Line:
#   vivado -mode batch -source scripts/run_vivado_flow.tcl
# ============================================================================

set project_name "rv64i_vivado_proj"
set target_device "xc7a100tcsg324-1"
set origin_dir [file dirname [info script]]
set project_dir "$origin_dir/../$project_name"

puts "=================================================================="
puts "       STARTING AUTOMATED VIVADO SYNTHESIS & IMPLEMENTATION       "
puts "=================================================================="

# Create Vivado Project
create_project $project_name $project_dir -part $target_device -force

# Set Project Properties
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]

# Add RTL Source Files
add_files -norecurse [glob "$origin_dir/../rtl/*.v"]

# Add Simulation Testbench Files
add_files -fileset sim_1 -norecurse [glob "$origin_dir/../tb/*.v"]

# Add Constraint File
add_files -fileset constrs_1 -norecurse "$origin_dir/../constraints/rv64i_artix7.xdc"

# Set Top Module
set_property top rv64i_core_top [current_fileset]
set_property top tb_rv64i_core [get_filesets sim_1]

# Update Compile Order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "\n---> Step 1: Running Synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

open_run synth_1
report_utilization -file "$project_dir/synthesis_utilization_report.txt"
report_timing_summary -file "$project_dir/synthesis_timing_report.txt"

puts "\n---> Step 2: Running Implementation (Place & Route)..."
launch_runs impl_1 -jobs 4
wait_on_run impl_1

open_run impl_1
report_utilization -file "$project_dir/implementation_utilization_report.txt"
report_timing_summary -file "$project_dir/implementation_timing_report.txt"
report_power -file "$project_dir/implementation_power_report.txt"

puts "=================================================================="
puts "  VIVADO FLOW COMPLETED SUCCESSFULLY! Reports saved in project dir "
puts "=================================================================="
