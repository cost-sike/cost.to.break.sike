SHELL := /bin/bash

RADIX = 32
SEED = 2024

##p = 2^216*3^137-1
prime = 434
prime_round = 448

WIDTH = $(shell python -c "from math import ceil; print int(ceil($(prime_round)/$(RADIX)))")

UTIL = ../../util
ADD_SOURCE_RTL = ..

all: run

include ../gen.mk

gen_input: gen_test.sage
	sage gen_test.sage -w $(RADIX) --prime $(prime) -R $(prime_round) #-s $(SEED) 

fp_sub_and_compare_tb: $(UTIL)/clog2.v $(UTIL)/single_port_mem.v fp_sub_and_compare_tb.v ../fp_sub_and_compare.v $(ADD_SOURCE_RTL)/serial_comparator.v ../unit_adder.v ../fp_adder.v  
	@iverilog -Wall -DRADIX=$(RADIX) -DDIGITS=$(WIDTH) -Wno-timescale $^ -o fp_sub_and_compare_tb 

tb: fp_sub_and_compare_tb
	./fp_sub_and_compare_tb 

run: gen_input tb
	diff Sage_sub_res.txt Simulation_sub_res.txt
	diff Sage_comp_res.txt Simulation_comp_res.txt 

clean: gen_clean
	rm -f fp_sub_and_compare_tb *.vcd *.txt *.sage.py *.mem  