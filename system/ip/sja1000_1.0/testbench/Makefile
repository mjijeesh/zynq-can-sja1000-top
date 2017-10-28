DEFINES :=
#DEFINES := -DCAN_FD_TOLERANT

SRC := ../hdl

all:
	#covered score -v can_testbench.v -dumpvars dut_dump.v -o dut.cdd -I ../hdl -I . -y ../hdl -t can_testbench
	iverilog $(DEFINES) -o test -I. -I $(SRC) -y $(SRC) can_testbench.v 
	#dut_dump.v
	./test
	#covered score -v can_testbench.v -vcd dut_dump.vcd -I $(SRC) -I . -y $(SRC) -t can_testbench
