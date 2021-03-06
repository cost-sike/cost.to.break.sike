####  Makefile for compilation on Linux  ####

OPT=-O3   # Optimization option by default

CC=gcc

# Prime for the P128 implementation
P128_PRIME=p_32_20

ifeq "$(CC)" "gcc"
    COMPILER=gcc
else ifeq "$(CC)" "clang"
    COMPILER=clang
endif

ARCHITECTURE=_AMD64_
USE_OPT_LEVEL=_FAST_
ifeq "$(ARCH)" "x64"
    ARCHITECTURE=_AMD64_
    USE_OPT_LEVEL=_FAST_
else ifeq "$(ARCH)" "x86"
    ARCHITECTURE=_X86_
    USE_OPT_LEVEL=_GENERIC_
endif

ifeq "$(OPT_LEVEL)" "GENERIC"
    USE_OPT_LEVEL=_GENERIC_
endif

ifeq "$(ARCHITECTURE)" "_AMD64_"
	ifeq "$(USE_OPT_LEVEL)" "_FAST_"
		MULX=-D _MULX_
		ifeq "$(USE_MULX)" "FALSE"
			MULX=
		else
			ADX=-D _ADX_
			ifeq "$(USE_ADX)" "FALSE"
				ADX=
			endif
		endif
	endif
endif

ifeq "$(SET)" "EXTENDED"
    ADDITIONAL_SETTINGS=-fwrapv -fomit-frame-pointer -march=native
endif

AR=ar rcs
RANLIB=ranlib

CFLAGS=$(OPT) $(ADDITIONAL_SETTINGS) -D $(ARCHITECTURE) -D __LINUX__ -D $(USE_OPT_LEVEL) -D $(P128_PRIME) $(MULX) $(ADX) -fPIE
LDFLAGS=-lm

ifeq "$(ARCHITECTURE)" "_AMD64_"
ifeq "$(USE_OPT_LEVEL)" "_FAST_"
CFLAGS += -mavx2 -maes -msse2
endif
endif

ifeq "$(USE_OPT_LEVEL)" "_GENERIC_"
    EXTRA_OBJECTS_128=objs128/fp_generic.o
    EXTRA_OBJECTS_377=objs377/fp_generic.o
    EXTRA_OBJECTS_434=objs434/fp_generic.o
else ifeq "$(USE_OPT_LEVEL)" "_FAST_"
ifeq "$(ARCHITECTURE)" "_AMD64_"
	EXTRA_OBJECTS_128=objs128/fp_x64.o objs128/fp_x64_asm.o
	EXTRA_OBJECTS_377=objs377/fp_x64.o objs377/fp_x64_asm.o
	EXTRA_OBJECTS_434=objs434/fp_x64.o objs434/fp_x64_asm.o
	CFLAGS+= -fPIC
endif
endif
OBJECTS_128=objs128/P128.o $(EXTRA_OBJECTS_128) objs/random.o objs/fips202.o
OBJECTS_377=objs377/P377.o $(EXTRA_OBJECTS_377) objs/random.o objs/fips202.o
OBJECTS_434=objs434/P434.o $(EXTRA_OBJECTS_434) objs/random.o objs/fips202.o

all: lib128 lib377 lib434 tests_vow_sike

objs128/%.o: src/P128/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

objs377/%.o: src/P377/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

objs434/%.o: src/P434/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

ifeq "$(USE_OPT_LEVEL)" "_GENERIC_"
objs128/fp_generic.o: src/P128/generic/fp_generic.c
	$(CC) -c $(CFLAGS) src/P128/generic/fp_generic.c -o objs128/fp_generic.o

objs377/fp_generic.o: src/P377/generic/fp_generic.c
	$(CC) -c $(CFLAGS) src/P377/generic/fp_generic.c -o objs377/fp_generic.o

objs434/fp_generic.o: src/P434/generic/fp_generic.c
	$(CC) -c $(CFLAGS) src/P434/generic/fp_generic.c -o objs434/fp_generic.o
else ifeq "$(USE_OPT_LEVEL)" "_FAST_"
ifeq "$(ARCHITECTURE)" "_AMD64_"
objs128/fp_x64.o: src/P128/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P128/AMD64/fp_x64.c -o objs128/fp_x64.o

objs128/fp_x64_asm.o: src/P128/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P128/AMD64/fp_x64_asm.S -o objs128/fp_x64_asm.o

objs377/fp_x64.o: src/P377/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P377/AMD64/fp_x64.c -o objs377/fp_x64.o

objs377/fp_x64_asm.o: src/P377/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P377/AMD64/fp_x64_asm.S -o objs377/fp_x64_asm.o

objs434/fp_x64.o: src/P434/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P434/AMD64/fp_x64.c -o objs434/fp_x64.o

objs434/fp_x64_asm.o: src/P434/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P434/AMD64/fp_x64_asm.S -o objs434/fp_x64_asm.o
endif
endif

INDEPENDENT_OBJS=objs/random.o objs/fips202.o objs/prng.o objs/sike_vow.o objs/sike_vow_constants.o objs/xxhash.o
objs/random.o: src/random/random.c
objs/fips202.o: src/sha3/fips202.c
objs/prng.o: src/prng.c
objs/sike_vow.o: src/sike_vow.c
objs/sike_vow_constants.o: src/sike_vow_constants.c
objs/xxhash.o: src/xxhash/xxhash.c

DEPENDENT_OBJS_128=objs/sike_vow128.o objs/sike_vow_constants128.o 
objs/sike_vow128.o: src/sike_vow.c
objs/sike_vow_constants128.o: src/sike_vow_constants.c
$(DEPENDENT_OBJS_128):
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -D P128 $< -o $@

DEPENDENT_OBJS_377=objs/sike_vow377.o objs/sike_vow_constants377.o
objs/sike_vow377.o: src/sike_vow.c
objs/sike_vow_constants377.o: src/sike_vow_constants.c
$(DEPENDENT_OBJS_377):
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -D P377 $< -o $@

DEPENDENT_OBJS_434=objs/sike_vow434.o objs/sike_vow_constants434.o
objs/sike_vow434.o: src/sike_vow.c
objs/sike_vow_constants434.o: src/sike_vow_constants.c
$(DEPENDENT_OBJS_434):
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -D P434 $< -o $@

$(INDEPENDENT_OBJS):
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

lib128: $(OBJECTS_128)
	rm -rf lib128 sike128
	mkdir lib128 sike128
	$(AR) lib128/libsidh.a $^
	$(RANLIB) lib128/libsidh.a

lib377: $(OBJECTS_377)
	rm -rf lib377 sike377
	mkdir lib377 sike377
	$(AR) lib377/libsidh.a $^
	$(RANLIB) lib377/libsidh.a

lib434: $(OBJECTS_434)
	rm -rf lib434 sike434
	mkdir lib434 sike434
	$(AR) lib434/libsidh.a $^
	$(RANLIB) lib434/libsidh.a
	
# AES
AES_OBJS=objs/aes/aes.o objs/aes/aes_c.o
objs/aes/aes.o: src/aes/aes.c
objs/aes/aes_c.o: src/aes/aes_c.c
ifeq "$(ARCHITECTURE)" "_AMD64_"
ifeq "$(USE_OPT_LEVEL)" "_FAST_"
AES_OBJS=objs/aes/aes.o objs/aes/aes_ni.o
objs/aes/aes.o: src/aes/aes.c
objs/aes/aes_ni.o: src/aes/aes_ni.c
endif
endif
$(AES_OBJS):
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

## vOW against a SIKE 2-isogeny tree

vow_sike128: objs/sike_vow128.o objs/prng.o objs/sike_vow_constants128.o objs/xxhash.o objs/fips202.o $(AES_OBJS)
	rm -rf vow_sike
	mkdir vow_sike
	$(AR) vow_sike/libvow_sike.a $^
	$(RANLIB) vow_sike/libvow_sike.a

vow_sike377: objs/sike_vow377.o objs/prng.o objs/sike_vow_constants377.o objs/xxhash.o objs/fips202.o $(AES_OBJS)
	rm -rf vow_sike
	mkdir vow_sike
	$(AR) vow_sike/libvow_sike.a $^
	$(RANLIB) vow_sike/libvow_sike.a

vow_sike434: objs/sike_vow434.o objs/prng.o objs/sike_vow_constants434.o objs/xxhash.o objs/fips202.o $(AES_OBJS)
	rm -rf vow_sike
	mkdir vow_sike
	$(AR) vow_sike/libvow_sike.a $^
	$(RANLIB) vow_sike/libvow_sike.a

vow_sike: vow_sike128 vow_sike377 vow_sike434 

tests_vow_sike128: vow_sike128 lib128
	$(CC) $(CFLAGS) -D P128 -L./vow_sike -L./lib128 tests/test_vOW_SIKE.c tests/test_extras.c -lvow_sike -lsidh $(LDFLAGS) -o test_vOW_SIKE_128 $(ARM_SETTING)
	
tests_vow_sike377: vow_sike377 lib377
	$(CC) $(CFLAGS) -D P377 -L./vow_sike -L./lib377 tests/test_vOW_SIKE.c tests/test_extras.c -lvow_sike -lsidh $(LDFLAGS) -o test_vOW_SIKE_377 $(ARM_SETTING)

tests_vow_sike434: vow_sike434 lib434
	$(CC) $(CFLAGS) -D P434 -L./vow_sike -L./lib434 tests/test_vOW_SIKE.c tests/test_extras.c -lvow_sike -lsidh $(LDFLAGS) -o test_vOW_SIKE_434 $(ARM_SETTING)

tests_vow_sike: tests_vow_sike128 tests_vow_sike377 tests_vow_sike434

check: tests_vow_sike

.PHONY: clean

clean:
	rm -rf *.req objs* lib* sike* vow_* test_vOW_*
