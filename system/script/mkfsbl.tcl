set hwdsgn [open_hw_design ../system.hdf]
generate_app -hw $hwdsgn -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl -dir ../fsbl
