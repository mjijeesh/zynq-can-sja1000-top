GHDL=ghdl

core_DIR=../hdl
core_SRC=display_16bit_cmd_data_bus_v1_0_io_fsm.vhd

tb_DIR=.
tb_SRC=display_16bit_cmd_data_bus_v1_0_tb.vhd

MODULES=core tb

TOP_COMPONENT = display_16bit_cmd_data_bus_tb

SRC=$(foreach m, $(MODULES), $($(m)_SRC:%=$($(m)_DIR)/%))

$(warning SRC=$(SRC))

#SRC+=mapo_tb.vhd

CFLAGS += -Wall

GHDLFLAGS+=
ANALYZEFLAGS+=--std=93c --ieee=synopsys -fexplicit -ggdb

#SIM_FLAGS=--stop-time=1000ns #--ieee-asserts=disable

all:	test-mapo

convert_bin2bits : convert_bin2bits.o

imem.bits : imem.bin convert_bin2bits
	./convert_bin2bits $< >$@

# imem.bits
test-mapo: analyze-all
	$(GHDL) $(GHDLFLAGS) -m $(ANALYZEFLAGS) $(TOP_COMPONENT)
	$(GHDL) $(GHDLFLAGS) -r $(TOP_COMPONENT) --stop-time=2000ns --vcd=$@.vcd --wave=$@.ghw

analyze-all: $(SRC)
	$(GHDL) $(GHDLFLAGS) -a $(ANALYZEFLAGS) $(SRC)

clean:
	rm -f convert_bin2bits
	rm -f *.o
	$(GHDL) --clean
	$(RM) work-obj93.cf
