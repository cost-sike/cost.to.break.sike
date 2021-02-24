/*
Function: one get_4_isog() function call is followed by multiple eval_4_isog() function calls

Follow the steps below:
get_4_isog(R, constant1, constant2, coeff);
eval_4_isog(A, coeff);
eval_4_isog(B, coeff);
eval_4_isog(C, coeff);
...
eval_4_isog(X, coeff);
*/

// Assumption: 
// 1: all of the operands are from GF(p^2)
// 2: inputs R, A, B, C, ..., X have been initialized before this module is triggered
// 3: when there are parallel add/sub computations, they share the same timing. FIXME, need to double check


module get_4_isog_and_eval_4_isog 
#(
  parameter RADIX = 32,
  parameter WIDTH_REAL = 14, 
  parameter SINGLE_MEM_WIDTH = RADIX,
  parameter SINGLE_MEM_DEPTH = WIDTH_REAL,
  parameter SINGLE_MEM_DEPTH_LOG = `CLOG2(SINGLE_MEM_DEPTH),
  parameter DOUBLE_MEM_WIDTH = RADIX*2,
  parameter DOUBLE_MEM_DEPTH = (WIDTH_REAL+1)/2,
  parameter DOUBLE_MEM_DEPTH_LOG = `CLOG2(DOUBLE_MEM_DEPTH),
  parameter FILE_CONST_P_PLUS_ONE = "mem_p_plus_one.mem",
  parameter FILE_CONST_PX2 = "px2.mem",
  parameter FILE_CONST_PX4 = "px4.mem"
)
(
  input wire clk,
  input wire rst,
  input wire start, // start is triggered after the input memory of get_4_isog is initialized
  output reg busy,
  output reg done,

  // interface with the SW-HW interface module
    // 2-phase handshake signals
  output reg eval_4_isog_XZ_can_overwrite,   // the input memory X/Z of eval_4_isog has been read and can be updated with new data; stay high 
  // on the software side: 
  //   eval_4_isog_XZ_newly_init goes high after the last data of Z has been written
  //   eval_4_isog_XZ_newly_init goes low after receiving a valid eval_4_isog_XZ_can_overwrite; software has to keep pooling the eval_4_isog_XZ_can_overwrite_status register
  input wire eval_4_isog_XZ_newly_init,       // the input memory X of eval_4_isog is initialized; stay high
  // on the software side:
  //   last_eval_4_isog goes high indicating that this is the last function call to eval_4_isog
  //   last_eval_4_isog goes low when a new function call to get_4_isog_and_eval_4_isog happens
  input wire last_eval_4_isog,             // this is the last input XZ to eval_4_isog; stay high
  
  output reg eval_4_isog_result_ready,       // the result for eval_4_isog is ready and can be read; stay high
  // on the software side:
  //   eval_4_isog_result_can_overwrite goes high after the software has read the results of one eval_4_isog fully (t10 and t11)
  //   eval_4_isog_result_can_overwrite goes low after receiving a valid eval_4_isog_result_ready signal; software has to keep pooling the eval_4_isog_result_ready_status register
  input wire eval_4_isog_result_can_overwrite,// the result for eval_4_isog has been read successfully; stay high
   
  // input memory for get_4_isog
  	// interface with input memory X4
  input wire [SINGLE_MEM_WIDTH-1:0] mem_X4_0_dout,
  output wire mem_X4_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X4_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_X4_1_dout,
  output wire mem_X4_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X4_1_rd_addr,

  	// interface with input memory Z4
  input wire [SINGLE_MEM_WIDTH-1:0] mem_Z4_0_dout,
  output wire mem_Z4_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z4_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_Z4_1_dout,
  output wire mem_Z4_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z4_1_rd_addr, 

  // input memory for eval_4_isog
  	// interface with input memory X
  input wire [SINGLE_MEM_WIDTH-1:0] mem_X_0_dout,
  output wire mem_X_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_X_1_dout,
  output wire mem_X_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_X_1_rd_addr,

  	// interface with input memory Z
  input wire [SINGLE_MEM_WIDTH-1:0] mem_Z_0_dout,
  output wire mem_Z_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_Z_1_dout,
  output wire mem_Z_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_Z_1_rd_addr,
 
  // interface with eval_4_isog's output memory t10 
  input wire out_mem_t10_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_dout,
 
  input wire out_mem_t10_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_dout,

    // interface with output memory t11 
  input wire out_mem_t11_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t11_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t11_0_dout,
 
  input wire out_mem_t11_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t11_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t11_1_dout

);



// get_4_isog specific signals
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_X4_0_dout;
wire get_4_isog_mem_X4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_X4_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_X4_1_dout;
wire get_4_isog_mem_X4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_X4_1_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_Z4_0_dout;
wire get_4_isog_mem_Z4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_Z4_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_Z4_1_dout;
wire get_4_isog_mem_Z4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_Z4_1_rd_addr;

assign get_4_isog_mem_X4_0_dout = mem_X4_0_dout;
assign mem_X4_0_rd_en = get_4_isog_mem_X4_0_rd_en;
assign mem_X4_0_rd_addr = get_4_isog_mem_X4_0_rd_addr;

assign get_4_isog_mem_X4_1_dout = mem_X4_1_dout;
assign mem_X4_1_rd_en = get_4_isog_mem_X4_1_rd_en;
assign mem_X4_1_rd_addr = get_4_isog_mem_X4_1_rd_addr;

assign get_4_isog_mem_Z4_0_dout = mem_Z4_0_dout;
assign mem_Z4_0_rd_en = get_4_isog_mem_Z4_0_rd_en;
assign mem_Z4_0_rd_addr = get_4_isog_mem_Z4_0_rd_addr;

assign get_4_isog_mem_Z4_1_dout = mem_Z4_1_dout;
assign mem_Z4_1_rd_en = get_4_isog_mem_Z4_1_rd_en;
assign mem_Z4_1_rd_addr = get_4_isog_mem_Z4_1_rd_addr;


// eval_4_isog specific signals
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_X_0_dout;
wire eval_4_isog_mem_X_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_X_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_X_1_dout;
wire eval_4_isog_mem_X_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_X_1_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_Z_0_dout;
wire eval_4_isog_mem_Z_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_Z_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_Z_1_dout;
wire eval_4_isog_mem_Z_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_Z_1_rd_addr;
 
assign eval_4_isog_mem_X_0_dout = mem_X_0_dout;
assign mem_X_0_rd_en = eval_4_isog_mem_X_0_rd_en;
assign mem_X_0_rd_addr = eval_4_isog_mem_X_0_rd_addr;

assign eval_4_isog_mem_X_1_dout = mem_X_1_dout;
assign mem_X_1_rd_en = eval_4_isog_mem_X_1_rd_en;
assign mem_X_1_rd_addr = eval_4_isog_mem_X_1_rd_addr;

assign eval_4_isog_mem_Z_0_dout = mem_Z_0_dout;
assign mem_Z_0_rd_en = eval_4_isog_mem_Z_0_rd_en;
assign mem_Z_0_rd_addr = eval_4_isog_mem_Z_0_rd_addr;

assign eval_4_isog_mem_Z_1_dout = mem_Z_1_dout;
assign mem_Z_1_rd_en = eval_4_isog_mem_Z_1_rd_en;
assign mem_Z_1_rd_addr = eval_4_isog_mem_Z_1_rd_addr;

wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_C0_0_dout;
wire eval_4_isog_mem_C0_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_C0_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_C0_1_dout;
wire eval_4_isog_mem_C0_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_C0_1_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_C1_0_dout;
wire eval_4_isog_mem_C1_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_C1_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_C1_1_dout;
wire eval_4_isog_mem_C1_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_C1_1_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_C2_0_dout;
wire eval_4_isog_mem_C2_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_C2_0_rd_addr;
 
wire [SINGLE_MEM_WIDTH-1:0] eval_4_isog_mem_C2_1_dout;
wire eval_4_isog_mem_C2_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] eval_4_isog_mem_C2_1_rd_addr;

assign eval_4_isog_mem_C0_0_dout = EVAL_4_ISOG_COMPUTATION_running ? mem_t7_0_dout : 0; 
assign eval_4_isog_mem_C0_1_dout = EVAL_4_ISOG_COMPUTATION_running ? mem_t7_1_dout : 0; 
assign eval_4_isog_mem_C1_0_dout = EVAL_4_ISOG_COMPUTATION_running ? mem_t8_0_dout : 0; 
assign eval_4_isog_mem_C1_1_dout = EVAL_4_ISOG_COMPUTATION_running ? mem_t8_1_dout : 0; 
assign eval_4_isog_mem_C2_0_dout = EVAL_4_ISOG_COMPUTATION_running ? mem_t9_0_dout : 0; 
assign eval_4_isog_mem_C2_1_dout = EVAL_4_ISOG_COMPUTATION_running ? mem_t9_1_dout : 0; 

// interface to memory
  // t0 not used
wire [SINGLE_MEM_WIDTH-1:0] mem_t0_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t0_1_dout;
  // t1
wire mem_t1_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t1_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t1_0_dout;
wire mem_t1_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t1_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t1_1_dout;

assign mem_t1_0_rd_en = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running;
assign mem_t1_0_rd_addr = copy_counter;

assign mem_t1_1_rd_en = mem_t1_0_rd_en;
assign mem_t1_1_rd_addr = mem_t1_0_rd_addr;

  // t2
wire mem_t2_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t2_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t2_0_dout;
wire mem_t2_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t2_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t2_1_dout;

assign mem_t2_0_rd_en = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running;
assign mem_t2_0_rd_addr = copy_counter;

assign mem_t2_1_rd_en = mem_t2_0_rd_en;
assign mem_t2_1_rd_addr = mem_t2_0_rd_addr;

  // t3
wire mem_t3_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t3_0_dout;
wire mem_t3_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t3_1_dout;

assign mem_t3_0_rd_en = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running;
assign mem_t3_0_rd_addr = copy_counter;

assign mem_t3_1_rd_en = mem_t3_0_rd_en;
assign mem_t3_1_rd_addr = mem_t3_0_rd_addr;

  // t4
wire out_mem_t4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t4_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_dout;
wire out_mem_t4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t4_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_dout;

assign out_mem_t4_0_rd_en = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running;
assign out_mem_t4_0_rd_addr = copy_counter;

assign out_mem_t4_1_rd_en = out_mem_t4_0_rd_en;
assign out_mem_t4_1_rd_addr = out_mem_t4_0_rd_addr;

  // t5
wire out_mem_t5_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t5_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_dout;
wire out_mem_t5_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t5_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_dout;

assign out_mem_t5_0_rd_en = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running;
assign out_mem_t5_0_rd_addr = copy_counter;

assign out_mem_t5_1_rd_en = out_mem_t5_0_rd_en;
assign out_mem_t5_1_rd_addr = out_mem_t5_0_rd_addr;

  // t6
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_dout;
  // t7
wire out_mem_t7_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_dout;

wire out_mem_t7_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_dout;

reg out_mem_t7_0_wr_en;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t7_0_din; 

wire out_mem_t7_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t7_1_din; 

assign out_mem_t7_0_rd_en = eval_4_isog_mem_C0_0_rd_en;
assign out_mem_t7_0_rd_addr = eval_4_isog_mem_C0_0_rd_addr;
assign out_mem_t7_1_rd_en = eval_4_isog_mem_C0_1_rd_en;
assign out_mem_t7_1_rd_addr = eval_4_isog_mem_C0_1_rd_addr;

assign out_mem_t7_0_din = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? mem_t1_0_dout : 0;
assign out_mem_t7_1_wr_en = out_mem_t7_0_wr_en;
assign out_mem_t7_1_wr_addr = out_mem_t7_0_wr_addr;
assign out_mem_t7_1_din = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? mem_t1_1_dout : 0;

  // t8
wire out_mem_t8_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t8_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_0_dout;

wire out_mem_t8_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t8_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_1_dout;

wire out_mem_t8_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t8_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t8_0_din; 

wire out_mem_t8_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t8_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t8_1_din;

assign out_mem_t8_0_rd_en = eval_4_isog_mem_C1_0_rd_en;
assign out_mem_t8_0_rd_addr = eval_4_isog_mem_C1_0_rd_addr;
assign out_mem_t8_1_rd_en = eval_4_isog_mem_C1_1_rd_en;
assign out_mem_t8_1_rd_addr = eval_4_isog_mem_C1_1_rd_addr;

assign out_mem_t8_0_wr_en = out_mem_t7_0_wr_en;
assign out_mem_t8_0_wr_addr = out_mem_t7_0_wr_addr;
assign out_mem_t8_0_din = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? mem_t5_0_dout : 0;
assign out_mem_t8_1_wr_en = out_mem_t8_0_wr_en;
assign out_mem_t8_1_wr_addr = out_mem_t8_0_wr_addr;
assign out_mem_t8_1_din = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? mem_t5_1_dout : 0;

  // t9
wire out_mem_t9_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t9_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_0_dout;

wire out_mem_t9_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t9_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_1_dout;

wire out_mem_t9_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t9_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t9_0_din; 

wire out_mem_t9_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t9_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t9_1_din; 

assign out_mem_t9_0_rd_en = eval_4_isog_mem_C2_0_rd_en;
assign out_mem_t9_0_rd_addr = eval_4_isog_mem_C2_0_rd_addr;
assign out_mem_t9_1_rd_en = eval_4_isog_mem_C2_1_rd_en;
assign out_mem_t9_1_rd_addr = eval_4_isog_mem_C2_1_rd_addr;

assign out_mem_t9_0_wr_en = out_mem_t8_0_wr_en;
assign out_mem_t9_0_wr_addr = out_mem_t8_0_wr_addr;
assign out_mem_t9_0_din = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? mem_t4_0_dout : 0;
assign out_mem_t9_1_wr_en = out_mem_t9_0_wr_en;
assign out_mem_t9_1_wr_addr = out_mem_t9_0_wr_addr;
assign out_mem_t9_1_din = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? mem_t4_1_dout : 0;
 
  // t10 
reg out_mem_t10_0_wr_en;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t10_0_din; 

wire out_mem_t10_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t10_1_din; 

assign out_mem_t10_0_din = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running ? mem_t2_0_dout : 0;
assign out_mem_t10_1_wr_en = out_mem_t10_0_wr_en;
assign out_mem_t10_1_wr_addr = out_mem_t10_0_wr_addr;
assign out_mem_t10_1_din = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running ? mem_t2_1_dout : 0;

	// t11
wire out_mem_t11_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t11_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t11_0_din; 

wire out_mem_t11_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t11_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t11_1_din; 

assign out_mem_t11_0_wr_en = out_mem_t10_0_wr_en;
assign out_mem_t11_0_wr_addr = out_mem_t10_0_wr_addr;
assign out_mem_t11_0_din = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running ? mem_t3_0_dout : 0;
assign out_mem_t11_1_wr_en = out_mem_t11_0_wr_en;
assign out_mem_t11_1_wr_addr = out_mem_t11_0_wr_addr;
assign out_mem_t11_1_din = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running ? mem_t3_1_dout : 0;

          // input: Z4, Z4, {X, Z} (different pairs) 
parameter IDLE                                                         = 0,  
          // get_4_isog running
          GET_4_ISOG_COMPUTATION                                       = IDLE + 1, 
          // results of get_4_isog get copied to t7, t8 and t9
          GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9 = GET_4_ISOG_COMPUTATION + 1,
          // eval_4_isog running
          EVAL_4_ISOG_COMPUTATION                                      = GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9 + 1,
          // results of eval_4_isog get copied to t10 and t11
          EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11                = EVAL_4_ISOG_COMPUTATION + 1, 
          MAX_STATE                                                    = EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11 + 1;

reg [`CLOG2(MAX_STATE)-1:0] state;

reg GET_4_ISOG_COMPUTATION_running;
reg GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running;
reg EVAL_4_ISOG_COMPUTATION_running;
reg EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running;
 
wire last_copy_write;
reg last_copy_write_buf;
reg [SINGLE_MEM_DEPTH_LOG-1:0] copy_counter;

assign last_copy_write = (GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running | EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running) & (copy_counter == (SINGLE_MEM_DEPTH-1));

always @(posedge clk or posedge rst) begin
  if (rst) begin
    last_copy_write_buf <= 1'b0;
    copy_counter <= 0;
    out_mem_t7_0_wr_en <= 1'b0;
    out_mem_t7_0_wr_addr <= 0;
    out_mem_t10_0_wr_en <= 1'b0;
    out_mem_t10_0_wr_addr <= 0;
  end 
  else begin
    last_copy_write_buf <= last_copy_write;
    copy_counter <= (start | last_copy_write | last_copy_write_buf) ? 0 :
                    (GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running | EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running) ? copy_counter + 1 :
                    copy_counter;

    out_mem_t7_0_wr_en <= (start | (out_mem_t7_0_wr_addr == (SINGLE_MEM_DEPTH-1))) ? 1'b0 : 
                          GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? 1'b1 :
                          out_mem_t7_0_wr_en;
    out_mem_t7_0_wr_addr <= GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running ? copy_counter : out_mem_t7_0_wr_addr;

    out_mem_t10_0_wr_en <= (start | (out_mem_t10_0_wr_addr == (SINGLE_MEM_DEPTH-1))) ? 1'b0 : 
                           EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running ? 1'b1 :
                           out_mem_t10_0_wr_en;
    out_mem_t10_0_wr_addr <= EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running ? copy_counter : out_mem_t10_0_wr_addr;

  end
end

reg [7:0] function_reg;

reg controller_start;
wire controller_done;
wire controller_busy;
reg eval_4_isog_start_pre;
reg eval_4_isog_write_result_pre; 
reg last_eval_4_isog_mem_X_0_rd_buf;
reg last_copy_write_buf_buf;

// finite state machine transitions
always @(posedge clk or posedge rst) begin
  if (rst) begin 
    state <= IDLE;
    GET_4_ISOG_COMPUTATION_running <= 1'b0;
    GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running <= 1'b0;
    EVAL_4_ISOG_COMPUTATION_running <= 1'b0;
    EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running <= 1'b0;
    busy <= 1'b0;
    done <= 1'b0;
    controller_start <= 1'b0; 
    function_reg <= 8'd0; 
    eval_4_isog_start_pre <= 1'b0;
    eval_4_isog_write_result_pre <= 1'b0;
    eval_4_isog_result_ready <= 1'b0;
    eval_4_isog_XZ_can_overwrite <= 1'b1;
    last_eval_4_isog_mem_X_0_rd_buf <= 1'b0;
    last_copy_write_buf_buf <= 1'b0;
  end
  else begin 
  	// one-clock high signal
    done <= 1'b0; 
    controller_start <= 1'b0;
    last_copy_write_buf_buf <= last_copy_write_buf & EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running;
    last_eval_4_isog_mem_X_0_rd_buf <= (EVAL_4_ISOG_COMPUTATION_running & (eval_4_isog_mem_X_0_rd_addr == (SINGLE_MEM_DEPTH-1)) & eval_4_isog_mem_X_0_rd_en);
    // eval_4_isog_start_pre <= 1'b0; 
    // eval_4_isog_write_result_pre <= 1'b0;
    
    // 2-phase handshake signals
    eval_4_isog_XZ_can_overwrite <= (EVAL_4_ISOG_COMPUTATION_running & (eval_4_isog_mem_X_0_rd_addr == (SINGLE_MEM_DEPTH-1)) & eval_4_isog_mem_X_0_rd_en) | last_eval_4_isog_mem_X_0_rd_buf ? 1'b1 : // X has been used already
                                    eval_4_isog_XZ_newly_init ? 1'b0 :
                                    eval_4_isog_XZ_can_overwrite;
    eval_4_isog_result_ready <= (last_copy_write_buf & EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running) | last_copy_write_buf_buf ? 1'b1 :
                                eval_4_isog_result_can_overwrite ? 1'b0 :
                                eval_4_isog_result_ready;
    case (state) 
      IDLE: 
        if (start) begin
          state <= GET_4_ISOG_COMPUTATION;
          GET_4_ISOG_COMPUTATION_running <= 1'b1;
          controller_start <= 1'b1; 
          function_reg <= 8'd2;
          busy <= 1'b1; 
        end
        else if (eval_4_isog_start_pre & eval_4_isog_XZ_newly_init) begin
          state <= EVAL_4_ISOG_COMPUTATION;
          EVAL_4_ISOG_COMPUTATION_running <= 1'b1;
          controller_start <= 1'b1;
          function_reg <= 8'd4;
        end
        else begin  
          state <= IDLE;
        end

      GET_4_ISOG_COMPUTATION:
        if (controller_done) begin
          state <= GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9;
          GET_4_ISOG_COMPUTATION_running <= 1'b0;
          GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running <= 1'b1;
          function_reg <= 8'd0;
        end
        else begin
          state <= GET_4_ISOG_COMPUTATION;
        end

      GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9: 
        if (last_copy_write_buf) begin
          state <= IDLE; 
          GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9_running <= 1'b0;
          eval_4_isog_start_pre <= 1'b1;
        end 
        else begin
          state <= GET_4_ISOG_T1_COPY_TO_T7_AND_T5_COPY_TO_T8_AND_T4_COPY_TO_T9;
        end

      EVAL_4_ISOG_COMPUTATION:  
        if (controller_done) begin
          state <= EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11;
          EVAL_4_ISOG_COMPUTATION_running <= 1'b0; 
          EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running <= 1'b1;
          function_reg <= 8'd0; 
        end
        else begin
          state <= EVAL_4_ISOG_COMPUTATION;
        end 

      EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11:
        if (last_copy_write_buf & last_eval_4_isog) begin
          state <= IDLE; 
          EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running <= 1'b0;
          eval_4_isog_result_ready <= 1'b1; 
          busy <= 1'b0;
          done <= 1'b1;
        end
        else if (last_copy_write_buf) begin
          state <= IDLE; 
          EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11_running <= 1'b0;
          eval_4_isog_result_ready <= 1'b1; 
          eval_4_isog_start_pre <= 1'b1; 
        end
        else begin
          state <= EVAL_4_ISOG_T2_COPY_TO_T10_AND_T3_COPY_TO_T11;
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
  .function_encoded(function_reg),
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
  .xDBLADD_mem_XP_0_dout(0),
  .xDBLADD_mem_XP_0_rd_en(),
  .xDBLADD_mem_XP_0_rd_addr(),
  .xDBLADD_mem_XP_1_dout(0),
  .xDBLADD_mem_XP_1_rd_en(),
  .xDBLADD_mem_XP_1_rd_addr(),
  .xDBLADD_mem_ZP_0_dout(0),
  .xDBLADD_mem_ZP_0_rd_en(),
  .xDBLADD_mem_ZP_0_rd_addr(),
  .xDBLADD_mem_ZP_1_dout(0),
  .xDBLADD_mem_ZP_1_rd_en(),
  .xDBLADD_mem_ZP_1_rd_addr(),
  .xDBLADD_mem_XQ_0_dout(0),
  .xDBLADD_mem_XQ_0_rd_en(),
  .xDBLADD_mem_XQ_0_rd_addr(),
  .xDBLADD_mem_XQ_1_dout(0),
  .xDBLADD_mem_XQ_1_rd_en(),
  .xDBLADD_mem_XQ_1_rd_addr(),
  .xDBLADD_mem_ZQ_0_dout(0),
  .xDBLADD_mem_ZQ_0_rd_en(),
  .xDBLADD_mem_ZQ_0_rd_addr(),
  .xDBLADD_mem_ZQ_1_dout(0),
  .xDBLADD_mem_ZQ_1_rd_en(),
  .xDBLADD_mem_ZQ_1_rd_addr(),
  .xDBLADD_mem_A24_0_dout(0),
  .xDBLADD_mem_A24_0_rd_en(),
  .xDBLADD_mem_A24_0_rd_addr(), 
  .xDBLADD_mem_A24_1_dout(0),
  .xDBLADD_mem_A24_1_rd_en(),
  .xDBLADD_mem_A24_1_rd_addr(),
  .xDBLADD_mem_xPQ_0_dout(0),
  .xDBLADD_mem_xPQ_0_rd_en(),
  .xDBLADD_mem_xPQ_0_rd_addr(),
  .xDBLADD_mem_xPQ_1_dout(0),
  .xDBLADD_mem_xPQ_1_rd_en(),
  .xDBLADD_mem_xPQ_1_rd_addr(),
  .xDBLADD_mem_zPQ_0_dout(0),
  .xDBLADD_mem_zPQ_0_rd_en(),
  .xDBLADD_mem_zPQ_0_rd_addr(),
  .xDBLADD_mem_zPQ_1_dout(0),
  .xDBLADD_mem_zPQ_1_rd_en(),
  .xDBLADD_mem_zPQ_1_rd_addr(),
  .get_4_isog_mem_X4_0_dout(get_4_isog_mem_X4_0_dout),
  .get_4_isog_mem_X4_0_rd_en(get_4_isog_mem_X4_0_rd_en),
  .get_4_isog_mem_X4_0_rd_addr(get_4_isog_mem_X4_0_rd_addr),
  .get_4_isog_mem_X4_1_dout(get_4_isog_mem_X4_1_dout),
  .get_4_isog_mem_X4_1_rd_en(get_4_isog_mem_X4_1_rd_en),
  .get_4_isog_mem_X4_1_rd_addr(get_4_isog_mem_X4_1_rd_addr),
  .get_4_isog_mem_Z4_0_dout(get_4_isog_mem_Z4_0_dout),
  .get_4_isog_mem_Z4_0_rd_en(get_4_isog_mem_Z4_0_rd_en),
  .get_4_isog_mem_Z4_0_rd_addr(get_4_isog_mem_Z4_0_rd_addr),
  .get_4_isog_mem_Z4_1_dout(get_4_isog_mem_Z4_1_dout),
  .get_4_isog_mem_Z4_1_rd_en(get_4_isog_mem_Z4_1_rd_en),
  .get_4_isog_mem_Z4_1_rd_addr(get_4_isog_mem_Z4_1_rd_addr), 
  .eval_4_isog_mem_X_0_dout(eval_4_isog_mem_X_0_dout),
  .eval_4_isog_mem_X_0_rd_en(eval_4_isog_mem_X_0_rd_en),
  .eval_4_isog_mem_X_0_rd_addr(eval_4_isog_mem_X_0_rd_addr),
  .eval_4_isog_mem_X_1_dout(eval_4_isog_mem_X_1_dout),
  .eval_4_isog_mem_X_1_rd_en(eval_4_isog_mem_X_1_rd_en),
  .eval_4_isog_mem_X_1_rd_addr(eval_4_isog_mem_X_1_rd_addr),
  .eval_4_isog_mem_Z_0_dout(eval_4_isog_mem_Z_0_dout),
  .eval_4_isog_mem_Z_0_rd_en(eval_4_isog_mem_Z_0_rd_en),
  .eval_4_isog_mem_Z_0_rd_addr(eval_4_isog_mem_Z_0_rd_addr),
  .eval_4_isog_mem_Z_1_dout(eval_4_isog_mem_Z_1_dout),
  .eval_4_isog_mem_Z_1_rd_en(eval_4_isog_mem_Z_1_rd_en),
  .eval_4_isog_mem_Z_1_rd_addr(eval_4_isog_mem_Z_1_rd_addr),
  .eval_4_isog_mem_C0_0_dout(eval_4_isog_mem_C0_0_dout),
  .eval_4_isog_mem_C0_0_rd_en(eval_4_isog_mem_C0_0_rd_en),
  .eval_4_isog_mem_C0_0_rd_addr(eval_4_isog_mem_C0_0_rd_addr),
  .eval_4_isog_mem_C0_1_dout(eval_4_isog_mem_C0_1_dout),
  .eval_4_isog_mem_C0_1_rd_en(eval_4_isog_mem_C0_1_rd_en),
  .eval_4_isog_mem_C0_1_rd_addr(eval_4_isog_mem_C0_1_rd_addr),
  .eval_4_isog_mem_C1_0_dout(eval_4_isog_mem_C1_0_dout),
  .eval_4_isog_mem_C1_0_rd_en(eval_4_isog_mem_C1_0_rd_en),
  .eval_4_isog_mem_C1_0_rd_addr(eval_4_isog_mem_C1_0_rd_addr),
  .eval_4_isog_mem_C1_1_dout(eval_4_isog_mem_C1_1_dout),
  .eval_4_isog_mem_C1_1_rd_en(eval_4_isog_mem_C1_1_rd_en),
  .eval_4_isog_mem_C1_1_rd_addr(eval_4_isog_mem_C1_1_rd_addr),
  .eval_4_isog_mem_C2_0_dout(eval_4_isog_mem_C2_0_dout),
  .eval_4_isog_mem_C2_0_rd_en(eval_4_isog_mem_C2_0_rd_en),
  .eval_4_isog_mem_C2_0_rd_addr(eval_4_isog_mem_C2_0_rd_addr), 
  .eval_4_isog_mem_C2_1_dout(eval_4_isog_mem_C2_1_dout),
  .eval_4_isog_mem_C2_1_rd_en(eval_4_isog_mem_C2_1_rd_en),
  .eval_4_isog_mem_C2_1_rd_addr(eval_4_isog_mem_C2_1_rd_addr),
  .mem_t0_0_rd_en(0),
  .mem_t0_0_rd_addr(0),
  .mem_t0_0_dout(mem_t0_0_dout),
  .mem_t0_1_rd_en(0),
  .mem_t0_1_rd_addr(0),
  .mem_t0_1_dout(mem_t0_1_dout),
  .mem_t1_0_rd_en(mem_t1_0_rd_en),
  .mem_t1_0_rd_addr(mem_t1_0_rd_addr),
  .mem_t1_0_dout(mem_t1_0_dout),
  .mem_t1_1_rd_en(mem_t1_1_rd_en),
  .mem_t1_1_rd_addr(mem_t1_1_rd_addr),
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
  .out_mem_t4_0_rd_en(out_mem_t4_0_rd_en),
  .out_mem_t4_0_rd_addr(out_mem_t4_0_rd_addr),
  .mem_t4_0_dout(mem_t4_0_dout),
  .out_mem_t4_1_rd_en(out_mem_t4_1_rd_en),
  .out_mem_t4_1_rd_addr(out_mem_t4_1_rd_addr),
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
  .out_mem_t7_0_wr_en(out_mem_t7_0_wr_en),
  .out_mem_t7_0_wr_addr(out_mem_t7_0_wr_addr),
  .out_mem_t7_0_din(out_mem_t7_0_din),
  .out_mem_t7_0_rd_en(out_mem_t7_0_rd_en),
  .out_mem_t7_0_rd_addr(out_mem_t7_0_rd_addr),
  .mem_t7_0_dout(mem_t7_0_dout),
  .out_mem_t7_1_wr_en(out_mem_t7_1_wr_en),
  .out_mem_t7_1_wr_addr(out_mem_t7_1_wr_addr),
  .out_mem_t7_1_din(out_mem_t7_1_din),
  .out_mem_t7_1_rd_en(out_mem_t7_1_rd_en),
  .out_mem_t7_1_rd_addr(out_mem_t7_1_rd_addr),
  .mem_t7_1_dout(mem_t7_1_dout),
  .out_mem_t8_0_wr_en(out_mem_t8_0_wr_en),
  .out_mem_t8_0_wr_addr(out_mem_t8_0_wr_addr),
  .out_mem_t8_0_din(out_mem_t8_0_din),
  .out_mem_t8_0_rd_en(out_mem_t8_0_rd_en),
  .out_mem_t8_0_rd_addr(out_mem_t8_0_rd_addr),
  .mem_t8_0_dout(mem_t8_0_dout),
  .out_mem_t8_1_wr_en(out_mem_t8_1_wr_en),
  .out_mem_t8_1_wr_addr(out_mem_t8_1_wr_addr),
  .out_mem_t8_1_din(out_mem_t8_1_din),
  .out_mem_t8_1_rd_en(out_mem_t8_1_rd_en),
  .out_mem_t8_1_rd_addr(out_mem_t8_1_rd_addr),
  .mem_t8_1_dout(mem_t8_1_dout),
  .out_mem_t9_0_wr_en(out_mem_t9_0_wr_en),
  .out_mem_t9_0_wr_addr(out_mem_t9_0_wr_addr),
  .out_mem_t9_0_din(out_mem_t9_0_din),
  .out_mem_t9_0_rd_en(out_mem_t9_0_rd_en),
  .out_mem_t9_0_rd_addr(out_mem_t9_0_rd_addr),
  .mem_t9_0_dout(mem_t9_0_dout),
  .out_mem_t9_1_wr_en(out_mem_t9_1_wr_en),
  .out_mem_t9_1_wr_addr(out_mem_t9_1_wr_addr),
  .out_mem_t9_1_din(out_mem_t9_1_din),
  .out_mem_t9_1_rd_en(out_mem_t9_1_rd_en),
  .out_mem_t9_1_rd_addr(out_mem_t9_1_rd_addr),
  .mem_t9_1_dout(mem_t9_1_dout),
  .out_mem_t10_0_wr_en(out_mem_t10_0_wr_en),
  .out_mem_t10_0_wr_addr(out_mem_t10_0_wr_addr),
  .out_mem_t10_0_din(out_mem_t10_0_din),
  .out_mem_t10_0_rd_en(out_mem_t10_0_rd_en),
  .out_mem_t10_0_rd_addr(out_mem_t10_0_rd_addr),
  .mem_t10_0_dout(mem_t10_0_dout),
  .out_mem_t10_1_wr_en(out_mem_t10_1_wr_en),
  .out_mem_t10_1_wr_addr(out_mem_t10_1_wr_addr),
  .out_mem_t10_1_din(out_mem_t10_1_din),
  .out_mem_t10_1_rd_en(out_mem_t10_1_rd_en),
  .out_mem_t10_1_rd_addr(out_mem_t10_1_rd_addr),
  .mem_t10_1_dout(mem_t10_1_dout)
  ); 

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t11_0 (  
  .clock(clk),
  .data(out_mem_t11_0_din),
  .address(out_mem_t11_0_wr_en ? out_mem_t11_0_wr_addr : out_mem_t11_0_rd_addr),
  .wr_en(out_mem_t11_0_wr_en),
  .q(mem_t11_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t11_1 (  
  .clock(clk),
  .data(out_mem_t11_1_din),
  .address(out_mem_t11_1_wr_en ? out_mem_t11_1_wr_addr : out_mem_t11_1_rd_addr),
  .wr_en(out_mem_t11_1_wr_en),
  .q(mem_t11_1_dout)
  );


endmodule