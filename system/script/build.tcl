set jobs 4

open_project ../project/canbench.xpr
reset_run synth_1
reset_run impl_1
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
launch_runs impl_1 -jobs $jobs
wait_on_run impl_1
launch_runs impl_1 -jobs $jobs -to_step write_bitstream
wait_on_run impl_1
file copy -force ../project/canbench.runs/impl_1/top_wrapper.sysdef ../system.hdf
