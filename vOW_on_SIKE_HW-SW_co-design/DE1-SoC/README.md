Generate and synthesize Murax cores for the DE1-SoC board.

Possible configuration targets are:

 - Murax
 - MuraxSparseMul 


## Generate a Murax core:

```sh
make TARGET=target gen
```


## Synthesize (includes 'make gen'):

```sh
make TARGET=target  
```


## Program the FPGA:

```sh
make TARGET=target program
```

