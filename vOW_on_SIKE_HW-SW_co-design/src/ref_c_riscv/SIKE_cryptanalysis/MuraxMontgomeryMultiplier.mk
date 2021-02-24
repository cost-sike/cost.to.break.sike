CFLAGS += -DMONTMUL_HARDWARE 

VPATH += ../hardware/library/

INC += -I../hardware/include/

SOURCES += ../hardware/library/fp2mul_mont_hw.c