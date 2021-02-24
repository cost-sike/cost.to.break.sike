# Proof-of-concept HW/SW co-design of the van Oorschot and Wiener (vOW) attack on SIKE 
# Paper "The Cost to Break SIKE: A Comparative Hardware-Based Analysis with AES and SHA-3"

This library contains a proof-of-concept HW/SW co-design of the parallel collision search algorithm by van Oorschot and Wiener (vOW)
for solving the supersingular isogeny problem in the context of the SIKE protocol using 2-isogeny graphs. 
The implementation is based on the software implementation provided in the folder "vOW_on_SIKE_software", which in turn
is based on the SIDH library version 3.3 (https://github.com/microsoft/PQCrypto-SIDH) and the vOW4SIKE library (https://github.com/microsoft/vOW4SIKE).


Index
====================

* [Code Organization](#code-organization) 

* [Install Pre-requisites](#install-pre-requisites) 

* [Tools Versions](#tools-versions) 

* [Real Tests On FPGAs](#real-tests-on-fpgas) 

* [Verilator Simulation](#verilator-simulation)


- - -
# Code Organization

- `platform/AC701/` contains hardware development files targeting the Artix-7 AC701 XC7A200TFBG676 FPGA.

- `platforms/DE1-SoC/` contains the hardware development files targeting the Cyclone V 5CSEMA5F31C6 FPGA.

- `platforms/Murax/` contains the scala source code for generating the Murax SoC.

- `platforms/rtl` contains the APB bridge modules developed for the communication between the software and hardware.

- `src/hardware` contains hardware accelerators source code.

- `src/murax` contains Murax library files.

- `src/ref_c` contains the modified SIKE software implementation, which is based on the
[SIKE cryptanalysis reference software implementation].

- `src/ref_c_riscv` contains the software libraries for calling the hardware accelerators
and RISC-V testing files.


- - -
# Install Pre-requisites

You need to install the following tools before running our design:

All the following information are collected from the README.md files from

- https://github.com/SpinalHDL/openocd_riscv 
- https://github.com/SpinalHDL/VexRiscv and 
- https://github.com/SpinalHDL/SpinalHDL

On Ubuntu 14 :

Install JAVA JDK 7 or 8

```sh
sudo apt-get install openjdk-8-jdk
```

Install SBT

```sh
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt
```

Compile the latest SpinalHDL

```sh
rm -rf SpinalHDL
git clone https://github.com/SpinalHDL/SpinalHDL.git 
```
 
Download VexRiscv hardware code  

```sh
git clone https://github.com/SpinalHDL/VexRiscv.git 
```
Install RISC-V GCC toolchain

```sh
# Get pre-compiled GCC
wget https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-20171231-x86_64-linux-centos6.tar.gz
tar -xzvf riscv64-unknown-elf-gcc-20171231-x86_64-linux-centos6.tar.gz
sudo mv riscv64-unknown-elf-gcc-20171231-x86_64-linux-centos6 /opt/riscv64-unknown-elf-gcc-20171231-x86_64-linux-centos6
sudo mv /opt/riscv64-unknown-elf-gcc-20171231-x86_64-linux-centos6 /opt/riscv
echo 'export PATH=/opt/riscv/bin:$PATH' >> ~/.bashrc
```

Download and build openocd

```sh
# Get OpenOCD version from SpinalHDL
git clone https://github.com/SpinalHDL/openocd_riscv.git
# Install OpenOCD dependencies:
sudo apt-get install libtool automake libusb-1.0.0-dev texinfo libusb-dev libyaml-dev pkg-config
./bootstrap
./configure --enable-ftdi --enable-dummy
make
```  

Install Verilator (for simulation):

```sh
sudo apt-get install verilator
```

- - -
# Tools Versions

Here are the versions of the tools that we use locally for testing, we recommend that users use the same version of the tools.

- SageMath (sage) 6.3 and 7.4

- Python (python) 2.7

- Icarus Verilog (iverilog) 0.9.7

- Vivado 2018.3

- Quartus (quartus) 16.1

- Verilator 3.874

- gcc version 5.4.0

- others: newest versions


- - -
# Real Tests On FPGAs

Hardware pre-requisites: 

- Artix-7 AC701 XC7A200TFBG676 FPGA
- HW-FMC-105 DBUG card for extending GPIO pins on the FPGA 
- USB-JTAG connection for programming the FPGA
- USB-serial connection for IO of the Murax SoC
- USB-JTAG connection for programming and debugging the software on the Murax SoC

Note: We tested our designs on both Xilinx Artix-7 AC701 and Cyclone V (Intel-Altera) FPGAs. 
Our design is not FPGA specific and therefore should run on any FPGA which has enough logic resources and memory.  

The following steps show how to run the whole software-hardware co-design on the FPGA (compile the code, start openocd, start serial interface, load the binary to the Murax SoC through jtagd, check outputs, etc)

### Step 1: Generate FPGA bitstream and program the FPGA
 
Choose **TARGET**

- `Murax` plain Murax SoC 
- `MuraxControllerMontgomeryMultiplier` Murax SoC integrated with SIKE isogeny accelerator
 
Generate the bitstream and program the FPGA:

```sh 
cd platforms/AC701/
make TARGET=Murax clean 
make TARGET=Murax program 
```

### Step 2: Open serial port connection to the Muarx SoC on FPGA

Start a new terminal window

```sh
# Assuming /dev/ttyUSB5 is the serial port
# If $USER is not in "dialout" group, need to use add sudo before minicom
minicom --baudrate 9600 --device=/dev/ttyUSB0
``` 

### Step 3: Open jtag connection to Murax on FPGA

Start a new terminal window

```sh 
cd openocd_riscv
sudo src/openocd -f tcl/interface/ftdi/c232hm.cfg -c "set MURAX_CPU0_YAML ../SIKE_HW_cryptanalysis/platforms/AC701/cpu0.yaml" -f tcl/target/murax.cfg
```

### Step 4: Connect GDB to load binary onto the Murax SoC on FPGA through Murax jtag interface

Start a new terminal window

Now, compile the software code for the required **TARGET** and load it to the Murax SoC
(here, the **TARGET** must fit to the hardware platform from Step 1):

```sh
cd src/ref_c_riscv/SIKE_cryptanalysis
make TARGET=Murax PROJ=test_vOW_SIKE clean
make TARGET=Murax PROJ=test_vOW_SIKE run  
```

### Step 5: Verify outputs

The outputs are displayed in the minicom window (Step 2).


---
# Verilator Simulation

The following steps show how to simulate the whole software-hardware co-design (instantiate the SoC, compile the software code, load the binary file to the Murax SoC through jtagd, display outputs in the minicom window, etc.)
 
### Step 1: Start the simulation in terminal window A

Choose **TARGET** from:

- `Murax` plain Murax SoC 

Run the simulation:
 
```sh
cd platforms/verilator_sim  
make TARGET=$(TARGET) (PRECOMP=yes) clean
# run the simulation
make TARGET=$(TARGET) (PRECOMP=yes) run
#check: platforms/DE1-SoC/README.md for more information 
```

After successfully running this step, you should see: `BOOT` in the terminal window A, now you are ready to start openocd


### Step 2: Start openocd in a new terminal window B

Start a new terminal window

```sh 
cd openocd_riscv
# start openocd
sudo src/openocd -f tcl/interface/jtag_tcp.cfg -c "set MURAX_CPU0_YAML ../SIKE_HW_cryptanalysis/platforms/verilator_sim/cpu0.yaml" -f tcl/target/murax.cfg
```

After successfully running this step, you should see: `CONNECTED` after the previous `BOOT` in terminal A

### Step 3: Load a code binary onto Murax:

Start a new terminal window

The **TARGET** must fit to the hardware platform from Step 1;  

Compile the software code for the required **TARGET** and load it to the Murax SoC:

```sh
# compile the code, generate the binary, then load to the Murax through the jtagd interface
make TARGET=$(TARGET) PROJ=$(PROJ) SIM=yes run  
```

### Step 4: Verify outputs

Check the outputs displayed in the terminal window A, the results are shown below `BOOT` and `CONNECTED`

### Start new tests

- To start a new software test with the same SoC configuration, re-do Step 3.

- To start a new software test with a different SoC configuration, re-do all the steps.

 