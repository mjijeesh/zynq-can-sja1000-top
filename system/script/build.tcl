set jobs 4

open_project ../project/canbench.xpr
reset_run synth_1
reset_run impl_1

set design_file ../src/top/top.bd
set obj [get_files $design_file]
generate_target all $obj
export_ip_user_files -of_objects $obj -no_script -force -quiet

update_compile_order -fileset sources_1

#foreach ip [get_ips] {
#	create_ip_run $ip
#}
#launch_run -jobs 4 {top_rst_processing_system7_0_100M_0_synth_1 top_processing_system7_0_1_synth_1 top_can_merge_0_1_synth_1}
#launch_run -jobs 4 [get_ips]
#export_simulation -of_objects $obj -directory ../project/canbench.ip_user_files/sim_scripts -force -quiet

launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
launch_runs impl_1 -jobs $jobs
wait_on_run impl_1
launch_runs impl_1 -jobs $jobs -to_step write_bitstream
wait_on_run impl_1
file copy -force ../project/canbench.runs/impl_1/top_wrapper.sysdef ../system.hdf
file copy -force ../project/canbench.runs/impl_1/top_wrapper.bit ../system.bit
