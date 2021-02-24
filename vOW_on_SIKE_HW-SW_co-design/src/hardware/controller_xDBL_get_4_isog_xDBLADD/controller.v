//--------------------------------------------------------------------
//--------------------------------------------------------------------

module controller
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
  input wire [7:0] function_encoded,
  input wire start,
  output wire busy,
  output wire done,

//--------------------------------------------------------------------
// input memory of xDBL_FSM
//--------------------------------------------------------------------
 // interface with input memory X
  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_X_0_dout,
  output wire xDBL_mem_X_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_X_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_X_1_dout,
  output wire xDBL_mem_X_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_X_1_rd_addr,

  // interface with input memory Z
  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_Z_0_dout,
  output wire xDBL_mem_Z_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_Z_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_Z_1_dout,
  output wire xDBL_mem_Z_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_Z_1_rd_addr,

  // interface with input memory A24
  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_A24_0_dout,
  output wire xDBL_mem_A24_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_A24_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_A24_1_dout,
  output wire xDBL_mem_A24_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_A24_1_rd_addr,

  // interface with input memory C24
  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_C24_0_dout,
  output wire xDBL_mem_C24_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_C24_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_C24_1_dout,
  output wire xDBL_mem_C24_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_C24_1_rd_addr,

//--------------------------------------------------------------------
// input memory of get_4_isog_FSM
//--------------------------------------------------------------------
  // interface with input memory X
  input wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_X4_0_dout,
  output wire get_4_isog_mem_X4_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_X4_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_X4_1_dout,
  output wire get_4_isog_mem_X4_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_X4_1_rd_addr,

  // interface with input memory Z
  input wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_Z4_0_dout,
  output wire get_4_isog_mem_Z4_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_Z4_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_Z4_1_dout,
  output wire get_4_isog_mem_Z4_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_Z4_1_rd_addr, 

//--------------------------------------------------------------------
// input memory of xDBLADD_FSM
//--------------------------------------------------------------------
   // interface with input memory XP
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XP_0_dout,
  output wire xDBLADD_mem_XP_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XP_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XP_1_dout,
  output wire xDBLADD_mem_XP_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XP_1_rd_addr,

  // interface with input memory XQ
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XQ_0_dout,
  output wire xDBLADD_mem_XQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_XQ_1_dout,
  output wire xDBLADD_mem_XQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_XQ_1_rd_addr,

    // interface with input memory ZP
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZP_0_dout,
  output wire xDBLADD_mem_ZP_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZP_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZP_1_dout,
  output wire xDBLADD_mem_ZP_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZP_1_rd_addr,

  // interface with input memory ZQ
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZQ_0_dout,
  output wire xDBLADD_mem_ZQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_ZQ_1_dout,
  output wire xDBLADD_mem_ZQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_ZQ_1_rd_addr,

  // interface with input memory A24
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_A24_0_dout,
  output wire xDBLADD_mem_A24_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_A24_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_A24_1_dout,
  output wire xDBLADD_mem_A24_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_A24_1_rd_addr,

  // interface with input memory xPQ
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_xPQ_0_dout,
  output wire xDBLADD_mem_xPQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_xPQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_xPQ_1_dout,
  output wire xDBLADD_mem_xPQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_xPQ_1_rd_addr,

  // interface with input memory zPQ
  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_zPQ_0_dout,
  output wire xDBLADD_mem_zPQ_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_zPQ_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_zPQ_1_dout,
  output wire xDBLADD_mem_zPQ_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_zPQ_1_rd_addr,
 
//--------------------------------------------------------------------
// output memories
//--------------------------------------------------------------------
  // interface with output memory t0 
  input wire mem_t0_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t0_0_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t0_0_dout,
 
  input wire mem_t0_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t0_1_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t0_1_dout,

  // interface with output memory t1 
  input wire mem_t1_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t1_0_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t1_0_dout,
 
  input wire mem_t1_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t1_1_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t1_1_dout,

  // interface with output memory t2 
  input wire mem_t2_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t2_0_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t2_0_dout,
 
  input wire mem_t2_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t2_1_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t2_1_dout,

  // interface with output memory t3 
  input wire mem_t3_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_0_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t3_0_dout,
 
  input wire mem_t3_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_1_rd_addr,
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t3_1_dout,

//--------------------------------------------------------------------
  // interface with output memory t4 
  input wire out_mem_t4_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t4_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_dout,
 
  input wire out_mem_t4_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t4_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_dout,

  // interface with output memory t5 
  input wire out_mem_t5_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t5_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_dout,
 
  input wire out_mem_t5_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t5_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_dout,

   // interface with output memory t10 
  input wire out_mem_t10_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_dout,
 
  input wire out_mem_t10_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t10_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_dout   
);



//----------------------------------------------------------------------------
// specific interface with xDBL_FSM 
//----------------------------------------------------------------------------
wire xDBL_start;
wire xDBL_busy;
wire xDBL_done; 

// interface with intermediate operands t4
wire xDBL_mem_t4_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t4_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_t4_0_din;
wire xDBL_mem_t4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t4_0_rd_addr; 

wire xDBL_mem_t4_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t4_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_t4_1_din;
wire xDBL_mem_t4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t4_1_rd_addr; 

// interface with intermediate operands t5 
wire xDBL_mem_t5_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t5_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_t5_0_din;
wire xDBL_mem_t5_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t5_0_rd_addr; 

wire xDBL_mem_t5_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t5_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mem_t5_1_din;
wire xDBL_mem_t5_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mem_t5_1_rd_addr; 

// interface to adder A
wire xDBL_add_A_start; 
wire [2:0] xDBL_add_A_cmd;
wire xDBL_add_A_extension_field_op; 
wire [RADIX-1:0] xDBL_add_A_mem_a_0_dout; 
wire [RADIX-1:0] xDBL_add_A_mem_a_1_dout; 
wire [RADIX-1:0] xDBL_add_A_mem_b_0_dout; 
wire [RADIX-1:0] xDBL_add_A_mem_b_1_dout; 
wire xDBL_add_A_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_add_A_mem_c_0_rd_addr;  
wire xDBL_add_A_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_add_A_mem_c_1_rd_addr;  

// interface to adder B
wire xDBL_add_B_start; 
wire [2:0] xDBL_add_B_cmd;
wire xDBL_add_B_extension_field_op; 
wire [RADIX-1:0] xDBL_add_B_mem_a_0_dout; 
wire [RADIX-1:0] xDBL_add_B_mem_a_1_dout; 
wire [RADIX-1:0] xDBL_add_B_mem_b_0_dout; 
wire [RADIX-1:0] xDBL_add_B_mem_b_1_dout; 
wire xDBL_add_B_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_add_B_mem_c_0_rd_addr;  
wire xDBL_add_B_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_add_B_mem_c_1_rd_addr;  

// interface to multiplier A
wire xDBL_mult_A_start;  
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_A_mem_a_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_A_mem_a_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_A_mem_b_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_A_mem_b_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_A_mem_c_1_dout; 
wire xDBL_mult_A_sub_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mult_A_sub_mem_single_rd_addr; 
wire xDBL_mult_A_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mult_A_add_mem_single_rd_addr; 
 
// interface to multiplier B
wire xDBL_mult_B_start;  
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_B_mem_a_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_B_mem_a_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_B_mem_b_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_B_mem_b_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBL_mult_B_mem_c_1_dout; 
wire xDBL_mult_B_sub_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mult_B_sub_mem_single_rd_addr;  
wire xDBL_mult_B_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_mult_B_add_mem_single_rd_addr; 

// common signals
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_p_plus_one_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_px2_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBL_px4_mem_rd_addr;

wire xDBL_mult_A_used_for_squaring_running;
wire xDBL_mult_B_used_for_squaring_running;

//----------------------------------------------------------------------------
// specific interface with get_4_isog_FSM 
//----------------------------------------------------------------------------
wire get_4_isog_start;
wire get_4_isog_busy;
wire get_4_isog_done; 

// interface with intermediate operands t4
wire get_4_isog_mem_t4_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_t4_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_t4_0_din;  

wire get_4_isog_mem_t4_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_t4_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_t4_1_din; 

// interface with intermediate operands t5
wire get_4_isog_mem_t5_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_t5_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_t5_0_din;  

wire get_4_isog_mem_t5_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mem_t5_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mem_t5_1_din;

// interface to adder A
wire get_4_isog_add_A_start; 
wire [2:0] get_4_isog_add_A_cmd;
wire get_4_isog_add_A_extension_field_op; 
wire [RADIX-1:0] get_4_isog_add_A_mem_a_0_dout; 
wire [RADIX-1:0] get_4_isog_add_A_mem_a_1_dout; 
wire [RADIX-1:0] get_4_isog_add_A_mem_b_0_dout; 
wire [RADIX-1:0] get_4_isog_add_A_mem_b_1_dout; 
wire get_4_isog_add_A_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_add_A_mem_c_0_rd_addr;  
wire get_4_isog_add_A_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_add_A_mem_c_1_rd_addr;  
 
// interface to adder B
wire get_4_isog_add_B_start;  
wire [2:0] get_4_isog_add_B_cmd;
wire get_4_isog_add_B_extension_field_op; 
wire [RADIX-1:0] get_4_isog_add_B_mem_a_0_dout; 
wire [RADIX-1:0] get_4_isog_add_B_mem_a_1_dout;  
wire [RADIX-1:0] get_4_isog_add_B_mem_b_0_dout;  
wire [RADIX-1:0] get_4_isog_add_B_mem_b_1_dout; 
wire get_4_isog_add_B_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_add_B_mem_c_0_rd_addr;  
wire get_4_isog_add_B_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_add_B_mem_c_1_rd_addr; 
 
// interface to multiplier A
wire get_4_isog_mult_A_start;  
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_A_mem_a_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_A_mem_a_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_A_mem_b_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_A_mem_b_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_A_mem_c_1_dout; 
wire get_4_isog_mult_A_sub_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mult_A_sub_mem_single_rd_addr;  
wire get_4_isog_mult_A_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mult_A_add_mem_single_rd_addr; 
 
// interface to multiplier B
wire get_4_isog_mult_B_start;  
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_B_mem_a_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_B_mem_a_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_B_mem_b_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_B_mem_b_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] get_4_isog_mult_B_mem_c_1_dout;  
wire get_4_isog_mult_B_sub_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mult_B_sub_mem_single_rd_addr;  
wire get_4_isog_mult_B_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_mult_B_add_mem_single_rd_addr; 

// common signals
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_p_plus_one_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_px2_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] get_4_isog_px4_mem_rd_addr;

wire get_4_isog_mult_A_used_for_squaring_running;
wire get_4_isog_mult_B_used_for_squaring_running;

//----------------------------------------------------------------------------
// specific interface with xDBLADD_FSM 
//----------------------------------------------------------------------------
wire xDBLADD_start;
wire xDBLADD_busy;
wire xDBLADD_done; 

// interface with intermediate operands t4
wire xDBLADD_mem_t4_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t4_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t4_0_din;
wire xDBLADD_mem_t4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t4_0_rd_addr; 

wire xDBLADD_mem_t4_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t4_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t4_1_din;
wire xDBLADD_mem_t4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t4_1_rd_addr; 

// interface with intermediate operands t5 
wire xDBLADD_mem_t5_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t5_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t5_0_din;
wire xDBLADD_mem_t5_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t5_0_rd_addr; 

wire xDBLADD_mem_t5_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t5_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t5_1_din;
wire xDBLADD_mem_t5_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t5_1_rd_addr; 

// interface with intermediate operands t6
wire xDBLADD_mem_t6_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t6_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t6_0_din;
wire xDBLADD_mem_t6_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t6_0_rd_addr; 

wire xDBLADD_mem_t6_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t6_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t6_1_din;
wire xDBLADD_mem_t6_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t6_1_rd_addr; 

// interface with intermediate operands t7 
wire xDBLADD_mem_t7_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t7_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t7_0_din;
wire xDBLADD_mem_t7_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t7_0_rd_addr; 

wire xDBLADD_mem_t7_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t7_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t7_1_din;
wire xDBLADD_mem_t7_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t7_1_rd_addr;

// interface with intermediate operands t8 
wire xDBLADD_mem_t8_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t8_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t8_0_din;
wire xDBLADD_mem_t8_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t8_0_rd_addr; 

wire xDBLADD_mem_t8_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t8_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t8_1_din;
wire xDBLADD_mem_t8_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t8_1_rd_addr; 

// interface with intermediate operands t9
wire xDBLADD_mem_t9_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t9_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t9_0_din;
wire xDBLADD_mem_t9_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t9_0_rd_addr; 

wire xDBLADD_mem_t9_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t9_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t9_1_din;
wire xDBLADD_mem_t9_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t9_1_rd_addr; 

// interface with intermediate operands t10 
  // there is no xDBLADD_mem_t10_rd signals, no need
wire xDBLADD_mem_t10_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t10_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t10_0_din; 

wire xDBLADD_mem_t10_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mem_t10_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mem_t10_1_din; 


// interface to adder A
wire xDBLADD_add_A_start; 
wire [2:0] xDBLADD_add_A_cmd;
wire xDBLADD_add_A_extension_field_op; 
wire [RADIX-1:0] xDBLADD_add_A_mem_a_0_dout; 
wire [RADIX-1:0] xDBLADD_add_A_mem_a_1_dout; 
wire [RADIX-1:0] xDBLADD_add_A_mem_b_0_dout; 
wire [RADIX-1:0] xDBLADD_add_A_mem_b_1_dout; 
wire xDBLADD_add_A_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_add_A_mem_c_0_rd_addr;  
wire xDBLADD_add_A_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_add_A_mem_c_1_rd_addr;  

// interface to adder B
wire xDBLADD_add_B_start; 
wire [2:0] xDBLADD_add_B_cmd;
wire xDBLADD_add_B_extension_field_op; 
wire [RADIX-1:0] xDBLADD_add_B_mem_a_0_dout; 
wire [RADIX-1:0] xDBLADD_add_B_mem_a_1_dout; 
wire [RADIX-1:0] xDBLADD_add_B_mem_b_0_dout; 
wire [RADIX-1:0] xDBLADD_add_B_mem_b_1_dout; 
wire xDBLADD_add_B_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_add_B_mem_c_0_rd_addr;  
wire xDBLADD_add_B_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_add_B_mem_c_1_rd_addr;  

// interface to multiplier A
wire xDBLADD_mult_A_start;  
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_A_mem_a_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_A_mem_a_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_A_mem_b_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_A_mem_b_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_A_mem_c_1_dout; 
wire xDBLADD_mult_A_sub_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mult_A_sub_mem_single_rd_addr; 
wire xDBLADD_mult_A_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mult_A_add_mem_single_rd_addr; 
 
// interface to multiplier B
wire xDBLADD_mult_B_start;  
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_B_mem_a_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_B_mem_a_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_B_mem_b_0_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_B_mem_b_1_dout; 
wire [SINGLE_MEM_WIDTH-1:0] xDBLADD_mult_B_mem_c_1_dout; 
wire xDBLADD_mult_B_sub_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mult_B_sub_mem_single_rd_addr;  
wire xDBLADD_mult_B_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_mult_B_add_mem_single_rd_addr; 

// common signals
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_p_plus_one_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_px2_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLADD_px4_mem_rd_addr;

wire xDBLADD_mult_A_used_for_squaring_running;
wire xDBLADD_mult_B_used_for_squaring_running;


//----------------------------------------------------------------------------
// common interface to constants memory
//----------------------------------------------------------------------------
wire [SINGLE_MEM_DEPTH_LOG-1:0] p_plus_one_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] px2_mem_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] px4_mem_rd_addr;

wire [SINGLE_MEM_WIDTH-1:0] p_plus_one_mem_dout;
wire [SINGLE_MEM_WIDTH-1:0] px2_mem_dout;
wire [SINGLE_MEM_WIDTH-1:0] px4_mem_dout;

assign p_plus_one_mem_rd_addr = xDBL_busy ? xDBL_p_plus_one_mem_rd_addr :
                                get_4_isog_busy ? get_4_isog_p_plus_one_mem_rd_addr :
                                xDBLADD_busy ? xDBLADD_p_plus_one_mem_rd_addr :
                                0;

assign px2_mem_rd_addr = xDBL_busy ? xDBL_px2_mem_rd_addr :
                         get_4_isog_busy ? get_4_isog_px2_mem_rd_addr :
                         xDBLADD_busy ? xDBLADD_px2_mem_rd_addr :
                         0;

assign px4_mem_rd_addr = xDBL_busy ? xDBL_px4_mem_rd_addr :
                         get_4_isog_busy ? get_4_isog_px4_mem_rd_addr :
                         xDBLADD_busy ? xDBLADD_px4_mem_rd_addr :
                         0;

//----------------------------------------------------------------------------
// interface to adder A
//----------------------------------------------------------------------------
wire add_A_start;
wire add_A_busy;
wire add_A_done;
wire [2:0] add_A_cmd;
wire add_A_extension_field_op;
wire add_A_mem_a_0_rd_en; 
wire add_A_mem_a_1_rd_en;
wire add_A_mem_b_0_rd_en;
wire add_A_mem_b_1_rd_en; 
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_a_0_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_a_1_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_b_0_rd_addr; 
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_b_1_rd_addr;
wire [RADIX-1:0] add_A_mem_a_0_dout;
wire [RADIX-1:0] add_A_mem_a_1_dout;
wire [RADIX-1:0] add_A_mem_b_0_dout;
wire [RADIX-1:0] add_A_mem_b_1_dout;
wire add_A_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_c_0_rd_addr;
wire [RADIX-1:0] add_A_mem_c_0_dout; 
wire add_A_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_mem_c_1_rd_addr; 
wire [RADIX-1:0] add_A_mem_c_1_dout;
wire add_A_px2_mem_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_px2_mem_rd_addr;
wire add_A_px4_mem_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_A_px4_mem_rd_addr;

assign add_A_start = xDBL_add_A_start | get_4_isog_add_A_start | xDBLADD_add_A_start;
assign add_A_cmd = xDBL_busy ? xDBL_add_A_cmd :
                   get_4_isog_busy ? get_4_isog_add_A_cmd :
                   xDBLADD_busy ? xDBLADD_add_A_cmd :
                   3'd0;
assign add_A_extension_field_op = 1'b1;
assign add_A_mem_a_0_dout = xDBL_busy ? xDBL_add_A_mem_a_0_dout :
                            get_4_isog_busy ? get_4_isog_add_A_mem_a_0_dout :
                            xDBLADD_busy ? xDBLADD_add_A_mem_a_0_dout :
                            0;
assign add_A_mem_a_1_dout = xDBL_busy ? xDBL_add_A_mem_a_1_dout :
                            get_4_isog_busy ? get_4_isog_add_A_mem_a_1_dout :
                            xDBLADD_busy ? xDBLADD_add_A_mem_a_1_dout :
                            0;
assign add_A_mem_b_0_dout = xDBL_busy ? xDBL_add_A_mem_b_0_dout :
                            get_4_isog_busy ? get_4_isog_add_A_mem_b_0_dout :
                            xDBLADD_busy ? xDBLADD_add_A_mem_b_0_dout :
                            0;
assign add_A_mem_b_1_dout = xDBL_busy ? xDBL_add_A_mem_b_1_dout :
                            get_4_isog_busy ? get_4_isog_add_A_mem_b_1_dout :
                            xDBLADD_busy ? xDBLADD_add_A_mem_b_1_dout :
                            0;
assign add_A_mem_c_0_rd_en = mem_t0_0_rd_en | xDBL_add_A_mem_c_0_rd_en | get_4_isog_add_A_mem_c_0_rd_en | xDBLADD_add_A_mem_c_0_rd_en;
assign add_A_mem_c_0_rd_addr = mem_t0_0_rd_en ? mem_t0_0_rd_addr :
                               xDBL_add_A_mem_c_0_rd_en ? xDBL_add_A_mem_c_0_rd_addr :
                               get_4_isog_add_A_mem_c_0_rd_en ? get_4_isog_add_A_mem_c_0_rd_addr :
                               xDBLADD_add_A_mem_c_0_rd_en ? xDBLADD_add_A_mem_c_0_rd_addr :
                               0;
assign add_A_mem_c_1_rd_en = mem_t0_1_rd_en | xDBL_add_A_mem_c_1_rd_en | get_4_isog_add_A_mem_c_1_rd_en | xDBLADD_add_A_mem_c_1_rd_en;
assign add_A_mem_c_1_rd_addr = mem_t0_1_rd_en ? mem_t0_1_rd_addr :
                               xDBL_add_A_mem_c_1_rd_en ? xDBL_add_A_mem_c_1_rd_addr :
                               get_4_isog_add_A_mem_c_1_rd_en ? get_4_isog_add_A_mem_c_1_rd_addr :
                               xDBLADD_add_A_mem_c_1_rd_en ? xDBLADD_add_A_mem_c_1_rd_addr :
                               0;
//----------------------------------------------------------------------------
// interface to adder B
//----------------------------------------------------------------------------
wire add_B_start;
wire add_B_busy;
wire add_B_done;
wire [2:0] add_B_cmd;
wire add_B_extension_field_op;
wire add_B_mem_a_0_rd_en;
wire add_B_mem_a_1_rd_en; 
wire add_B_mem_b_0_rd_en;
wire add_B_mem_b_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_a_0_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_a_1_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_b_0_rd_addr; 
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_b_1_rd_addr;
wire [RADIX-1:0] add_B_mem_a_0_dout;
wire [RADIX-1:0] add_B_mem_a_1_dout;
wire [RADIX-1:0] add_B_mem_b_0_dout;
wire [RADIX-1:0] add_B_mem_b_1_dout;
wire add_B_mem_c_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_c_0_rd_addr; 
wire [RADIX-1:0] add_B_mem_c_0_dout; 
wire add_B_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_mem_c_1_rd_addr;
wire [RADIX-1:0] add_B_mem_c_1_dout;
wire add_B_px2_mem_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_px2_mem_rd_addr;
wire add_B_px4_mem_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] add_B_px4_mem_rd_addr;

assign add_B_start = xDBL_add_B_start | get_4_isog_add_B_start | xDBLADD_add_B_start;
assign add_B_cmd = xDBL_busy ? xDBL_add_B_cmd :
                   get_4_isog_busy ? get_4_isog_add_B_cmd :
                   xDBLADD_busy ? xDBLADD_add_B_cmd :
                   3'd0;
assign add_B_extension_field_op = 1'b1;
assign add_B_mem_a_0_dout = xDBL_busy ? xDBL_add_B_mem_a_0_dout :
                            get_4_isog_busy ? get_4_isog_add_B_mem_a_0_dout :
                            xDBLADD_busy ? xDBLADD_add_B_mem_a_0_dout :
                            0;
assign add_B_mem_a_1_dout = xDBL_busy ? xDBL_add_B_mem_a_1_dout :
                            get_4_isog_busy ? get_4_isog_add_B_mem_a_1_dout :
                            xDBLADD_busy ? xDBLADD_add_B_mem_a_1_dout :
                            0;
assign add_B_mem_b_0_dout = xDBL_busy ? xDBL_add_B_mem_b_0_dout :
                            get_4_isog_busy ? get_4_isog_add_B_mem_b_0_dout :
                            xDBLADD_busy ? xDBLADD_add_B_mem_b_0_dout :
                            0;
assign add_B_mem_b_1_dout = xDBL_busy ? xDBL_add_B_mem_b_1_dout :
                            get_4_isog_busy ? get_4_isog_add_B_mem_b_1_dout :
                            xDBLADD_busy ? xDBLADD_add_B_mem_b_1_dout :
                            0;
assign add_B_mem_c_0_rd_en = mem_t1_0_rd_en | xDBL_add_B_mem_c_0_rd_en | get_4_isog_add_B_mem_c_0_rd_en | xDBLADD_add_B_mem_c_0_rd_en;
assign add_B_mem_c_0_rd_addr = mem_t1_0_rd_en ? mem_t1_0_rd_addr :
                               xDBL_add_B_mem_c_0_rd_en ? xDBL_add_B_mem_c_0_rd_addr :
                               get_4_isog_add_B_mem_c_0_rd_en ? get_4_isog_add_B_mem_c_0_rd_addr :
                               xDBLADD_add_B_mem_c_0_rd_en ? xDBLADD_add_B_mem_c_0_rd_addr :
                               0;
assign add_B_mem_c_1_rd_en = mem_t1_1_rd_en | xDBL_add_B_mem_c_1_rd_en | get_4_isog_add_B_mem_c_1_rd_en | xDBLADD_add_B_mem_c_1_rd_en;
assign add_B_mem_c_1_rd_addr = mem_t1_1_rd_en ? mem_t1_1_rd_addr :
                               xDBL_add_B_mem_c_1_rd_en ? xDBL_add_B_mem_c_1_rd_addr :
                               get_4_isog_add_B_mem_c_1_rd_en ? get_4_isog_add_B_mem_c_1_rd_addr :
                               xDBLADD_add_B_mem_c_1_rd_en ? xDBLADD_add_B_mem_c_1_rd_addr :
                               0;

//----------------------------------------------------------------------------
// interface to multiplier A
//----------------------------------------------------------------------------
wire mult_A_start;
wire mult_A_busy;
wire mult_A_done;
wire mult_A_mem_a_0_rd_en;
wire mult_A_mem_a_1_rd_en;
wire mult_A_mem_b_0_rd_en;
wire mult_A_mem_b_1_rd_en;
wire mult_A_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_a_0_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_a_1_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_b_0_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_b_1_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_mem_c_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_a_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_a_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_A_mem_c_1_dout;
wire mult_A_sub_mult_mem_res_rd_en;
wire [DOUBLE_MEM_DEPTH_LOG-1:0] mult_A_sub_mult_mem_res_rd_addr; 
wire [DOUBLE_MEM_WIDTH-1:0] mult_A_sub_mult_mem_res_dout; 
wire mult_A_add_mult_mem_res_rd_en;
wire [DOUBLE_MEM_DEPTH_LOG-1:0] mult_A_add_mult_mem_res_rd_addr; 
wire [DOUBLE_MEM_WIDTH-1:0] mult_A_add_mult_mem_res_dout;
wire mult_A_px2_mem_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_px2_mem_rd_addr;

assign mult_A_start = xDBL_mult_A_start | get_4_isog_mult_A_start | xDBLADD_mult_A_start;
assign mult_A_mem_a_0_dout = xDBL_busy ? xDBL_mult_A_mem_a_0_dout :
                             get_4_isog_busy ? get_4_isog_mult_A_mem_a_0_dout :
                             xDBLADD_busy ? xDBLADD_mult_A_mem_a_0_dout :
                             0;
assign mult_A_mem_a_1_dout = xDBL_busy ? xDBL_mult_A_mem_a_1_dout :
                             get_4_isog_busy ? get_4_isog_mult_A_mem_a_1_dout :
                             xDBLADD_busy ? xDBLADD_mult_A_mem_a_1_dout :
                             0;                             
assign mult_A_mem_b_0_dout = xDBL_busy ? xDBL_mult_A_mem_b_0_dout :
                             get_4_isog_busy ? get_4_isog_mult_A_mem_b_0_dout :
                             xDBLADD_busy ? xDBLADD_mult_A_mem_b_0_dout :
                             0;
assign mult_A_mem_b_1_dout = xDBL_busy ? xDBL_mult_A_mem_b_1_dout :
                             get_4_isog_busy ? get_4_isog_mult_A_mem_b_1_dout :
                             xDBLADD_busy ? xDBLADD_mult_A_mem_b_1_dout :
                             0;  
assign mult_A_mem_c_1_dout = xDBL_busy ? xDBL_mult_A_mem_c_1_dout :
                             get_4_isog_busy ? get_4_isog_mult_A_mem_c_1_dout :
                             xDBLADD_busy ? xDBLADD_mult_A_mem_c_1_dout :
                             0;

//----------------------------------------------------------------------------
// interface to multiplier B
//----------------------------------------------------------------------------
wire mult_B_start;
wire mult_B_busy;
wire mult_B_done;
wire mult_B_mem_a_0_rd_en;
wire mult_B_mem_a_1_rd_en;
wire mult_B_mem_b_0_rd_en;
wire mult_B_mem_b_1_rd_en;
wire mult_B_mem_c_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_a_0_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_a_1_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_b_0_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_b_1_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_mem_c_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_a_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_a_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mult_B_mem_c_1_dout;
wire mult_B_sub_mult_mem_res_rd_en;
wire [DOUBLE_MEM_DEPTH_LOG-1:0] mult_B_sub_mult_mem_res_rd_addr; 
wire [DOUBLE_MEM_WIDTH-1:0] mult_B_sub_mult_mem_res_dout; 
wire mult_B_add_mult_mem_res_rd_en;
wire [DOUBLE_MEM_DEPTH_LOG-1:0] mult_B_add_mult_mem_res_rd_addr; 
wire [DOUBLE_MEM_WIDTH-1:0] mult_B_add_mult_mem_res_dout;
wire mult_B_px2_mem_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_px2_mem_rd_addr;

assign mult_B_start = xDBL_mult_B_start | get_4_isog_mult_B_start | xDBLADD_mult_B_start;
assign mult_B_mem_a_0_dout = xDBL_busy ? xDBL_mult_B_mem_a_0_dout :
                             get_4_isog_busy ? get_4_isog_mult_B_mem_a_0_dout :
                             xDBLADD_busy ? xDBLADD_mult_B_mem_a_0_dout :
                             0;
assign mult_B_mem_a_1_dout = xDBL_busy ? xDBL_mult_B_mem_a_1_dout :
                             get_4_isog_busy ? get_4_isog_mult_B_mem_a_1_dout :
                             xDBLADD_busy ? xDBLADD_mult_B_mem_a_1_dout :
                             0;                             
assign mult_B_mem_b_0_dout = xDBL_busy ? xDBL_mult_B_mem_b_0_dout :
                             get_4_isog_busy ? get_4_isog_mult_B_mem_b_0_dout :
                             xDBLADD_busy ? xDBLADD_mult_B_mem_b_0_dout :
                             0;
assign mult_B_mem_b_1_dout = xDBL_busy ? xDBL_mult_B_mem_b_1_dout :
                             get_4_isog_busy ? get_4_isog_mult_B_mem_b_1_dout :
                             xDBLADD_busy ? xDBLADD_mult_B_mem_b_1_dout :
                             0;  
assign mult_B_mem_c_1_dout = xDBL_busy ? xDBL_mult_B_mem_c_1_dout :
                             get_4_isog_busy ? get_4_isog_mult_B_mem_c_1_dout :
                             xDBLADD_busy ? xDBLADD_mult_B_mem_c_1_dout :
                             0;

//----------------------------------------------------------------------------
// interface to memory converter wrapper
//----------------------------------------------------------------------------
wire mult_A_sub_mem_single_rd_en;
wire mult_A_add_mem_single_rd_en;
wire mult_B_sub_mem_single_rd_en;
wire mult_B_add_mem_single_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_sub_mem_single_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_A_add_mem_single_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_sub_mem_single_rd_addr;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mult_B_add_mem_single_rd_addr;
wire [RADIX-1:0] mult_A_sub_mem_single_dout;
wire [RADIX-1:0] mult_A_add_mem_single_dout;
wire [RADIX-1:0] mult_B_sub_mem_single_dout;
wire [RADIX-1:0] mult_B_add_mem_single_dout;

assign mult_A_sub_mem_single_rd_en = mem_t2_0_rd_en | xDBL_mult_A_sub_mem_single_rd_en | get_4_isog_mult_A_sub_mem_single_rd_en | xDBLADD_mult_A_sub_mem_single_rd_en;
assign mult_A_sub_mem_single_rd_addr = mem_t2_0_rd_en ? mem_t2_0_rd_addr : 
                                       xDBL_mult_A_sub_mem_single_rd_en ? xDBL_mult_A_sub_mem_single_rd_addr :
                                       get_4_isog_mult_A_sub_mem_single_rd_en ? get_4_isog_mult_A_sub_mem_single_rd_addr :
                                       xDBLADD_mult_A_sub_mem_single_rd_en ? xDBLADD_mult_A_sub_mem_single_rd_addr :
                                       0;
assign mult_A_add_mem_single_rd_en = mem_t2_1_rd_en | xDBL_mult_A_add_mem_single_rd_en | get_4_isog_mult_A_add_mem_single_rd_en | xDBLADD_mult_A_add_mem_single_rd_en;
assign mult_A_add_mem_single_rd_addr = mem_t2_1_rd_en ? mem_t2_1_rd_addr :
                                       xDBL_mult_A_add_mem_single_rd_en ? xDBL_mult_A_add_mem_single_rd_addr :
                                       get_4_isog_mult_A_add_mem_single_rd_en ? get_4_isog_mult_A_add_mem_single_rd_addr :
                                       xDBLADD_mult_A_add_mem_single_rd_en ? xDBLADD_mult_A_add_mem_single_rd_addr :
                                       0;
assign mult_B_sub_mem_single_rd_en = mem_t3_0_rd_en | xDBL_mult_B_sub_mem_single_rd_en | get_4_isog_mult_B_sub_mem_single_rd_en | xDBLADD_mult_B_sub_mem_single_rd_en;
assign mult_B_sub_mem_single_rd_addr = mem_t3_0_rd_en ? mem_t3_0_rd_addr : 
                                       xDBL_mult_B_sub_mem_single_rd_en ? xDBL_mult_B_sub_mem_single_rd_addr :
                                       get_4_isog_mult_B_sub_mem_single_rd_en ? get_4_isog_mult_B_sub_mem_single_rd_addr :
                                       xDBLADD_mult_B_sub_mem_single_rd_en ? xDBLADD_mult_B_sub_mem_single_rd_addr :
                                       0;
assign mult_B_add_mem_single_rd_en = mem_t3_1_rd_en | xDBL_mult_B_add_mem_single_rd_en | get_4_isog_mult_B_add_mem_single_rd_en | xDBLADD_mult_B_add_mem_single_rd_en;
assign mult_B_add_mem_single_rd_addr = mem_t3_1_rd_en ? mem_t3_1_rd_addr : 
                                       xDBL_mult_B_add_mem_single_rd_en ? xDBL_mult_B_add_mem_single_rd_addr :
                                       get_4_isog_mult_B_add_mem_single_rd_en ? get_4_isog_mult_B_add_mem_single_rd_addr :
                                       xDBLADD_mult_B_add_mem_single_rd_en ? xDBLADD_mult_B_add_mem_single_rd_addr :
                                       0;
//---------------------------------------------------------- ------------------
// interface to memory t4
//----------------------------------------------------------------------------
wire mem_t4_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_din;
wire mem_t4_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_0_rd_addr; 

wire mem_t4_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_din;
wire mem_t4_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t4_1_rd_addr; 

assign mem_t4_0_wr_en = xDBL_mem_t4_0_wr_en | get_4_isog_mem_t4_0_wr_en | xDBLADD_mem_t4_0_wr_en;
assign mem_t4_0_wr_addr = xDBL_mem_t4_0_wr_en ? xDBL_mem_t4_0_wr_addr :
                          get_4_isog_mem_t4_0_wr_en ? get_4_isog_mem_t4_0_wr_addr :
                          xDBLADD_mem_t4_0_wr_en ? xDBLADD_mem_t4_0_wr_addr :
                          0;
assign mem_t4_0_din = xDBL_mem_t4_0_wr_en ? xDBL_mem_t4_0_din :
                      get_4_isog_mem_t4_0_wr_en ? get_4_isog_mem_t4_0_din :
                      xDBLADD_mem_t4_0_wr_en ? xDBLADD_mem_t4_0_din :
                      0;
assign mem_t4_0_rd_en = out_mem_t4_0_rd_en | xDBL_mem_t4_0_rd_en | xDBLADD_mem_t4_0_rd_en;
assign mem_t4_0_rd_addr = out_mem_t4_0_rd_en ? out_mem_t4_0_rd_addr :
                          xDBL_mem_t4_0_rd_en ? xDBL_mem_t4_0_rd_addr :
                          xDBLADD_mem_t4_0_rd_en ? xDBLADD_mem_t4_0_rd_addr :
                          0;

assign mem_t4_1_wr_en = xDBL_mem_t4_1_wr_en | get_4_isog_mem_t4_1_wr_en | xDBLADD_mem_t4_1_wr_en;
assign mem_t4_1_wr_addr = xDBL_mem_t4_1_wr_en ? xDBL_mem_t4_1_wr_addr :
                          get_4_isog_mem_t4_1_wr_en ? get_4_isog_mem_t4_1_wr_addr :
                          xDBLADD_mem_t4_1_wr_en ? xDBLADD_mem_t4_1_wr_addr :
                          0;
assign mem_t4_1_din = xDBL_mem_t4_1_wr_en ? xDBL_mem_t4_1_din :
                      get_4_isog_mem_t4_1_wr_en ? get_4_isog_mem_t4_1_din :
                      xDBLADD_mem_t4_1_wr_en ? xDBLADD_mem_t4_1_din :
                      0;
assign mem_t4_1_rd_en = out_mem_t4_1_rd_en | xDBL_mem_t4_1_rd_en | xDBLADD_mem_t4_1_rd_en;
assign mem_t4_1_rd_addr = out_mem_t4_1_rd_en ? out_mem_t4_1_rd_addr :
                          xDBL_mem_t4_1_rd_en ? xDBL_mem_t4_1_rd_addr :
                          xDBLADD_mem_t4_1_rd_en ? xDBLADD_mem_t4_1_rd_addr :
                          0;
//----------------------------------------------------------------------------
// interface to memory t5
//----------------------------------------------------------------------------
wire mem_t5_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_din;
wire mem_t5_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_0_rd_addr; 

wire mem_t5_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_din;
wire mem_t5_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t5_1_rd_addr; 

assign mem_t5_0_wr_en = xDBL_mem_t5_0_wr_en | xDBLADD_mem_t5_0_wr_en | get_4_isog_mem_t5_0_wr_en;
assign mem_t5_0_wr_addr = xDBL_mem_t5_0_wr_en ? xDBL_mem_t5_0_wr_addr : 
                          xDBLADD_mem_t5_0_wr_en ? xDBLADD_mem_t5_0_wr_addr : 
                          get_4_isog_mem_t5_0_wr_en ? get_4_isog_mem_t5_0_wr_addr :
                          0;
assign mem_t5_0_din = xDBL_mem_t5_0_wr_en ? xDBL_mem_t5_0_din : 
                      xDBLADD_mem_t5_0_wr_en ? xDBLADD_mem_t5_0_din :
                      get_4_isog_mem_t5_0_wr_en ? get_4_isog_mem_t5_0_din :
                      0;
assign mem_t5_0_rd_en = out_mem_t5_0_rd_en | xDBL_mem_t5_0_rd_en | xDBLADD_mem_t5_0_rd_en;
assign mem_t5_0_rd_addr = out_mem_t5_0_rd_en ? out_mem_t5_0_rd_addr :
                          xDBL_mem_t5_0_rd_en ? xDBL_mem_t5_0_rd_addr :
                          xDBLADD_mem_t5_0_rd_en ? xDBLADD_mem_t5_0_rd_addr :
                          0;

assign mem_t5_1_wr_en = xDBL_mem_t5_1_wr_en | xDBLADD_mem_t5_1_wr_en | get_4_isog_mem_t5_1_wr_en;
assign mem_t5_1_wr_addr = xDBL_mem_t5_1_wr_en ? xDBL_mem_t5_1_wr_addr : 
                          xDBLADD_mem_t5_1_wr_en ? xDBLADD_mem_t5_1_wr_addr : 
                          get_4_isog_mem_t5_1_wr_en ? get_4_isog_mem_t5_1_wr_addr :
                          0;
assign mem_t5_1_din = xDBL_mem_t5_1_wr_en ? xDBL_mem_t5_1_din : 
                      xDBLADD_mem_t5_1_wr_en ? xDBLADD_mem_t5_1_din :
                      get_4_isog_mem_t5_1_wr_en ? get_4_isog_mem_t5_1_din :
                      0;
assign mem_t5_1_rd_en = out_mem_t5_1_rd_en | xDBL_mem_t5_1_rd_en | xDBLADD_mem_t5_1_rd_en;
assign mem_t5_1_rd_addr = out_mem_t5_1_rd_en ? out_mem_t5_1_rd_addr :
                          xDBL_mem_t5_1_rd_en ? xDBL_mem_t5_1_rd_addr :
                          xDBLADD_mem_t5_1_rd_en ? xDBLADD_mem_t5_1_rd_addr :
                          0;

//----------------------------------------------------------------------------
// interface to memory t6
//----------------------------------------------------------------------------
wire mem_t6_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_din;
wire mem_t6_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_dout; 

wire mem_t6_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_din;
wire mem_t6_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t6_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_dout;

assign mem_t6_0_wr_en = xDBLADD_mem_t6_0_wr_en;
assign mem_t6_0_wr_addr = xDBLADD_mem_t6_0_wr_en ? xDBLADD_mem_t6_0_wr_addr : 
                          0;
assign mem_t6_0_din = xDBLADD_mem_t6_0_wr_en ? xDBLADD_mem_t6_0_din :
                      0;
assign mem_t6_0_rd_en = xDBLADD_mem_t6_0_rd_en;
assign mem_t6_0_rd_addr = xDBLADD_mem_t6_0_rd_en ? xDBLADD_mem_t6_0_rd_addr :
                          0;

assign mem_t6_1_wr_en = xDBLADD_mem_t6_1_wr_en;
assign mem_t6_1_wr_addr = xDBLADD_mem_t6_1_wr_en ? xDBLADD_mem_t6_1_wr_addr : 
                          0;
assign mem_t6_1_din = xDBLADD_mem_t6_1_wr_en ? xDBLADD_mem_t6_1_din :
                      0;
assign mem_t6_1_rd_en = xDBLADD_mem_t6_1_rd_en;
assign mem_t6_1_rd_addr = xDBLADD_mem_t6_1_rd_en ? xDBLADD_mem_t6_1_rd_addr :
                          0;

//----------------------------------------------------------------------------
// interface to memory t7
//----------------------------------------------------------------------------
wire mem_t7_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_din;
wire mem_t7_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_dout; 

wire mem_t7_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_din;
wire mem_t7_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t7_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_dout;

assign mem_t7_0_wr_en = xDBLADD_mem_t7_0_wr_en;
assign mem_t7_0_wr_addr = xDBLADD_mem_t7_0_wr_en ? xDBLADD_mem_t7_0_wr_addr : 
                          0;
assign mem_t7_0_din = xDBLADD_mem_t7_0_wr_en ? xDBLADD_mem_t7_0_din :
                      0;
assign mem_t7_0_rd_en = xDBLADD_mem_t7_0_rd_en;
assign mem_t7_0_rd_addr = xDBLADD_mem_t7_0_rd_en ? xDBLADD_mem_t7_0_rd_addr :
                          0;

assign mem_t7_1_wr_en = xDBLADD_mem_t7_1_wr_en;
assign mem_t7_1_wr_addr = xDBLADD_mem_t7_1_wr_en ? xDBLADD_mem_t7_1_wr_addr : 
                          0;
assign mem_t7_1_din = xDBLADD_mem_t7_1_wr_en ? xDBLADD_mem_t7_1_din :
                      0;
assign mem_t7_1_rd_en = xDBLADD_mem_t7_1_rd_en;
assign mem_t7_1_rd_addr = xDBLADD_mem_t7_1_rd_en ? xDBLADD_mem_t7_1_rd_addr :
                          0;

//----------------------------------------------------------------------------
// interface to memory t8
//----------------------------------------------------------------------------
wire mem_t8_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_0_din;
wire mem_t8_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_0_dout; 

wire mem_t8_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_1_din;
wire mem_t8_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t8_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t8_1_dout;

assign mem_t8_0_wr_en = xDBLADD_mem_t8_0_wr_en;
assign mem_t8_0_wr_addr = xDBLADD_mem_t8_0_wr_en ? xDBLADD_mem_t8_0_wr_addr : 
                          0;
assign mem_t8_0_din = xDBLADD_mem_t8_0_wr_en ? xDBLADD_mem_t8_0_din :
                      0;
assign mem_t8_0_rd_en = xDBLADD_mem_t8_0_rd_en;
assign mem_t8_0_rd_addr = xDBLADD_mem_t8_0_rd_en ? xDBLADD_mem_t8_0_rd_addr :
                          0;

assign mem_t8_1_wr_en = xDBLADD_mem_t8_1_wr_en;
assign mem_t8_1_wr_addr = xDBLADD_mem_t8_1_wr_en ? xDBLADD_mem_t8_1_wr_addr : 
                          0;
assign mem_t8_1_din = xDBLADD_mem_t8_1_wr_en ? xDBLADD_mem_t8_1_din :
                      0;
assign mem_t8_1_rd_en = xDBLADD_mem_t8_1_rd_en;
assign mem_t8_1_rd_addr = xDBLADD_mem_t8_1_rd_en ? xDBLADD_mem_t8_1_rd_addr :
                          0;

//----------------------------------------------------------------------------
// interface to memory t9
//----------------------------------------------------------------------------
wire mem_t9_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_0_din;
wire mem_t9_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_0_dout; 

wire mem_t9_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_1_din;
wire mem_t9_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t9_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t9_1_dout;

assign mem_t9_0_wr_en = xDBLADD_mem_t9_0_wr_en;
assign mem_t9_0_wr_addr = xDBLADD_mem_t9_0_wr_en ? xDBLADD_mem_t9_0_wr_addr : 
                          0;
assign mem_t9_0_din = xDBLADD_mem_t9_0_wr_en ? xDBLADD_mem_t9_0_din :
                      0;
assign mem_t9_0_rd_en = xDBLADD_mem_t9_0_rd_en;
assign mem_t9_0_rd_addr = xDBLADD_mem_t9_0_rd_en ? xDBLADD_mem_t9_0_rd_addr :
                          0;

assign mem_t9_1_wr_en = xDBLADD_mem_t9_1_wr_en;
assign mem_t9_1_wr_addr = xDBLADD_mem_t9_1_wr_en ? xDBLADD_mem_t9_1_wr_addr : 
                          0;
assign mem_t9_1_din = xDBLADD_mem_t9_1_wr_en ? xDBLADD_mem_t9_1_din :
                      0;
assign mem_t9_1_rd_en = xDBLADD_mem_t9_1_rd_en;
assign mem_t9_1_rd_addr = xDBLADD_mem_t9_1_rd_en ? xDBLADD_mem_t9_1_rd_addr :
                          0;

//---------------------------------------------------------- ------------------
// interface to memory t10
//----------------------------------------------------------------------------
wire mem_t10_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t10_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_din;
wire mem_t10_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t10_0_rd_addr; 

wire mem_t10_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t10_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_din;
wire mem_t10_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t10_1_rd_addr; 

assign mem_t10_0_wr_en = xDBLADD_mem_t10_0_wr_en;
assign mem_t10_0_wr_addr = xDBLADD_mem_t10_0_wr_en ? xDBLADD_mem_t10_0_wr_addr :
                          0;
assign mem_t10_0_din = xDBLADD_mem_t10_0_wr_en ? xDBLADD_mem_t10_0_din :
                       0;
assign mem_t10_0_rd_en = out_mem_t10_0_rd_en;
assign mem_t10_0_rd_addr = out_mem_t10_0_rd_en ? out_mem_t10_0_rd_addr : 
                           0;

assign mem_t10_1_wr_en = xDBLADD_mem_t10_1_wr_en;
assign mem_t10_1_wr_addr = xDBLADD_mem_t10_1_wr_en ? xDBLADD_mem_t10_1_wr_addr :
                           0;
assign mem_t10_1_din = xDBLADD_mem_t10_1_wr_en ? xDBLADD_mem_t10_1_din :
                       0;
assign mem_t10_1_rd_en = out_mem_t10_1_rd_en;
assign mem_t10_1_rd_addr = out_mem_t10_1_rd_en ? out_mem_t10_1_rd_addr : 
                           0;
                                                                          
//----------------------------------------------------------------------------
// common logic: specific for squaring logic
//----------------------------------------------------------------------------
reg [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_0_dout_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_1_dout_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_0_dout_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_1_dout_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_0_dout_next_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_A_mem_b_1_dout_next_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_0_dout_next_buf;
reg [SINGLE_MEM_WIDTH-1:0] mult_B_mem_b_1_dout_next_buf;
 

wire mult_A_a_addr_is_b_addr_plus_one;
reg mult_A_a_addr_is_b_addr_plus_one_buf;
wire mult_B_a_addr_is_b_addr_plus_one;
reg mult_B_a_addr_is_b_addr_plus_one_buf;

wire mult_A_used_for_squaring_running;
wire mult_B_used_for_squaring_running;

assign mult_A_used_for_squaring_running = xDBL_mult_A_used_for_squaring_running | get_4_isog_mult_A_used_for_squaring_running | xDBLADD_mult_A_used_for_squaring_running;
assign mult_B_used_for_squaring_running = xDBL_mult_B_used_for_squaring_running | get_4_isog_mult_B_used_for_squaring_running | xDBLADD_mult_B_used_for_squaring_running;

assign mult_A_a_addr_is_b_addr_plus_one = (mult_A_mem_a_0_rd_addr == (mult_A_mem_b_0_rd_addr + 1)) & mult_A_used_for_squaring_running;
assign mult_B_a_addr_is_b_addr_plus_one = (mult_B_mem_a_0_rd_addr == (mult_B_mem_b_0_rd_addr + 1)) & mult_B_used_for_squaring_running;
 
always @(posedge clk or posedge rst) begin
  if (rst) begin
    mult_A_mem_b_0_dout_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_A_mem_b_1_dout_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_B_mem_b_0_dout_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_B_mem_b_1_dout_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_A_mem_b_0_dout_next_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_A_mem_b_1_dout_next_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_B_mem_b_0_dout_next_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_B_mem_b_1_dout_next_buf <= {SINGLE_MEM_WIDTH{1'b0}};
    mult_A_a_addr_is_b_addr_plus_one_buf <= 1'b0;
    mult_B_a_addr_is_b_addr_plus_one_buf <= 1'b0; 
  end 
  else begin
    mult_A_mem_b_0_dout_buf <= (mult_A_start & mult_A_used_for_squaring_running) ? mult_A_mem_a_0_dout :
                               (mult_A_mem_a_0_rd_addr == 0) & mult_A_used_for_squaring_running ? mult_A_mem_b_0_dout_next_buf :
                               mult_A_mem_b_0_dout_buf;

    mult_A_mem_b_1_dout_buf <= (mult_A_start & mult_A_used_for_squaring_running) ? mult_A_mem_a_1_dout :
                               (mult_A_mem_a_1_rd_addr == 0) & mult_A_used_for_squaring_running ? mult_A_mem_b_1_dout_next_buf :
                               mult_A_mem_b_1_dout_buf;

    mult_B_mem_b_0_dout_buf <= (mult_B_start & mult_B_used_for_squaring_running) ? mult_B_mem_a_0_dout :
                               (mult_B_mem_a_0_rd_addr == 0) & mult_B_used_for_squaring_running ? mult_B_mem_b_0_dout_next_buf :
                               mult_B_mem_b_0_dout_buf;

    mult_B_mem_b_1_dout_buf <= (mult_B_start & mult_B_used_for_squaring_running) ? mult_B_mem_a_1_dout :
                               (mult_B_mem_a_1_rd_addr == 0) & mult_B_used_for_squaring_running ? mult_B_mem_b_1_dout_next_buf :
                               mult_B_mem_b_1_dout_buf;

    mult_A_a_addr_is_b_addr_plus_one_buf <= mult_A_a_addr_is_b_addr_plus_one;
    mult_B_a_addr_is_b_addr_plus_one_buf <= mult_B_a_addr_is_b_addr_plus_one;

    mult_A_mem_b_0_dout_next_buf <= mult_A_a_addr_is_b_addr_plus_one_buf ? mult_A_mem_a_0_dout : mult_A_mem_b_0_dout_next_buf;
    mult_A_mem_b_1_dout_next_buf <= mult_A_a_addr_is_b_addr_plus_one_buf ? mult_A_mem_a_1_dout : mult_A_mem_b_1_dout_next_buf;
    mult_B_mem_b_0_dout_next_buf <= mult_B_a_addr_is_b_addr_plus_one_buf ? mult_B_mem_a_0_dout : mult_B_mem_b_0_dout_next_buf;
    mult_B_mem_b_1_dout_next_buf <= mult_B_a_addr_is_b_addr_plus_one_buf ? mult_B_mem_a_1_dout : mult_B_mem_b_1_dout_next_buf;
     
  end
end

assign xDBL_start = (function_encoded == 8'd1) & start;
assign get_4_isog_start = (function_encoded == 8'd2) & start;
assign xDBLADD_start = (function_encoded == 8'd3) & start;
assign busy = xDBL_busy | get_4_isog_busy | xDBLADD_busy;
assign done = xDBL_done | get_4_isog_done | xDBLADD_done;
assign mem_t0_0_dout = add_A_mem_c_0_dout;
assign mem_t0_1_dout = add_A_mem_c_1_dout;
assign mem_t1_0_dout = add_B_mem_c_0_dout;
assign mem_t1_1_dout = add_B_mem_c_1_dout;
assign mem_t2_0_dout = mult_A_sub_mem_single_dout;
assign mem_t2_1_dout = mult_A_add_mem_single_dout;
assign mem_t3_0_dout = mult_B_sub_mem_single_dout;
assign mem_t3_1_dout = mult_B_add_mem_single_dout; 

//----------------------------------------------------------------------------
// sub-modules
//----------------------------------------------------------------------------

xDBL_FSM #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) xDBL_FSM_inst (
  .rst(rst),
  .clk(clk),
  .start(xDBL_start),
  .done(xDBL_done),
  .busy(xDBL_busy),
  .mem_X_0_dout(xDBL_mem_X_0_dout),
  .mem_X_0_rd_en(xDBL_mem_X_0_rd_en),
  .mem_X_0_rd_addr(xDBL_mem_X_0_rd_addr),
  .mem_X_1_dout(xDBL_mem_X_1_dout),
  .mem_X_1_rd_en(xDBL_mem_X_1_rd_en),
  .mem_X_1_rd_addr(xDBL_mem_X_1_rd_addr),
  .mem_Z_0_dout(xDBL_mem_Z_0_dout),
  .mem_Z_0_rd_en(xDBL_mem_Z_0_rd_en),
  .mem_Z_0_rd_addr(xDBL_mem_Z_0_rd_addr),
  .mem_Z_1_dout(xDBL_mem_Z_1_dout),
  .mem_Z_1_rd_en(xDBL_mem_Z_1_rd_en),
  .mem_Z_1_rd_addr(xDBL_mem_Z_1_rd_addr),
  .mem_A24_0_dout(xDBL_mem_A24_0_dout),
  .mem_A24_0_rd_en(xDBL_mem_A24_0_rd_en),
  .mem_A24_0_rd_addr(xDBL_mem_A24_0_rd_addr), 
  .mem_A24_1_dout(xDBL_mem_A24_1_dout),
  .mem_A24_1_rd_en(xDBL_mem_A24_1_rd_en),
  .mem_A24_1_rd_addr(xDBL_mem_A24_1_rd_addr),
  .mem_C24_0_dout(xDBL_mem_C24_0_dout),
  .mem_C24_0_rd_en(xDBL_mem_C24_0_rd_en),
  .mem_C24_0_rd_addr(xDBL_mem_C24_0_rd_addr),
  .mem_C24_1_dout(xDBL_mem_C24_1_dout),
  .mem_C24_1_rd_en(xDBL_mem_C24_1_rd_en),
  .mem_C24_1_rd_addr(xDBL_mem_C24_1_rd_addr), 
  .mem_t4_0_wr_en(xDBL_mem_t4_0_wr_en),
  .mem_t4_0_wr_addr(xDBL_mem_t4_0_wr_addr),
  .mem_t4_0_din(xDBL_mem_t4_0_din),
  .mem_t4_0_rd_en(xDBL_mem_t4_0_rd_en),
  .mem_t4_0_rd_addr(xDBL_mem_t4_0_rd_addr),
  .mem_t4_0_dout(mem_t4_0_dout),
  .mem_t4_1_wr_en(xDBL_mem_t4_1_wr_en),
  .mem_t4_1_wr_addr(xDBL_mem_t4_1_wr_addr),
  .mem_t4_1_din(xDBL_mem_t4_1_din),
  .mem_t4_1_rd_en(xDBL_mem_t4_1_rd_en),
  .mem_t4_1_rd_addr(xDBL_mem_t4_1_rd_addr),
  .mem_t4_1_dout(mem_t4_1_dout),
  .mem_t5_0_wr_en(xDBL_mem_t5_0_wr_en),
  .mem_t5_0_wr_addr(xDBL_mem_t5_0_wr_addr),
  .mem_t5_0_din(xDBL_mem_t5_0_din),
  .mem_t5_0_rd_en(xDBL_mem_t5_0_rd_en),
  .mem_t5_0_rd_addr(xDBL_mem_t5_0_rd_addr),
  .mem_t5_0_dout(mem_t5_0_dout),
  .mem_t5_1_wr_en(xDBL_mem_t5_1_wr_en),
  .mem_t5_1_wr_addr(xDBL_mem_t5_1_wr_addr),
  .mem_t5_1_din(xDBL_mem_t5_1_din),
  .mem_t5_1_rd_en(xDBL_mem_t5_1_rd_en),
  .mem_t5_1_rd_addr(xDBL_mem_t5_1_rd_addr),
  .mem_t5_1_dout(mem_t5_1_dout),
  .add_A_start(xDBL_add_A_start),
  .add_A_busy(add_A_busy),
  .add_A_done(add_A_done),
  .add_A_cmd(xDBL_add_A_cmd),
  .add_A_extension_field_op(xDBL_add_A_extension_field_op),
  .add_A_mem_a_0_rd_en(add_A_mem_a_0_rd_en),
  .add_A_mem_a_0_rd_addr(add_A_mem_a_0_rd_addr),
  .add_A_mem_a_0_dout(xDBL_add_A_mem_a_0_dout),
  .add_A_mem_a_1_rd_en(add_A_mem_a_1_rd_en),
  .add_A_mem_a_1_rd_addr(add_A_mem_a_1_rd_addr),
  .add_A_mem_a_1_dout(xDBL_add_A_mem_a_1_dout),
  .add_A_mem_b_0_rd_en(add_A_mem_b_0_rd_en),
  .add_A_mem_b_0_rd_addr(add_A_mem_b_0_rd_addr),
  .add_A_mem_b_0_dout(xDBL_add_A_mem_b_0_dout),
  .add_A_mem_b_1_rd_en(add_A_mem_b_1_rd_en),
  .add_A_mem_b_1_rd_addr(add_A_mem_b_1_rd_addr),
  .add_A_mem_b_1_dout(xDBL_add_A_mem_b_1_dout),  
  .add_A_mem_c_0_rd_en(xDBL_add_A_mem_c_0_rd_en),
  .add_A_mem_c_0_rd_addr(xDBL_add_A_mem_c_0_rd_addr),
  .add_A_mem_c_0_dout(add_A_mem_c_0_dout),
  .add_A_mem_c_1_rd_en(xDBL_add_A_mem_c_1_rd_en),
  .add_A_mem_c_1_rd_addr(xDBL_add_A_mem_c_1_rd_addr),
  .add_A_mem_c_1_dout(add_A_mem_c_1_dout),
  .add_A_px2_mem_rd_en(add_A_px2_mem_rd_en),
  .add_A_px2_mem_rd_addr(add_A_px2_mem_rd_addr),
  .add_A_px4_mem_rd_en(add_A_px4_mem_rd_en),
  .add_A_px4_mem_rd_addr(add_A_px4_mem_rd_addr),
  .add_B_start(xDBL_add_B_start),
  .add_B_busy(add_B_busy),
  .add_B_done(add_B_done),
  .add_B_cmd(xDBL_add_B_cmd),
  .add_B_extension_field_op(xDBL_add_B_extension_field_op),
  .add_B_mem_a_0_rd_en(add_B_mem_a_0_rd_en),
  .add_B_mem_a_0_rd_addr(add_B_mem_a_0_rd_addr),
  .add_B_mem_a_0_dout(xDBL_add_B_mem_a_0_dout),
  .add_B_mem_a_1_rd_en(add_B_mem_a_1_rd_en),
  .add_B_mem_a_1_rd_addr(add_B_mem_a_1_rd_addr),
  .add_B_mem_a_1_dout(xDBL_add_B_mem_a_1_dout),
  .add_B_mem_b_0_rd_en(add_B_mem_b_0_rd_en),
  .add_B_mem_b_0_rd_addr(add_B_mem_b_0_rd_addr),
  .add_B_mem_b_0_dout(xDBL_add_B_mem_b_0_dout),
  .add_B_mem_b_1_rd_en(add_B_mem_b_1_rd_en),
  .add_B_mem_b_1_rd_addr(add_B_mem_b_1_rd_addr),
  .add_B_mem_b_1_dout(xDBL_add_B_mem_b_1_dout),  
  .add_B_mem_c_0_rd_en(xDBL_add_B_mem_c_0_rd_en),
  .add_B_mem_c_0_rd_addr(xDBL_add_B_mem_c_0_rd_addr),
  .add_B_mem_c_0_dout(add_B_mem_c_0_dout),
  .add_B_mem_c_1_rd_en(xDBL_add_B_mem_c_1_rd_en),
  .add_B_mem_c_1_rd_addr(xDBL_add_B_mem_c_1_rd_addr),
  .add_B_mem_c_1_dout(add_B_mem_c_1_dout),
  .add_B_px2_mem_rd_en(add_B_px2_mem_rd_en),
  .add_B_px2_mem_rd_addr(add_B_px2_mem_rd_addr),
  .add_B_px4_mem_rd_en(add_B_px4_mem_rd_en),
  .add_B_px4_mem_rd_addr(add_B_px4_mem_rd_addr),
  .mult_A_start(xDBL_mult_A_start),
  .mult_A_done(mult_A_done),
  .mult_A_busy(mult_A_busy),
  .mult_A_mem_a_0_rd_en(mult_A_mem_a_0_rd_en),
  .mult_A_mem_a_0_rd_addr(mult_A_mem_a_0_rd_addr),
  .mult_A_mem_a_0_dout(xDBL_mult_A_mem_a_0_dout),  
  .mult_A_mem_a_1_rd_en(mult_A_mem_a_1_rd_en),
  .mult_A_mem_a_1_rd_addr(mult_A_mem_a_1_rd_addr),
  .mult_A_mem_a_1_dout(xDBL_mult_A_mem_a_1_dout),
  .mult_A_mem_b_0_rd_en(mult_A_mem_b_0_rd_en),
  .mult_A_mem_b_0_rd_addr(mult_A_mem_b_0_rd_addr),
  .mult_A_mem_b_0_dout(xDBL_mult_A_mem_b_0_dout),
  .mult_A_mem_b_1_rd_en(mult_A_mem_b_1_rd_en),
  .mult_A_mem_b_1_rd_addr(mult_A_mem_b_1_rd_addr),
  .mult_A_mem_b_1_dout(xDBL_mult_A_mem_b_1_dout),
  .mult_A_mem_c_1_rd_en(mult_A_mem_c_1_rd_en),
  .mult_A_mem_c_1_rd_addr(mult_A_mem_c_1_rd_addr),
  .mult_A_mem_c_1_dout(xDBL_mult_A_mem_c_1_dout),
  .mult_A_sub_mem_single_rd_en(xDBL_mult_A_sub_mem_single_rd_en),
  .mult_A_sub_mem_single_rd_addr(xDBL_mult_A_sub_mem_single_rd_addr),
  .mult_A_sub_mem_single_dout(mult_A_sub_mem_single_dout),
  .mult_A_add_mem_single_rd_en(xDBL_mult_A_add_mem_single_rd_en),  
  .mult_A_add_mem_single_rd_addr(xDBL_mult_A_add_mem_single_rd_addr),
  .mult_A_add_mem_single_dout(mult_A_add_mem_single_dout),
  .mult_A_px2_mem_rd_en(mult_A_px2_mem_rd_en),
  .mult_A_px2_mem_rd_addr(mult_A_px2_mem_rd_addr),
  .mult_B_start(xDBL_mult_B_start),
  .mult_B_done(mult_B_done),
  .mult_B_busy(mult_B_busy),
  .mult_B_mem_a_0_rd_en(mult_B_mem_a_0_rd_en),
  .mult_B_mem_a_0_rd_addr(mult_B_mem_a_0_rd_addr),
  .mult_B_mem_a_0_dout(xDBL_mult_B_mem_a_0_dout),  
  .mult_B_mem_a_1_rd_en(mult_B_mem_a_1_rd_en),
  .mult_B_mem_a_1_rd_addr(mult_B_mem_a_1_rd_addr),
  .mult_B_mem_a_1_dout(xDBL_mult_B_mem_a_1_dout),
  .mult_B_mem_b_0_rd_en(mult_B_mem_b_0_rd_en),
  .mult_B_mem_b_0_rd_addr(mult_B_mem_b_0_rd_addr),
  .mult_B_mem_b_0_dout(xDBL_mult_B_mem_b_0_dout),
  .mult_B_mem_b_1_rd_en(mult_B_mem_b_1_rd_en),
  .mult_B_mem_b_1_rd_addr(mult_B_mem_b_1_rd_addr),
  .mult_B_mem_b_1_dout(xDBL_mult_B_mem_b_1_dout),
  .mult_B_mem_c_1_rd_en(mult_B_mem_c_1_rd_en),
  .mult_B_mem_c_1_rd_addr(mult_B_mem_c_1_rd_addr),
  .mult_B_mem_c_1_dout(xDBL_mult_B_mem_c_1_dout),
  .mult_B_sub_mem_single_rd_en(xDBL_mult_B_sub_mem_single_rd_en),
  .mult_B_sub_mem_single_rd_addr(xDBL_mult_B_sub_mem_single_rd_addr),
  .mult_B_sub_mem_single_dout(mult_B_sub_mem_single_dout),
  .mult_B_add_mem_single_rd_en(xDBL_mult_B_add_mem_single_rd_en),  
  .mult_B_add_mem_single_rd_addr(xDBL_mult_B_add_mem_single_rd_addr),
  .mult_B_add_mem_single_dout(mult_B_add_mem_single_dout),
  .mult_B_px2_mem_rd_en(mult_B_px2_mem_rd_en),
  .mult_B_px2_mem_rd_addr(mult_B_px2_mem_rd_addr),
  .p_plus_one_mem_rd_addr(xDBL_p_plus_one_mem_rd_addr),  
  .px2_mem_rd_addr(xDBL_px2_mem_rd_addr),
  .px4_mem_rd_addr(xDBL_px4_mem_rd_addr),
  .p_plus_one_mem_dout(p_plus_one_mem_dout),
  .px2_mem_dout(px2_mem_dout),
  .px4_mem_dout(px4_mem_dout),
  .mult_A_mem_b_0_dout_buf(mult_A_mem_b_0_dout_buf),
  .mult_A_mem_b_1_dout_buf(mult_A_mem_b_1_dout_buf),
  .mult_B_mem_b_0_dout_buf(mult_B_mem_b_0_dout_buf),
  .mult_B_mem_b_1_dout_buf(mult_B_mem_b_1_dout_buf),
  .mult_A_used_for_squaring_running(xDBL_mult_A_used_for_squaring_running),
  .mult_B_used_for_squaring_running(xDBL_mult_B_used_for_squaring_running)
  ); 


get_4_isog_FSM #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) get_4_isog_FSM_inst (
  .rst(rst),
  .clk(clk),
  .start(get_4_isog_start),
  .done(get_4_isog_done),
  .busy(get_4_isog_busy),
  .mem_X4_0_dout(get_4_isog_mem_X4_0_dout),
  .mem_X4_0_rd_en(get_4_isog_mem_X4_0_rd_en),
  .mem_X4_0_rd_addr(get_4_isog_mem_X4_0_rd_addr),
  .mem_X4_1_dout(get_4_isog_mem_X4_1_dout),
  .mem_X4_1_rd_en(get_4_isog_mem_X4_1_rd_en),
  .mem_X4_1_rd_addr(get_4_isog_mem_X4_1_rd_addr),
  .mem_Z4_0_dout(get_4_isog_mem_Z4_0_dout),
  .mem_Z4_0_rd_en(get_4_isog_mem_Z4_0_rd_en),
  .mem_Z4_0_rd_addr(get_4_isog_mem_Z4_0_rd_addr),
  .mem_Z4_1_dout(get_4_isog_mem_Z4_1_dout),
  .mem_Z4_1_rd_en(get_4_isog_mem_Z4_1_rd_en),
  .mem_Z4_1_rd_addr(get_4_isog_mem_Z4_1_rd_addr), 
  .mem_t4_0_wr_en(get_4_isog_mem_t4_0_wr_en),
  .mem_t4_0_wr_addr(get_4_isog_mem_t4_0_wr_addr),
  .mem_t4_0_din(get_4_isog_mem_t4_0_din), 
  .mem_t4_0_dout(mem_t4_0_dout), 
  .mem_t4_1_wr_en(get_4_isog_mem_t4_1_wr_en),
  .mem_t4_1_wr_addr(get_4_isog_mem_t4_1_wr_addr),
  .mem_t4_1_din(get_4_isog_mem_t4_1_din), 
  .mem_t4_1_dout(mem_t4_1_dout), 
  .mem_t5_0_wr_en(get_4_isog_mem_t5_0_wr_en),
  .mem_t5_0_wr_addr(get_4_isog_mem_t5_0_wr_addr),
  .mem_t5_0_din(get_4_isog_mem_t5_0_din), 
  .mem_t5_0_dout(mem_t5_0_dout), 
  .mem_t5_1_wr_en(get_4_isog_mem_t5_1_wr_en),
  .mem_t5_1_wr_addr(get_4_isog_mem_t5_1_wr_addr),
  .mem_t5_1_din(get_4_isog_mem_t5_1_din), 
  .mem_t5_1_dout(mem_t5_1_dout),
  .add_A_start(get_4_isog_add_A_start),
  .add_A_busy(add_A_busy),
  .add_A_done(add_A_done),
  .add_A_cmd(get_4_isog_add_A_cmd),
  .add_A_extension_field_op(get_4_isog_add_A_extension_field_op),
  .add_A_mem_a_0_rd_en(add_A_mem_a_0_rd_en),
  .add_A_mem_a_0_rd_addr(add_A_mem_a_0_rd_addr),
  .add_A_mem_a_0_dout(get_4_isog_add_A_mem_a_0_dout),
  .add_A_mem_a_1_rd_en(add_A_mem_a_1_rd_en),
  .add_A_mem_a_1_rd_addr(add_A_mem_a_1_rd_addr),
  .add_A_mem_a_1_dout(get_4_isog_add_A_mem_a_1_dout),
  .add_A_mem_b_0_rd_en(add_A_mem_b_0_rd_en),
  .add_A_mem_b_0_rd_addr(add_A_mem_b_0_rd_addr),
  .add_A_mem_b_0_dout(get_4_isog_add_A_mem_b_0_dout),
  .add_A_mem_b_1_rd_en(add_A_mem_b_1_rd_en),
  .add_A_mem_b_1_rd_addr(add_A_mem_b_1_rd_addr),
  .add_A_mem_b_1_dout(get_4_isog_add_A_mem_b_1_dout),  
  .add_A_mem_c_0_rd_en(get_4_isog_add_A_mem_c_0_rd_en),
  .add_A_mem_c_0_rd_addr(get_4_isog_add_A_mem_c_0_rd_addr),
  .add_A_mem_c_0_dout(add_A_mem_c_0_dout),
  .add_A_mem_c_1_rd_en(get_4_isog_add_A_mem_c_1_rd_en),
  .add_A_mem_c_1_rd_addr(get_4_isog_add_A_mem_c_1_rd_addr),
  .add_A_mem_c_1_dout(add_A_mem_c_1_dout),
  .add_A_px2_mem_rd_en(add_A_px2_mem_rd_en),
  .add_A_px2_mem_rd_addr(add_A_px2_mem_rd_addr),
  .add_A_px4_mem_rd_en(add_A_px4_mem_rd_en),
  .add_A_px4_mem_rd_addr(add_A_px4_mem_rd_addr),
  .add_B_start(get_4_isog_add_B_start),
  .add_B_busy(add_B_busy),
  .add_B_done(add_B_done),
  .add_B_cmd(get_4_isog_add_B_cmd),
  .add_B_extension_field_op(get_4_isog_add_B_extension_field_op),
  .add_B_mem_a_0_rd_en(add_B_mem_a_0_rd_en),
  .add_B_mem_a_0_rd_addr(add_B_mem_a_0_rd_addr),
  .add_B_mem_a_0_dout(get_4_isog_add_B_mem_a_0_dout),
  .add_B_mem_a_1_rd_en(add_B_mem_a_1_rd_en),
  .add_B_mem_a_1_rd_addr(add_B_mem_a_1_rd_addr),
  .add_B_mem_a_1_dout(get_4_isog_add_B_mem_a_1_dout),
  .add_B_mem_b_0_rd_en(add_B_mem_b_0_rd_en),
  .add_B_mem_b_0_rd_addr(add_B_mem_b_0_rd_addr),
  .add_B_mem_b_0_dout(get_4_isog_add_B_mem_b_0_dout),
  .add_B_mem_b_1_rd_en(add_B_mem_b_1_rd_en),
  .add_B_mem_b_1_rd_addr(add_B_mem_b_1_rd_addr),
  .add_B_mem_b_1_dout(get_4_isog_add_B_mem_b_1_dout),  
  .add_B_mem_c_0_rd_en(get_4_isog_add_B_mem_c_0_rd_en),
  .add_B_mem_c_0_rd_addr(get_4_isog_add_B_mem_c_0_rd_addr),
  .add_B_mem_c_0_dout(add_B_mem_c_0_dout),
  .add_B_mem_c_1_rd_en(get_4_isog_add_B_mem_c_1_rd_en),
  .add_B_mem_c_1_rd_addr(get_4_isog_add_B_mem_c_1_rd_addr),
  .add_B_mem_c_1_dout(add_B_mem_c_1_dout),
  .add_B_px2_mem_rd_en(add_B_px2_mem_rd_en),
  .add_B_px2_mem_rd_addr(add_B_px2_mem_rd_addr),
  .add_B_px4_mem_rd_en(add_B_px4_mem_rd_en),
  .add_B_px4_mem_rd_addr(add_B_px4_mem_rd_addr),
  .mult_A_start(get_4_isog_mult_A_start),
  .mult_A_done(mult_A_done),
  .mult_A_busy(mult_A_busy),
  .mult_A_mem_a_0_rd_en(mult_A_mem_a_0_rd_en),
  .mult_A_mem_a_0_rd_addr(mult_A_mem_a_0_rd_addr),
  .mult_A_mem_a_0_dout(get_4_isog_mult_A_mem_a_0_dout),  
  .mult_A_mem_a_1_rd_en(mult_A_mem_a_1_rd_en),
  .mult_A_mem_a_1_rd_addr(mult_A_mem_a_1_rd_addr),
  .mult_A_mem_a_1_dout(get_4_isog_mult_A_mem_a_1_dout),
  .mult_A_mem_b_0_rd_en(mult_A_mem_b_0_rd_en),
  .mult_A_mem_b_0_rd_addr(mult_A_mem_b_0_rd_addr),
  .mult_A_mem_b_0_dout(get_4_isog_mult_A_mem_b_0_dout),
  .mult_A_mem_b_1_rd_en(mult_A_mem_b_1_rd_en),
  .mult_A_mem_b_1_rd_addr(mult_A_mem_b_1_rd_addr),
  .mult_A_mem_b_1_dout(get_4_isog_mult_A_mem_b_1_dout),
  .mult_A_mem_c_1_rd_en(mult_A_mem_c_1_rd_en),
  .mult_A_mem_c_1_rd_addr(mult_A_mem_c_1_rd_addr),
  .mult_A_mem_c_1_dout(get_4_isog_mult_A_mem_c_1_dout),
  .mult_A_sub_mem_single_rd_en(get_4_isog_mult_A_sub_mem_single_rd_en),
  .mult_A_sub_mem_single_rd_addr(get_4_isog_mult_A_sub_mem_single_rd_addr),
  .mult_A_sub_mem_single_dout(mult_A_sub_mem_single_dout),
  .mult_A_add_mem_single_rd_en(get_4_isog_mult_A_add_mem_single_rd_en),  
  .mult_A_add_mem_single_rd_addr(get_4_isog_mult_A_add_mem_single_rd_addr),
  .mult_A_add_mem_single_dout(mult_A_add_mem_single_dout),
  .mult_A_px2_mem_rd_en(mult_A_px2_mem_rd_en),
  .mult_A_px2_mem_rd_addr(mult_A_px2_mem_rd_addr),
  .mult_B_start(get_4_isog_mult_B_start),
  .mult_B_done(mult_B_done),
  .mult_B_busy(mult_B_busy),
  .mult_B_mem_a_0_rd_en(mult_B_mem_a_0_rd_en),
  .mult_B_mem_a_0_rd_addr(mult_B_mem_a_0_rd_addr),
  .mult_B_mem_a_0_dout(get_4_isog_mult_B_mem_a_0_dout),  
  .mult_B_mem_a_1_rd_en(mult_B_mem_a_1_rd_en),
  .mult_B_mem_a_1_rd_addr(mult_B_mem_a_1_rd_addr),
  .mult_B_mem_a_1_dout(get_4_isog_mult_B_mem_a_1_dout),
  .mult_B_mem_b_0_rd_en(mult_B_mem_b_0_rd_en),
  .mult_B_mem_b_0_rd_addr(mult_B_mem_b_0_rd_addr),
  .mult_B_mem_b_0_dout(get_4_isog_mult_B_mem_b_0_dout),
  .mult_B_mem_b_1_rd_en(mult_B_mem_b_1_rd_en),
  .mult_B_mem_b_1_rd_addr(mult_B_mem_b_1_rd_addr),
  .mult_B_mem_b_1_dout(get_4_isog_mult_B_mem_b_1_dout),
  .mult_B_mem_c_1_rd_en(mult_B_mem_c_1_rd_en),
  .mult_B_mem_c_1_rd_addr(mult_B_mem_c_1_rd_addr),
  .mult_B_mem_c_1_dout(get_4_isog_mult_B_mem_c_1_dout),
  .mult_B_sub_mem_single_rd_en(get_4_isog_mult_B_sub_mem_single_rd_en),
  .mult_B_sub_mem_single_rd_addr(get_4_isog_mult_B_sub_mem_single_rd_addr),
  .mult_B_sub_mem_single_dout(mult_B_sub_mem_single_dout),
  .mult_B_add_mem_single_rd_en(get_4_isog_mult_B_add_mem_single_rd_en),  
  .mult_B_add_mem_single_rd_addr(get_4_isog_mult_B_add_mem_single_rd_addr),
  .mult_B_add_mem_single_dout(mult_B_add_mem_single_dout),
  .mult_B_px2_mem_rd_en(mult_B_px2_mem_rd_en),
  .mult_B_px2_mem_rd_addr(mult_B_px2_mem_rd_addr),
  .p_plus_one_mem_rd_addr(get_4_isog_p_plus_one_mem_rd_addr),  
  .px2_mem_rd_addr(get_4_isog_px2_mem_rd_addr),
  .px4_mem_rd_addr(get_4_isog_px4_mem_rd_addr),
  .p_plus_one_mem_dout(p_plus_one_mem_dout),
  .px2_mem_dout(px2_mem_dout),
  .px4_mem_dout(px4_mem_dout),
  .mult_A_mem_b_0_dout_buf(mult_A_mem_b_0_dout_buf),
  .mult_A_mem_b_1_dout_buf(mult_A_mem_b_1_dout_buf),
  .mult_B_mem_b_0_dout_buf(mult_B_mem_b_0_dout_buf),
  .mult_B_mem_b_1_dout_buf(mult_B_mem_b_1_dout_buf),
  .mult_A_used_for_squaring_running(get_4_isog_mult_A_used_for_squaring_running),
  .mult_B_used_for_squaring_running(get_4_isog_mult_B_used_for_squaring_running)
  ); 

xDBLADD_FSM #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) xDBLADD_FSM_inst (
  .rst(rst),
  .clk(clk),
  .start(xDBLADD_start),
  .done(xDBLADD_done),
  .busy(xDBLADD_busy),
  .mem_XP_0_dout(xDBLADD_mem_XP_0_dout),
  .mem_XP_0_rd_en(xDBLADD_mem_XP_0_rd_en),
  .mem_XP_0_rd_addr(xDBLADD_mem_XP_0_rd_addr),
  .mem_XP_1_dout(xDBLADD_mem_XP_1_dout),
  .mem_XP_1_rd_en(xDBLADD_mem_XP_1_rd_en),
  .mem_XP_1_rd_addr(xDBLADD_mem_XP_1_rd_addr),
  .mem_ZP_0_dout(xDBLADD_mem_ZP_0_dout),
  .mem_ZP_0_rd_en(xDBLADD_mem_ZP_0_rd_en),
  .mem_ZP_0_rd_addr(xDBLADD_mem_ZP_0_rd_addr),
  .mem_ZP_1_dout(xDBLADD_mem_ZP_1_dout),
  .mem_ZP_1_rd_en(xDBLADD_mem_ZP_1_rd_en),
  .mem_ZP_1_rd_addr(xDBLADD_mem_ZP_1_rd_addr),
  .mem_XQ_0_dout(xDBLADD_mem_XQ_0_dout),
  .mem_XQ_0_rd_en(xDBLADD_mem_XQ_0_rd_en),
  .mem_XQ_0_rd_addr(xDBLADD_mem_XQ_0_rd_addr),
  .mem_XQ_1_dout(xDBLADD_mem_XQ_1_dout),
  .mem_XQ_1_rd_en(xDBLADD_mem_XQ_1_rd_en),
  .mem_XQ_1_rd_addr(xDBLADD_mem_XQ_1_rd_addr),
  .mem_ZQ_0_dout(xDBLADD_mem_ZQ_0_dout),
  .mem_ZQ_0_rd_en(xDBLADD_mem_ZQ_0_rd_en),
  .mem_ZQ_0_rd_addr(xDBLADD_mem_ZQ_0_rd_addr),
  .mem_ZQ_1_dout(xDBLADD_mem_ZQ_1_dout),
  .mem_ZQ_1_rd_en(xDBLADD_mem_ZQ_1_rd_en),
  .mem_ZQ_1_rd_addr(xDBLADD_mem_ZQ_1_rd_addr),
  .mem_A24_0_dout(xDBLADD_mem_A24_0_dout),
  .mem_A24_0_rd_en(xDBLADD_mem_A24_0_rd_en),
  .mem_A24_0_rd_addr(xDBLADD_mem_A24_0_rd_addr), 
  .mem_A24_1_dout(xDBLADD_mem_A24_1_dout),
  .mem_A24_1_rd_en(xDBLADD_mem_A24_1_rd_en),
  .mem_A24_1_rd_addr(xDBLADD_mem_A24_1_rd_addr),
  .mem_xPQ_0_dout(xDBLADD_mem_xPQ_0_dout),
  .mem_xPQ_0_rd_en(xDBLADD_mem_xPQ_0_rd_en),
  .mem_xPQ_0_rd_addr(xDBLADD_mem_xPQ_0_rd_addr),
  .mem_xPQ_1_dout(xDBLADD_mem_xPQ_1_dout),
  .mem_xPQ_1_rd_en(xDBLADD_mem_xPQ_1_rd_en),
  .mem_xPQ_1_rd_addr(xDBLADD_mem_xPQ_1_rd_addr), 
  .mem_zPQ_0_dout(xDBLADD_mem_zPQ_0_dout),
  .mem_zPQ_0_rd_en(xDBLADD_mem_zPQ_0_rd_en),
  .mem_zPQ_0_rd_addr(xDBLADD_mem_zPQ_0_rd_addr),
  .mem_zPQ_1_dout(xDBLADD_mem_zPQ_1_dout),
  .mem_zPQ_1_rd_en(xDBLADD_mem_zPQ_1_rd_en),
  .mem_zPQ_1_rd_addr(xDBLADD_mem_zPQ_1_rd_addr),
  .mem_t4_0_wr_en(xDBLADD_mem_t4_0_wr_en),
  .mem_t4_0_wr_addr(xDBLADD_mem_t4_0_wr_addr),
  .mem_t4_0_din(xDBLADD_mem_t4_0_din),
  .mem_t4_0_rd_en(xDBLADD_mem_t4_0_rd_en),
  .mem_t4_0_rd_addr(xDBLADD_mem_t4_0_rd_addr),
  .mem_t4_0_dout(mem_t4_0_dout),
  .mem_t4_1_wr_en(xDBLADD_mem_t4_1_wr_en),
  .mem_t4_1_wr_addr(xDBLADD_mem_t4_1_wr_addr),
  .mem_t4_1_din(xDBLADD_mem_t4_1_din),
  .mem_t4_1_rd_en(xDBLADD_mem_t4_1_rd_en),
  .mem_t4_1_rd_addr(xDBLADD_mem_t4_1_rd_addr),
  .mem_t4_1_dout(mem_t4_1_dout),
  .mem_t5_0_wr_en(xDBLADD_mem_t5_0_wr_en),
  .mem_t5_0_wr_addr(xDBLADD_mem_t5_0_wr_addr),
  .mem_t5_0_din(xDBLADD_mem_t5_0_din),
  .mem_t5_0_rd_en(xDBLADD_mem_t5_0_rd_en),
  .mem_t5_0_rd_addr(xDBLADD_mem_t5_0_rd_addr),
  .mem_t5_0_dout(mem_t5_0_dout),
  .mem_t5_1_wr_en(xDBLADD_mem_t5_1_wr_en),
  .mem_t5_1_wr_addr(xDBLADD_mem_t5_1_wr_addr),
  .mem_t5_1_din(xDBLADD_mem_t5_1_din),
  .mem_t5_1_rd_en(xDBLADD_mem_t5_1_rd_en),
  .mem_t5_1_rd_addr(xDBLADD_mem_t5_1_rd_addr),
  .mem_t5_1_dout(mem_t5_1_dout),
  .mem_t6_0_wr_en(xDBLADD_mem_t6_0_wr_en),
  .mem_t6_0_wr_addr(xDBLADD_mem_t6_0_wr_addr),
  .mem_t6_0_din(xDBLADD_mem_t6_0_din),
  .mem_t6_0_rd_en(xDBLADD_mem_t6_0_rd_en),
  .mem_t6_0_rd_addr(xDBLADD_mem_t6_0_rd_addr),
  .mem_t6_0_dout(mem_t6_0_dout),
  .mem_t6_1_wr_en(xDBLADD_mem_t6_1_wr_en),
  .mem_t6_1_wr_addr(xDBLADD_mem_t6_1_wr_addr),
  .mem_t6_1_din(xDBLADD_mem_t6_1_din),
  .mem_t6_1_rd_en(xDBLADD_mem_t6_1_rd_en),
  .mem_t6_1_rd_addr(xDBLADD_mem_t6_1_rd_addr),
  .mem_t6_1_dout(mem_t6_1_dout),
  .mem_t7_0_wr_en(xDBLADD_mem_t7_0_wr_en),
  .mem_t7_0_wr_addr(xDBLADD_mem_t7_0_wr_addr),
  .mem_t7_0_din(xDBLADD_mem_t7_0_din),
  .mem_t7_0_rd_en(xDBLADD_mem_t7_0_rd_en),
  .mem_t7_0_rd_addr(xDBLADD_mem_t7_0_rd_addr),
  .mem_t7_0_dout(mem_t7_0_dout),
  .mem_t7_1_wr_en(xDBLADD_mem_t7_1_wr_en),
  .mem_t7_1_wr_addr(xDBLADD_mem_t7_1_wr_addr),
  .mem_t7_1_din(xDBLADD_mem_t7_1_din),
  .mem_t7_1_rd_en(xDBLADD_mem_t7_1_rd_en),
  .mem_t7_1_rd_addr(xDBLADD_mem_t7_1_rd_addr),
  .mem_t7_1_dout(mem_t7_1_dout),
  .mem_t8_0_wr_en(xDBLADD_mem_t8_0_wr_en),
  .mem_t8_0_wr_addr(xDBLADD_mem_t8_0_wr_addr),
  .mem_t8_0_din(xDBLADD_mem_t8_0_din),
  .mem_t8_0_rd_en(xDBLADD_mem_t8_0_rd_en),
  .mem_t8_0_rd_addr(xDBLADD_mem_t8_0_rd_addr),
  .mem_t8_0_dout(mem_t8_0_dout),
  .mem_t8_1_wr_en(xDBLADD_mem_t8_1_wr_en),
  .mem_t8_1_wr_addr(xDBLADD_mem_t8_1_wr_addr),
  .mem_t8_1_din(xDBLADD_mem_t8_1_din),
  .mem_t8_1_rd_en(xDBLADD_mem_t8_1_rd_en),
  .mem_t8_1_rd_addr(xDBLADD_mem_t8_1_rd_addr),
  .mem_t8_1_dout(mem_t8_1_dout),
  .mem_t9_0_wr_en(xDBLADD_mem_t9_0_wr_en),
  .mem_t9_0_wr_addr(xDBLADD_mem_t9_0_wr_addr),
  .mem_t9_0_din(xDBLADD_mem_t9_0_din),
  .mem_t9_0_rd_en(xDBLADD_mem_t9_0_rd_en),
  .mem_t9_0_rd_addr(xDBLADD_mem_t9_0_rd_addr),
  .mem_t9_0_dout(mem_t9_0_dout),
  .mem_t9_1_wr_en(xDBLADD_mem_t9_1_wr_en),
  .mem_t9_1_wr_addr(xDBLADD_mem_t9_1_wr_addr),
  .mem_t9_1_din(xDBLADD_mem_t9_1_din),
  .mem_t9_1_rd_en(xDBLADD_mem_t9_1_rd_en),
  .mem_t9_1_rd_addr(xDBLADD_mem_t9_1_rd_addr),
  .mem_t9_1_dout(mem_t9_1_dout),
  .mem_t10_0_wr_en(xDBLADD_mem_t10_0_wr_en),
  .mem_t10_0_wr_addr(xDBLADD_mem_t10_0_wr_addr),
  .mem_t10_0_din(xDBLADD_mem_t10_0_din), 
  .mem_t10_1_wr_en(xDBLADD_mem_t10_1_wr_en),
  .mem_t10_1_wr_addr(xDBLADD_mem_t10_1_wr_addr),
  .mem_t10_1_din(xDBLADD_mem_t10_1_din),
  .add_A_start(xDBLADD_add_A_start),
  .add_A_busy(add_A_busy),
  .add_A_done(add_A_done),
  .add_A_cmd(xDBLADD_add_A_cmd),
  .add_A_extension_field_op(xDBLADD_add_A_extension_field_op),
  .add_A_mem_a_0_rd_en(add_A_mem_a_0_rd_en),
  .add_A_mem_a_0_rd_addr(add_A_mem_a_0_rd_addr),
  .add_A_mem_a_0_dout(xDBLADD_add_A_mem_a_0_dout),
  .add_A_mem_a_1_rd_en(add_A_mem_a_1_rd_en),
  .add_A_mem_a_1_rd_addr(add_A_mem_a_1_rd_addr),
  .add_A_mem_a_1_dout(xDBLADD_add_A_mem_a_1_dout),
  .add_A_mem_b_0_rd_en(add_A_mem_b_0_rd_en),
  .add_A_mem_b_0_rd_addr(add_A_mem_b_0_rd_addr),
  .add_A_mem_b_0_dout(xDBLADD_add_A_mem_b_0_dout),
  .add_A_mem_b_1_rd_en(add_A_mem_b_1_rd_en),
  .add_A_mem_b_1_rd_addr(add_A_mem_b_1_rd_addr),
  .add_A_mem_b_1_dout(xDBLADD_add_A_mem_b_1_dout),  
  .add_A_mem_c_0_rd_en(xDBLADD_add_A_mem_c_0_rd_en),
  .add_A_mem_c_0_rd_addr(xDBLADD_add_A_mem_c_0_rd_addr),
  .add_A_mem_c_0_dout(add_A_mem_c_0_dout),
  .add_A_mem_c_1_rd_en(xDBLADD_add_A_mem_c_1_rd_en),
  .add_A_mem_c_1_rd_addr(xDBLADD_add_A_mem_c_1_rd_addr),
  .add_A_mem_c_1_dout(add_A_mem_c_1_dout),
  .add_A_px2_mem_rd_en(add_A_px2_mem_rd_en),
  .add_A_px2_mem_rd_addr(add_A_px2_mem_rd_addr),
  .add_A_px4_mem_rd_en(add_A_px4_mem_rd_en),
  .add_A_px4_mem_rd_addr(add_A_px4_mem_rd_addr),
  .add_B_start(xDBLADD_add_B_start),
  .add_B_busy(add_B_busy),
  .add_B_done(add_B_done),
  .add_B_cmd(xDBLADD_add_B_cmd),
  .add_B_extension_field_op(xDBLADD_add_B_extension_field_op),
  .add_B_mem_a_0_rd_en(add_B_mem_a_0_rd_en),
  .add_B_mem_a_0_rd_addr(add_B_mem_a_0_rd_addr),
  .add_B_mem_a_0_dout(xDBLADD_add_B_mem_a_0_dout),
  .add_B_mem_a_1_rd_en(add_B_mem_a_1_rd_en),
  .add_B_mem_a_1_rd_addr(add_B_mem_a_1_rd_addr),
  .add_B_mem_a_1_dout(xDBLADD_add_B_mem_a_1_dout),
  .add_B_mem_b_0_rd_en(add_B_mem_b_0_rd_en),
  .add_B_mem_b_0_rd_addr(add_B_mem_b_0_rd_addr),
  .add_B_mem_b_0_dout(xDBLADD_add_B_mem_b_0_dout),
  .add_B_mem_b_1_rd_en(add_B_mem_b_1_rd_en),
  .add_B_mem_b_1_rd_addr(add_B_mem_b_1_rd_addr),
  .add_B_mem_b_1_dout(xDBLADD_add_B_mem_b_1_dout),  
  .add_B_mem_c_0_rd_en(xDBLADD_add_B_mem_c_0_rd_en),
  .add_B_mem_c_0_rd_addr(xDBLADD_add_B_mem_c_0_rd_addr),
  .add_B_mem_c_0_dout(add_B_mem_c_0_dout),
  .add_B_mem_c_1_rd_en(xDBLADD_add_B_mem_c_1_rd_en),
  .add_B_mem_c_1_rd_addr(xDBLADD_add_B_mem_c_1_rd_addr),
  .add_B_mem_c_1_dout(add_B_mem_c_1_dout),
  .add_B_px2_mem_rd_en(add_B_px2_mem_rd_en),
  .add_B_px2_mem_rd_addr(add_B_px2_mem_rd_addr),
  .add_B_px4_mem_rd_en(add_B_px4_mem_rd_en),
  .add_B_px4_mem_rd_addr(add_B_px4_mem_rd_addr),
  .mult_A_start(xDBLADD_mult_A_start),
  .mult_A_done(mult_A_done),
  .mult_A_busy(mult_A_busy),
  .mult_A_mem_a_0_rd_en(mult_A_mem_a_0_rd_en),
  .mult_A_mem_a_0_rd_addr(mult_A_mem_a_0_rd_addr),
  .mult_A_mem_a_0_dout(xDBLADD_mult_A_mem_a_0_dout),  
  .mult_A_mem_a_1_rd_en(mult_A_mem_a_1_rd_en),
  .mult_A_mem_a_1_rd_addr(mult_A_mem_a_1_rd_addr),
  .mult_A_mem_a_1_dout(xDBLADD_mult_A_mem_a_1_dout),
  .mult_A_mem_b_0_rd_en(mult_A_mem_b_0_rd_en),
  .mult_A_mem_b_0_rd_addr(mult_A_mem_b_0_rd_addr),
  .mult_A_mem_b_0_dout(xDBLADD_mult_A_mem_b_0_dout),
  .mult_A_mem_b_1_rd_en(mult_A_mem_b_1_rd_en),
  .mult_A_mem_b_1_rd_addr(mult_A_mem_b_1_rd_addr),
  .mult_A_mem_b_1_dout(xDBLADD_mult_A_mem_b_1_dout),
  .mult_A_mem_c_1_rd_en(mult_A_mem_c_1_rd_en),
  .mult_A_mem_c_1_rd_addr(mult_A_mem_c_1_rd_addr),
  .mult_A_mem_c_1_dout(xDBLADD_mult_A_mem_c_1_dout),
  .mult_A_sub_mem_single_rd_en(xDBLADD_mult_A_sub_mem_single_rd_en),
  .mult_A_sub_mem_single_rd_addr(xDBLADD_mult_A_sub_mem_single_rd_addr),
  .mult_A_sub_mem_single_dout(mult_A_sub_mem_single_dout),
  .mult_A_add_mem_single_rd_en(xDBLADD_mult_A_add_mem_single_rd_en),  
  .mult_A_add_mem_single_rd_addr(xDBLADD_mult_A_add_mem_single_rd_addr),
  .mult_A_add_mem_single_dout(mult_A_add_mem_single_dout),
  .mult_A_px2_mem_rd_en(mult_A_px2_mem_rd_en),
  .mult_A_px2_mem_rd_addr(mult_A_px2_mem_rd_addr),
  .mult_B_start(xDBLADD_mult_B_start),
  .mult_B_done(mult_B_done),
  .mult_B_busy(mult_B_busy),
  .mult_B_mem_a_0_rd_en(mult_B_mem_a_0_rd_en),
  .mult_B_mem_a_0_rd_addr(mult_B_mem_a_0_rd_addr),
  .mult_B_mem_a_0_dout(xDBLADD_mult_B_mem_a_0_dout),  
  .mult_B_mem_a_1_rd_en(mult_B_mem_a_1_rd_en),
  .mult_B_mem_a_1_rd_addr(mult_B_mem_a_1_rd_addr),
  .mult_B_mem_a_1_dout(xDBLADD_mult_B_mem_a_1_dout),
  .mult_B_mem_b_0_rd_en(mult_B_mem_b_0_rd_en),
  .mult_B_mem_b_0_rd_addr(mult_B_mem_b_0_rd_addr),
  .mult_B_mem_b_0_dout(xDBLADD_mult_B_mem_b_0_dout),
  .mult_B_mem_b_1_rd_en(mult_B_mem_b_1_rd_en),
  .mult_B_mem_b_1_rd_addr(mult_B_mem_b_1_rd_addr),
  .mult_B_mem_b_1_dout(xDBLADD_mult_B_mem_b_1_dout),
  .mult_B_mem_c_1_rd_en(mult_B_mem_c_1_rd_en),
  .mult_B_mem_c_1_rd_addr(mult_B_mem_c_1_rd_addr),
  .mult_B_mem_c_1_dout(xDBLADD_mult_B_mem_c_1_dout),
  .mult_B_sub_mem_single_rd_en(xDBLADD_mult_B_sub_mem_single_rd_en),
  .mult_B_sub_mem_single_rd_addr(xDBLADD_mult_B_sub_mem_single_rd_addr),
  .mult_B_sub_mem_single_dout(mult_B_sub_mem_single_dout),
  .mult_B_add_mem_single_rd_en(xDBLADD_mult_B_add_mem_single_rd_en),  
  .mult_B_add_mem_single_rd_addr(xDBLADD_mult_B_add_mem_single_rd_addr),
  .mult_B_add_mem_single_dout(mult_B_add_mem_single_dout),
  .mult_B_px2_mem_rd_en(mult_B_px2_mem_rd_en),
  .mult_B_px2_mem_rd_addr(mult_B_px2_mem_rd_addr),
  .p_plus_one_mem_rd_addr(xDBLADD_p_plus_one_mem_rd_addr),  
  .px2_mem_rd_addr(xDBLADD_px2_mem_rd_addr),
  .px4_mem_rd_addr(xDBLADD_px4_mem_rd_addr),
  .p_plus_one_mem_dout(p_plus_one_mem_dout),
  .px2_mem_dout(px2_mem_dout),
  .px4_mem_dout(px4_mem_dout),
  .mult_A_mem_b_0_dout_buf(mult_A_mem_b_0_dout_buf),
  .mult_A_mem_b_1_dout_buf(mult_A_mem_b_1_dout_buf),
  .mult_B_mem_b_0_dout_buf(mult_B_mem_b_0_dout_buf),
  .mult_B_mem_b_1_dout_buf(mult_B_mem_b_1_dout_buf),
  .mult_A_used_for_squaring_running(xDBLADD_mult_A_used_for_squaring_running),
  .mult_B_used_for_squaring_running(xDBLADD_mult_B_used_for_squaring_running)
  ); 

fp2_sub_add_correction #(.RADIX(RADIX), .DIGITS(WIDTH_REAL)) fp2_sub_add_correction_inst_A (
  .start(add_A_start),
  .rst(rst),
  .clk(clk),
  .cmd(add_A_cmd),
  .extension_field_op(add_A_extension_field_op),
  .mem_a_0_rd_en(add_A_mem_a_0_rd_en),
  .mem_a_0_rd_addr(add_A_mem_a_0_rd_addr),
  .mem_a_0_dout(add_A_mem_a_0_dout),
  .mem_a_1_rd_en(add_A_mem_a_1_rd_en),
  .mem_a_1_rd_addr(add_A_mem_a_1_rd_addr),
  .mem_a_1_dout(add_A_mem_a_1_dout),
  .mem_b_0_rd_en(add_A_mem_b_0_rd_en),
  .mem_b_0_rd_addr(add_A_mem_b_0_rd_addr),
  .mem_b_0_dout(add_A_mem_b_0_dout),
  .mem_b_1_rd_en(add_A_mem_b_1_rd_en),
  .mem_b_1_rd_addr(add_A_mem_b_1_rd_addr),
  .mem_b_1_dout(add_A_mem_b_1_dout),
  .mem_c_0_rd_en(add_A_mem_c_0_rd_en),
  .mem_c_0_rd_addr(add_A_mem_c_0_rd_addr),
  .mem_c_0_dout(add_A_mem_c_0_dout), 
  .mem_c_1_rd_en(add_A_mem_c_1_rd_en),
  .mem_c_1_rd_addr(add_A_mem_c_1_rd_addr),
  .mem_c_1_dout(add_A_mem_c_1_dout), 
  .px2_mem_rd_en(add_A_px2_mem_rd_en),
  .px2_mem_rd_addr(add_A_px2_mem_rd_addr),
  .px2_mem_dout(px2_mem_dout),
  .px4_mem_rd_en(add_A_px4_mem_rd_en),
  .px4_mem_rd_addr(add_A_px4_mem_rd_addr),
  .px4_mem_dout(px4_mem_dout),
  .busy(add_A_busy),
  .done(add_A_done)
  );

fp2_sub_add_correction #(.RADIX(RADIX), .DIGITS(WIDTH_REAL)) fp2_sub_add_correction_inst_B (
  .start(add_B_start),
  .rst(rst),
  .clk(clk),
  .cmd(add_B_cmd),
  .extension_field_op(add_B_extension_field_op),
  .mem_a_0_rd_en(add_B_mem_a_0_rd_en),
  .mem_a_0_rd_addr(add_B_mem_a_0_rd_addr),
  .mem_a_0_dout(add_B_mem_a_0_dout),
  .mem_a_1_rd_en(add_B_mem_a_1_rd_en),
  .mem_a_1_rd_addr(add_B_mem_a_1_rd_addr),
  .mem_a_1_dout(add_B_mem_a_1_dout),
  .mem_b_0_rd_en(add_B_mem_b_0_rd_en),
  .mem_b_0_rd_addr(add_B_mem_b_0_rd_addr),
  .mem_b_0_dout(add_B_mem_b_0_dout),
  .mem_b_1_rd_en(add_B_mem_b_1_rd_en),
  .mem_b_1_rd_addr(add_B_mem_b_1_rd_addr),
  .mem_b_1_dout(add_B_mem_b_1_dout),
  .mem_c_0_rd_en(add_B_mem_c_0_rd_en),
  .mem_c_0_rd_addr(add_B_mem_c_0_rd_addr),
  .mem_c_0_dout(add_B_mem_c_0_dout), 
  .mem_c_1_rd_en(add_B_mem_c_1_rd_en),
  .mem_c_1_rd_addr(add_B_mem_c_1_rd_addr),
  .mem_c_1_dout(add_B_mem_c_1_dout), 
  .px2_mem_rd_en(add_B_px2_mem_rd_en),
  .px2_mem_rd_addr(add_B_px2_mem_rd_addr),
  .px2_mem_dout(px2_mem_dout),
  .px4_mem_rd_en(add_B_px4_mem_rd_en),
  .px4_mem_rd_addr(add_B_px4_mem_rd_addr),
  .px4_mem_dout(px4_mem_dout),
  .busy(add_B_busy),
  .done(add_B_done)
  );

// memory storing (p+1)
single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL), .FILE(FILE_CONST_P_PLUS_ONE)) single_port_mem_inst_p_plus_one (  
  .clock(clk),
  .data(0),
  .address(p_plus_one_mem_rd_addr),
  .wr_en(0),
  .q(p_plus_one_mem_dout)
  ); 

// memory storing 2*p
single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL), .FILE(FILE_CONST_PX2)) single_port_mem_inst_px2 (  
  .clock(clk),
  .data(0),
  .address(px2_mem_rd_addr),
  .wr_en(0),
  .q(px2_mem_dout)
  ); 

// memory storing 4*p
single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL), .FILE(FILE_CONST_PX4)) single_port_mem_inst_px4 (  
  .clock(clk),
  .data(0),
  .address(px4_mem_rd_addr),
  .wr_en(1'b0),
  .q(px4_mem_dout)
  );
          
fp2_mont_mul #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) fp2_mont_mul_inst_A (
  .rst(rst),
  .clk(clk),
  .start(mult_A_start),
  .done(mult_A_done),
  .busy(mult_A_busy),
  .mem_a_0_rd_en(mult_A_mem_a_0_rd_en),
  .mem_a_0_rd_addr(mult_A_mem_a_0_rd_addr),
  .mem_a_0_dout(mult_A_mem_a_0_dout),
  .mem_a_1_rd_en(mult_A_mem_a_1_rd_en),
  .mem_a_1_rd_addr(mult_A_mem_a_1_rd_addr),
  .mem_a_1_dout(mult_A_mem_a_1_dout),
  .mem_b_0_rd_en(mult_A_mem_b_0_rd_en),
  .mem_b_0_rd_addr(mult_A_mem_b_0_rd_addr),
  .mem_b_0_dout(mult_A_mem_b_0_dout),
  .mem_b_1_rd_en(mult_A_mem_b_1_rd_en),
  .mem_b_1_rd_addr(mult_A_mem_b_1_rd_addr),
  .mem_b_1_dout(mult_A_mem_b_1_dout),
  .mem_c_1_rd_en(mult_A_mem_c_1_rd_en),
  .mem_c_1_rd_addr(mult_A_mem_c_1_rd_addr),
  .mem_c_1_dout(mult_A_mem_c_1_dout), 
  .sub_mult_mem_res_rd_en(mult_A_sub_mult_mem_res_rd_en),
  .sub_mult_mem_res_rd_addr(mult_A_sub_mult_mem_res_rd_addr),
  .sub_mult_mem_res_dout(mult_A_sub_mult_mem_res_dout),
  .add_mult_mem_res_rd_en(mult_A_add_mult_mem_res_rd_en),
  .add_mult_mem_res_rd_addr(mult_A_add_mult_mem_res_rd_addr),
  .add_mult_mem_res_dout(mult_A_add_mult_mem_res_dout),
  .px2_mem_rd_en(mult_A_px2_mem_rd_en),
  .px2_mem_rd_addr(mult_A_px2_mem_rd_addr),
  .px2_mem_dout(px2_mem_dout)
);

fp2_mont_mul #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) fp2_mont_mul_inst_B (
  .rst(rst),
  .clk(clk),
  .start(mult_B_start),
  .done(mult_B_done),
  .busy(mult_B_busy),
  .mem_a_0_rd_en(mult_B_mem_a_0_rd_en),
  .mem_a_0_rd_addr(mult_B_mem_a_0_rd_addr),
  .mem_a_0_dout(mult_B_mem_a_0_dout),
  .mem_a_1_rd_en(mult_B_mem_a_1_rd_en),
  .mem_a_1_rd_addr(mult_B_mem_a_1_rd_addr),
  .mem_a_1_dout(mult_B_mem_a_1_dout),
  .mem_b_0_rd_en(mult_B_mem_b_0_rd_en),
  .mem_b_0_rd_addr(mult_B_mem_b_0_rd_addr),
  .mem_b_0_dout(mult_B_mem_b_0_dout),
  .mem_b_1_rd_en(mult_B_mem_b_1_rd_en),
  .mem_b_1_rd_addr(mult_B_mem_b_1_rd_addr),
  .mem_b_1_dout(mult_B_mem_b_1_dout),
  .mem_c_1_rd_en(mult_B_mem_c_1_rd_en),
  .mem_c_1_rd_addr(mult_B_mem_c_1_rd_addr),
  .mem_c_1_dout(mult_B_mem_c_1_dout), 
  .sub_mult_mem_res_rd_en(mult_B_sub_mult_mem_res_rd_en),
  .sub_mult_mem_res_rd_addr(mult_B_sub_mult_mem_res_rd_addr),
  .sub_mult_mem_res_dout(mult_B_sub_mult_mem_res_dout),
  .add_mult_mem_res_rd_en(mult_B_add_mult_mem_res_rd_en),
  .add_mult_mem_res_rd_addr(mult_B_add_mult_mem_res_rd_addr),
  .add_mult_mem_res_dout(mult_B_add_mult_mem_res_dout),
  .px2_mem_rd_en(mult_B_px2_mem_rd_en),
  .px2_mem_rd_addr(mult_B_px2_mem_rd_addr),
  .px2_mem_dout(px2_mem_dout)
);

single_to_double_memory_wrapper #(.SINGLE_MEM_WIDTH(RADIX), .SINGLE_MEM_DEPTH(WIDTH_REAL)) single_to_double_memory_wrapper_inst_sub_A (
  .rst(rst),
  .clk(clk),
  .single_mem_rd_en(mult_A_sub_mem_single_rd_en),
  .single_mem_rd_addr(mult_A_sub_mem_single_rd_addr),
  .single_mem_dout(mult_A_sub_mem_single_dout),
  .double_mem_rd_en(mult_A_sub_mult_mem_res_rd_en),
  .double_mem_rd_addr(mult_A_sub_mult_mem_res_rd_addr),
  .double_mem_dout(mult_A_sub_mult_mem_res_dout)
  );

single_to_double_memory_wrapper #(.SINGLE_MEM_WIDTH(RADIX), .SINGLE_MEM_DEPTH(WIDTH_REAL)) single_to_double_memory_wrapper_inst_add_A (
  .rst(rst),
  .clk(clk),
  .single_mem_rd_en(mult_A_add_mem_single_rd_en),
  .single_mem_rd_addr(mult_A_add_mem_single_rd_addr),
  .single_mem_dout(mult_A_add_mem_single_dout),
  .double_mem_rd_en(mult_A_add_mult_mem_res_rd_en),
  .double_mem_rd_addr(mult_A_add_mult_mem_res_rd_addr),
  .double_mem_dout(mult_A_add_mult_mem_res_dout)
  );
 
 single_to_double_memory_wrapper #(.SINGLE_MEM_WIDTH(RADIX), .SINGLE_MEM_DEPTH(WIDTH_REAL)) single_to_double_memory_wrapper_inst_sub_B (
  .rst(rst),
  .clk(clk),
  .single_mem_rd_en(mult_B_sub_mem_single_rd_en),
  .single_mem_rd_addr(mult_B_sub_mem_single_rd_addr),
  .single_mem_dout(mult_B_sub_mem_single_dout),
  .double_mem_rd_en(mult_B_sub_mult_mem_res_rd_en),
  .double_mem_rd_addr(mult_B_sub_mult_mem_res_rd_addr),
  .double_mem_dout(mult_B_sub_mult_mem_res_dout)
  );

single_to_double_memory_wrapper #(.SINGLE_MEM_WIDTH(RADIX), .SINGLE_MEM_DEPTH(WIDTH_REAL)) single_to_double_memory_wrapper_inst_add_B (
  .rst(rst),
  .clk(clk),
  .single_mem_rd_en(mult_B_add_mem_single_rd_en),
  .single_mem_rd_addr(mult_B_add_mem_single_rd_addr),
  .single_mem_dout(mult_B_add_mem_single_dout),
  .double_mem_rd_en(mult_B_add_mult_mem_res_rd_en),
  .double_mem_rd_addr(mult_B_add_mult_mem_res_rd_addr),
  .double_mem_dout(mult_B_add_mult_mem_res_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t4_0 (  
  .clock(clk),
  .data(mem_t4_0_din),
  .address(mem_t4_0_wr_en ? mem_t4_0_wr_addr : mem_t4_0_rd_addr),
  .wr_en(mem_t4_0_wr_en),
  .q(mem_t4_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t4_1 (  
  .clock(clk),
  .data(mem_t4_1_din),
  .address(mem_t4_1_wr_en ? mem_t4_1_wr_addr : mem_t4_1_rd_addr),
  .wr_en(mem_t4_1_wr_en),
  .q(mem_t4_1_dout)
  ); 

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t5_0 (  
  .clock(clk),
  .data(mem_t5_0_din),
  .address(mem_t5_0_wr_en ? mem_t5_0_wr_addr : mem_t5_0_rd_addr),
  .wr_en(mem_t5_0_wr_en),
  .q(mem_t5_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t5_1 (  
  .clock(clk),
  .data(mem_t5_1_din),
  .address(mem_t5_1_wr_en ? mem_t5_1_wr_addr : mem_t5_1_rd_addr),
  .wr_en(mem_t5_1_wr_en),
  .q(mem_t5_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t6_0 (  
  .clock(clk),
  .data(mem_t6_0_din),
  .address(mem_t6_0_wr_en ? mem_t6_0_wr_addr : mem_t6_0_rd_addr),
  .wr_en(mem_t6_0_wr_en),
  .q(mem_t6_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t6_1 (  
  .clock(clk),
  .data(mem_t6_1_din),
  .address(mem_t6_1_wr_en ? mem_t6_1_wr_addr : mem_t6_1_rd_addr),
  .wr_en(mem_t6_1_wr_en),
  .q(mem_t6_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t7_0 (  
  .clock(clk),
  .data(mem_t7_0_din),
  .address(mem_t7_0_wr_en ? mem_t7_0_wr_addr : mem_t7_0_rd_addr),
  .wr_en(mem_t7_0_wr_en),
  .q(mem_t7_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t7_1 (  
  .clock(clk),
  .data(mem_t7_1_din),
  .address(mem_t7_1_wr_en ? mem_t7_1_wr_addr : mem_t7_1_rd_addr),
  .wr_en(mem_t7_1_wr_en),
  .q(mem_t7_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t8_0 (  
  .clock(clk),
  .data(mem_t8_0_din),
  .address(mem_t8_0_wr_en ? mem_t8_0_wr_addr : mem_t8_0_rd_addr),
  .wr_en(mem_t8_0_wr_en),
  .q(mem_t8_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t8_1 (  
  .clock(clk),
  .data(mem_t8_1_din),
  .address(mem_t8_1_wr_en ? mem_t8_1_wr_addr : mem_t8_1_rd_addr),
  .wr_en(mem_t8_1_wr_en),
  .q(mem_t8_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t9_0 (  
  .clock(clk),
  .data(mem_t9_0_din),
  .address(mem_t9_0_wr_en ? mem_t9_0_wr_addr : mem_t9_0_rd_addr),
  .wr_en(mem_t9_0_wr_en),
  .q(mem_t9_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t9_1 (  
  .clock(clk),
  .data(mem_t9_1_din),
  .address(mem_t9_1_wr_en ? mem_t9_1_wr_addr : mem_t9_1_rd_addr),
  .wr_en(mem_t9_1_wr_en),
  .q(mem_t9_1_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t10_0 (  
  .clock(clk),
  .data(mem_t10_0_din),
  .address(mem_t10_0_wr_en ? mem_t10_0_wr_addr : mem_t10_0_rd_addr),
  .wr_en(mem_t10_0_wr_en),
  .q(mem_t10_0_dout)
  );

single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL)) single_port_mem_inst_t10_1 (  
  .clock(clk),
  .data(mem_t10_1_din),
  .address(mem_t10_1_wr_en ? mem_t10_1_wr_addr : mem_t10_1_rd_addr),
  .wr_en(mem_t10_1_wr_en),
  .q(mem_t10_1_dout)
  );


endmodule