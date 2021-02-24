SHELL := /bin/bash

RADIX = 32
SEED = 12345
prime = 434 
prime_round = 448 

WIDTH_REAL = $(shell python -c "from math import ceil; print int(ceil($(prime_round)/$(RADIX)))")

WIDTH = $(WIDTH_REAL)

all: run

UTIL = ../../util
ADD_SOURCE_RTL = ../../fp2_sub_add_correction
ADDER_SOURCE_RTL = ../../fp_sub_and_add
MUL_SOURCE_RTL = ../../fp2_mont_mul_one_cycle_pipeline
STEP_SOURCE_RTL = ../../Montgomery_multiplier_two_cycle_pipeline

include $(ADD_SOURCE_RTL)/gen.mk

gen_input: gen_test.sage
	sage gen_test.sage -w $(RADIX) -prime $(prime) -R $(prime_round) -s $(SEED) 

xDBL_FSM_tb: $(UTIL)/clog2.v $(UTIL)/delay.v $(UTIL)/single_port_mem.v tb.v ../xDBL_FSM.v ../double_to_single_memory_wrapper.v $(MUL_SOURCE_RTL)/fp2_mont_mul.v $(STEP_SOURCE_RTL)/step_sub.v $(STEP_SOURCE_RTL)/step_add.v $(STEP_SOURCE_RTL)/multiplier.v $(ADD_SOURCE_RTL)/fp2_sub_add_correction.v $(ADD_SOURCE_RTL)/serial_comparator.v $(ADDER_SOURCE_RTL)/unit_adder.v $(ADDER_SOURCE_RTL)/fp_adder.v
	@iverilog -Wall -DRADIX=$(RADIX) -DWIDTH_REAL=$(WIDTH_REAL) -Wno-timescale $^ -o xDBL_FSM_tb 

tb: xDBL_FSM_tb
	./xDBL_FSM_tb 

run: gen_input tb
	@diff sim_t2_0.txt sage_t2_0.txt
	@diff sim_t2_1.txt sage_t2_1.txt
	@diff sim_t3_0.txt sage_t3_0.txt
	@diff sim_t3_1.txt sage_t3_1.txt

clean:
	rm -f xDBL_FSM_tb *.txt *.vcd *.sage.py *.mem $(ADD_SOURCE_RTL)/serial_comparator.v