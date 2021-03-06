SHELL := /bin/bash
 
SEED = 12345 
LOOPS = 16

RADIX = 34
prime = 377 
prime_round = 408

WIDTH_REAL = $(shell python -c "from math import ceil; print int(ceil($(prime_round)/$(RADIX)))")

WIDTH = $(WIDTH_REAL)

all: run

UTIL = ../../util
ADD_SOURCE_RTL = ../../fp2_sub_add_correction
ADDER_SOURCE_RTL = ../../fp_sub_and_add
MUL_SOURCE_RTL = ../../fp2_mont_mul_one_cycle_pipeline
STEP_SOURCE_RTL = ../../Montgomery_multiplier_two_cycle_pipeline
CONTROLLER_RTL = ../../controller_xDBL_get_4_isog_xDBLADD_eval_4_isog
CONTROLLER_XDBL_RTL = ../../controller_xDBL
CONTROLLER_GET_4_ISOG_RTL = ../../controller_get_4_isog
CONTROLLER_EVAL_4_ISOG_RTL = ../../controller_eval_4_isog
CONTROLLER_XDBLADD_RTL = ../../controller_xDBLADD

include $(ADD_SOURCE_RTL)/gen.mk

gen_input: gen_test.sage
	sage gen_test.sage -w $(RADIX) -prime $(prime) -R $(prime_round) -l $(LOOPS) -s $(SEED) 

xDBLe_tb: $(UTIL)/clog2.v $(UTIL)/delay.v $(UTIL)/single_port_mem.v xDBLe_tb.v ../xDBLe.v $(CONTROLLER_RTL)/controller.v $(CONTROLLER_RTL)/double_to_single_memory_wrapper.v $(CONTROLLER_XDBL_RTL)/xDBL_FSM.v $(CONTROLLER_GET_4_ISOG_RTL)/get_4_isog_FSM.v $(CONTROLLER_EVAL_4_ISOG_RTL)/eval_4_isog_FSM.v $(CONTROLLER_XDBLADD_RTL)/xDBLADD_FSM.v $(MUL_SOURCE_RTL)/fp2_mont_mul.v $(STEP_SOURCE_RTL)/step_sub.v $(STEP_SOURCE_RTL)/step_add.v $(STEP_SOURCE_RTL)/multiplier.v $(ADD_SOURCE_RTL)/fp2_sub_add_correction.v $(ADD_SOURCE_RTL)/serial_comparator.v $(ADDER_SOURCE_RTL)/unit_adder.v $(ADDER_SOURCE_RTL)/fp_adder.v
	@iverilog -Wall -DRADIX=$(RADIX) -DWIDTH_REAL=$(WIDTH_REAL) -DLOOPS=$(LOOPS) -Wno-timescale $^ -o xDBLe_tb 

tb: xDBLe_tb
	./xDBLe_tb 

run: gen_input tb
	@diff sim_t6_0.txt sage_xDBLe_t6_0.txt
	@diff sim_t6_1.txt sage_xDBLe_t6_1.txt
	@diff sim_t7_0.txt sage_xDBLe_t7_0.txt
	@diff sim_t7_1.txt sage_xDBLe_t7_1.txt

clean:
	rm -f xDBLe_tb *.txt *.vcd *.sage.py *.mem $(ADD_SOURCE_RTL)/serial_comparator.v