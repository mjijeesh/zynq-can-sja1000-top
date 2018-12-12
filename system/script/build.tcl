set jobs [exec "nproc"]
puts "Using $jobs jobs."

open_project ../project/zynq-can-top.xpr
reset_run synth_1
reset_run impl_1

set design_file ../src/top/top.bd
set obj [get_files $design_file]
generate_target all $obj
export_ip_user_files -of_objects $obj -no_script -force -quiet

update_compile_order -fileset sources_1
update_ip_catalog -rebuild -update_module_ref -scan_changes
upgrade_ip [get_ips]

#foreach ip [get_ips] {
#	create_ip_run $ip
#}
#launch_run -jobs $jobs {top_rst_processing_system7_0_100M_0_synth_1 top_processing_system7_0_1_synth_1 top_can_merge_0_1_synth_1}
#launch_run -jobs $jobs [get_ips]
#export_simulation -of_objects $obj -directory ../project/zynq-can-top.ip_user_files/sim_scripts -force -quiet

launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
launch_runs impl_1 -jobs $jobs
wait_on_run impl_1
launch_runs impl_1 -jobs $jobs -to_step write_bitstream
wait_on_run impl_1
file copy -force ../project/zynq-can-top.runs/impl_1/top_hdl.hwdef ../system.hdf
file copy -force ../project/zynq-can-top.runs/impl_1/top_hdl.bit ../system.bit

set d "../project"

open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_1 -file $d/timing_report.txt -rpx $d/timing_report.rpx
report_utilization -file $d/utilization_report.txt -name utilization_1
