`timescale 1ns / 1ps

module xDBLe_tb;

parameter RADIX = `RADIX;
parameter WIDTH_REAL = `WIDTH_REAL;
parameter SINGLE_MEM_WIDTH = RADIX;
parameter SINGLE_MEM_DEPTH = WIDTH_REAL;
parameter SINGLE_MEM_DEPTH_LOG = `CLOG2(SINGLE_MEM_DEPTH);
parameter DOUBLE_MEM_WIDTH = RADIX*2;
parameter DOUBLE_MEM_DEPTH = (WIDTH_REAL+1)/2;
parameter DOUBLE_MEM_DEPTH_LOG = `CLOG2(DOUBLE_MEM_DEPTH);
parameter LOOPS = `LOOPS;

// inputs
reg rst = 1'b0;
reg clk = 1'b0;
reg start = 1'b0;

// outputs 
wire done;
wire busy;

reg [7:0] NUM_LOOPS = LOOPS;
 
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

// interface with memory A24
reg mem_A24_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_A24_0_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_A24_0_dout;
wire mem_A24_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_0_rd_addr;

reg mem_A24_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_A24_1_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_A24_1_dout;
wire mem_A24_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_1_rd_addr;

// interface with memory C24
reg mem_C24_0_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_C24_0_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_C24_0_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_C24_0_dout;
wire mem_C24_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_C24_0_rd_addr;

reg mem_C24_1_wr_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_C24_1_wr_addr = 0;
reg [SINGLE_MEM_WIDTH-1:0] mem_C24_1_din = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_C24_1_dout;
wire mem_C24_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_C24_1_rd_addr;

// interface with results memory t6 
reg out_mem_t6_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t6_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_dout;

reg out_mem_t6_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t6_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_dout;

// interface with results memory t7 
reg out_mem_t7_0_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_0_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_dout;

reg out_mem_t7_1_rd_en = 0;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_1_rd_addr = 0;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_dout;
 
initial
  begin
    $dumpfile("xDBLe_tb.vcd");
    $dumpvars(0, xDBLe_tb);
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
    // load X_0, X_1, Z_0, Z_1, A24_0, A24_1, C24_0, and C24_1
    // load X_0 
    element_file = $fopen("xDBLe_mem_X_0.txt", "r");
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
    element_file = $fopen("xDBLe_mem_X_1.txt", "r");
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
    element_file = $fopen("xDBLe_mem_Z_0.txt", "r");
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
    element_file = $fopen("xDBLe_mem_Z_1.txt", "r");
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

    // load A24_0 
    element_file = $fopen("xDBLe_mem_A24_0.txt", "r");
    # 10;
    $display("\nloading input A24_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_A24_0_wr_en = 1'b1;
    mem_A24_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_A24_0_din); 
      #10;
      mem_A24_0_wr_addr = mem_A24_0_wr_addr + 1;
    end
    mem_A24_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load A24_1 
    element_file = $fopen("xDBLe_mem_A24_1.txt", "r");
    # 10;
    $display("\nloading input A24_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_A24_1_wr_en = 1'b1;
    mem_A24_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_A24_1_din); 
      #10;
      mem_A24_1_wr_addr = mem_A24_1_wr_addr + 1;
    end
    mem_A24_1_wr_en = 1'b0;
    end
    $fclose(element_file);

    // load C24_0 
    element_file = $fopen("xDBLe_mem_C24_0.txt", "r");
    # 10;
    $display("\nloading input C24_0...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_C24_0_wr_en = 1'b1;
    mem_C24_0_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_C24_0_din); 
      #10;
      mem_C24_0_wr_addr = mem_C24_0_wr_addr + 1;
    end
    mem_C24_0_wr_en = 1'b0;
    end
    $fclose(element_file);
    
    // load C24_1 
    element_file = $fopen("xDBLe_mem_C24_1.txt", "r");
    # 10;
    $display("\nloading input C24_1...");
    while (!$feof(element_file)) begin
    @(negedge clk);
    mem_C24_1_wr_en = 1'b1;
    mem_C24_1_wr_addr = 0;
    for (i=0; i < SINGLE_MEM_DEPTH; i=i+1) begin
      scan_file = $fscanf(element_file, "%b\n", mem_C24_1_din); 
      #10;
      mem_C24_1_wr_addr = mem_C24_1_wr_addr + 1;
    end
    mem_C24_1_wr_en = 1'b0;
    end
    $fclose(element_file);
 
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
    #100;
    $display("\nread result t6 back...");

    element_file = $fopen("sim_t6_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t6_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t6_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t6_0_dout); 
    end

    out_mem_t6_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_t6_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t6_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t6_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t6_1_dout); 
    end

    out_mem_t6_1_rd_en = 1'b0;

    $fclose(element_file);

//---------------------------------------------------------------------
    #100;
    $display("\nread result t7 back...");

    element_file = $fopen("sim_t7_0.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t7_0_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t7_0_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t7_0_dout); 
    end

    out_mem_t7_0_rd_en = 1'b0;

    $fclose(element_file);

    element_file = $fopen("sim_t7_1.txt", "w");

    #100;

    @(negedge clk);
    out_mem_t7_1_rd_en = 1'b1;

    for (i=0; i<SINGLE_MEM_DEPTH; i=i+1) begin
      out_mem_t7_1_rd_addr = i;
      # 10; 
      $fwrite(element_file, "%b\n", mem_t7_1_dout); 
    end

    out_mem_t7_1_rd_en = 1'b0;

    $fclose(element_file);  


    #10;
    $display("\ncomparing results from software and hardware simulation by git diff:");
    $display("    DONE! Test Passes!\n"); 

    # 1000;
      
    $finish;

end 

xDBLe #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) xDBLe_inst (
  .rst(rst),
  .clk(clk),
  .start(start),
  .done(done),
  .busy(busy),
  .NUM_LOOPS(NUM_LOOPS),
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
  .mem_A24_0_dout(mem_A24_0_dout),
  .mem_A24_0_rd_en(mem_A24_0_rd_en),
  .mem_A24_0_rd_addr(mem_A24_0_rd_addr), 
  .mem_A24_1_dout(mem_A24_1_dout),
  .mem_A24_1_rd_en(mem_A24_1_rd_en),
  .mem_A24_1_rd_addr(mem_A24_1_rd_addr),
  .mem_C24_0_dout(mem_C24_0_dout),
  .mem_C24_0_rd_en(mem_C24_0_rd_en),
  .mem_C24_0_rd_addr(mem_C24_0_rd_addr),
  .mem_C24_1_dout(mem_C24_1_dout),
  .mem_C24_1_rd_en(mem_C24_1_rd_en),
  .mem_C24_1_rd_addr(mem_C24_1_rd_addr),
  .out_mem_t6_0_rd_en(out_mem_t6_0_rd_en),
  .out_mem_t6_0_rd_addr(out_mem_t6_0_rd_addr),
  .mem_t6_0_dout(mem_t6_0_dout),
  .out_mem_t6_1_rd_en(out_mem_t6_1_rd_en),
  .out_mem_t6_1_rd_addr(out_mem_t6_1_rd_addr),
  .mem_t6_1_dout(mem_t6_1_dout),
  .out_mem_t7_0_rd_en(out_mem_t7_0_rd_en),
  .out_mem_t7_0_rd_addr(out_mem_t7_0_rd_addr),
  .mem_t7_0_dout(mem_t7_0_dout),
  .out_mem_t7_1_rd_en(out_mem_t7_1_rd_en),
  .out_mem_t7_1_rd_addr(out_mem_t7_1_rd_addr),
  .mem_t7_1_dout(mem_t7_1_dout)
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

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_A24_0 (  
  .clock(clk),
  .data(mem_A24_0_din),
  .address(mem_A24_0_wr_en ? mem_A24_0_wr_addr : (mem_A24_0_rd_en ? mem_A24_0_rd_addr : 0)),
  .wr_en(mem_A24_0_wr_en),
  .q(mem_A24_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_A24_1 (  
  .clock(clk),
  .data(mem_A24_1_din),
  .address(mem_A24_1_wr_en ? mem_A24_1_wr_addr : (mem_A24_1_rd_en ? mem_A24_1_rd_addr : 0)),
  .wr_en(mem_A24_1_wr_en),
  .q(mem_A24_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_C24_0 (  
  .clock(clk),
  .data(mem_C24_0_din),
  .address(mem_C24_0_wr_en ? mem_C24_0_wr_addr : (mem_C24_0_rd_en ? mem_C24_0_rd_addr : 0)),
  .wr_en(mem_C24_0_wr_en),
  .q(mem_C24_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_C24_1 (  
  .clock(clk),
  .data(mem_C24_1_din),
  .address(mem_C24_1_wr_en ? mem_C24_1_wr_addr : (mem_C24_1_rd_en ? mem_C24_1_rd_addr : 0)),
  .wr_en(mem_C24_1_wr_en),
  .q(mem_C24_1_dout)
  ); 

always 
  # 5 clk = !clk;


endmodule