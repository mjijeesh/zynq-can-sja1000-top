DEFINES :=
DEFINES := -DCAN_FD_TOLERANT

SRC := orig_src
#SRC := path_to_unmodified_src

all:
	iverilog $(DEFINES) -o test -s can_testbench -I. -I $(SRC) $(SRC)/*.v *.v
	./test
