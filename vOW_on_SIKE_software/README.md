# Software implementation of the van Oorschot and Wiener (vOW) attack on SIKE 
# Paper "The Cost to Break SIKE: A Comparative Hardware-Based Analysis with AES and SHA-3"

This library contains an efficient C implementation of the parallel collision search algorithm by van Oorschot and Wiener (vOW)
for solving the supersingular isogeny problem in the context of the SIKE protocol using 2-isogeny graphs. 
This software, which is used as the basis for the HW/SW co-design implementation of the attack included in the paper,
is in turn based on the SIDH library version 3.3 (https://github.com/microsoft/PQCrypto-SIDH)
and the vOW4SIKE library (https://github.com/microsoft/vOW4SIKE).

This library includes the following vOW setups:

* vOW on SIKEp128: collision search on a toy parameter (p = 23 * 2^32*3^20 - 1) for experimentation purposes.
* vOW on SIKEp377: collision search on a NEW parameter matching the post-quantum security of AES128 (level 1).
* vOW on SIKEp434: collision search on a parameter matching the post-quantum security of AES128 (level 1).

In the remainder, pXXX is one of {p128,p377,p434}.

## Instructions for Linux

By executing:

```sh
$ make
```

the library is compiled by default for x64 using gcc, optimization level `FAST` that uses assembly-optimized arithmetic
(this option requires CPU support for the instructions MULX and ADX).

Other options for x64:

```sh
$ make CC=[gcc/clang] OPT_LEVEL=[FAST/GENERIC]
```

The use of `OPT_LEVEL=GENERIC` disables the use of assembly-optimized arithmetic.

To run the full attack, execute:

```sh
$ ./test_vOW_SIKE_XXX
```

NOTE: full attacks on p377 and p434 can be stopped at any time using Control+C. The software displays a summary of partial results
for the attack up to that point.

To collect statistical data for only one function version run of the attack, execute:

```sh
$ ./test_vOW_SIKE_XXX -s
```

## XOF functionality

The xxHash non-cryptographic hash function is used by default for the XOF for improved performance.
Alternatively, one can use AES instead: comment out the define for USE_XXHASH_XOF in `\src\prng.h`, and uncomment the define for USE_AES_XOF.
