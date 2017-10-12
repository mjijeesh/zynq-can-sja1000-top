TESTS := $(wildcard test_*.v)
OUTS := $(TESTS:.v=)
DEPS := $(wildcard *.v ../hdl/can_*.v)

all: $(OUTS)

%: %.v FORCE
	iverilog -o $@ -s $@ -I ../hdl $< $(wildcard ../hdl/can_*.v)
	@echo === $@ ===
	@vvp $@

FORCE:
