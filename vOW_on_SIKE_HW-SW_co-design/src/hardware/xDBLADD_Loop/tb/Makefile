SHELL := /bin/bash
 
SEED = 12345  
SK_WIDTH = 8
SK_DEPTH = 500
START_INDEX = 2
END_INDEX = 5

RADIX = 32
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
CONTROLLER_RTL = ../../controller_xDBL_get_4_isog_xDBLADD_eval_4_isog
CONTROLLER_XDBL_RTL = ../../controller_xDBL
CONTROLLER_GET_4_ISOG_RTL = ../../controller_get_4_isog
CONTROLLER_EVAL_4_ISOG_RTL = ../../controller_eval_4_isog
CONTROLLER_XDBLADD_RTL = ../../controller_xDBLADD

include $(ADD_SOURCE_RTL)/gen.mk

gen_input: gen_test.sage
	sage gen_test.sage -w $(RADIX) -prime $(prime) -R $(prime_round) -b $(START_INDEX) -e $(END_INDEX) -sw $(SK_WIDTH) -sd $(SK_DEPTH) -s $(SEED) 

xDBLADD_Loop_tb: $(UTIL)/clog2.v $(UTIL)/delay.v $(UTIL)/single_port_mem.v xDBLADD_Loop_tb.v ../xDBLADD_Loop.v $(CONTROLLER_RTL)/controller.v $(CONTROLLER_RTL)/double_to_single_memory_wrapper.v $(CONTROLLER_XDBL_RTL)/xDBL_FSM.v $(CONTROLLER_GET_4_ISOG_RTL)/get_4_isog_FSM.v $(CONTROLLER_EVAL_4_ISOG_RTL)/eval_4_isog_FSM.v $(CONTROLLER_XDBLADD_RTL)/xDBLADD_FSM.v $(MUL_SOURCE_RTL)/fp2_mont_mul.v $(STEP_SOURCE_RTL)/step_sub.v $(STEP_SOURCE_RTL)/step_add.v $(STEP_SOURCE_RTL)/multiplier.v $(ADD_SOURCE_RTL)/fp2_sub_add_correction.v $(ADD_SOURCE_RTL)/serial_comparator.v $(ADDER_SOURCE_RTL)/unit_adder.v $(ADDER_SOURCE_RTL)/fp_adder.v
	@iverilog -Wall -DSTART_INDEX=$(START_INDEX) -DEND_INDEX=$(END_INDEX) -DRADIX=$(RADIX) -DWIDTH_REAL=$(WIDTH_REAL) -DSK_WIDTH=$(SK_WIDTH) -DSK_DEPTH=$(SK_DEPTH) -Wno-timescale $^ -o xDBLADD_Loop_tb 

tb: xDBLADD_Loop_tb
	./xDBLADD_Loop_tb 

run: gen_input tb
	@diff sage_XP_0.txt sim_XP_0.txt
	@diff sage_XP_1.txt sim_XP_1.txt
	@diff sage_ZP_0.txt sim_ZP_0.txt
	@diff sage_ZP_1.txt sim_ZP_1.txt
	@diff sage_XQ_0.txt sim_XQ_0.txt
	@diff sage_XQ_1.txt sim_XQ_1.txt
	@diff sage_ZQ_0.txt sim_ZQ_0.txt
	@diff sage_ZQ_1.txt sim_ZQ_1.txt
	@diff sage_xPQ_0.txt sim_xPQ_0.txt
	@diff sage_xPQ_1.txt sim_xPQ_1.txt
	@diff sage_zPQ_0.txt sim_zPQ_0.txt
	@diff sage_zPQ_1.txt sim_zPQ_1.txt
	
clean:
	rm -f xDBLADD_Loop_tb *.txt *.vcd *.sage.py *.mem $(ADD_SOURCE_RTL)/serial_comparator.v