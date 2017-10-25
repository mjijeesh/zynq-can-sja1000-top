DEFINES :=
#DEFINES := -DCAN_FD_TOLERANT

SRC := ../hdl

all:
	iverilog $(DEFINES) -o test -s can_testbench -I. -I $(SRC) $(SRC)/can_*.v can_testbench.v
	./test
