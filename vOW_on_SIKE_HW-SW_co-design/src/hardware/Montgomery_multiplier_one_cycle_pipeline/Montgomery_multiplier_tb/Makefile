SHELL := /bin/bash

RADIX = 32
SEED = 6080

## testing purpose
## p = 2^32*3^20*23-1  
# prime = 128
# prime_round = 128

## p = 2^191*3^117-1
# prime = 377
# prime_round = 384
# prime_round = 382
# prime_round = 408

##p = 2^216*3^137-1
prime = 434
# prime_round = 438
# prime_round = 440
prime_round = 448
# prime_round = 512
# prime_round = 456
# prime_round = 442
# prime_round = 459

##p = 2^250*3^159-1
# prime = 503
# prime_round = 512
# prime_round = 508
# prime_round = 528
# prime_round = 510

##p = 2^372*3^239-1
# prime = 751
# prime_round = 756
# prime_round = 768
# prime_round = 760 
# prime_round = 782
# prime_round = 765

WIDTH_REAL = $(shell python -c "from math import ceil; print int(ceil($(prime_round)/$(RADIX)))")

all: run_sub run_add 

UTIL = ../../util
SRC = ../../Montgomery_multiplier_two_cycle_pipeline
C_SRC_PATH = ../../../ref_c_riscv/2020_SIKE/

gen_input: 
	make -C $(C_SRC_PATH) TARGET=x86 PROJ=fp2_mul_test clean
	make -C $(C_SRC_PATH) TARGET=x86 PROJ=fp2_mul_test run
	cp $(C_SRC_PATH)/*.txt .

gen_res_sub: gen_input $(SRC)/Montgomery_multiplier_tb/gen_test_sub.sage 
	sage $(SRC)/Montgomery_multiplier_tb/gen_test_sub.sage -w $(RADIX) -s $(SEED) -prime $(prime) -R $(prime_round)

Montgomery_multiplier_sub_tb: $(UTIL)/clog2.v $(UTIL)/delay.v $(UTIL)/single_port_mem.v Montgomery_multiplier_tb.v ../Montgomery_multiplier_sub.v $(SRC)/step_sub.v $(SRC)/multiplier.v
	sed -i 's/\bMontgomery_multiplier/Montgomery_multiplier_sub/g' Montgomery_multiplier_tb.v
	@iverilog -Wall -DRADIX=$(RADIX) -DWIDTH_REAL=$(WIDTH_REAL) -Wno-timescale $^ -o Montgomery_multiplier_sub_tb
	sed -i 's/\Montgomery_multiplier_sub/Montgomery_multiplier/g' Montgomery_multiplier_tb.v

gen_res_add: gen_input $(SRC)/Montgomery_multiplier_tb/gen_test_add.sage 
	sage $(SRC)/Montgomery_multiplier_tb/gen_test_add.sage -w $(RADIX) -s $(SEED) -prime $(prime) -R $(prime_round)

Montgomery_multiplier_add_tb: $(UTIL)/clog2.v $(UTIL)/delay.v $(UTIL)/single_port_mem.v Montgomery_multiplier_tb.v ../Montgomery_multiplier_add.v $(SRC)/step_add.v $(SRC)/multiplier.v
	sed -i 's/\bMontgomery_multiplier/Montgomery_multiplier_add/g' Montgomery_multiplier_tb.v
	@iverilog -Wall -DRADIX=$(RADIX) -DWIDTH_REAL=$(WIDTH_REAL) -Wno-timescale $^ -o Montgomery_multiplier_add_tb
	sed -i 's/\Montgomery_multiplier_add/Montgomery_multiplier/g' Montgomery_multiplier_tb.v

mem_c_1.mem: gen_res_sub

tb_sub: Montgomery_multiplier_sub_tb
	./Montgomery_multiplier_sub_tb

tb_add: Montgomery_multiplier_add_tb
	./Montgomery_multiplier_add_tb

run_sub: gen_res_sub tb_sub
	@diff mult_0_res_sage.txt mult_res_sim.txt 

run_add: gen_res_add tb_add
	@diff mult_0_res_sage.txt mult_res_sim.txt

clean:
	rm -f Montgomery_multiplier_sub_tb Montgomery_multiplier_add_tb *.txt *.vcd *.sage.py *.mem