# run in hsi, not vivado!

set_repo_path ../../modules/device-tree-xlnx
open_hw_design ../system.hdf
create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0

# Generate DTS/DTSI files to folder my_dts where output DTS/DTSI files will be generated
#set_property CONFIG.periph_type_overrides "{BOARD zcu102-rev1.0}" [get_os]

generate_target -dir ../dts
