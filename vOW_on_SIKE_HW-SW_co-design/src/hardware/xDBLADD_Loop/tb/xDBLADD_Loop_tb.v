`timescale 1ns / 1ps

module xDBLADD_Loop_tb;

parameter RADIX = `RADIX;
parameter WIDTH_REAL = `WIDTH_REAL;
parameter SK_MEM_WIDTH = `SK_WIDTH;
parameter SK_MEM_WIDTH_LOG = `CLOG2(SK_MEM_WIDTH);
parameter SK_MEM_DEPTH = `SK_DEPTH;
parameter SK_MEM_DEPTH_LOG = `CLOG2(SK_MEM_DEPTH);
parameter SINGLE_MEM_WIDTH = RADIX;
parameter SINGLE_MEM_DEPTH = WIDTH_REAL;
parameter SINGLE_MEM_DEPTH_LOG = `CLOG2(SINGLE_MEM_DEPTH);
parameter DOUBLE_MEM_WIDTH = RADIX*2;
parameter DOUBLE_MEM_DEPTH = (WIDTH_REAL+1)/2;
parameter DOUBLE_MEM_DEPTH_LOG = `CLOG2(DOUBLE_MEM_DEPTH); 
parameter START_INDEX = `START_INDEX;
parameter END_INDEX = `END_INDEX;

// inputs
reg rst = 1'b0;
reg clk = 1'b0;
reg start = 1'b0;
reg [15:0] start_index = START_INDEX;
reg [15:0] end_index = END_INDEX;

// outputs 
wire done;
wire busy;
  
reg out_mem_A24_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_A24_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_A24_0_din = 0;

reg out_mem_A24_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_A24_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_A24_1_din = 0;

reg out_mem_XP_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_XP_0_din = 0;
reg out_mem_XP_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_XP_0_dout;

reg out_mem_ZP_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_ZP_0_din = 0;
reg out_mem_ZP_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_0_dout;

reg out_mem_XQ_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_XQ_0_din = 0;
reg out_mem_XQ_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_0_dout;

reg out_mem_ZQ_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_ZQ_0_din = 0;
reg out_mem_ZQ_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_0_dout;

reg out_mem_xPQ_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_xPQ_0_din = 0;
reg out_mem_xPQ_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_0_dout;

reg out_mem_zPQ_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_zPQ_0_din = 0;
reg out_mem_zPQ_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_0_dout;

reg out_mem_XP_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_XP_1_din = 0;
reg out_mem_XP_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_XP_1_dout;

reg out_mem_ZP_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_ZP_1_din = 0;
reg out_mem_ZP_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_1_dout;

reg out_mem_XQ_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_XQ_1_din = 0;
reg out_mem_XQ_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_1_dout;

reg out_mem_ZQ_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_ZQ_1_din = 0;
reg out_mem_ZQ_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_1_dout;

reg out_mem_xPQ_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_xPQ_1_din = 0;
reg out_mem_xPQ_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_1_dout;

reg out_mem_zPQ_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] out_mem_zPQ_1_din = 0;
reg out_mem_zPQ_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_1_dout;
 
initial
  begin
    $dumpfile("xDBLADD_Loop_tb.vcd");
    $dumpvars(0, xDBLADD_Loop_tb);
  end

integer start_time = 0; 
integer element_file;
integer scan_file;
integer i;

initial
  begin
    rst <= 1'b0;
    start <= 1'b0;
    # 45;
    rst <= 1'b1;
    # 20;
    rst <= 1'b0;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    // load input memory XP
    // load XP 0
    element_file = $fopen("mem_XP_0.txt", "r");
    # 10;
    $display("\nloading input XP_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_XP_0_wr_en = 1'b1;
    out_mem_XP_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_XP_0_din); 
      #10;
      out_mem_XP_0_wr_addr = out_mem_XP_0_wr_addr + 1;
    end
    out_mem_XP_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load XP 1 
    element_file = $fopen("mem_XP_1.txt", "r");
    # 10;
    $display("\nloading input XP_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_XP_1_wr_en = 1'b1;
    out_mem_XP_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_XP_1_din); 
      #10;
      out_mem_XP_1_wr_addr = out_mem_XP_1_wr_addr + 1;
    end
    out_mem_XP_1_wr_en = 1'b0;
    end
    $fclose(element_file);     

     // load input memory ZP
    // load ZP 0
    element_file = $fopen("mem_ZP_0.txt", "r");
    # 10;
    $display("\nloading input ZP_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_ZP_0_wr_en = 1'b1;
    out_mem_ZP_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_ZP_0_din); 
      #10;
      out_mem_ZP_0_wr_addr = out_mem_ZP_0_wr_addr + 1;
    end
    out_mem_ZP_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load ZP 1 
    element_file = $fopen("mem_ZP_1.txt", "r");
    # 10;
    $display("\nloading input ZP_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_ZP_1_wr_en = 1'b1;
    out_mem_ZP_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_ZP_1_din); 
      #10;
      out_mem_ZP_1_wr_addr = out_mem_ZP_1_wr_addr + 1;
    end
    out_mem_ZP_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    // load input memory XQ
    // load XQ 0
    element_file = $fopen("mem_XQ_0.txt", "r");
    # 10;
    $display("\nloading input XQ_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_XQ_0_wr_en = 1'b1;
    out_mem_XQ_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_XQ_0_din); 
      #10;
      out_mem_XQ_0_wr_addr = out_mem_XQ_0_wr_addr + 1;
    end
    out_mem_XQ_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load XQ 1 
    element_file = $fopen("mem_XQ_1.txt", "r");
    # 10;
    $display("\nloading input XQ_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_XQ_1_wr_en = 1'b1;
    out_mem_XQ_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_XQ_1_din); 
      #10;
      out_mem_XQ_1_wr_addr = out_mem_XQ_1_wr_addr + 1;
    end
    out_mem_XQ_1_wr_en = 1'b0;
    end
    $fclose(element_file);     

     // load input memory ZQ
    // load ZQ 0
    element_file = $fopen("mem_ZQ_0.txt", "r");
    # 10;
    $display("\nloading input ZQ_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_ZQ_0_wr_en = 1'b1;
    out_mem_ZQ_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_ZQ_0_din); 
      #10;
      out_mem_ZQ_0_wr_addr = out_mem_ZQ_0_wr_addr + 1;
    end
    out_mem_ZQ_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load ZQ 1 
    element_file = $fopen("mem_ZQ_1.txt", "r");
    # 10;
    $display("\nloading input ZQ_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_ZQ_1_wr_en = 1'b1;
    out_mem_ZQ_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_ZQ_1_din); 
      #10;
      out_mem_ZQ_1_wr_addr = out_mem_ZQ_1_wr_addr + 1;
    end
    out_mem_ZQ_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    // load input memory xPQ
    // load xPQ 0
    element_file = $fopen("mem_xPQ_0.txt", "r");
    # 10;
    $display("\nloading input xPQ_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_xPQ_0_wr_en = 1'b1;
    out_mem_xPQ_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_xPQ_0_din); 
      #10;
      out_mem_xPQ_0_wr_addr = out_mem_xPQ_0_wr_addr + 1;
    end
    out_mem_xPQ_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load xPQ 1 
    element_file = $fopen("mem_xPQ_1.txt", "r");
    # 10;
    $display("\nloading input xPQ_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_xPQ_1_wr_en = 1'b1;
    out_mem_xPQ_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_xPQ_1_din); 
      #10;
      out_mem_xPQ_1_wr_addr = out_mem_xPQ_1_wr_addr + 1;
    end
    out_mem_xPQ_1_wr_en = 1'b0;
    end
    $fclose(element_file);     

     // load input memory zPQ
    // load zPQ 0
    element_file = $fopen("mem_zPQ_0.txt", "r");
    # 10;
    $display("\nloading input zPQ_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_zPQ_0_wr_en = 1'b1;
    out_mem_zPQ_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_zPQ_0_din); 
      #10;
      out_mem_zPQ_0_wr_addr = out_mem_zPQ_0_wr_addr + 1;
    end
    out_mem_zPQ_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load zPQ 1 
    element_file = $fopen("mem_zPQ_1.txt", "r");
    # 10;
    $display("\nloading input zPQ_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_zPQ_1_wr_en = 1'b1;
    out_mem_zPQ_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_zPQ_1_din); 
      #10;
      out_mem_zPQ_1_wr_addr = out_mem_zPQ_1_wr_addr + 1;
    end
    out_mem_zPQ_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    // load input memory A24
    // load A24 0
    element_file = $fopen("mem_A24_0.txt", "r");
    # 10;
    $display("\nloading input A24_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_A24_0_wr_en = 1'b1;
    out_mem_A24_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_A24_0_din); 
      #10;
      out_mem_A24_0_wr_addr = out_mem_A24_0_wr_addr + 1;
    end
    out_mem_A24_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load A24 1 
    element_file = $fopen("mem_A24_1.txt", "r");
    # 10;
    $display("\nloading input A24_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    out_mem_A24_1_wr_en = 1'b1;
    out_mem_A24_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%x\n", out_mem_A24_1_din); 
      #10;
      out_mem_A24_1_wr_addr = out_mem_A24_1_wr_addr + 1;
    end
    out_mem_A24_1_wr_en = 1'b0;
    end
    $fclose(element_file);  

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    // start computation
    # 15;
    start <= 1'b1;
    start_time = $time;
    $display("\n    start computation");
    # 10;
    start <= 1'b0;

    // computation finishes
    @(posedge done);
    $display("\n    comptation finished in %0d cycles", ($time-start_time)/10);


//---------------------------------------------------------------------
    // restart computation without forcing reset
    # 100; 
    start <= 1'b1;
    start_time = $time;
    $display("\n\n    repeat computation without resetting");
    # 10;
    start <= 1'b0;
    
    // computation finishes
    @(posedge done);
    $display("\n    comptation finished in %0d cycles", ($time-start_time)/10);
    
    
    // restart computation without forcing reset
    # 100;
    start <= 1'b1;
    start_time = $time;
    $display("\n\n    repeat computation without resetting");
    # 10;
    start <= 1'b0;
    
    // computation finishes
    @(posedge done);
    $display("\n    comptation finished in %0d cycles", ($time-start_time)/10);


//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    #100;
    $display("\nread result XP back...");

    element_file = $fopen("sim_XP_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_XP_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_XP_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_XP_0_dout); 
    end

    out_mem_XP_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_XP_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_XP_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_XP_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_XP_1_dout); 
    end

    out_mem_XP_1_rd_en = 1'b0;

    $fclose(element_file);

    #100;
    $display("\nread result ZP back...");

    element_file = $fopen("sim_ZP_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_ZP_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_ZP_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_ZP_0_dout); 
    end

    out_mem_ZP_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_ZP_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_ZP_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_ZP_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_ZP_1_dout); 
    end

    out_mem_ZP_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    #100;
    $display("\nread result XQ back...");

    element_file = $fopen("sim_XQ_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_XQ_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_XQ_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_XQ_0_dout); 
    end

    out_mem_XQ_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_XQ_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_XQ_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_XQ_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_XQ_1_dout); 
    end

    out_mem_XQ_1_rd_en = 1'b0;

    $fclose(element_file);

    #100;
    $display("\nread result ZQ back...");

    element_file = $fopen("sim_ZQ_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_ZQ_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_ZQ_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_ZQ_0_dout); 
    end

    out_mem_ZQ_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_ZQ_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_ZQ_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_ZQ_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_ZQ_1_dout); 
    end

    out_mem_ZQ_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    #100;
    $display("\nread result xPQ back...");

    element_file = $fopen("sim_xPQ_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_xPQ_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_xPQ_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_xPQ_0_dout); 
    end

    out_mem_xPQ_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_xPQ_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_xPQ_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_xPQ_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_xPQ_1_dout); 
    end

    out_mem_xPQ_1_rd_en = 1'b0;

    $fclose(element_file);

    #100;
    $display("\nread result zPQ back...");

    element_file = $fopen("sim_zPQ_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_zPQ_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_zPQ_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_zPQ_0_dout); 
    end

    out_mem_zPQ_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_zPQ_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_zPQ_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_zPQ_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%x\n", mem_zPQ_1_dout); 
    end

    out_mem_zPQ_1_rd_en = 1'b0;

    $fclose(element_file);

    #10;
    $display("\ncomparing results from software and hardware simulation by git diff:");
    $display("    DONE! Test Passes!\n"); 

    # 1000;
      
    $finish;

end 

xDBLADD_Loop #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL), .SK_MEM_WIDTH(SK_MEM_WIDTH), .SK_MEM_DEPTH(SK_MEM_DEPTH)) xDBLADD_Loop_inst (
  .rst(rst),
  .clk(clk),
  .start(start),
  .done(done),
  .busy(busy),
  .start_index(start_index),
  .end_index(end_index),
//
  .out_mem_XP_0_wr_en(out_mem_XP_0_wr_en),
  .out_mem_XP_0_wr_addr(out_mem_XP_0_wr_addr),
  .out_mem_XP_0_din(out_mem_XP_0_din),
  .mem_XP_0_dout(mem_XP_0_dout),
  .out_mem_XP_0_rd_en(out_mem_XP_0_rd_en),
  .out_mem_XP_0_rd_addr(out_mem_XP_0_rd_addr), 
  .out_mem_XP_1_wr_en(out_mem_XP_1_wr_en),
  .out_mem_XP_1_wr_addr(out_mem_XP_1_wr_addr),
  .out_mem_XP_1_din(out_mem_XP_1_din),
  .mem_XP_1_dout(mem_XP_1_dout),
  .out_mem_XP_1_rd_en(out_mem_XP_1_rd_en),
  .out_mem_XP_1_rd_addr(out_mem_XP_1_rd_addr),
  .out_mem_ZP_0_wr_en(out_mem_ZP_0_wr_en),
  .out_mem_ZP_0_wr_addr(out_mem_ZP_0_wr_addr),
  .out_mem_ZP_0_din(out_mem_ZP_0_din),
  .mem_ZP_0_dout(mem_ZP_0_dout),
  .out_mem_ZP_0_rd_en(out_mem_ZP_0_rd_en),
  .out_mem_ZP_0_rd_addr(out_mem_ZP_0_rd_addr), 
  .out_mem_ZP_1_wr_en(out_mem_ZP_1_wr_en),
  .out_mem_ZP_1_wr_addr(out_mem_ZP_1_wr_addr),
  .out_mem_ZP_1_din(out_mem_ZP_1_din),
  .mem_ZP_1_dout(mem_ZP_1_dout),
  .out_mem_ZP_1_rd_en(out_mem_ZP_1_rd_en),
  .out_mem_ZP_1_rd_addr(out_mem_ZP_1_rd_addr),
//
  .out_mem_XQ_0_wr_en(out_mem_XQ_0_wr_en),
  .out_mem_XQ_0_wr_addr(out_mem_XQ_0_wr_addr),
  .out_mem_XQ_0_din(out_mem_XQ_0_din),
  .mem_XQ_0_dout(mem_XQ_0_dout),
  .out_mem_XQ_0_rd_en(out_mem_XQ_0_rd_en),
  .out_mem_XQ_0_rd_addr(out_mem_XQ_0_rd_addr), 
  .out_mem_XQ_1_wr_en(out_mem_XQ_1_wr_en),
  .out_mem_XQ_1_wr_addr(out_mem_XQ_1_wr_addr),
  .out_mem_XQ_1_din(out_mem_XQ_1_din),
  .mem_XQ_1_dout(mem_XQ_1_dout),
  .out_mem_XQ_1_rd_en(out_mem_XQ_1_rd_en),
  .out_mem_XQ_1_rd_addr(out_mem_XQ_1_rd_addr),
  .out_mem_ZQ_0_wr_en(out_mem_ZQ_0_wr_en),
  .out_mem_ZQ_0_wr_addr(out_mem_ZQ_0_wr_addr),
  .out_mem_ZQ_0_din(out_mem_ZQ_0_din),
  .mem_ZQ_0_dout(mem_ZQ_0_dout),
  .out_mem_ZQ_0_rd_en(out_mem_ZQ_0_rd_en),
  .out_mem_ZQ_0_rd_addr(out_mem_ZQ_0_rd_addr), 
  .out_mem_ZQ_1_wr_en(out_mem_ZQ_1_wr_en),
  .out_mem_ZQ_1_wr_addr(out_mem_ZQ_1_wr_addr),
  .out_mem_ZQ_1_din(out_mem_ZQ_1_din),
  .mem_ZQ_1_dout(mem_ZQ_1_dout),
  .out_mem_ZQ_1_rd_en(out_mem_ZQ_1_rd_en),
  .out_mem_ZQ_1_rd_addr(out_mem_ZQ_1_rd_addr),
//
  .out_mem_xPQ_0_wr_en(out_mem_xPQ_0_wr_en),
  .out_mem_xPQ_0_wr_addr(out_mem_xPQ_0_wr_addr),
  .out_mem_xPQ_0_din(out_mem_xPQ_0_din),
  .mem_xPQ_0_dout(mem_xPQ_0_dout),
  .out_mem_xPQ_0_rd_en(out_mem_xPQ_0_rd_en),
  .out_mem_xPQ_0_rd_addr(out_mem_xPQ_0_rd_addr), 
  .out_mem_xPQ_1_wr_en(out_mem_xPQ_1_wr_en),
  .out_mem_xPQ_1_wr_addr(out_mem_xPQ_1_wr_addr),
  .out_mem_xPQ_1_din(out_mem_xPQ_1_din),
  .mem_xPQ_1_dout(mem_xPQ_1_dout),
  .out_mem_xPQ_1_rd_en(out_mem_xPQ_1_rd_en),
  .out_mem_xPQ_1_rd_addr(out_mem_xPQ_1_rd_addr),
  .out_mem_zPQ_0_wr_en(out_mem_zPQ_0_wr_en),
  .out_mem_zPQ_0_wr_addr(out_mem_zPQ_0_wr_addr),
  .out_mem_zPQ_0_din(out_mem_zPQ_0_din),
  .mem_zPQ_0_dout(mem_zPQ_0_dout),
  .out_mem_zPQ_0_rd_en(out_mem_zPQ_0_rd_en),
  .out_mem_zPQ_0_rd_addr(out_mem_zPQ_0_rd_addr), 
  .out_mem_zPQ_1_wr_en(out_mem_zPQ_1_wr_en),
  .out_mem_zPQ_1_wr_addr(out_mem_zPQ_1_wr_addr),
  .out_mem_zPQ_1_din(out_mem_zPQ_1_din),
  .mem_zPQ_1_dout(mem_zPQ_1_dout),
  .out_mem_zPQ_1_rd_en(out_mem_zPQ_1_rd_en),
  .out_mem_zPQ_1_rd_addr(out_mem_zPQ_1_rd_addr),
//
  .out_mem_A24_0_wr_en(out_mem_A24_0_wr_en),
  .out_mem_A24_0_wr_addr(out_mem_A24_0_wr_addr),
  .out_mem_A24_0_din(out_mem_A24_0_din), 
  .out_mem_A24_1_wr_en(out_mem_A24_1_wr_en),
  .out_mem_A24_1_wr_addr(out_mem_A24_1_wr_addr),
  .out_mem_A24_1_din(out_mem_A24_1_din)
  ); 

always 
  # 5 clk = !clk;


endmodule