# post-write_bitstream script
# executed in impl_1 directory

#set dir [get_property DIRECTORY [current_project]]
#set impl_dir [get_property DIRECTORY [current_run]]
set _pwd [pwd]
set impl_dir .
set dir ../..
puts "Current dir: $_pwd"
puts "Project dir: $dir"
puts "Impl dir: $impl_dir"
file copy -force $impl_dir/top_wrapper.hwdef $dir/../system.hdf
file copy -force $impl_dir/top_wrapper.bit $dir/../system.bit
file copy -force $dir/../system.hdf /tftpboot/system.hdf
file copy -force $dir/../system.bit /tftpboot/system.bit

cd $dir/..
exec bootgen -image system.bif -w -process_bitstream bin
cd $_pwd

file copy -force $dir/../system.bit.bin /export/canbench/system.bit.bin
exec gzip -f /export/canbench/system.bit.bin
