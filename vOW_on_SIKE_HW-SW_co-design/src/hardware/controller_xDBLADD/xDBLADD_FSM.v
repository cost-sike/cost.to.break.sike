/* 
Function: doubling-and-add function

Follow the steps below:
def xDBLADD(XP,ZP,XQ,ZQ,xPQ,A24):

    t0 = XP+ZP
    t1 = XP-ZP
    
    t4 = t0
    t5 = t1
    t0 = XQ+ZQ
    t1 = XQ-ZQ

    t2 = t1*t4          #### parallel1    t4 keep
    t3 = t0*t5          #### parallel1    t5 keep
    
    t6 = t2
    t7 = t3
    t2 = t4^2           #### parallel2    t4 free
    t3 = t5^2           #### parallel2    t5 free

    t4 = t2                               t4 keep
    t5 = t3                               t5 keep
    t0 = t2-t3
    t1 = t6-t7                            t6 keep; t7 keep
    
    t8 = t0                               t8 keep
    t9 = t1                               t9 keep
    t2 = t4*t5          #### parallel3    t4 free; t5 keep
    t3 = t0*A24         #### parallel3
    
    t10 = t2 
    t4 = t3
    t0 = t5+t3                             t5 free                
    t1 = t6+t7                             t6 free; t7 free

    t2 = t1^2          #### parallel4      t9 free
    t3 = t9^2           #### parallel4
    
    t5 = t3
    t4 = t2

    t2 = t0*t8         #### parallel5
    t3 = xPQ*t5         #### parallel5

    return t10,t2,t4,t3
*/

// Assumption: 
// 1: all of the operands are from GF(p^2)
// 2: inputs XP,ZP,XQ,ZQ,xPQ,A24 have been initialized before this module is triggered
// 3: when there are parallel add/sub computations, they share the same timing. FIXME, need to double check

module xDBLADD_FSM 
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
  input wire start,
  output reg busy,
  output reg done,

  // interface with input memory XP
  input wire [SINGLE_MEM_WIDTH-1:0] mem_XP_0_dout,
  output wire mem_XP_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XP_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_XP_1_dout,
  output wire mem_XP_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XP_1_rd_addr,

  // interface with input memory XQ
  input wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_0_dout,
  output wire mem_XQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_XQ_1_dout,
  output wire mem_XQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_XQ_1_rd_addr,

    // interface with input memory ZP
  input wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_0_dout,
  output wire mem_ZP_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZP_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_ZP_1_dout,
  output wire mem_ZP_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZP_1_rd_addr,

  // interface with input memory ZQ
  input wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_0_dout,
  output wire mem_ZQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_ZQ_1_dout,
  output wire mem_ZQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_ZQ_1_rd_addr,

  // interface with input memory A24
  input wire [SINGLE_MEM_WIDTH-1:0] mem_A24_0_dout,
  output wire mem_A24_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_A24_1_dout,
  output wire mem_A24_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_1_rd_addr,

  // interface with input memory xPQ
  input wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_0_dout,
  output wire mem_xPQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_xPQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_xPQ_1_dout,
  output wire mem_xPQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_xPQ_1_rd_addr,

  // interface with input memory zPQ
  input wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_0_dout,
  output wire mem_zPQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_zPQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_zPQ_1_dout,
  output wire mem_zPQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_zPQ_1_rd_addr,

  // interface with intermediate operands t4 
  output reg mem_t4_0_wr_en,
  output reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_din,
  output wire mem_t4_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_0_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_dout,

  output wire mem_t4_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_din,
  output wire mem_t4_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_1_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_dout,

  // interface with intermediate operands t5 
  output reg mem_t5_0_wr_en,
  output reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_din,
  output wire mem_t5_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_0_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_dout, 

  output wire mem_t5_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_din,
  output wire mem_t5_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_1_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_dout,

  // interface with intermediate operands t6 
  output reg mem_t6_0_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_din,
  output wire mem_t6_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_0_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_dout, 

  output wire mem_t6_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_din,
  output wire mem_t6_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_1_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_dout,

    // interface with intermediate operands t7 
  output reg mem_t7_0_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_din,
  output wire mem_t7_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_0_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_dout, 

  output wire mem_t7_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_din,
  output wire mem_t7_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_1_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_dout,

    // interface with intermediate operands t8 
  output reg mem_t8_0_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t8_0_din,
  output wire mem_t8_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_0_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t8_0_dout, 

  output wire mem_t8_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t8_1_din,
  output wire mem_t8_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_1_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t8_1_dout,

    // interface with intermediate operands t9 
  output reg mem_t9_0_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t9_0_din,
  output wire mem_t9_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_0_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t9_0_dout, 

  output wire mem_t9_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t9_1_din,
  output wire mem_t9_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_1_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mem_t9_1_dout,

    // interface with intermediate operands t10 
  output reg mem_t10_0_wr_en,
  output reg [SINGLE_MEM_DEPTH_LOG-1:0] mem_t10_0_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_din, 

  output wire mem_t10_1_wr_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t10_1_wr_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_din, 

   // interface to adder A
  output reg add_A_start,
  input wire add_A_busy,
  input wire add_A_done,

  output wire [2:0] add_A_cmd,
  output wire add_A_extension_field_op,

    // input memories
  input wire add_A_mem_a_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_a_0_rd_addr, 
  output wire [RADIX-1:0] add_A_mem_a_0_dout,
  input wire add_A_mem_a_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_a_1_rd_addr, 
  output wire [RADIX-1:0] add_A_mem_a_1_dout,
   
  input wire add_A_mem_b_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_b_0_rd_addr, 
  output wire [RADIX-1:0] add_A_mem_b_0_dout,
   
  input wire add_A_mem_b_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_b_1_rd_addr, 
  output wire [RADIX-1:0] add_A_mem_b_1_dout,
    // result memory
  output wire add_A_mem_c_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_c_0_rd_addr, 
  input wire [RADIX-1:0] add_A_mem_c_0_dout, 

  output wire add_A_mem_c_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_c_1_rd_addr, 
  input wire [RADIX-1:0] add_A_mem_c_1_dout,

    // px2 memory
  input wire add_A_px2_mem_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_px2_mem_rd_addr,

    // px4 memory
  input wire add_A_px4_mem_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_px4_mem_rd_addr,

   // interface to adder B
  output reg add_B_start,
  input wire add_B_busy,
  input wire add_B_done,

  output wire [2:0] add_B_cmd,
  output wire add_B_extension_field_op,
    // input memories
  input wire add_B_mem_a_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_a_0_rd_addr, 
  output wire [RADIX-1:0] add_B_mem_a_0_dout,
   
  input wire add_B_mem_a_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_a_1_rd_addr, 
  output wire [RADIX-1:0] add_B_mem_a_1_dout,
   
  input wire add_B_mem_b_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_b_0_rd_addr, 
  output wire [RADIX-1:0] add_B_mem_b_0_dout,
   
  input wire add_B_mem_b_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_b_1_rd_addr, 
  output wire [RADIX-1:0] add_B_mem_b_1_dout,
    // result memory
  output wire add_B_mem_c_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_c_0_rd_addr, 
  input wire [RADIX-1:0] add_B_mem_c_0_dout, 

  output wire add_B_mem_c_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_c_1_rd_addr, 
  input wire [RADIX-1:0] add_B_mem_c_1_dout,

    // px2 memory
  input wire add_B_px2_mem_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_px2_mem_rd_addr,

    // px4 memory
  input wire add_B_px4_mem_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_px4_mem_rd_addr,

  // interface to multiplier A
  output reg mult_A_start,
  input wire mult_A_done,
  input wire mult_A_busy,

    // input memory
  input wire mult_A_mem_a_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_a_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_a_0_dout,
   
  input wire mult_A_mem_a_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_a_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_a_1_dout,
   
  input wire mult_A_mem_b_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_b_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_0_dout,

  input wire mult_A_mem_b_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_b_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_1_dout,
   
  input wire mult_A_mem_c_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_c_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_c_1_dout, 
    
    // result memory  
  output wire mult_A_sub_mem_single_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_sub_mem_single_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_A_sub_mem_single_dout,

  output wire mult_A_add_mem_single_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_add_mem_single_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_A_add_mem_single_dout,

  input wire mult_A_px2_mem_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_px2_mem_rd_addr, 

  // interface to multiplier B
  output reg mult_B_start,
  input wire mult_B_done,
  input wire mult_B_busy,

    // input memory
  input wire mult_B_mem_a_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_a_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_a_0_dout,
   
  input wire mult_B_mem_a_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_a_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_a_1_dout,
   
  input wire mult_B_mem_b_0_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_b_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_0_dout,

  input wire mult_B_mem_b_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_b_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_1_dout,
   
  input wire mult_B_mem_c_1_rd_en, 
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_c_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_c_1_dout, 
    
    // result memory 
  output wire mult_B_sub_mem_single_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_sub_mem_single_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_B_sub_mem_single_dout,

  output wire mult_B_add_mem_single_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_add_mem_single_rd_addr,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_B_add_mem_single_dout,

  input wire mult_B_px2_mem_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_px2_mem_rd_addr,

  // interface to constants memory
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] p_plus_one_mem_rd_addr,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] px2_mem_rd_addr,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] px4_mem_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] p_plus_one_mem_dout,
  input wire [SINGLE_MEM_WIDTH-1:0] px2_mem_dout,
  input wire [SINGLE_MEM_WIDTH-1:0] px4_mem_dout,

  // specific for squaring logic
  input wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_0_dout_buf,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_1_dout_buf,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_0_dout_buf,
  input wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_1_dout_buf,

  output wire mult_A_used_for_squaring_running,
  output wire mult_B_used_for_squaring_running

);
  
wire add_running;
wire mult_running;

reg real_mult_A_start;
reg real_mult_B_start;
 
          // input: XP,ZP,XQ,ZQ,xPQ,A24
parameter IDLE                            = 0, 
          // t0 = XP+ZP
          // t1 = XP-ZP
          XP_PLUS_ZP_AND_XP_MINUS_ZP      = IDLE + 1, 
          // t4 = t0
          // t5 = t1
          T0_COPY_TO_T4_AND_T1_COPY_TO_T5 = XP_PLUS_ZP_AND_XP_MINUS_ZP + 1,
          // t0 = XQ+ZQ
          // t1 = XQ-ZQ
          XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ      = T0_COPY_TO_T4_AND_T1_COPY_TO_T5 + 1, 
          // t2 = t1*t4
          // t3 = t0*t5
          T1_TIMES_T4_AND_T0_TIMES_T5     = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ + 1,
          // t6 = t2
          // t7 = t3
          T2_COPY_TO_T6_AND_T3_COPY_TO_T7 = T1_TIMES_T4_AND_T0_TIMES_T5 + 1,
          // t2 = t4*t4
          // t3 = t5*t5
          T4_SQUARE_AND_T5_SQUARE         = T2_COPY_TO_T6_AND_T3_COPY_TO_T7 + 1,
          // t4 = t2
          // t5 = t3
          // t0 = t2-t3
          // t1 = t6-t7
          T2_MINUS_T3_AND_T6_MINUS_T7     = T4_SQUARE_AND_T5_SQUARE + 1,
          // t8 = t0
          // t9 = t1
          T0_COPY_TO_T8_AND_T1_COPY_TO_T9 = T2_MINUS_T3_AND_T6_MINUS_T7 + 1,
          // t2 = t4*t5
          // t3 = t0*A24
          T4_TIMES_T5_AND_T0_TIMES_A24    = T0_COPY_TO_T8_AND_T1_COPY_TO_T9 + 1, 
          // t10 = t2
          // t4 = t3
          // t0 = t5+t3
          // t1 = t6+t7
          T5_PLUS_T3_AND_T6_PLUS_T7       = T4_TIMES_T5_AND_T0_TIMES_A24 + 1,
          // t2 = t1*t1
          // t3 = t9*t9
          T1_SQUARE_AND_T9_SQUARE         = T5_PLUS_T3_AND_T6_PLUS_T7 + 1,
          // t4 = t2 
          // t5 = t3
          T2_COPY_TO_T4_AND_T3_COPY_TO_T5 = T1_SQUARE_AND_T9_SQUARE + 1,
          // t2 = t0*t8
          // t3 = xPQ*t5
          T0_TIMES_T8_AND_XPQ_TIMES_T5    = T2_COPY_TO_T4_AND_T3_COPY_TO_T5 + 1,
          // t5 = t2
          T2_COPY_TO_T5                   = T0_TIMES_T8_AND_XPQ_TIMES_T5 + 1,
          // t2 = t4*zPQ
          T4_TIMES_zPQ                    = T2_COPY_TO_T5 + 1,
          MAX_STATE                       = T4_TIMES_zPQ + 1;

reg [`CLOG2(MAX_STATE)-1:0] state; 
 
reg XP_PLUS_ZP_AND_XP_MINUS_ZP_running;
reg T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running;
reg XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running;
reg T1_TIMES_T4_AND_T0_TIMES_T5_running;
reg T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running;
reg T4_SQUARE_AND_T5_SQUARE_running;
reg T2_MINUS_T3_AND_T6_MINUS_T7_running;
reg T4_TIMES_T5_AND_T0_TIMES_A24_running;
reg T5_PLUS_T3_AND_T6_PLUS_T7_running;
reg T1_SQUARE_AND_T9_SQUARE_running;
reg T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running;
reg T0_TIMES_T8_AND_XPQ_TIMES_T5_running;
reg T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running;
reg T2_COPY_TO_T5_running;
reg T4_TIMES_zPQ_running;
reg MAX_STATE_running;

reg [SINGLE_MEM_DEPTH_LOG-1:0] counter; 
reg [SINGLE_MEM_DEPTH_LOG-1:0] counter_buf; 
wire last_copy_write;
reg last_copy_write_buf;
reg last_copy_write_buf_2;
assign last_copy_write = (T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running | T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T5_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) & (counter == (SINGLE_MEM_DEPTH-1));


assign mult_A_used_for_squaring_running = T4_SQUARE_AND_T5_SQUARE_running | T1_SQUARE_AND_T9_SQUARE_running;
assign mult_B_used_for_squaring_running = mult_A_used_for_squaring_running;

// interface to memory XP
// here it requires that add_A and add_B have exactly the same timing sequence
// XP is read at :
// t0 = XP+ZP
// t1 = XP-ZP
assign mem_XP_0_rd_en = XP_PLUS_ZP_AND_XP_MINUS_ZP_running & add_A_mem_a_0_rd_en;
assign mem_XP_0_rd_addr = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? add_A_mem_a_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_XP_1_rd_en = XP_PLUS_ZP_AND_XP_MINUS_ZP_running & add_A_mem_a_1_rd_en;
assign mem_XP_1_rd_addr = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? add_A_mem_a_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory ZP
// ZP is read at :
// t0 = XP+ZP
// t1 = XP-ZP
assign mem_ZP_0_rd_en = XP_PLUS_ZP_AND_XP_MINUS_ZP_running & add_A_mem_b_0_rd_en;
assign mem_ZP_0_rd_addr = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? add_A_mem_b_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_ZP_1_rd_en = XP_PLUS_ZP_AND_XP_MINUS_ZP_running & add_A_mem_b_1_rd_en;
assign mem_ZP_1_rd_addr = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? add_A_mem_b_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory XQ
// here it requires that add_A and add_B have exactly the same timing sequence
// XQ is read at :
// t0 = XQ+ZQ
// t1 = XQ-ZQ
assign mem_XQ_0_rd_en = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running & add_A_mem_a_0_rd_en;
assign mem_XQ_0_rd_addr = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? add_A_mem_a_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_XQ_1_rd_en = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running & add_A_mem_a_1_rd_en;
assign mem_XQ_1_rd_addr = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? add_A_mem_a_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory ZQ
// ZQ is read at :
// t0 = XQ+ZQ
// t1 = XQ-ZQ
assign mem_ZQ_0_rd_en = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running & add_A_mem_b_0_rd_en;
assign mem_ZQ_0_rd_addr = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? add_A_mem_b_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_ZQ_1_rd_en = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running & add_A_mem_b_1_rd_en;
assign mem_ZQ_1_rd_addr = XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? add_A_mem_b_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory xPQ
// xPQ is read at :
// t3 = xPQ*t5 
assign mem_xPQ_0_rd_en = T0_TIMES_T8_AND_XPQ_TIMES_T5_running & mult_B_mem_a_0_rd_en;
assign mem_xPQ_0_rd_addr = T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_B_mem_a_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_xPQ_1_rd_en = T0_TIMES_T8_AND_XPQ_TIMES_T5_running & mult_B_mem_a_1_rd_en;
assign mem_xPQ_1_rd_addr = T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_B_mem_a_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory zPQ
// zPQ is read at :
// t2 = t4*zPQ 
assign mem_zPQ_0_rd_en = T4_TIMES_zPQ_running & mult_A_mem_b_0_rd_en;
assign mem_zPQ_0_rd_addr = T4_TIMES_zPQ_running ? mult_A_mem_b_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_zPQ_1_rd_en = T4_TIMES_zPQ_running & mult_A_mem_b_1_rd_en;
assign mem_zPQ_1_rd_addr = T4_TIMES_zPQ_running ? mult_A_mem_b_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory A24
// A24 is read at :
// t3 = t0*A24
assign mem_A24_0_rd_en = T4_TIMES_T5_AND_T0_TIMES_A24_running & mult_B_mem_b_0_rd_en;
assign mem_A24_0_rd_addr = T4_TIMES_T5_AND_T0_TIMES_A24_running ? mult_B_mem_b_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_A24_1_rd_en = T4_TIMES_T5_AND_T0_TIMES_A24_running & mult_B_mem_b_1_rd_en;
assign mem_A24_1_rd_addr = T4_TIMES_T5_AND_T0_TIMES_A24_running ? mult_B_mem_b_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory t4
// t4 is written at:
// t4 = t0 T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running
// t4 = t2 T2_MINUS_T3_AND_T6_MINUS_T7_running
// t4 = t3 T5_PLUS_T3_AND_T6_PLUS_T7_running
// t4 = t2 T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running
assign mem_t4_0_din = T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running ? add_A_mem_c_0_dout : 
                      (T2_MINUS_T3_AND_T6_MINUS_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? mult_A_sub_mem_single_dout :
                      T5_PLUS_T3_AND_T6_PLUS_T7_running ? mult_B_sub_mem_single_dout :
                      {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t4_1_wr_en = mem_t4_0_wr_en;
assign mem_t4_1_wr_addr = mem_t4_0_wr_addr;
assign mem_t4_1_din = T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running ? add_A_mem_c_1_dout : 
                      (T2_MINUS_T3_AND_T6_MINUS_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? mult_A_add_mem_single_dout :
                      T5_PLUS_T3_AND_T6_PLUS_T7_running ? mult_B_add_mem_single_dout :
                      {SINGLE_MEM_WIDTH{1'b0}};
// t4 is read at:
// t2 = t1*t4   T1_TIMES_T4_AND_T0_TIMES_T5_running
// t2 = t4^2    T4_SQUARE_AND_T5_SQUARE_running
// t2 = t4*t5   T4_TIMES_T5_AND_T0_TIMES_A24_running
// t2 = t4*zPQ  T4_TIMES_zPQ_running
assign mem_t4_0_rd_en = T1_TIMES_T4_AND_T0_TIMES_T5_running ? mult_A_mem_b_0_rd_en :
                        (T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24_running | T4_TIMES_zPQ_running) ? mult_A_mem_a_0_rd_en :
                        1'b0;
assign mem_t4_0_rd_addr = T1_TIMES_T4_AND_T0_TIMES_T5_running ? mult_A_mem_b_0_rd_addr :
                          (T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24_running | T4_TIMES_zPQ_running) ? mult_A_mem_a_0_rd_addr :
                          {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t4_1_rd_en = T1_TIMES_T4_AND_T0_TIMES_T5_running ? mult_A_mem_b_1_rd_en :
                        (T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24_running | T4_TIMES_zPQ_running) ? mult_A_mem_a_1_rd_en :
                        1'b0;
assign mem_t4_1_rd_addr = T1_TIMES_T4_AND_T0_TIMES_T5_running ? mult_A_mem_b_1_rd_addr :
                          (T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24_running | T4_TIMES_zPQ_running) ? mult_A_mem_a_1_rd_addr :
                          {SINGLE_MEM_DEPTH_LOG{1'b0}};


// interface to memory t5
// t5 is written at:
// t5 = t1  T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running
// t5 = t3  T2_MINUS_T3_AND_T6_MINUS_T7_running
// t5 = t3  T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running
// t5 = t2  T2_COPY_TO_T5_running
assign mem_t5_0_din = T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running ? add_B_mem_c_0_dout :
                      (T2_MINUS_T3_AND_T6_MINUS_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? mult_B_sub_mem_single_dout :
                      T2_COPY_TO_T5_running ? mult_A_sub_mem_single_dout :
                      {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t5_1_wr_en = mem_t5_0_wr_en;
assign mem_t5_1_wr_addr = mem_t5_0_wr_addr;
assign mem_t5_1_din = T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running ? add_B_mem_c_1_dout :
                      (T2_MINUS_T3_AND_T6_MINUS_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? mult_B_add_mem_single_dout :
                      T2_COPY_TO_T5_running ? mult_A_add_mem_single_dout :
                      {SINGLE_MEM_WIDTH{1'b0}};
// t5 is read at:
// t3 = t0*t5  T1_TIMES_T4_AND_T0_TIMES_T5_running
// t3 = t5^2   T4_SQUARE_AND_T5_SQUARE_running
// t2 = t4*t5  T4_TIMES_T5_AND_T0_TIMES_A24_running     
// t0 = t5+t3  T5_PLUS_T3_AND_T6_PLUS_T7_running 
// t3 = xPQ*t5 T0_TIMES_T8_AND_XPQ_TIMES_T5_running        
assign mem_t5_0_rd_en = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running) ? mult_B_mem_b_0_rd_en :
                        T4_SQUARE_AND_T5_SQUARE_running ? mult_B_mem_a_0_rd_en :
                        T4_TIMES_T5_AND_T0_TIMES_A24_running ? mult_A_mem_b_0_rd_en :
                        T5_PLUS_T3_AND_T6_PLUS_T7_running ? add_A_mem_a_0_rd_en :
                        1'b0;
assign mem_t5_0_rd_addr = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running) ? mult_B_mem_b_0_rd_addr :
                          T4_SQUARE_AND_T5_SQUARE_running ? mult_B_mem_a_0_rd_addr :
                          T4_TIMES_T5_AND_T0_TIMES_A24_running ? mult_A_mem_b_0_rd_addr :
                          T5_PLUS_T3_AND_T6_PLUS_T7_running ? add_A_mem_a_0_rd_addr :
                          {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t5_1_rd_en = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running) ? mult_B_mem_b_1_rd_en :
                        T4_SQUARE_AND_T5_SQUARE_running ? mult_B_mem_a_1_rd_en :
                        T4_TIMES_T5_AND_T0_TIMES_A24_running ? mult_A_mem_b_1_rd_en :
                        T5_PLUS_T3_AND_T6_PLUS_T7_running ? add_A_mem_a_1_rd_en :
                        1'b0;
assign mem_t5_1_rd_addr = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running) ? mult_B_mem_b_1_rd_addr :
                          T4_SQUARE_AND_T5_SQUARE_running ? mult_B_mem_a_1_rd_addr :
                          T4_TIMES_T5_AND_T0_TIMES_A24_running ? mult_A_mem_b_1_rd_addr :
                          T5_PLUS_T3_AND_T6_PLUS_T7_running ? add_A_mem_a_1_rd_addr :
                          {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory t6
// t6 is written at:
// t6 = t2  T2_COPY_TO_T6_AND_T3_COPY_TO_T7 
assign mem_t6_0_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mult_A_sub_mem_single_dout : {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t6_1_wr_en = mem_t6_0_wr_en;
assign mem_t6_1_wr_addr = mem_t6_0_wr_addr;
assign mem_t6_1_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mult_A_add_mem_single_dout : {SINGLE_MEM_WIDTH{1'b0}};
// t6 is read at:
// t1 = t6-t7  T2_MINUS_T3_AND_T6_MINUS_T7_running      
// t1 = t6+t7  T5_PLUS_T3_AND_T6_PLUS_T7_running        
assign mem_t6_0_rd_en = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_a_0_rd_en : 1'b0;
assign mem_t6_0_rd_addr = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_a_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t6_1_rd_en = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_a_1_rd_en : 1'b0;
assign mem_t6_1_rd_addr = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_a_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory t7
// t7 is written at:
// t7 = t3  T4_SQUARE_AND_T5_SQUARE_running 
assign mem_t7_0_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mult_B_sub_mem_single_dout : {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t7_1_wr_en = mem_t7_0_wr_en;
assign mem_t7_1_wr_addr = mem_t7_0_wr_addr;
assign mem_t7_1_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mult_B_add_mem_single_dout : {SINGLE_MEM_WIDTH{1'b0}};
// t7 is read at:
// t1 = t6-t7  T2_MINUS_T3_AND_T6_MINUS_T7_running      
// t1 = t6+t7  T5_PLUS_T3_AND_T6_PLUS_T7_running        
assign mem_t7_0_rd_en = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_b_0_rd_en : 1'b0;
assign mem_t7_0_rd_addr = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_b_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t7_1_rd_en = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_b_1_rd_en : 1'b0;
assign mem_t7_1_rd_addr = (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? add_B_mem_b_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory t8
// t8 is written at:
// t8 = t0  T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running 
assign mem_t8_0_din = T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? add_A_mem_c_0_dout : {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t8_1_wr_en = mem_t8_0_wr_en;
assign mem_t8_1_wr_addr = mem_t8_0_wr_addr;
assign mem_t8_1_din = T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? add_A_mem_c_1_dout : {SINGLE_MEM_WIDTH{1'b0}};
// t8 is read at:
// t2 = t0*t8  T0_TIMES_T8_AND_XPQ_TIMES_T5_running      
assign mem_t8_0_rd_en = T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_b_0_rd_en : 1'b0;
assign mem_t8_0_rd_addr = T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_b_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t8_1_rd_en = T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_b_1_rd_en : 1'b0;
assign mem_t8_1_rd_addr = T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_b_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory t9
// t9 is written at:
// t9 = t1  T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running 
assign mem_t9_0_din = T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? add_B_mem_c_0_dout : {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t9_1_wr_en = mem_t9_0_wr_en;
assign mem_t9_1_wr_addr = mem_t9_0_wr_addr;
assign mem_t9_1_din = T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? add_B_mem_c_1_dout : {SINGLE_MEM_WIDTH{1'b0}};
// t9 is read at:
// t3 = t9^2  T1_SQUARE_AND_T9_SQUARE_running      
assign mem_t9_0_rd_en = T1_SQUARE_AND_T9_SQUARE_running ? mult_B_mem_a_0_rd_en : 1'b0;
assign mem_t9_0_rd_addr = T1_SQUARE_AND_T9_SQUARE_running ? mult_B_mem_a_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t9_1_rd_en = T1_SQUARE_AND_T9_SQUARE_running ? mult_B_mem_a_1_rd_en : 1'b0;
assign mem_t9_1_rd_addr = T1_SQUARE_AND_T9_SQUARE_running ? mult_B_mem_a_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to memory t10
// t10 is written at:
// t10 = t2  T5_PLUS_T3_AND_T6_PLUS_T7_running 
assign mem_t10_0_din = T5_PLUS_T3_AND_T6_PLUS_T7_running ? mult_A_sub_mem_single_dout : {SINGLE_MEM_WIDTH{1'b0}};
assign mem_t10_1_wr_en = mem_t10_0_wr_en;
assign mem_t10_1_wr_addr = mem_t10_0_wr_addr;
assign mem_t10_1_din = T5_PLUS_T3_AND_T6_PLUS_T7_running ? mult_A_add_mem_single_dout : {SINGLE_MEM_WIDTH{1'b0}}; 


// interface to adder A:  
// the memories within the adder is READ only to the outside world
assign add_A_cmd = (XP_PLUS_ZP_AND_XP_MINUS_ZP_running | XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? 3'd1 :
                   T2_MINUS_T3_AND_T6_MINUS_T7_running ? 3'd2 : 
                   3'd0;
assign add_A_extension_field_op = 1'b1; // always doing GF(p^2) operation
assign add_A_mem_a_0_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_XP_0_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_XQ_0_dout : 
                            T2_MINUS_T3_AND_T6_MINUS_T7_running ? mult_A_sub_mem_single_dout :
                            T5_PLUS_T3_AND_T6_PLUS_T7_running ? mem_t5_0_dout :
                            {SINGLE_MEM_WIDTH{1'b0}};
assign add_A_mem_a_1_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_XP_1_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_XQ_1_dout : 
                            T2_MINUS_T3_AND_T6_MINUS_T7_running ? mult_A_add_mem_single_dout :
                            T5_PLUS_T3_AND_T6_PLUS_T7_running ? mem_t5_1_dout :
                            {SINGLE_MEM_WIDTH{1'b0}};
assign add_A_mem_b_0_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_ZP_0_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_ZQ_0_dout : 
                            (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mult_B_sub_mem_single_dout : 
                            {SINGLE_MEM_WIDTH{1'b0}};
assign add_A_mem_b_1_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_ZP_1_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_ZQ_1_dout : 
                            (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mult_B_add_mem_single_dout : 
                            {SINGLE_MEM_WIDTH{1'b0}};
// t0 is read at:
// t4 = t0      T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running
// t3 = t0*t5   T1_TIMES_T4_AND_T0_TIMES_T5_running
// t8 = t0      T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running
// t3 = t0*A24  T4_TIMES_T5_AND_T0_TIMES_A24_running
// t2 = t0*t8   T0_TIMES_T8_AND_XPQ_TIMES_T5_running
assign add_A_mem_c_0_rd_en = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? 1'b1 : 
                             (T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_TIMES_T5_AND_T0_TIMES_A24_running) ? mult_B_mem_a_0_rd_en :
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_a_0_rd_en :
                             1'b0;
assign add_A_mem_c_0_rd_addr = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? counter : 
                               (T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_TIMES_T5_AND_T0_TIMES_A24_running) ? mult_B_mem_a_0_rd_addr :
                               T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_a_0_rd_addr :
                               {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign add_A_mem_c_1_rd_en = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? 1'b1 : 
                             (T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_TIMES_T5_AND_T0_TIMES_A24_running) ? mult_B_mem_a_1_rd_en :
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_a_1_rd_en :
                             1'b0;
assign add_A_mem_c_1_rd_addr = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? counter : 
                               (T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_TIMES_T5_AND_T0_TIMES_A24_running) ? mult_B_mem_a_1_rd_addr :
                               T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mult_A_mem_a_1_rd_addr :
                               {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to adder B 
// the memories within the adder is READ only to the outside world 
assign add_B_cmd = T5_PLUS_T3_AND_T6_PLUS_T7_running ? 3'd1 :
                   (XP_PLUS_ZP_AND_XP_MINUS_ZP_running | XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running | T2_MINUS_T3_AND_T6_MINUS_T7_running) ? 3'd2 :
                   3'd0;
assign add_B_extension_field_op = 1'b1; // always doing GF(p^2) operation
assign add_B_mem_a_0_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_XP_0_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_XQ_0_dout :
                            (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t6_0_dout : 
                            {SINGLE_MEM_WIDTH{1'b0}};
assign add_B_mem_a_1_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_XP_1_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_XQ_1_dout :
                            (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t6_1_dout : 
                            {SINGLE_MEM_WIDTH{1'b0}};
assign add_B_mem_b_0_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_ZP_0_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_ZQ_0_dout :
                            (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_0_dout : 
                            {SINGLE_MEM_WIDTH{1'b0}};
assign add_B_mem_b_1_dout = XP_PLUS_ZP_AND_XP_MINUS_ZP_running ? mem_ZP_1_dout : 
                            XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running ? mem_ZQ_1_dout :
                            (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_1_dout : 
                            {SINGLE_MEM_WIDTH{1'b0}};
// t1 is read at:
// t5 = t1     T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running 
// t2 = t1*t4  T1_TIMES_T4_AND_T0_TIMES_T5_running 
// t9 = t1     T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running
// t2 = t1^2   T1_SQUARE_AND_T9_SQUARE_running
assign add_B_mem_c_0_rd_en = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? 1'b1 : 
                             (T1_SQUARE_AND_T9_SQUARE_running | T1_TIMES_T4_AND_T0_TIMES_T5_running) ? mult_A_mem_a_0_rd_en :
                             1'b0;
assign add_B_mem_c_0_rd_addr = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? counter : 
                               (T1_SQUARE_AND_T9_SQUARE_running | T1_TIMES_T4_AND_T0_TIMES_T5_running) ? mult_A_mem_a_0_rd_addr :
                               {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign add_B_mem_c_1_rd_en = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? 1'b1 : 
                             (T1_SQUARE_AND_T9_SQUARE_running | T1_TIMES_T4_AND_T0_TIMES_T5_running) ? mult_A_mem_a_1_rd_en :
                             1'b0;
assign add_B_mem_c_1_rd_addr = (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? counter : 
                               (T1_SQUARE_AND_T9_SQUARE_running | T1_TIMES_T4_AND_T0_TIMES_T5_running) ? mult_A_mem_a_1_rd_addr :
                               {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to multiplier A 
assign mult_A_mem_a_0_dout = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T1_SQUARE_AND_T9_SQUARE_running) ? add_B_mem_c_0_dout : 
                             (T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24_running | T4_TIMES_zPQ_running) ? mem_t4_0_dout :  
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? add_A_mem_c_0_dout : 
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_A_mem_a_1_dout = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T1_SQUARE_AND_T9_SQUARE_running) ? add_B_mem_c_1_dout : 
                             (T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24_running | T4_TIMES_zPQ_running) ? mem_t4_1_dout :  
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? add_A_mem_c_1_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_A_mem_b_0_dout = real_mult_A_start & T4_SQUARE_AND_T5_SQUARE_running ? mem_t4_0_dout :
                             real_mult_A_start & T1_SQUARE_AND_T9_SQUARE_running ? add_B_mem_c_0_dout :
                             T1_TIMES_T4_AND_T0_TIMES_T5_running ? mem_t4_0_dout :
                             (T1_SQUARE_AND_T9_SQUARE_running | T4_SQUARE_AND_T5_SQUARE_running) ? mult_A_mem_b_0_dout_buf :
                             T4_TIMES_T5_AND_T0_TIMES_A24_running ? mem_t5_0_dout :
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mem_t8_0_dout :
                             T4_TIMES_zPQ_running ? mem_zPQ_0_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_A_mem_b_1_dout = real_mult_A_start & T4_SQUARE_AND_T5_SQUARE_running ? mem_t4_1_dout :
                             real_mult_A_start & T1_SQUARE_AND_T9_SQUARE_running ? add_B_mem_c_1_dout :
                             T1_TIMES_T4_AND_T0_TIMES_T5_running ? mem_t4_1_dout :
                             (T1_SQUARE_AND_T9_SQUARE_running | T4_SQUARE_AND_T5_SQUARE_running) ? mult_A_mem_b_1_dout_buf :
                             T4_TIMES_T5_AND_T0_TIMES_A24_running ? mem_t5_1_dout :
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mem_t8_1_dout :
                             T4_TIMES_zPQ_running ? mem_zPQ_1_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_A_mem_c_1_dout = mult_running ? p_plus_one_mem_dout : {SINGLE_MEM_WIDTH{1'b0}};

// t2 is read at:
// t6 = t2     T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running
// t0 = t2-t3  T2_MINUS_T3_AND_T6_MINUS_T7_running
// t10 = t2    T5_PLUS_T3_AND_T6_PLUS_T7_running
// t4 = t2     T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running
// t5 = t2     T2_COPY_TO_T5_running
assign mult_A_sub_mem_single_rd_en = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T2_COPY_TO_T5_running) ? 1'b1 : 
                                     (T5_PLUS_T3_AND_T6_PLUS_T7_running | T2_MINUS_T3_AND_T6_MINUS_T7_running) ? mem_t7_0_rd_en : 
                                     1'b0;
assign mult_A_sub_mem_single_rd_addr = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T2_COPY_TO_T5_running) ? counter : 
                                       (T5_PLUS_T3_AND_T6_PLUS_T7_running | T2_MINUS_T3_AND_T6_MINUS_T7_running) ? mem_t7_0_rd_addr : 
                                       {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mult_A_add_mem_single_rd_en = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T2_COPY_TO_T5_running) ? 1'b1 : 
                                     (T5_PLUS_T3_AND_T6_PLUS_T7_running | T2_MINUS_T3_AND_T6_MINUS_T7_running) ? mem_t7_1_rd_en : 
                                     1'b0;
assign mult_A_add_mem_single_rd_addr = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T2_COPY_TO_T5_running) ? counter : 
                                       (T5_PLUS_T3_AND_T6_PLUS_T7_running | T2_MINUS_T3_AND_T6_MINUS_T7_running) ? mem_t7_1_rd_addr : 
                                       {SINGLE_MEM_DEPTH_LOG{1'b0}};
  

// interface to multiplier B
assign mult_B_mem_a_0_dout = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_TIMES_T5_AND_T0_TIMES_A24_running) ? add_A_mem_c_0_dout :
                             T1_SQUARE_AND_T9_SQUARE_running ? mem_t9_0_dout :
                             T4_SQUARE_AND_T5_SQUARE_running ? mem_t5_0_dout :
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mem_xPQ_0_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_B_mem_a_1_dout = (T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_TIMES_T5_AND_T0_TIMES_A24_running) ? add_A_mem_c_1_dout :
                             T1_SQUARE_AND_T9_SQUARE_running ? mem_t9_1_dout :
                             T4_SQUARE_AND_T5_SQUARE_running ? mem_t5_1_dout :
                             T0_TIMES_T8_AND_XPQ_TIMES_T5_running ? mem_xPQ_1_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_B_mem_b_0_dout = real_mult_B_start & T4_SQUARE_AND_T5_SQUARE_running ? mem_t5_0_dout :
                             real_mult_B_start & T1_SQUARE_AND_T9_SQUARE_running ? mem_t9_0_dout :
                             (T1_TIMES_T4_AND_T0_TIMES_T5_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running) ? mem_t5_0_dout :
                             (T1_SQUARE_AND_T9_SQUARE_running | T4_SQUARE_AND_T5_SQUARE_running) ? mult_B_mem_b_0_dout_buf :
                             T4_TIMES_T5_AND_T0_TIMES_A24_running ? mem_A24_0_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_B_mem_b_1_dout = real_mult_B_start & T4_SQUARE_AND_T5_SQUARE_running ? mem_t5_1_dout :
                             real_mult_B_start & T1_SQUARE_AND_T9_SQUARE_running ? mem_t9_1_dout :
                             (T1_TIMES_T4_AND_T0_TIMES_T5_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running) ? mem_t5_1_dout :
                             (T1_SQUARE_AND_T9_SQUARE_running | T4_SQUARE_AND_T5_SQUARE_running) ? mult_B_mem_b_1_dout_buf :
                             T4_TIMES_T5_AND_T0_TIMES_A24_running ? mem_A24_1_dout :
                             {SINGLE_MEM_WIDTH{1'b0}};
assign mult_B_mem_c_1_dout = mult_A_mem_c_1_dout;
 
// t3 is read at:
// t7 = t3     T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running
// t0 = t2-t3  T2_MINUS_T3_AND_T6_MINUS_T7_running
// t0 = t5+t3  T5_PLUS_T3_AND_T6_PLUS_T7_running
// t5 = t3     T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running
assign mult_B_sub_mem_single_rd_en = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? 1'b1 :
                                     (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_0_rd_en : 
                                     1'b0;
assign mult_B_sub_mem_single_rd_addr = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? counter :
                                       (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_0_rd_addr : 
                                       {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mult_B_add_mem_single_rd_en = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? 1'b1 :
                                     (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_1_rd_en : 
                                     1'b0;
assign mult_B_add_mem_single_rd_addr = (T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? counter :
                                       (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_1_rd_addr : 
                                       {SINGLE_MEM_DEPTH_LOG{1'b0}};

// interface to constant memories 
assign add_running = XP_PLUS_ZP_AND_XP_MINUS_ZP_running | XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running | T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running;
assign mult_running = T1_TIMES_T4_AND_T0_TIMES_T5_running | T4_SQUARE_AND_T5_SQUARE_running | T4_TIMES_T5_AND_T0_TIMES_A24 | T1_SQUARE_AND_T9_SQUARE_running | T0_TIMES_T8_AND_XPQ_TIMES_T5_running;

assign p_plus_one_mem_rd_addr = mult_running ? mult_A_mem_c_1_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign px2_mem_rd_addr = add_running ? add_A_px2_mem_rd_addr : 
                         mult_running ? mult_A_px2_mem_rd_addr :
                         {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign px4_mem_rd_addr = add_running ? add_A_px4_mem_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};


assign mem_t6_0_wr_addr = T2_COPY_TO_T6_AND_T3_COPY_TO_T7 ? counter_buf : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t7_0_wr_addr = mem_t6_0_wr_addr;
assign mem_t8_0_wr_addr = T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? counter_buf : {SINGLE_MEM_DEPTH_LOG{1'b0}};
assign mem_t9_0_wr_addr = mem_t8_0_wr_addr;

// write signals for intermediate operands t4, t5, t6, t7, t8, t9, t10
always @(posedge clk or posedge rst) begin
  if (rst) begin
    counter <= {SINGLE_MEM_DEPTH_LOG{1'b0}};
    counter_buf <= {SINGLE_MEM_DEPTH_LOG{1'b0}};
    mem_t4_0_wr_en <= 1'b0;
    mem_t4_0_wr_addr <= {SINGLE_MEM_DEPTH_LOG{1'b0}}; 
    mem_t5_0_wr_en <= 1'b0;
    mem_t5_0_wr_addr <= {SINGLE_MEM_DEPTH_LOG{1'b0}};
    mem_t6_0_wr_en <= 1'b0; 
    mem_t7_0_wr_en <= 1'b0;
    mem_t8_0_wr_en <= 1'b0;
    mem_t9_0_wr_en <= 1'b0;
    mem_t10_0_wr_en <= 1'b0;
    mem_t10_0_wr_addr <= {SINGLE_MEM_DEPTH_LOG{1'b0}};
    last_copy_write_buf <= 1'b0;
    last_copy_write_buf_2 <= 1'b0;
    real_mult_A_start <= 1'b0;
    real_mult_B_start <= 1'b0;
  end
  else begin
    real_mult_A_start <= mult_A_start;
    real_mult_B_start <= mult_B_start;
    counter_buf <= counter;
    counter <= (start | last_copy_write | last_copy_write_buf | done) ? {SINGLE_MEM_DEPTH_LOG{1'b0}} : 
               (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running | T2_COPY_TO_T5_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running) ? counter + 1 :
               counter;
    mem_t4_0_wr_en <= (mem_t4_0_wr_addr == (SINGLE_MEM_DEPTH-1)) ? 1'b0 :
                      (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? 1'b1 :
                      (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_0_rd_en :
                      mem_t4_0_wr_en;
    mem_t4_0_wr_addr <= (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running) ? counter :
                        (T2_MINUS_T3_AND_T6_MINUS_T7_running | T5_PLUS_T3_AND_T6_PLUS_T7_running) ? mem_t7_0_rd_addr :
                        {SINGLE_MEM_DEPTH_LOG{1'b0}};
    mem_t5_0_wr_en <= (mem_t5_0_wr_addr == (SINGLE_MEM_DEPTH-1)) ? 1'b0 :
                      (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T2_COPY_TO_T5_running) ? 1'b1 :
                      T2_MINUS_T3_AND_T6_MINUS_T7_running ? mem_t7_0_rd_en :
                      mem_t5_0_wr_en;
    mem_t5_0_wr_addr <= (T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running | T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running | T2_COPY_TO_T5_running) ? counter :
                        T2_MINUS_T3_AND_T6_MINUS_T7_running ? mem_t7_0_rd_addr :
                        {SINGLE_MEM_DEPTH_LOG{1'b0}}; 
    mem_t6_0_wr_en <= (mem_t6_0_wr_addr == (SINGLE_MEM_DEPTH-1)) ? 1'b0 :
                      T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? 1'b1 : 
                      1'b0;
    mem_t7_0_wr_en <= (mem_t7_0_wr_addr == (SINGLE_MEM_DEPTH-1)) ? 1'b0 :
                      T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? 1'b1 : 
                      1'b0;
    mem_t8_0_wr_en <= (mem_t8_0_wr_addr == (SINGLE_MEM_DEPTH-1)) ? 1'b0 :
                      T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? 1'b1 :
                      1'b0;
    last_copy_write_buf <= last_copy_write;
    last_copy_write_buf_2 <= last_copy_write_buf;

    mem_t9_0_wr_en <= (mem_t9_0_wr_addr == (SINGLE_MEM_DEPTH-1)) ? 1'b0 :
                      T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running ? 1'b1 :
                      1'b0;
    mem_t10_0_wr_en <= T5_PLUS_T3_AND_T6_PLUS_T7_running & mem_t7_0_rd_en;
    mem_t10_0_wr_addr <= T5_PLUS_T3_AND_T6_PLUS_T7_running ? mem_t7_0_rd_addr : {SINGLE_MEM_DEPTH_LOG{1'b0}};

  end
end

// finite state machine transitions
always @(posedge clk or posedge rst) begin
  if (rst) begin
    add_A_start <= 1'b0;
    add_B_start <= 1'b0;
    mult_A_start <= 1'b0;
    mult_B_start <= 1'b0;
    busy <= 1'b0;
    done <= 1'b0;
    state <= IDLE;
    XP_PLUS_ZP_AND_XP_MINUS_ZP_running <= 1'b0;
    T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running <= 1'b0;
    XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running <= 1'b0;
    T1_TIMES_T4_AND_T0_TIMES_T5_running <= 1'b0;
    T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running <= 1'b0;
    T4_SQUARE_AND_T5_SQUARE_running <= 1'b0;
    T2_MINUS_T3_AND_T6_MINUS_T7_running <= 1'b0;
    T4_TIMES_T5_AND_T0_TIMES_A24_running <= 1'b0;
    T5_PLUS_T3_AND_T6_PLUS_T7_running <= 1'b0;
    T1_SQUARE_AND_T9_SQUARE_running <= 1'b0;
    T0_TIMES_T8_AND_XPQ_TIMES_T5_running <= 1'b0;
    T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running <= 1'b0;
    T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running <= 1'b0;
    T2_COPY_TO_T5_running <= 1'b0;
    T4_TIMES_zPQ_running <= 1'b0;
  end
  else begin 
    add_A_start <= 1'b0;
    add_B_start <= 1'b0;
    mult_A_start <= 1'b0;
    mult_B_start <= 1'b0; 
    done <= 1'b0; 
    case (state) 
      IDLE: 
        if (start) begin
          state <= XP_PLUS_ZP_AND_XP_MINUS_ZP;
          XP_PLUS_ZP_AND_XP_MINUS_ZP_running <= 1'b1;
          add_A_start <= 1'b1;
          add_B_start <= 1'b1;
          busy <= 1'b1;
        end
        else begin
          state <= IDLE;
        end

      XP_PLUS_ZP_AND_XP_MINUS_ZP: 
        if (add_A_done) begin
          state <= T0_COPY_TO_T4_AND_T1_COPY_TO_T5;
          XP_PLUS_ZP_AND_XP_MINUS_ZP_running <= 1'b0;
          T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running <= 1'b1; 
        end
        else begin
          state <= XP_PLUS_ZP_AND_XP_MINUS_ZP;
        end

      T0_COPY_TO_T4_AND_T1_COPY_TO_T5:
        if (last_copy_write_buf) begin
          state <= XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ;
          T0_COPY_TO_T4_AND_T1_COPY_TO_T5_running <= 1'b0;
          XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running <= 1'b1;
          add_A_start <= 1'b1;
          add_B_start <= 1'b1;
        end
        else begin
          state <= T0_COPY_TO_T4_AND_T1_COPY_TO_T5;
        end

      XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ: 
        if (add_A_done) begin
          state <= T1_TIMES_T4_AND_T0_TIMES_T5;
          XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ_running <= 1'b0;
          T1_TIMES_T4_AND_T0_TIMES_T5_running <= 1'b1; 
          mult_A_start <= 1'b1;
          mult_B_start <= 1'b1;
        end
        else begin
          state <= XQ_PLUS_ZQ_AND_XQ_MINUS_ZQ;
        end

      T1_TIMES_T4_AND_T0_TIMES_T5: 
        if (mult_A_done) begin
          state <= T2_COPY_TO_T6_AND_T3_COPY_TO_T7;
          T1_TIMES_T4_AND_T0_TIMES_T5_running <= 1'b0;
          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running <= 1'b1; 
        end
        else begin
          state <= T1_TIMES_T4_AND_T0_TIMES_T5;
        end

      T2_COPY_TO_T6_AND_T3_COPY_TO_T7:
        if (last_copy_write_buf) begin
          state <= T4_SQUARE_AND_T5_SQUARE;
          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running <= 1'b0;
          T4_SQUARE_AND_T5_SQUARE_running <= 1'b1;
          mult_A_start <= 1'b1;
          mult_B_start <= 1'b1;
        end
        else begin
          state <= T2_COPY_TO_T6_AND_T3_COPY_TO_T7;
        end

      T4_SQUARE_AND_T5_SQUARE: 
        if (mult_A_done) begin
          state <= T2_MINUS_T3_AND_T6_MINUS_T7;
          T4_SQUARE_AND_T5_SQUARE_running <= 1'b0;
          T2_MINUS_T3_AND_T6_MINUS_T7_running <= 1'b1;
          add_A_start <= 1'b1;
          add_B_start <= 1'b1;
        end
        else begin
          state <= T4_SQUARE_AND_T5_SQUARE;
        end

      T2_MINUS_T3_AND_T6_MINUS_T7:  
        if (add_A_done) begin
          state <= T0_COPY_TO_T8_AND_T1_COPY_TO_T9;
          T2_MINUS_T3_AND_T6_MINUS_T7_running <= 1'b0;
          T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running <= 1'b1; 
        end
        else begin
          state <= T2_MINUS_T3_AND_T6_MINUS_T7;
        end

      T0_COPY_TO_T8_AND_T1_COPY_TO_T9:
        if (last_copy_write_buf) begin
          state <= T4_TIMES_T5_AND_T0_TIMES_A24;
          T0_COPY_TO_T8_AND_T1_COPY_TO_T9_running <= 1'b0;
          T4_TIMES_T5_AND_T0_TIMES_A24_running <= 1'b1;
          mult_A_start <= 1'b1;
          mult_B_start <= 1'b1;
        end
        else begin
          state <= T0_COPY_TO_T8_AND_T1_COPY_TO_T9;
        end
      
      T4_TIMES_T5_AND_T0_TIMES_A24: 
        if (mult_A_done) begin
          state <= T5_PLUS_T3_AND_T6_PLUS_T7;
          T4_TIMES_T5_AND_T0_TIMES_A24_running <= 1'b0;
          T5_PLUS_T3_AND_T6_PLUS_T7_running <= 1'b1;
          add_A_start <= 1'b1;
          add_B_start <= 1'b1;  
        end
        else begin
          state <= T4_TIMES_T5_AND_T0_TIMES_A24;
        end

      T5_PLUS_T3_AND_T6_PLUS_T7:
        if (add_A_done) begin
          state <= T1_SQUARE_AND_T9_SQUARE;
          T5_PLUS_T3_AND_T6_PLUS_T7_running <= 1'b0;
          T1_SQUARE_AND_T9_SQUARE_running <= 1'b1;
          mult_A_start <= 1'b1;
          mult_B_start <= 1'b1;       
        end
        else begin
          state <= T5_PLUS_T3_AND_T6_PLUS_T7;
        end

      T1_SQUARE_AND_T9_SQUARE:
        if (mult_A_done) begin
          state <= T2_COPY_TO_T4_AND_T3_COPY_TO_T5;
          T1_SQUARE_AND_T9_SQUARE_running <= 1'b0;
          T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running <= 1'b1;
        end
        else begin
          state <= T1_SQUARE_AND_T9_SQUARE;
        end

      T2_COPY_TO_T4_AND_T3_COPY_TO_T5:
        if (last_copy_write_buf) begin
          T2_COPY_TO_T4_AND_T3_COPY_TO_T5_running <= 1'b0;
        end
        else if (last_copy_write_buf_2) begin
          state <= T0_TIMES_T8_AND_XPQ_TIMES_T5;
          T0_TIMES_T8_AND_XPQ_TIMES_T5_running <= 1'b1;
          mult_A_start <= 1'b1;
          mult_B_start <= 1'b1;         
        end
        else begin
          state <= T2_COPY_TO_T4_AND_T3_COPY_TO_T5;
        end

      T0_TIMES_T8_AND_XPQ_TIMES_T5:
        if (mult_A_done) begin
          state <= T2_COPY_TO_T5;
          T0_TIMES_T8_AND_XPQ_TIMES_T5_running <= 1'b0; 
          T2_COPY_TO_T5_running <= 1'b1;
        end
        else begin
          state <= T0_TIMES_T8_AND_XPQ_TIMES_T5;
        end

      T2_COPY_TO_T5:
        if (last_copy_write_buf) begin
          T2_COPY_TO_T5_running <= 1'b0;
        end 
        else if (last_copy_write_buf_2) begin
          state <= T4_TIMES_zPQ;
          T4_TIMES_zPQ_running <= 1'b1;
          mult_A_start <= 1'b1;
        end
        else begin
          state <= T2_COPY_TO_T5;
        end

      T4_TIMES_zPQ:
        if (mult_A_done) begin
          state <= IDLE;
          T4_TIMES_zPQ_running <= 1'b0;
          busy <= 1'b0;
          done <= 1'b1;
        end
        else begin
          state <= T4_TIMES_zPQ;
        end

      default: 
        begin
          state <= state;
        end
    endcase
  end 
end

// define states here 

endmodule