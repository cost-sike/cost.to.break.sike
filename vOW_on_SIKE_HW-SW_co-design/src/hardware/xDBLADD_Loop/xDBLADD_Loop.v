/* 
Function: repeated xDBLADD function

Follow the steps below:
for (i = start_index; i < end_index; i++) {
  if (sk[i] == 1'b0) {
    xDBLADD(P, Q, Z, A24);
  } else {
    xDBLADD(P, Z, Q, A24);
  }
}
*/

// Assumption: 
// 1: all of the operands are from GF(p^2)
// 2: inputs P, Q, Z, and A24, as well as the sk have been initialized before this module is triggered
// 3: when there are parallel add/sub computations, they share the same timing. FIXME, need to double check

module xDBLADD_Loop
#(
  parameter RADIX = 32,
  parameter WIDTH_REAL = 14,
  parameter SK_MEM_WIDTH = 64,
  parameter SK_MEM_WIDTH_LOG = `CLOG2(SK_MEM_WIDTH),
  parameter SK_MEM_DEPTH = 120,
  parameter SK_MEM_DEPTH_LOG = `CLOG2(SK_MEM_DEPTH),
  parameter SINGLE_MEM_WIDTH = RADIX,
  parameter SINGLE_MEM_DEPTH = WIDTH_REAL,
  parameter SINGLE_MEM_DEPTH_LOG = `CLOG2(SINGLE_MEM_DEPTH),
  parameter DOUBLE_MEM_WIDTH = RADIX*2,
  parameter DOUBLE_MEM_DEPTH = (WIDTH_REAL+1)/2,
  parameter DOUBLE_MEM_DEPTH_LOG = `CLOG2(DOUBLE_MEM_DEPTH),
  parameter FILE_CONST_P_PLUS_ONE = "mem_p_plus_one.mem",
  parameter FILE_CONST_PX2 = "px2.mem",
  parameter FILE_CONST_PX4 = "px4.mem",
  parameter FILE_SK = "sk.mem"
)
(
  input wire clk,
  input wire rst,
  input wire start,
  output reg busy,
  output reg done,
  // index = start_index, start_index+1, ..., end_index-1, end_index.
  input wire [15:0] start_index, // start index of the main loop
  input wire [15:0] end_index,   // end index of the main loop
 
  // interface with input mem A24
  input wire out_mem_A24_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_A24_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_A24_0_din,

  input wire out_mem_A24_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_A24_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_A24_1_din,

  // interface with input mem XP
  input wire out_mem_XP_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_XP_0_din,

  input wire out_mem_XP_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_XP_1_din,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_XP_0_dout,
  input wire out_mem_XP_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_0_rd_addr,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_XP_1_dout,
  input wire out_mem_XP_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XP_1_rd_addr,

  // interface with input mem ZP
  input wire out_mem_ZP_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_ZP_0_din,

  input wire out_mem_ZP_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_ZP_1_din,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_0_dout,
  input wire out_mem_ZP_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_0_rd_addr,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_1_dout,
  input wire out_mem_ZP_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZP_1_rd_addr,

  // interface with input mem XQ
  input wire out_mem_XQ_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_XQ_0_din,

  input wire out_mem_XQ_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_XQ_1_din,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_0_dout,
  input wire out_mem_XQ_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_0_rd_addr,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_1_dout,
  input wire out_mem_XQ_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_XQ_1_rd_addr,

  // interface with input mem ZQ
  input wire out_mem_ZQ_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_ZQ_0_din,

  input wire out_mem_ZQ_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_ZQ_1_din,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_0_dout,
  input wire out_mem_ZQ_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_0_rd_addr,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_1_dout,
  input wire out_mem_ZQ_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_ZQ_1_rd_addr,

  // interface with input mem xPQ
  input wire out_mem_xPQ_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_xPQ_0_din,

  input wire out_mem_xPQ_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_xPQ_1_din,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_0_dout,
  input wire out_mem_xPQ_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_0_rd_addr,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_1_dout,
  input wire out_mem_xPQ_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_xPQ_1_rd_addr,

  // interface with input mem zPQ
  input wire out_mem_zPQ_0_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_0_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_zPQ_0_din,

  input wire out_mem_zPQ_1_wr_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_1_wr_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] out_mem_zPQ_1_din,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_0_dout,
  input wire out_mem_zPQ_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_0_rd_addr,

  output wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_1_dout,
  input wire out_mem_zPQ_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_zPQ_1_rd_addr 
 
);

// xDBLADD specific signals, output signals, from the controller
// interface with  memory XP 
wire xDBLADD_mem_XP_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XP_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XP_0_dout;
 
wire xDBLADD_mem_XP_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XP_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XP_1_dout;

// interface with  memory ZP 
wire xDBLADD_mem_ZP_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZP_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZP_0_dout;
 
wire xDBLADD_mem_ZP_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZP_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZP_1_dout;

// interface with  memory XQ 
wire xDBLADD_mem_XQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XQ_0_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XQ_0_dout;
 
wire xDBLADD_mem_XQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XQ_1_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XQ_1_dout;

// interface with  memory ZQ 
wire xDBLADD_mem_ZQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZQ_0_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZQ_0_dout;
 
wire xDBLADD_mem_ZQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZQ_1_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZQ_1_dout;

// interface with  memory xPQ 
wire xDBLADD_mem_xPQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_xPQ_0_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_xPQ_0_dout;
 
wire xDBLADD_mem_xPQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_xPQ_1_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_xPQ_1_dout;

// interface with  memory zPQ 
wire xDBLADD_mem_zPQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_zPQ_0_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_zPQ_0_dout;
 
wire xDBLADD_mem_zPQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_zPQ_1_rd_addr;
wire[SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_zPQ_1_dout;

// interface with  memory A24
wire xDBLADD_mem_A24_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_A24_0_rd_addr;

wire xDBLADD_mem_A24_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_A24_1_rd_addr;

assign xDBLADD_mem_XP_0_dout = controller_busy ? mem_XP_0_dout : 0;
assign xDBLADD_mem_XP_1_dout = controller_busy ? mem_XP_1_dout : 0; 
assign xDBLADD_mem_ZP_0_dout = controller_busy ? mem_ZP_0_dout : 0;
assign xDBLADD_mem_ZP_1_dout = controller_busy ? mem_ZP_1_dout : 0; 

assign xDBLADD_mem_XQ_0_dout = controller_busy & (!message_bit_at_current_index) ? mem_XQ_0_dout :
                               controller_busy ? mem_xPQ_0_dout :
                               0;
assign xDBLADD_mem_XQ_1_dout = controller_busy & (!message_bit_at_current_index) ? mem_XQ_1_dout :
                               controller_busy ? mem_xPQ_1_dout :
                               0;
assign xDBLADD_mem_ZQ_0_dout = controller_busy & (!message_bit_at_current_index) ? mem_ZQ_0_dout :
                               controller_busy ? mem_zPQ_0_dout :
                               0;
assign xDBLADD_mem_ZQ_1_dout = controller_busy & (!message_bit_at_current_index) ? mem_ZQ_1_dout :
                               controller_busy ? mem_zPQ_1_dout :
                               0;

assign xDBLADD_mem_xPQ_0_dout = controller_busy & (!message_bit_at_current_index) ? mem_xPQ_0_dout :
                                controller_busy ? mem_XQ_0_dout :
                                0;
assign xDBLADD_mem_xPQ_1_dout = controller_busy & (!message_bit_at_current_index) ? mem_xPQ_1_dout :
                                controller_busy ? mem_XQ_1_dout :
                                0;
assign xDBLADD_mem_zPQ_0_dout = controller_busy & (!message_bit_at_current_index) ? mem_zPQ_0_dout :
                                controller_busy ? mem_ZQ_0_dout :
                                0;
assign xDBLADD_mem_zPQ_1_dout = controller_busy & (!message_bit_at_current_index) ? mem_zPQ_1_dout :
                                controller_busy ? mem_ZQ_1_dout :
                                0;

// interface with input memories P, Q, PQ, and A24
wire mem_XP_0_wr_en;
wire mem_XP_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XP_0_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XP_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_XP_0_din;

wire mem_XP_1_wr_en;
wire mem_XP_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XP_1_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XP_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_XP_1_din;

assign mem_XP_0_wr_en = out_mem_XP_0_wr_en | input_mem_wr_en;
assign mem_XP_0_wr_addr = out_mem_XP_0_wr_en ? out_mem_XP_0_wr_addr :
                          input_mem_wr_en ? input_mem_wr_addr :
                          0;
assign mem_XP_0_din = out_mem_XP_0_wr_en ? out_mem_XP_0_din :
                      input_mem_wr_en ? mem_t10_0_dout :
                      0;
assign mem_XP_0_rd_en = xDBLADD_mem_XP_0_rd_en | out_mem_XP_0_rd_en;
assign mem_XP_0_rd_addr = xDBLADD_mem_XP_0_rd_en ? xDBLADD_mem_XP_0_rd_addr :
                          out_mem_XP_0_rd_en ? out_mem_XP_0_rd_addr :
                          0;

assign mem_XP_1_wr_en = out_mem_XP_1_wr_en | input_mem_wr_en;
assign mem_XP_1_wr_addr = out_mem_XP_1_wr_en ? out_mem_XP_1_wr_addr :
                          input_mem_wr_en ? input_mem_wr_addr :
                          0;
assign mem_XP_1_din = out_mem_XP_1_wr_en ? out_mem_XP_1_din :
                      input_mem_wr_en ? mem_t10_1_dout :
                      0;
assign mem_XP_1_rd_en = xDBLADD_mem_XP_1_rd_en | out_mem_XP_1_rd_en;
assign mem_XP_1_rd_addr = xDBLADD_mem_XP_1_rd_en ? xDBLADD_mem_XP_1_rd_addr :
                          out_mem_XP_1_rd_en ? out_mem_XP_1_rd_addr :
                          0;

wire mem_ZP_0_wr_en;
wire mem_ZP_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZP_0_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZP_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_0_din;

wire mem_ZP_1_wr_en;
wire mem_ZP_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZP_1_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZP_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_1_din;

assign mem_ZP_0_wr_en = out_mem_ZP_0_wr_en | input_mem_wr_en;
assign mem_ZP_0_wr_addr = out_mem_ZP_0_wr_en ? out_mem_ZP_0_wr_addr :
                          input_mem_wr_en ? input_mem_wr_addr :
                          0;
assign mem_ZP_0_din = out_mem_ZP_0_wr_en ? out_mem_ZP_0_din :
                      input_mem_wr_en ? mem_t5_0_dout :
                      0;
assign mem_ZP_0_rd_en = xDBLADD_mem_ZP_0_rd_en | out_mem_ZP_0_rd_en;
assign mem_ZP_0_rd_addr = xDBLADD_mem_ZP_0_rd_en ? xDBLADD_mem_ZP_0_rd_addr :
                          out_mem_ZP_0_rd_en ? out_mem_ZP_0_rd_addr :
                          0;


assign mem_ZP_1_wr_en = out_mem_ZP_1_wr_en | input_mem_wr_en;
assign mem_ZP_1_wr_addr = out_mem_ZP_1_wr_en ? out_mem_ZP_1_wr_addr :
                          input_mem_wr_en ? input_mem_wr_addr :
                          0;
assign mem_ZP_1_din = out_mem_ZP_1_wr_en ? out_mem_ZP_1_din :
                      input_mem_wr_en ? mem_t5_1_dout :
                      0;
assign mem_ZP_1_rd_en = xDBLADD_mem_ZP_1_rd_en | out_mem_ZP_1_rd_en;
assign mem_ZP_1_rd_addr = xDBLADD_mem_ZP_1_rd_en ? xDBLADD_mem_ZP_1_rd_addr :
                          out_mem_ZP_1_rd_en ? out_mem_ZP_1_rd_addr :
                          0;

wire mem_XQ_0_wr_en;
wire mem_XQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XQ_0_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XQ_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_0_din;

wire mem_XQ_1_wr_en;
wire mem_XQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XQ_1_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XQ_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_1_din;

assign mem_XQ_0_wr_en = out_mem_XQ_0_wr_en | (input_mem_wr_en & (!message_bit_at_current_index));
assign mem_XQ_0_wr_addr = out_mem_XQ_0_wr_en ? out_mem_XQ_0_wr_addr :
                          (input_mem_wr_en & (!message_bit_at_current_index)) ? input_mem_wr_addr :
                          0;
assign mem_XQ_0_din = out_mem_XQ_0_wr_en ? out_mem_XQ_0_din :
                      (input_mem_wr_en & (!message_bit_at_current_index)) ? mem_t2_0_dout :
                      0;
assign mem_XQ_0_rd_en = (xDBLADD_mem_XQ_0_rd_en & (!message_bit_at_current_index)) | out_mem_XQ_0_rd_en | (xDBLADD_mem_xPQ_0_rd_en & message_bit_at_current_index);
assign mem_XQ_0_rd_addr = out_mem_XQ_0_rd_en ? out_mem_XQ_0_rd_addr :
                          (xDBLADD_mem_XQ_0_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_XQ_0_rd_addr :
                          (xDBLADD_mem_xPQ_0_rd_en & message_bit_at_current_index) ? xDBLADD_mem_xPQ_0_rd_addr :
                          0;

assign mem_XQ_1_wr_en = out_mem_XQ_1_wr_en | (input_mem_wr_en & (!message_bit_at_current_index));
assign mem_XQ_1_wr_addr = out_mem_XQ_1_wr_en ? out_mem_XQ_1_wr_addr :
                          (input_mem_wr_en & (!message_bit_at_current_index)) ? input_mem_wr_addr :
                          0;
assign mem_XQ_1_din = out_mem_XQ_1_wr_en ? out_mem_XQ_1_din :
                      (input_mem_wr_en & (!message_bit_at_current_index)) ? mem_t2_1_dout :
                      0;
assign mem_XQ_1_rd_en = (xDBLADD_mem_XQ_1_rd_en & (!message_bit_at_current_index)) | out_mem_XQ_1_rd_en | (xDBLADD_mem_xPQ_1_rd_en & message_bit_at_current_index);
assign mem_XQ_1_rd_addr = out_mem_XQ_1_rd_en ? out_mem_XQ_1_rd_addr :
                          (xDBLADD_mem_XQ_1_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_XQ_1_rd_addr :
                          (xDBLADD_mem_xPQ_1_rd_en & message_bit_at_current_index) ? xDBLADD_mem_xPQ_1_rd_addr :
                          0;

wire mem_ZQ_0_wr_en;
wire mem_ZQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZQ_0_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZQ_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_0_din;

wire mem_ZQ_1_wr_en;
wire mem_ZQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZQ_1_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZQ_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_1_din;



assign mem_ZQ_0_wr_en = out_mem_ZQ_0_wr_en | (input_mem_wr_en & (!message_bit_at_current_index));
assign mem_ZQ_0_wr_addr = out_mem_ZQ_0_wr_en ? out_mem_ZQ_0_wr_addr :
                          (input_mem_wr_en & (!message_bit_at_current_index)) ? input_mem_wr_addr :
                          0;
assign mem_ZQ_0_din = out_mem_ZQ_0_wr_en ? out_mem_ZQ_0_din :
                      (input_mem_wr_en & (!message_bit_at_current_index)) ? mem_t3_0_dout :
                      0;
assign mem_ZQ_0_rd_en = (xDBLADD_mem_ZQ_0_rd_en & (!message_bit_at_current_index)) | out_mem_ZQ_0_rd_en | (xDBLADD_mem_zPQ_0_rd_en & message_bit_at_current_index);
assign mem_ZQ_0_rd_addr = out_mem_ZQ_0_rd_en ? out_mem_ZQ_0_rd_addr :
                          (xDBLADD_mem_ZQ_0_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_ZQ_0_rd_addr :
                          (xDBLADD_mem_zPQ_0_rd_en & message_bit_at_current_index) ? xDBLADD_mem_zPQ_0_rd_addr :
                          0;

assign mem_ZQ_1_wr_en = out_mem_ZQ_1_wr_en | (input_mem_wr_en & (!message_bit_at_current_index));
assign mem_ZQ_1_wr_addr = out_mem_ZQ_1_wr_en ? out_mem_ZQ_1_wr_addr :
                          (input_mem_wr_en & (!message_bit_at_current_index)) ? input_mem_wr_addr :
                          0;
assign mem_ZQ_1_din = out_mem_ZQ_1_wr_en ? out_mem_ZQ_1_din :
                      (input_mem_wr_en & (!message_bit_at_current_index)) ? mem_t3_1_dout :
                      0;
assign mem_ZQ_1_rd_en = (xDBLADD_mem_ZQ_1_rd_en & (!message_bit_at_current_index)) | out_mem_ZQ_1_rd_en | (xDBLADD_mem_zPQ_0_rd_en & message_bit_at_current_index);
assign mem_ZQ_1_rd_addr = out_mem_ZQ_1_rd_en ? out_mem_ZQ_1_rd_addr :
                          (xDBLADD_mem_ZQ_1_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_ZQ_1_rd_addr :
                          (xDBLADD_mem_zPQ_0_rd_en & message_bit_at_current_index) ? xDBLADD_mem_zPQ_1_rd_addr :
                          0;

wire mem_xPQ_0_wr_en;
wire mem_xPQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_xPQ_0_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_xPQ_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_0_din;

wire mem_xPQ_1_wr_en;
wire mem_xPQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_xPQ_1_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_xPQ_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_1_din;

assign mem_xPQ_0_wr_en = out_mem_xPQ_0_wr_en | (input_mem_wr_en & message_bit_at_current_index);
assign mem_xPQ_0_wr_addr = out_mem_xPQ_0_wr_en ? out_mem_xPQ_0_wr_addr :
                           (input_mem_wr_en & message_bit_at_current_index) ? input_mem_wr_addr :
                           0;
assign mem_xPQ_0_din = out_mem_xPQ_0_wr_en ? out_mem_xPQ_0_din :
                       (input_mem_wr_en & message_bit_at_current_index) ? mem_t2_0_dout :
                       0;
assign mem_xPQ_0_rd_en = out_mem_xPQ_0_rd_en | (xDBLADD_mem_ZQ_0_rd_en & message_bit_at_current_index) | (xDBLADD_mem_xPQ_0_rd_en & (!message_bit_at_current_index));
assign mem_xPQ_0_rd_addr = out_mem_xPQ_0_rd_en ? out_mem_xPQ_0_rd_addr :
                           (xDBLADD_mem_ZQ_0_rd_en & message_bit_at_current_index) ? xDBLADD_mem_ZQ_0_rd_addr :
                           (xDBLADD_mem_xPQ_0_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_xPQ_0_rd_addr :
                           0;
assign mem_xPQ_1_wr_en = out_mem_xPQ_1_wr_en | (input_mem_wr_en & message_bit_at_current_index);
assign mem_xPQ_1_wr_addr = out_mem_xPQ_1_wr_en ? out_mem_xPQ_1_wr_addr :
                           (input_mem_wr_en & message_bit_at_current_index) ? input_mem_wr_addr :
                           0;
assign mem_xPQ_1_din = out_mem_xPQ_1_wr_en ? out_mem_xPQ_1_din :
                       (input_mem_wr_en & message_bit_at_current_index) ? mem_t2_1_dout :
                       0;
assign mem_xPQ_1_rd_en = out_mem_xPQ_1_rd_en | (xDBLADD_mem_ZQ_1_rd_en & message_bit_at_current_index) | (xDBLADD_mem_xPQ_1_rd_en & (!message_bit_at_current_index));
assign mem_xPQ_1_rd_addr = out_mem_xPQ_1_rd_en ? out_mem_xPQ_1_rd_addr :
                           (xDBLADD_mem_ZQ_1_rd_en & message_bit_at_current_index) ? xDBLADD_mem_ZQ_1_rd_addr :
                           (xDBLADD_mem_xPQ_1_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_xPQ_1_rd_addr :
                           0;                          

wire mem_zPQ_0_wr_en;
wire mem_zPQ_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_zPQ_0_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_zPQ_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_0_din;

wire mem_zPQ_1_wr_en;
wire mem_zPQ_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_zPQ_1_wr_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_zPQ_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_1_din;

assign mem_zPQ_0_wr_en = out_mem_zPQ_0_wr_en | (input_mem_wr_en & message_bit_at_current_index);
assign mem_zPQ_0_wr_addr = out_mem_zPQ_0_wr_en ? out_mem_zPQ_0_wr_addr :
                           (input_mem_wr_en & message_bit_at_current_index) ? input_mem_wr_addr :
                           0;
assign mem_zPQ_0_din = out_mem_zPQ_0_wr_en ? out_mem_zPQ_0_din :
                       (input_mem_wr_en & message_bit_at_current_index) ? mem_t3_0_dout :
                       0;
assign mem_zPQ_0_rd_en = out_mem_zPQ_0_rd_en | (xDBLADD_mem_ZQ_0_rd_en & message_bit_at_current_index) | (xDBLADD_mem_zPQ_0_rd_en & (!message_bit_at_current_index));
assign mem_zPQ_0_rd_addr = out_mem_zPQ_0_rd_en ? out_mem_zPQ_0_rd_addr :
                           (xDBLADD_mem_ZQ_0_rd_en & message_bit_at_current_index) ? xDBLADD_mem_ZQ_0_rd_addr :
                           (xDBLADD_mem_zPQ_0_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_zPQ_0_rd_addr :
                           0;
assign mem_zPQ_1_wr_en = out_mem_zPQ_1_wr_en | (input_mem_wr_en & message_bit_at_current_index);
assign mem_zPQ_1_wr_addr = out_mem_zPQ_1_wr_en ? out_mem_zPQ_1_wr_addr :
                           (input_mem_wr_en & message_bit_at_current_index) ? input_mem_wr_addr :
                           0;
assign mem_zPQ_1_din = out_mem_zPQ_1_wr_en ? out_mem_zPQ_1_din :
                       (input_mem_wr_en & message_bit_at_current_index) ? mem_t3_1_dout :
                       0;
assign mem_zPQ_1_rd_en = out_mem_zPQ_1_rd_en | (xDBLADD_mem_ZQ_1_rd_en & message_bit_at_current_index) | (xDBLADD_mem_zPQ_1_rd_en & (!message_bit_at_current_index));
assign mem_zPQ_1_rd_addr = out_mem_zPQ_1_rd_en ? out_mem_zPQ_1_rd_addr :
                           (xDBLADD_mem_ZQ_1_rd_en & message_bit_at_current_index) ? xDBLADD_mem_ZQ_1_rd_addr :
                           (xDBLADD_mem_zPQ_1_rd_en & (!message_bit_at_current_index)) ? xDBLADD_mem_zPQ_1_rd_addr :
                           0;  

wire [SINGLE_MEM_WIDTH-1:0] mem_A24_0_dout;
wire mem_A24_0_rd_en; 
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_0_rd_addr;

wire [SINGLE_MEM_WIDTH-1:0] mem_A24_1_dout;
wire mem_A24_1_rd_en; 
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_1_rd_addr; 

assign mem_A24_0_rd_en = xDBLADD_mem_A24_0_rd_en;
assign mem_A24_0_rd_addr = xDBLADD_mem_A24_0_rd_addr;
assign mem_A24_1_rd_en = xDBLADD_mem_A24_1_rd_en;
assign mem_A24_1_rd_addr = xDBLADD_mem_A24_1_rd_addr;

// interface to t memory
wire [SINGLE_MEM_WIDTH-1:0] mem_t0_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t0_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t1_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t1_1_dout;

wire mem_t2_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t2_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t2_0_dout;
wire mem_t2_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t2_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t2_1_dout;

assign mem_t2_0_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign mem_t2_0_rd_addr = copy_counter;
assign mem_t2_1_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign mem_t2_1_rd_addr = copy_counter;

wire mem_t3_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t3_0_dout;
wire mem_t3_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t3_1_dout;

assign mem_t3_0_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign mem_t3_0_rd_addr = copy_counter;
assign mem_t3_1_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign mem_t3_1_rd_addr = copy_counter;

wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_dout;

wire out_mem_t5_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t5_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_dout;
wire out_mem_t5_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t5_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_dout;

assign out_mem_t5_0_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign out_mem_t5_0_rd_addr = copy_counter;
assign out_mem_t5_1_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign out_mem_t5_1_rd_addr = copy_counter;

wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_1_dout;

wire out_mem_t10_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_dout;
wire out_mem_t10_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_dout;

assign out_mem_t10_0_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign out_mem_t10_0_rd_addr = copy_counter;
assign out_mem_t10_1_rd_en = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
assign out_mem_t10_1_rd_addr = copy_counter;

// interface with sk memory
wire sk_mem_rd_en;
wire [SK_MEM_DEPTH_LOG-1:0] sk_mem_rd_addr;
wire [SK_MEM_WIDTH-1:0] sk_mem_dout;

assign sk_mem_rd_en = busy;
assign sk_mem_rd_addr = busy ? (current_index >> SK_MEM_WIDTH_LOG) : 0;

reg [15:0] current_index;

          // input: P, Q, Z, A24
parameter IDLE                            = 0,  
          xDBLADD_COMPUTATION             = IDLE + 1, 
          COPY_xDBLADD_RES_TO_PQZ_MEMORY  = xDBLADD_COMPUTATION + 1, 
          MAX_STATE                       = COPY_xDBLADD_RES_TO_PQZ_MEMORY + 1;

reg [`CLOG2(MAX_STATE)-1:0] state;

reg xDBLADD_COMPUTATION_running;
reg COPY_xDBLADD_RES_TO_PQZ_MEMORY_running;
 
wire last_copy_write;
reg last_copy_write_buf;
reg [SINGLE_MEM_DEPTH_LOG-1:0] copy_counter;
 
reg input_mem_wr_en;
reg [SINGLE_MEM_DEPTH_LOG-1:0] input_mem_wr_addr;

assign last_copy_write = COPY_xDBLADD_RES_TO_PQZ_MEMORY_running & (copy_counter == (SINGLE_MEM_DEPTH-1));

always @(posedge clk or posedge rst) begin
  if (rst) begin
    last_copy_write_buf <= 1'b0;
    copy_counter <= 0;
    input_mem_wr_en <= 1'b0;
    input_mem_wr_addr <= 0;
  end 
  else begin
    last_copy_write_buf <= last_copy_write;
    copy_counter <= (start | last_copy_write | last_copy_write_buf) ? 0 :
                    COPY_xDBLADD_RES_TO_PQZ_MEMORY_running ? copy_counter + 1 :
                    copy_counter;
    input_mem_wr_en <= (start | (input_mem_wr_addr == (SINGLE_MEM_DEPTH-1))) ? 1'b0 : 
                        COPY_xDBLADD_RES_TO_PQZ_MEMORY_running ? 1'b1 :
                        input_mem_wr_en;
    input_mem_wr_addr <= COPY_xDBLADD_RES_TO_PQZ_MEMORY_running ? copy_counter : input_mem_wr_addr;
  end
end

reg controller_start_pre; 
wire controller_start;
wire controller_done;
wire controller_busy;

reg xDBLADD_start_pre;

reg message_bit_at_current_index;

// finite state machine transitions
always @(posedge clk or posedge rst) begin
  if (rst) begin 
    state <= IDLE; 
    busy <= 1'b0;
    done <= 1'b0;
    controller_start_pre <= 1'b0; 
    xDBLADD_start_pre <= 1'b0;
    current_index <= 16'd0;
    message_bit_at_current_index <= 1'b0;
    xDBLADD_COMPUTATION_running <= 1'b0;
    COPY_xDBLADD_RES_TO_PQZ_MEMORY_running <= 1'b0;
  end
  else begin 
    done <= 1'b0; 
    controller_start_pre <= 1'b0; 
    xDBLADD_start_pre <= 1'b0;
    message_bit_at_current_index <= sk_mem_dout[SK_MEM_WIDTH-(current_index%SK_MEM_WIDTH)-1]; // FIXME stay valid 
    case (state) 
      IDLE: 
        if (start) begin
          state <= xDBLADD_COMPUTATION;
          controller_start_pre <= 1'b1;
          xDBLADD_COMPUTATION_running <= 1'b1;
          busy <= 1'b1;
          current_index <= start_index;
        end
        else if (xDBLADD_start_pre) begin
          state <= xDBLADD_COMPUTATION;
          controller_start_pre <= 1'b1;
          xDBLADD_COMPUTATION_running <= 1'b1; 
          current_index <= current_index + 1; 
        end
        else begin
          state <= IDLE;
        end

      xDBLADD_COMPUTATION: 
        if (controller_done) begin
          state <= COPY_xDBLADD_RES_TO_PQZ_MEMORY;
          xDBLADD_COMPUTATION_running <= 1'b0;
          COPY_xDBLADD_RES_TO_PQZ_MEMORY_running <= 1'b1;
        end
        else begin
          state <= xDBLADD_COMPUTATION;
        end

      COPY_xDBLADD_RES_TO_PQZ_MEMORY: 
        if (last_copy_write_buf & (current_index == end_index)) begin
          state <= IDLE;
          COPY_xDBLADD_RES_TO_PQZ_MEMORY_running <= 1'b0;
          busy <= 1'b0;
          done <= 1'b1;
        end 
        else if (last_copy_write_buf) begin
          state <= IDLE;
          COPY_xDBLADD_RES_TO_PQZ_MEMORY_running <= 1'b0;
          xDBLADD_start_pre <= 1'b1;
        end
        else begin
          state <= COPY_xDBLADD_RES_TO_PQZ_MEMORY;
        end 

      default: 
        begin
          state <= state;
        end
    endcase
  end 
end



controller #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) controller_inst (
  .rst(rst),
  .clk(clk),
  .function_encoded(8'd3),
  .start(controller_start),
  .done(controller_done),
  .busy(controller_busy), 
  .xDBL_mem_X_0_dout(0),
  .xDBL_mem_X_0_rd_en(),
  .xDBL_mem_X_0_rd_addr(),
  .xDBL_mem_X_1_dout(0),
  .xDBL_mem_X_1_rd_en(),
  .xDBL_mem_X_1_rd_addr(),
  .xDBL_mem_Z_0_dout(0),
  .xDBL_mem_Z_0_rd_en(),
  .xDBL_mem_Z_0_rd_addr(),
  .xDBL_mem_Z_1_dout(0),
  .xDBL_mem_Z_1_rd_en(),
  .xDBL_mem_Z_1_rd_addr(),
  .xDBL_mem_A24_0_dout(0),
  .xDBL_mem_A24_0_rd_en(),
  .xDBL_mem_A24_0_rd_addr(), 
  .xDBL_mem_A24_1_dout(0),
  .xDBL_mem_A24_1_rd_en(),
  .xDBL_mem_A24_1_rd_addr(),
  .xDBL_mem_C24_0_dout(0),
  .xDBL_mem_C24_0_rd_en(),
  .xDBL_mem_C24_0_rd_addr(),
  .xDBL_mem_C24_1_dout(0),
  .xDBL_mem_C24_1_rd_en(),
  .xDBL_mem_C24_1_rd_addr(),
  .xDBLADD_mem_XP_0_dout(xDBLADD_mem_XP_0_dout),
  .xDBLADD_mem_XP_0_rd_en(xDBLADD_mem_XP_0_rd_en),
  .xDBLADD_mem_XP_0_rd_addr(xDBLADD_mem_XP_0_rd_addr),
  .xDBLADD_mem_XP_1_dout(xDBLADD_mem_XP_1_dout),
  .xDBLADD_mem_XP_1_rd_en(xDBLADD_mem_XP_1_rd_en),
  .xDBLADD_mem_XP_1_rd_addr(xDBLADD_mem_XP_1_rd_addr),
  .xDBLADD_mem_ZP_0_dout(xDBLADD_mem_ZP_0_dout),
  .xDBLADD_mem_ZP_0_rd_en(xDBLADD_mem_ZP_0_rd_en),
  .xDBLADD_mem_ZP_0_rd_addr(xDBLADD_mem_ZP_0_rd_addr),
  .xDBLADD_mem_ZP_1_dout(xDBLADD_mem_ZP_1_dout),
  .xDBLADD_mem_ZP_1_rd_en(xDBLADD_mem_ZP_1_rd_en),
  .xDBLADD_mem_ZP_1_rd_addr(xDBLADD_mem_ZP_1_rd_addr),
  .xDBLADD_mem_XQ_0_dout(xDBLADD_mem_XQ_0_dout),
  .xDBLADD_mem_XQ_0_rd_en(xDBLADD_mem_XQ_0_rd_en),
  .xDBLADD_mem_XQ_0_rd_addr(xDBLADD_mem_XQ_0_rd_addr),
  .xDBLADD_mem_XQ_1_dout(xDBLADD_mem_XQ_1_dout),
  .xDBLADD_mem_XQ_1_rd_en(xDBLADD_mem_XQ_1_rd_en),
  .xDBLADD_mem_XQ_1_rd_addr(xDBLADD_mem_XQ_1_rd_addr),
  .xDBLADD_mem_ZQ_0_dout(xDBLADD_mem_ZQ_0_dout),
  .xDBLADD_mem_ZQ_0_rd_en(xDBLADD_mem_ZQ_0_rd_en),
  .xDBLADD_mem_ZQ_0_rd_addr(xDBLADD_mem_ZQ_0_rd_addr),
  .xDBLADD_mem_ZQ_1_dout(xDBLADD_mem_ZQ_1_dout),
  .xDBLADD_mem_ZQ_1_rd_en(xDBLADD_mem_ZQ_1_rd_en),
  .xDBLADD_mem_ZQ_1_rd_addr(xDBLADD_mem_ZQ_1_rd_addr),
  .xDBLADD_mem_xPQ_0_dout(xDBLADD_mem_xPQ_0_dout),
  .xDBLADD_mem_xPQ_0_rd_en(xDBLADD_mem_xPQ_0_rd_en),
  .xDBLADD_mem_xPQ_0_rd_addr(xDBLADD_mem_xPQ_0_rd_addr),
  .xDBLADD_mem_xPQ_1_dout(xDBLADD_mem_xPQ_1_dout),
  .xDBLADD_mem_xPQ_1_rd_en(xDBLADD_mem_xPQ_1_rd_en),
  .xDBLADD_mem_xPQ_1_rd_addr(xDBLADD_mem_xPQ_1_rd_addr),
  .xDBLADD_mem_zPQ_0_dout(xDBLADD_mem_zPQ_0_dout),
  .xDBLADD_mem_zPQ_0_rd_en(xDBLADD_mem_zPQ_0_rd_en),
  .xDBLADD_mem_zPQ_0_rd_addr(xDBLADD_mem_zPQ_0_rd_addr),
  .xDBLADD_mem_zPQ_1_dout(xDBLADD_mem_zPQ_1_dout),
  .xDBLADD_mem_zPQ_1_rd_en(xDBLADD_mem_zPQ_1_rd_en),
  .xDBLADD_mem_zPQ_1_rd_addr(xDBLADD_mem_zPQ_1_rd_addr),
  .xDBLADD_mem_A24_0_dout(mem_A24_0_dout),
  .xDBLADD_mem_A24_0_rd_en(xDBLADD_mem_A24_0_rd_en),
  .xDBLADD_mem_A24_0_rd_addr(xDBLADD_mem_A24_0_rd_addr), 
  .xDBLADD_mem_A24_1_dout(mem_A24_1_dout),
  .xDBLADD_mem_A24_1_rd_en(xDBLADD_mem_A24_1_rd_en),
  .xDBLADD_mem_A24_1_rd_addr(xDBLADD_mem_A24_1_rd_addr),
  .get_4_isog_mem_X4_0_dout(0),
  .get_4_isog_mem_X4_0_rd_en(),
  .get_4_isog_mem_X4_0_rd_addr(),
  .get_4_isog_mem_X4_1_dout(0),
  .get_4_isog_mem_X4_1_rd_en(),
  .get_4_isog_mem_X4_1_rd_addr(),
  .get_4_isog_mem_Z4_0_dout(0),
  .get_4_isog_mem_Z4_0_rd_en(),
  .get_4_isog_mem_Z4_0_rd_addr(),
  .get_4_isog_mem_Z4_1_dout(0),
  .get_4_isog_mem_Z4_1_rd_en(),
  .get_4_isog_mem_Z4_1_rd_addr(), 
  .eval_4_isog_mem_X_0_dout(0),
  .eval_4_isog_mem_X_0_rd_en(),
  .eval_4_isog_mem_X_0_rd_addr(),
  .eval_4_isog_mem_X_1_dout(0),
  .eval_4_isog_mem_X_1_rd_en(),
  .eval_4_isog_mem_X_1_rd_addr(),
  .eval_4_isog_mem_Z_0_dout(0),
  .eval_4_isog_mem_Z_0_rd_en(),
  .eval_4_isog_mem_Z_0_rd_addr(),
  .eval_4_isog_mem_Z_1_dout(0),
  .eval_4_isog_mem_Z_1_rd_en(),
  .eval_4_isog_mem_Z_1_rd_addr(),
  .eval_4_isog_mem_C0_0_dout(0),
  .eval_4_isog_mem_C0_0_rd_en(),
  .eval_4_isog_mem_C0_0_rd_addr(),
  .eval_4_isog_mem_C0_1_dout(0),
  .eval_4_isog_mem_C0_1_rd_en(),
  .eval_4_isog_mem_C0_1_rd_addr(),
  .eval_4_isog_mem_C1_0_dout(0),
  .eval_4_isog_mem_C1_0_rd_en(),
  .eval_4_isog_mem_C1_0_rd_addr(),
  .eval_4_isog_mem_C1_1_dout(0),
  .eval_4_isog_mem_C1_1_rd_en(),
  .eval_4_isog_mem_C1_1_rd_addr(),
  .eval_4_isog_mem_C2_0_dout(0),
  .eval_4_isog_mem_C2_0_rd_en(),
  .eval_4_isog_mem_C2_0_rd_addr(), 
  .eval_4_isog_mem_C2_1_dout(0),
  .eval_4_isog_mem_C2_1_rd_en(),
  .eval_4_isog_mem_C2_1_rd_addr(),
  .mem_t0_0_rd_en(0),
  .mem_t0_0_rd_addr(0),
  .mem_t0_0_dout(mem_t0_0_dout),
  .mem_t0_1_rd_en(0),
  .mem_t0_1_rd_addr(0),
  .mem_t0_1_dout(mem_t0_1_dout),
  .mem_t1_0_rd_en(0),
  .mem_t1_0_rd_addr(0),
  .mem_t1_0_dout(mem_t1_0_dout),
  .mem_t1_1_rd_en(0),
  .mem_t1_1_rd_addr(0),
  .mem_t1_1_dout(mem_t1_1_dout),
  .mem_t2_0_rd_en(mem_t2_0_rd_en),
  .mem_t2_0_rd_addr(mem_t2_0_rd_addr),
  .mem_t2_0_dout(mem_t2_0_dout),
  .mem_t2_1_rd_en(mem_t2_1_rd_en),
  .mem_t2_1_rd_addr(mem_t2_1_rd_addr),
  .mem_t2_1_dout(mem_t2_1_dout),
  .mem_t3_0_rd_en(mem_t3_0_rd_en),
  .mem_t3_0_rd_addr(mem_t3_0_rd_addr),
  .mem_t3_0_dout(mem_t3_0_dout),
  .mem_t3_1_rd_en(mem_t3_1_rd_en),
  .mem_t3_1_rd_addr(mem_t3_1_rd_addr),
  .mem_t3_1_dout(mem_t3_1_dout),
  .out_mem_t4_0_rd_en(0),
  .out_mem_t4_0_rd_addr(0),
  .mem_t4_0_dout(mem_t4_0_dout),
  .out_mem_t4_1_rd_en(0),
  .out_mem_t4_1_rd_addr(0),
  .mem_t4_1_dout(mem_t4_1_dout),
  .out_mem_t5_0_rd_en(out_mem_t5_0_rd_en),
  .out_mem_t5_0_rd_addr(out_mem_t5_0_rd_addr),
  .mem_t5_0_dout(mem_t5_0_dout),
  .out_mem_t5_1_rd_en(out_mem_t5_1_rd_en),
  .out_mem_t5_1_rd_addr(out_mem_t5_1_rd_addr),
  .mem_t5_1_dout(mem_t5_1_dout),
  .out_mem_t6_0_wr_en(0),
  .out_mem_t6_0_wr_addr(0),
  .out_mem_t6_0_din(0),
  .out_mem_t6_0_rd_en(0),
  .out_mem_t6_0_rd_addr(0),
  .mem_t6_0_dout(mem_t6_0_dout),
  .out_mem_t6_1_wr_en(0),
  .out_mem_t6_1_wr_addr(0),
  .out_mem_t6_1_din(0),
  .out_mem_t6_1_rd_en(0),
  .out_mem_t6_1_rd_addr(0),
  .mem_t6_1_dout(mem_t6_1_dout),
  .out_mem_t7_0_wr_en(0),
  .out_mem_t7_0_wr_addr(0),
  .out_mem_t7_0_din(0),
  .out_mem_t7_0_rd_en(0),
  .out_mem_t7_0_rd_addr(0),
  .mem_t7_0_dout(mem_t7_0_dout),
  .out_mem_t7_1_wr_en(0),
  .out_mem_t7_1_wr_addr(0),
  .out_mem_t7_1_din(0),
  .out_mem_t7_1_rd_en(0),
  .out_mem_t7_1_rd_addr(0),
  .mem_t7_1_dout(mem_t7_1_dout),
  .out_mem_t8_0_wr_en(0),
  .out_mem_t8_0_wr_addr(0),
  .out_mem_t8_0_din(0),
  .out_mem_t8_0_rd_en(0),
  .out_mem_t8_0_rd_addr(0),
  .mem_t8_0_dout(mem_t8_0_dout),
  .out_mem_t8_1_wr_en(0),
  .out_mem_t8_1_wr_addr(0),
  .out_mem_t8_1_din(0),
  .out_mem_t8_1_rd_en(0),
  .out_mem_t8_1_rd_addr(0),
  .mem_t8_1_dout(mem_t8_1_dout),
  .out_mem_t9_0_wr_en(0),
  .out_mem_t9_0_wr_addr(0),
  .out_mem_t9_0_din(0),
  .out_mem_t9_0_rd_en(0),
  .out_mem_t9_0_rd_addr(0),
  .mem_t9_0_dout(mem_t9_0_dout),
  .out_mem_t9_1_wr_en(0),
  .out_mem_t9_1_wr_addr(0),
  .out_mem_t9_1_din(0),
  .out_mem_t9_1_rd_en(0),
  .out_mem_t9_1_rd_addr(0),
  .mem_t9_1_dout(mem_t9_1_dout),
  .out_mem_t10_0_wr_en(0),
  .out_mem_t10_0_wr_addr(0),
  .out_mem_t10_0_din(0),
  .out_mem_t10_0_rd_en(out_mem_t10_0_rd_en),
  .out_mem_t10_0_rd_addr(out_mem_t10_0_rd_addr),
  .mem_t10_0_dout(mem_t10_0_dout),
  .out_mem_t10_1_wr_en(0),
  .out_mem_t10_1_wr_addr(0),
  .out_mem_t10_1_din(0),
  .out_mem_t10_1_rd_en(out_mem_t10_1_rd_en),
  .out_mem_t10_1_rd_addr(out_mem_t10_1_rd_addr),
  .mem_t10_1_dout(mem_t10_1_dout)
  ); 


single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_XP_0 (  
  .clock(clk),
  .data(mem_XP_0_din),
  .address(mem_XP_0_wr_en ? mem_XP_0_wr_addr : (mem_XP_0_rd_en ? mem_XP_0_rd_addr : 0)),
  .wr_en(mem_XP_0_wr_en),
  .q(mem_XP_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_XP_1 (  
  .clock(clk),
  .data(mem_XP_1_din),
  .address(mem_XP_1_wr_en ? mem_XP_1_wr_addr : (mem_XP_1_rd_en ? mem_XP_1_rd_addr : 0)),
  .wr_en(mem_XP_1_wr_en),
  .q(mem_XP_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_ZP_0 (  
  .clock(clk),
  .data(mem_ZP_0_din),
  .address(mem_ZP_0_wr_en ? mem_ZP_0_wr_addr : (mem_ZP_0_rd_en ? mem_ZP_0_rd_addr : 0)),
  .wr_en(mem_ZP_0_wr_en),
  .q(mem_ZP_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_ZP_1 (  
  .clock(clk),
  .data(mem_ZP_1_din),
  .address(mem_ZP_1_wr_en ? mem_ZP_1_wr_addr : (mem_ZP_1_rd_en ? mem_ZP_1_rd_addr : 0)),
  .wr_en(mem_ZP_1_wr_en),
  .q(mem_ZP_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_XQ_0 (  
  .clock(clk),
  .data(mem_XQ_0_din),
  .address(mem_XQ_0_wr_en ? mem_XQ_0_wr_addr : (mem_XQ_0_rd_en ? mem_XQ_0_rd_addr : 0)),
  .wr_en(mem_XQ_0_wr_en),
  .q(mem_XQ_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_XQ_1 (  
  .clock(clk),
  .data(mem_XQ_1_din),
  .address(mem_XQ_1_wr_en ? mem_XQ_1_wr_addr : (mem_XQ_1_rd_en ? mem_XQ_1_rd_addr : 0)),
  .wr_en(mem_XQ_1_wr_en),
  .q(mem_XQ_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_ZQ_0 (  
  .clock(clk),
  .data(mem_ZQ_0_din),
  .address(mem_ZQ_0_wr_en ? mem_ZQ_0_wr_addr : (mem_ZQ_0_rd_en ? mem_ZQ_0_rd_addr : 0)),
  .wr_en(mem_ZQ_0_wr_en),
  .q(mem_ZQ_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_ZQ_1 (  
  .clock(clk),
  .data(mem_ZQ_1_din),
  .address(mem_ZQ_1_wr_en ? mem_ZQ_1_wr_addr : (mem_ZQ_1_rd_en ? mem_ZQ_1_rd_addr : 0)),
  .wr_en(mem_ZQ_1_wr_en),
  .q(mem_ZQ_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_A24_0 (  
  .clock(clk),
  .data(out_mem_A24_0_din),
  .address(out_mem_A24_0_wr_en ? out_mem_A24_0_wr_addr : (mem_A24_0_rd_en ? mem_A24_0_rd_addr : 0)),
  .wr_en(out_mem_A24_0_wr_en),
  .q(mem_A24_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_A24_1 (  
  .clock(clk),
  .data(out_mem_A24_1_din),
  .address(out_mem_A24_1_wr_en ? out_mem_A24_1_wr_addr : (mem_A24_1_rd_en ? mem_A24_1_rd_addr : 0)),
  .wr_en(out_mem_A24_1_wr_en),
  .q(mem_A24_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_xPQ_0 (  
  .clock(clk),
  .data(mem_xPQ_0_din),
  .address(mem_xPQ_0_wr_en ? mem_xPQ_0_wr_addr : (mem_xPQ_0_rd_en ? mem_xPQ_0_rd_addr : 0)),
  .wr_en(mem_xPQ_0_wr_en),
  .q(mem_xPQ_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_xPQ_1 (  
  .clock(clk),
  .data(mem_xPQ_1_din),
  .address(mem_xPQ_1_wr_en ? mem_xPQ_1_wr_addr : (mem_xPQ_1_rd_en ? mem_xPQ_1_rd_addr : 0)),
  .wr_en(mem_xPQ_1_wr_en),
  .q(mem_xPQ_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_zPQ_0 (  
  .clock(clk),
  .data(mem_zPQ_0_din),
  .address(mem_zPQ_0_wr_en ? mem_zPQ_0_wr_addr : (mem_zPQ_0_rd_en ? mem_zPQ_0_rd_addr : 0)),
  .wr_en(mem_zPQ_0_wr_en),
  .q(mem_zPQ_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_zPQ_1 (  
  .clock(clk),
  .data(mem_zPQ_1_din),
  .address(mem_zPQ_1_wr_en ? mem_zPQ_1_wr_addr : (mem_zPQ_1_rd_en ? mem_zPQ_1_rd_addr : 0)),
  .wr_en(mem_zPQ_1_wr_en),
  .q(mem_zPQ_1_dout)
  );

single_port_mem #(.FILE(FILE_SK), .WIDTH(SK_MEM_WIDTH), .DEPTH(SK_MEM_DEPTH)) single_port_mem_inst_sk (  
  .clock(clk),
  .data(0),
  .address(sk_mem_rd_addr),
  .wr_en(0),
  .q(sk_mem_dout)
  );

delay #(.WIDTH(1), .DELAY(2)) delay_inst (
  .clk(clk),
  .rst(rst),
  .din(controller_start_pre),
  .dout(controller_start)
  );

endmodule