TARGET=Murax
 
DEBUG?=no
TRACE?=yes
# TRACE?=no
PRINT_PERF?=no
TRACE_START=0
ADDCFLAGS += -CFLAGS -pthread -LDFLAGS -pthread
ADDCFLAGS += -CFLAGS -DVMURAX=V$(TARGET)
ADDCFLAGS += -CFLAGS -DVMURAX_H=\\\"V$(TARGET).h\\\"
ADDCFLAGS += -CFLAGS -DVMURAX_MURAX_H=\\\"V$(TARGET)_$(TARGET).h\\\"

ifeq ($(TRACE),yes)
	VERILATOR_ARGS += --trace --trace-depth 2
	ADDCFLAGS += -CFLAGS -DTRACE
endif
ifeq ($(DEBUG),yes)
	ADDCFLAGS += -CFLAGS "-g3 -O0"
endif
ifneq ($(DEBUG),yes)
	ADDCFLAGS += -CFLAGS "-O3"
endif
ifeq ($(PRINT_PERF),yes)
	ADDCFLAGS += -CFLAGS -DPRINT_PERF
endif

ADDCFLAGS += -CFLAGS -DTRACE_START=${TRACE_START}
ADDCFLAGS += -Wno-PINMISSING
ADDCFLAGS += -CFLAGS -funroll-loops 

include ../DE1-SoC/gen.mk


SOURCES = $(shell grep VERILOG_FILE ../DE1-SoC/$(TARGET).qsf  | cut -d " " -f 4)
# SOURCES += $(shell grep VHDL_FILE ../DE1-SoC/$(TARGET).qsf  | cut -d " " -f 4)
# SOURCES += ../DE1-SoC/zeta.bin
# SOURCES += ../DE1-SoC/zetainv.bin

all: compile

run: compile
	./obj_dir/V$(TARGET)

verilate: gen_verilog_files $(SOURCES) set_params mem_p_plus_one.mem px2.mem px4.mem 
	rm -f $(TARGET).v*.bin 
	verilator --top-module $(TARGET) -cc $(SOURCES) -CFLAGS -std=c++11  ${ADDCFLAGS} --gdbbt ${VERILATOR_ARGS} -Wno-WIDTH -Wno-UNOPTFLAT --x-assign unique --exe main.cpp

compile: verilate
	make  -j  -C obj_dir/ -f V$(TARGET).mk V$(TARGET)
	
clean:
	rm -rf obj_dir
	rm -f $(TARGET).v*.bin $(TARGET).logTrace
	rm -rf $(TARGET).v
	rm -rf cpu0.yaml *.vcd Murax.*
	rm -f *.mem *.sage.py *.v
