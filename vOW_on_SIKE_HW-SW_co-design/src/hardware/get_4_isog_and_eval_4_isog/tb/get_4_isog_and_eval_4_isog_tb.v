`timescale 1ns / 1ps

module get_4_isog_and_eval_4_isog_tb;

parameter RADIX = `RADIX;
parameter WIDTH_REAL = `WIDTH_REAL;
parameter SINGLE_MEM_WIDTH = RADIX;
parameter SINGLE_MEM_DEPTH = WIDTH_REAL;
parameter SINGLE_MEM_DEPTH_LOG = `CLOG2(SINGLE_MEM_DEPTH);
parameter DOUBLE_MEM_WIDTH = RADIX*2;
parameter DOUBLE_MEM_DEPTH = (WIDTH_REAL+1)/2;
parameter DOUBLE_MEM_DEPTH_LOG = `CLOG2(DOUBLE_MEM_DEPTH); 

// inputs
reg rst = 1'b0;
reg clk = 1'b0;
reg start = 1'b0;
reg eval_4_isog_XZ_newly_init = 1'b0;
reg last_eval_4_isog = 1'b0;
reg eval_4_isog_result_can_overwrite = 1'b1;

// outputs 
wire done;
wire busy; 
wire eval_4_isog_XZ_can_overwrite;
wire eval_4_isog_result_ready;
 
// interface with memory X4
reg mem_X4_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_X4_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_X4_0_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_X4_0_dout;
wire mem_X4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X4_0_rd_addr;

reg mem_X4_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_X4_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_X4_1_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_X4_1_dout;
wire mem_X4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X4_1_rd_addr;

// interface with memory Z4
reg mem_Z4_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z4_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_Z4_0_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_Z4_0_dout;
wire mem_Z4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z4_0_rd_addr;

reg mem_Z4_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z4_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_Z4_1_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_Z4_1_dout;
wire mem_Z4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z4_1_rd_addr;

// interface with memory X
reg mem_X_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_X_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_X_0_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_X_0_dout;
wire mem_X_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X_0_rd_addr;

reg mem_X_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_X_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_X_1_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_X_1_dout;
wire mem_X_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X_1_rd_addr;

// interface with memory Z
reg mem_Z_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_Z_0_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_Z_0_dout;
wire mem_Z_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z_0_rd_addr;

reg mem_Z_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_Z_1_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_Z_1_dout;
wire mem_Z_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z_1_rd_addr;
 
// interface with results memory t10 
reg out_mem_t10_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_dout;

reg out_mem_t10_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_dout;

// interface with results memory t11 
reg out_mem_t11_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t11_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t11_0_dout;

reg out_mem_t11_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t11_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t11_1_dout;

reg eval_4_isog_XZ_newly_init_pre = 1'b0;
reg eval_4_isog_XZ_newly_init_pre_buf = 1'b0;
reg eval_4_isog_result_can_overwrite_pre = 1'b0;
reg eval_4_isog_result_can_overwrite_pre_buf = 1'b0;

always @(posedge clk or negedge rst) begin
  if (rst) begin
    eval_4_isog_XZ_newly_init <= 1'b0;
    eval_4_isog_result_can_overwrite <= 1'b1;
    eval_4_isog_XZ_newly_init_pre_buf <= 1'b0;
    eval_4_isog_result_can_overwrite_pre_buf <= 1'b0;
  end
  else begin
    eval_4_isog_XZ_newly_init_pre_buf <= eval_4_isog_XZ_newly_init_pre;
    eval_4_isog_result_can_overwrite_pre_buf <= eval_4_isog_result_can_overwrite_pre;

    eval_4_isog_XZ_newly_init <= eval_4_isog_XZ_newly_init_pre | eval_4_isog_XZ_newly_init_pre_buf ? 1'b1 : 
                                 eval_4_isog_XZ_can_overwrite ? 1'b0 :
                                 eval_4_isog_XZ_newly_init;

    eval_4_isog_result_can_overwrite <= eval_4_isog_result_can_overwrite_pre | eval_4_isog_result_can_overwrite_pre_buf ? 1'b1 :
                                        eval_4_isog_result_ready ? 1'b0 :
                                        eval_4_isog_result_can_overwrite;
  end
end

 
 
initial
  begin
    $dumpfile("get_4_isog_and_eval_4_isog_tb.vcd");
    $dumpvars(0, get_4_isog_and_eval_4_isog_tb);
  end

integer start_time = 0; 
integer element_file;
integer scan_file;
integer i;


//--------------------------------------------------------------------------------------------
//--------------------------------------SOFTWARE SIDE-----------------------------------------
//-----------------------------------INIT INPUT MEMORY----------------------------------------
//--------------------------------------------------------------------------------------------
/*
// software checks if new (X, Z) input pair can be written to the input memory of eval_4_isog
  // first time load
initial begin 
    @(posedge start); 
    # 1000;
    //---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    element_file = $fopen("0-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("0-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("0-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("0-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;

    //---------------------------------------------------------------------
    //---------------------------------------------------------------------
    //---------------------------------------------------------------------

    @(posedge eval_4_isog_XZ_can_overwrite); 
    //---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    element_file = $fopen("1-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("1-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("1-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("1-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;

    //---------------------------------------------------------------------
    //---------------------------------------------------------------------
    //---------------------------------------------------------------------

    @(posedge eval_4_isog_XZ_can_overwrite);
    # 100;
    //---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    element_file = $fopen("2-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("2-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("2-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("2-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;
end

//--------------------------------------------------------------------------------------------
//--------------------------------------SOFTWARE SIDE-----------------------------------------
//-----------------------------------INIT INPUT MEMORY----------------------------------------
//--------------------------------------------------------------------------------------------
/*
  // second time load
initial begin
    @(posedge start); 
    # 1000;
    @(posedge eval_4_isog_XZ_can_overwrite); 
    //---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    element_file = $fopen("1-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("1-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("1-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("1-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;
end


//--------------------------------------------------------------------------------------------
//--------------------------------------SOFTWARE SIDE-----------------------------------------
//-----------------------------------INIT INPUT MEMORY----------------------------------------
//--------------------------------------------------------------------------------------------

  // third time load
initial begin
    @(posedge start); 
    # 1000;
    @(posedge eval_4_isog_XZ_can_overwrite);
    # 100;
    @(posedge eval_4_isog_XZ_can_overwrite);
    # 100;
    //---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    element_file = $fopen("2-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("2-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("2-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("2-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;
end
*/
 
//--------------------------------------------------------------------------------------------
//--------------------------------------SOFTWARE SIDE-----------------------------------------
//------------------------------READ BACK RESULTS FROM MEMORY---------------------------------
//--------------------------------------------------------------------------------------------
/*
// software read first pair of t10 and t11 results back
initial 
  begin
    # 1000;
    @(posedge eval_4_isog_result_ready);
    //---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("0-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("0-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("0-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("0-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file); 

    //---------------------------------------------------------------------
    //---------------------------------------------------------------------
    //---------------------------------------------------------------------

    @(posedge eval_4_isog_result_ready);

    # 100;
    last_eval_4_isog <= 1'b1;
    //---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("1-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("1-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("1-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("1-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file); 

    //---------------------------------------------------------------------
    //---------------------------------------------------------------------
    //---------------------------------------------------------------------

    @(posedge eval_4_isog_result_ready);
    //---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("2-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("2-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("2-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("2-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file);  


  end


//--------------------------------------------------------------------------------------------
//--------------------------------------SOFTWARE SIDE-----------------------------------------
//------------------------------READ BACK RESULTS FROM MEMORY---------------------------------
//--------------------------------------------------------------------------------------------
/*
// software read second pair of t10 and t11 results back
initial 
  begin
    # 1000;
    @(posedge eval_4_isog_result_ready);
    @(posedge eval_4_isog_result_ready);

    # 100;
    last_eval_4_isog <= 1'b1;
    //---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("1-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("1-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("1-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("1-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file);   
  end

//--------------------------------------------------------------------------------------------
//--------------------------------------SOFTWARE SIDE-----------------------------------------
//------------------------------READ BACK RESULTS FROM MEMORY---------------------------------
//--------------------------------------------------------------------------------------------

// software read third pair of t10 and t11 results back
initial 
  begin
    # 1000;
    @(posedge eval_4_isog_result_ready);
    @(posedge eval_4_isog_result_ready);
    @(posedge eval_4_isog_result_ready);
    //---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("2-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("2-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("2-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("2-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file);  
  end
*/
//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
//--------------------------------------HARDWARE SIDE----------------------------------------- 
//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------

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
    // load X4_0, X4_1, Z4_0, Z4_1 for get_4_isog
    // load X4_0 
    element_file = $fopen("get_4_isog_mem_X4_0.txt", "r");
    # 10;
    $display("\nloading input X4_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X4_0_wr_en = 1'b1;
    mem_X4_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X4_0_din); 
      #10;
      mem_X4_0_wr_addr = mem_X4_0_wr_addr + 1;
    end
    mem_X4_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X4_1 
    element_file = $fopen("get_4_isog_mem_X4_1.txt", "r");
    # 10;
    $display("\nloading input X4_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X4_1_wr_en = 1'b1;
    mem_X4_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X4_1_din); 
      #10;
      mem_X4_1_wr_addr = mem_X4_1_wr_addr + 1;
    end
    mem_X4_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z4_0 
    element_file = $fopen("get_4_isog_mem_Z4_0.txt", "r");
    # 10;
    $display("\nloading input Z4_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z4_0_wr_en = 1'b1;
    mem_Z4_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z4_0_din); 
      #10;
      mem_Z4_0_wr_addr = mem_Z4_0_wr_addr + 1;
    end
    mem_Z4_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z4_1 
    element_file = $fopen("get_4_isog_mem_Z4_1.txt", "r");
    # 10;
    $display("\nloading input Z4_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z4_1_wr_en = 1'b1;
    mem_Z4_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z4_1_din); 
      #10;
      mem_Z4_1_wr_addr = mem_Z4_1_wr_addr + 1;
    end
    mem_Z4_1_wr_en = 1'b0;
    end
    $fclose(element_file);

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    // start computation
    # 15;
    start <= 1'b1;
    start_time = $time;
    $display("\n    start get_4_isog computation");
    # 10;
    start <= 1'b0;  

//---------------------------------------------------------------------    
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    # 10;
    element_file = $fopen("0-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("0-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("0-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("0-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;


//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

    @(posedge eval_4_isog_result_ready); 
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("0-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("0-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("0-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("0-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file); 


//---------------------------------------------------------------------
//---------------------------------------------------------------------
//--------------------------------------------------------------------- 
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    element_file = $fopen("1-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("1-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("1-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("1-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    @(posedge eval_4_isog_result_ready);

    //---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("1-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("1-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("1-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("1-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file); 

    # 100;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    // load X_0, X_1, Z_0, Z_1 for eval_4_isog
    // load X_0 
    # 100;
    last_eval_4_isog <= 1'b1;

    element_file = $fopen("2-sage_eval_4_isog_mem_X_0.txt", "r");
    # 10;
    $display("\nloading input X_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_0_wr_en = 1'b1;
    mem_X_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_0_din); 
      #10;
      mem_X_0_wr_addr = mem_X_0_wr_addr + 1;
    end
    mem_X_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load X_1 
    element_file = $fopen("2-sage_eval_4_isog_mem_X_1.txt", "r");
    # 10;
    $display("\nloading input X_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_X_1_wr_en = 1'b1;
    mem_X_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_X_1_din); 
      #10;
      mem_X_1_wr_addr = mem_X_1_wr_addr + 1;
    end
    mem_X_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load Z_0 
    element_file = $fopen("2-sage_eval_4_isog_mem_Z_0.txt", "r");
    # 10;
    $display("\nloading input Z_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_0_wr_en = 1'b1;
    mem_Z_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_0_din); 
      #10;
      mem_Z_0_wr_addr = mem_Z_0_wr_addr + 1;
    end
    mem_Z_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load Z_1 
    element_file = $fopen("2-sage_eval_4_isog_mem_Z_1.txt", "r");
    # 10;
    $display("\nloading input Z_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_Z_1_wr_en = 1'b1;
    mem_Z_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_Z_1_din); 
      #10;
      mem_Z_1_wr_addr = mem_Z_1_wr_addr + 1;
    end
    mem_Z_1_wr_en = 1'b0;
    end
    $fclose(element_file); 

    eval_4_isog_XZ_newly_init_pre = 1'b1;
    # 10;
    eval_4_isog_XZ_newly_init_pre = 1'b0;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    // computation finishes
    @(posedge done);
    $display("\n    comptation finished in %0d cycles", ($time-start_time)/10);

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
    #100;
    $display("\nread result t10 back...");

    element_file = $fopen("2-sim_t10_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_0_dout); 
    end

    out_mem_t10_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("2-sim_t10_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t10_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t10_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t10_1_dout); 
    end

    out_mem_t10_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t11 back...");

    element_file = $fopen("2-sim_t11_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_0_dout); 
    end

    out_mem_t11_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("2-sim_t11_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t11_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t11_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t11_1_dout); 
    end

    out_mem_t11_1_rd_en = 1'b0;

    eval_4_isog_result_can_overwrite_pre = 1'b1;
    # 10;
    eval_4_isog_result_can_overwrite_pre = 1'b0;

    $fclose(element_file);
 
    # 1000;
      
    $finish;
end 

get_4_isog_and_eval_4_isog #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) get_4_isog_and_eval_4_isog_inst (
  .rst(rst),
  .clk(clk),
  .start(start),
  .done(done),
  .busy(busy),
  .eval_4_isog_XZ_can_overwrite(eval_4_isog_XZ_can_overwrite),
  .eval_4_isog_XZ_newly_init(eval_4_isog_XZ_newly_init),
  .last_eval_4_isog(last_eval_4_isog),
  .eval_4_isog_result_ready(eval_4_isog_result_ready),
  .eval_4_isog_result_can_overwrite(eval_4_isog_result_can_overwrite),
  .mem_X_0_dout(mem_X_0_dout),
  .mem_X_0_rd_en(mem_X_0_rd_en),
  .mem_X_0_rd_addr(mem_X_0_rd_addr),
  .mem_X_1_dout(mem_X_1_dout),
  .mem_X_1_rd_en(mem_X_1_rd_en),
  .mem_X_1_rd_addr(mem_X_1_rd_addr),
  .mem_Z_0_dout(mem_Z_0_dout),
  .mem_Z_0_rd_en(mem_Z_0_rd_en),
  .mem_Z_0_rd_addr(mem_Z_0_rd_addr),
  .mem_Z_1_dout(mem_Z_1_dout),
  .mem_Z_1_rd_en(mem_Z_1_rd_en),
  .mem_Z_1_rd_addr(mem_Z_1_rd_addr),
  .mem_X4_0_dout(mem_X4_0_dout),
  .mem_X4_0_rd_en(mem_X4_0_rd_en),
  .mem_X4_0_rd_addr(mem_X4_0_rd_addr), 
  .mem_X4_1_dout(mem_X4_1_dout),
  .mem_X4_1_rd_en(mem_X4_1_rd_en),
  .mem_X4_1_rd_addr(mem_X4_1_rd_addr),
  .mem_Z4_0_dout(mem_Z4_0_dout),
  .mem_Z4_0_rd_en(mem_Z4_0_rd_en),
  .mem_Z4_0_rd_addr(mem_Z4_0_rd_addr),
  .mem_Z4_1_dout(mem_Z4_1_dout),
  .mem_Z4_1_rd_en(mem_Z4_1_rd_en),
  .mem_Z4_1_rd_addr(mem_Z4_1_rd_addr),
  .out_mem_t10_0_rd_en(out_mem_t10_0_rd_en),
  .out_mem_t10_0_rd_addr(out_mem_t10_0_rd_addr),
  .mem_t10_0_dout(mem_t10_0_dout),
  .out_mem_t10_1_rd_en(out_mem_t10_1_rd_en),
  .out_mem_t10_1_rd_addr(out_mem_t10_1_rd_addr),
  .mem_t10_1_dout(mem_t10_1_dout),
  .out_mem_t11_0_rd_en(out_mem_t11_0_rd_en),
  .out_mem_t11_0_rd_addr(out_mem_t11_0_rd_addr),
  .mem_t11_0_dout(mem_t11_0_dout),
  .out_mem_t11_1_rd_en(out_mem_t11_1_rd_en),
  .out_mem_t11_1_rd_addr(out_mem_t11_1_rd_addr),
  .mem_t11_1_dout(mem_t11_1_dout)
  );
 
single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_X_0 (  
  .clock(clk),
  .data(mem_X_0_din),
  .address(mem_X_0_wr_en ? mem_X_0_wr_addr : (mem_X_0_rd_en ? mem_X_0_rd_addr : 0)),
  .wr_en(mem_X_0_wr_en),
  .q(mem_X_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_X_1 (  
  .clock(clk),
  .data(mem_X_1_din),
  .address(mem_X_1_wr_en ? mem_X_1_wr_addr : (mem_X_1_rd_en ? mem_X_1_rd_addr : 0)),
  .wr_en(mem_X_1_wr_en),
  .q(mem_X_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_Z_0 (  
  .clock(clk),
  .data(mem_Z_0_din),
  .address(mem_Z_0_wr_en ? mem_Z_0_wr_addr : (mem_Z_0_rd_en ? mem_Z_0_rd_addr : 0)),
  .wr_en(mem_Z_0_wr_en),
  .q(mem_Z_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_Z_1 (  
  .clock(clk),
  .data(mem_Z_1_din),
  .address(mem_Z_1_wr_en ? mem_Z_1_wr_addr : (mem_Z_1_rd_en ? mem_Z_1_rd_addr : 0)),
  .wr_en(mem_Z_1_wr_en),
  .q(mem_Z_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_X4_0 (  
  .clock(clk),
  .data(mem_X4_0_din),
  .address(mem_X4_0_wr_en ? mem_X4_0_wr_addr : (mem_X4_0_rd_en ? mem_X4_0_rd_addr : 0)),
  .wr_en(mem_X4_0_wr_en),
  .q(mem_X4_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_X4_1 (  
  .clock(clk),
  .data(mem_X4_1_din),
  .address(mem_X4_1_wr_en ? mem_X4_1_wr_addr : (mem_X4_1_rd_en ? mem_X4_1_rd_addr : 0)),
  .wr_en(mem_X4_1_wr_en),
  .q(mem_X4_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_Z4_0 (  
  .clock(clk),
  .data(mem_Z4_0_din),
  .address(mem_Z4_0_wr_en ? mem_Z4_0_wr_addr : (mem_Z4_0_rd_en ? mem_Z4_0_rd_addr : 0)),
  .wr_en(mem_Z4_0_wr_en),
  .q(mem_Z4_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_Z4_1 (  
  .clock(clk),
  .data(mem_Z4_1_din),
  .address(mem_Z4_1_wr_en ? mem_Z4_1_wr_addr : (mem_Z4_1_rd_en ? mem_Z4_1_rd_addr : 0)),
  .wr_en(mem_Z4_1_wr_en),
  .q(mem_Z4_1_dout)
  ); 

always 
  # 5 clk = !clk;


endmodule