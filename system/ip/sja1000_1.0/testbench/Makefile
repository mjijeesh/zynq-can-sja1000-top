all:
	iverilog -DCAN_FD_TOLERANT -o test -s can_testbench -I. -I orig_src orig_src/*.v *.v
	./test
