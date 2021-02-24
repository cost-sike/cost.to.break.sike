
module memory_2_to_1_wrapper
  #(
    parameter WIDTH = 32,
    parameter SINGLE_MEM_DEPTH = 14,
    parameter FULL_MEM_DEPTH = 28,
    parameter SINGLE_MEM_DEPTH_LOG = `CLOG2(SINGLE_MEM_DEPTH),
    parameter FULL_MEM_DEPTH_LOG = `CLOG2(FULL_MEM_DEPTH),
    parameter MEM_0_START_ADDR = 0,
    parameter MEM_1_START_ADDR = 14

  )
  (
    input  wire                            clk,
    // memory 0
    input  wire                            mem_0_wr_en,
    input  wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_0_wr_addr,
    input  wire [WIDTH-1:0]                mem_0_din,
    input  wire                            mem_0_rd_en,
    input  wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_0_rd_addr,
    // memory 1
    input  wire                            mem_1_wr_en,
    input  wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_1_wr_addr,
    input  wire [WIDTH-1:0]                mem_1_din,
    input  wire                            mem_1_rd_en,
    input  wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_1_rd_addr,
    output wire [WIDTH-1:0]                mem_dout
  );

// interface to single port memory
wire [WIDTH-1:0] mem_din;
wire mem_wr_en;
wire [FULL_MEM_DEPTH_LOG-1:0] mem_wr_addr; 
wire [FULL_MEM_DEPTH_LOG-1:0] mem_rd_addr; 

// addr zeroes
wire [FULL_MEM_DEPTH_LOG-SINGLE_MEM_DEPTH_LOG-1:0] const_zeroes;
assign const_zeroes = {(FULL_MEM_DEPTH_LOG-SINGLE_MEM_DEPTH_LOG){1'b0}};


assign mem_wr_en = mem_0_wr_en | mem_1_wr_en;

assign mem_wr_addr = mem_0_wr_en ? {const_zeroes, mem_0_wr_addr} + MEM_0_START_ADDR :
                     mem_1_wr_en ? {const_zeroes, mem_1_wr_addr} + MEM_1_START_ADDR : 
                     {FULL_MEM_DEPTH_LOG{1'b0}};

assign mem_din = mem_0_wr_en ? mem_0_din :
                 mem_1_wr_en ? mem_1_din :
                 {WIDTH{1'b0}};

assign mem_rd_addr = mem_0_rd_en ? {const_zeroes, mem_0_rd_addr} + MEM_0_START_ADDR :
                     mem_1_rd_en ? {const_zeroes, mem_1_rd_addr} + MEM_1_START_ADDR :
                     {FULL_MEM_DEPTH_LOG{1'b0}};


single_port_mem #(.WIDTH(WIDTH), .DEPTH(FULL_MEM_DEPTH)) single_port_mem_inst (  
  .clock(clk),
  .data(mem_din),
  .address(mem_wr_en ? mem_wr_addr : mem_rd_addr),
  .wr_en(mem_wr_en),
  .q(mem_dout)
  );

endmodule


