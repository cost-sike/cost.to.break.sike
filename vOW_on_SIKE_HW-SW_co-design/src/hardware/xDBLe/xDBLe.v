/* 
Function: repeated doubling function

Follow the steps below:
def xDBLe(X,Z,A24,C24,e):
    # A24 = A+2
    # C24 = 4
    
    t0 = X; t1 = Z
    for i in range(0,e):
        t0,t1 = xDBL(t0,t1,A24,C24)
    return t0,t1
*/

// Assumption: 
// 1: all of the operands are from GF(p^2)
// 2: inputs X, Z, A24, C24 have been initialized before this module is triggered
// 3: when there are parallel add/sub computations, they share the same timing. FIXME, need to double check

module xDBLe 
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

  input wire [7:0] NUM_LOOPS,

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

  // interface with input memory A24
  input wire [SINGLE_MEM_WIDTH-1:0] mem_A24_0_dout,
  output wire mem_A24_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_A24_1_dout,
  output wire mem_A24_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_A24_1_rd_addr,

  // interface with input memory C24
  input wire [SINGLE_MEM_WIDTH-1:0] mem_C24_0_dout,
  output wire mem_C24_0_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_C24_0_rd_addr,

  input wire [SINGLE_MEM_WIDTH-1:0] mem_C24_1_dout,
  output wire mem_C24_1_rd_en,
  output wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_C24_1_rd_addr,
 
  // interface with output memory t6 
  input wire out_mem_t6_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t6_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t6_0_dout,
 
  input wire out_mem_t6_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t6_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t6_1_dout,

  // interface with output memory t7 
  input wire out_mem_t7_0_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_0_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t7_0_dout,
 
  input wire out_mem_t7_1_rd_en,
  input wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_1_rd_addr, 
  output wire [SINGLE_MEM_WIDTH-1:0] mem_t7_1_dout
 
);

// xDBLe specific signals
// interface with  memory X
wire [SINGLE_MEM_WIDTH-1:0] xDBLe_mem_X_0_dout;
wire xDBLe_mem_X_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLe_mem_X_0_rd_addr;

wire [SINGLE_MEM_WIDTH-1:0] xDBLe_mem_X_1_dout;
wire xDBLe_mem_X_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLe_mem_X_1_rd_addr;

// interface with  memory Z
wire [SINGLE_MEM_WIDTH-1:0] xDBLe_mem_Z_0_dout;
wire xDBLe_mem_Z_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLe_mem_Z_0_rd_addr;

wire [SINGLE_MEM_WIDTH-1:0] xDBLe_mem_Z_1_dout;
wire xDBLe_mem_Z_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] xDBLe_mem_Z_1_rd_addr;
 

assign xDBLe_mem_X_0_dout = busy & (counter_for_loops == 0) ? mem_X_0_dout : 
                            busy ? mem_t2_0_dout :
                            0;
assign mem_X_0_rd_en = busy & (counter_for_loops == 0) & xDBLe_mem_X_0_rd_en;
assign mem_X_0_rd_addr = mem_X_0_rd_en ? xDBLe_mem_X_0_rd_addr : 0;

assign xDBLe_mem_X_1_dout = busy & (counter_for_loops == 0) ? mem_X_1_dout : 
                            busy ? mem_t2_1_dout :
                            0;
assign mem_X_1_rd_en = busy & (counter_for_loops == 0) & xDBLe_mem_X_1_rd_en;
assign mem_X_1_rd_addr = mem_X_1_rd_en ? xDBLe_mem_X_1_rd_addr : 0;

assign xDBLe_mem_Z_0_dout = busy & (counter_for_loops == 0) ? mem_Z_0_dout : 
                            busy ? mem_t3_0_dout :
                            0;
assign mem_Z_0_rd_en = busy & (counter_for_loops == 0) & xDBLe_mem_Z_0_rd_en;
assign mem_Z_0_rd_addr = mem_Z_0_rd_en ? xDBLe_mem_Z_0_rd_addr : 0;

assign xDBLe_mem_Z_1_dout = busy & (counter_for_loops == 0) ? mem_Z_1_dout : 
                            busy ? mem_t3_1_dout :
                            0;
assign mem_Z_1_rd_en = busy & (counter_for_loops == 0) & xDBLe_mem_Z_1_rd_en;
assign mem_Z_1_rd_addr = mem_Z_1_rd_en ? xDBLe_mem_Z_1_rd_addr : 0;

// interface with intermediate operands t6 
reg out_mem_t6_0_wr_en;
reg [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t6_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t6_0_din; 

wire out_mem_t6_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t6_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t6_1_din; 

// interface with intermediate operands t7 
wire out_mem_t7_0_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_0_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t7_0_din; 

wire out_mem_t7_1_wr_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] out_mem_t7_1_wr_addr;
wire [SINGLE_MEM_WIDTH-1:0] out_mem_t7_1_din; 

assign out_mem_t6_0_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mem_t2_0_dout : 0;
assign out_mem_t6_1_wr_en = out_mem_t6_0_wr_en;
assign out_mem_t6_1_wr_addr = out_mem_t6_0_wr_addr;
assign out_mem_t6_1_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mem_t2_1_dout : 0;
assign out_mem_t7_0_wr_en = out_mem_t6_0_wr_en;
assign out_mem_t7_0_wr_addr = out_mem_t6_0_wr_addr;
assign out_mem_t7_0_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mem_t3_0_dout : 0;
assign out_mem_t7_1_wr_en = out_mem_t7_0_wr_en;
assign out_mem_t7_1_wr_addr = out_mem_t7_0_wr_addr;
assign out_mem_t7_1_din = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? mem_t3_1_dout : 0;

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
wire mem_t3_0_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_0_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t3_0_dout;
wire mem_t3_1_rd_en;
wire [SINGLE_MEM_DEPTH_LOG-1:0] mem_t3_1_rd_addr;
wire [SINGLE_MEM_WIDTH-1:0] mem_t3_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t4_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t5_1_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_0_dout;
wire [SINGLE_MEM_WIDTH-1:0] mem_t10_1_dout;

assign mem_t2_0_rd_en = (xDBLe_mem_X_0_rd_en & (counter_for_loops > 0)) | T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running;
assign mem_t2_0_rd_addr = (xDBLe_mem_X_0_rd_en & (counter_for_loops > 0)) ? xDBLe_mem_X_0_rd_addr :
                          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? copy_counter : 
                          0;
assign mem_t2_1_rd_en = mem_t2_0_rd_en;
assign mem_t2_1_rd_addr = mem_t2_0_rd_addr;
assign mem_t3_0_rd_en = (xDBLe_mem_Z_0_rd_en & (counter_for_loops > 0)) | T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running;
assign mem_t3_0_rd_addr = (xDBLe_mem_Z_0_rd_en & (counter_for_loops > 0)) ? xDBLe_mem_Z_0_rd_addr :
                          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? copy_counter : 
                          0;
assign mem_t3_1_rd_en = mem_t3_0_rd_en;
assign mem_t3_1_rd_addr = mem_t3_0_rd_addr;

          // input: X, Z, A24, C24, NUM_LOOPS
parameter IDLE                            = 0, 
          // for i in range(0,NUM_LOOPS): 
          //   (X,Z) = xDBL(X,Z,A24,C24)
          xDBL_LOOPS                      = IDLE + 1, 
          // t2 = t0*t0
          // t3 = t1*t1
          T2_COPY_TO_T6_AND_T3_COPY_TO_T7 = xDBL_LOOPS + 1, 
          MAX_STATE                       = T2_COPY_TO_T6_AND_T3_COPY_TO_T7 + 1;

reg [`CLOG2(MAX_STATE)-1:0] state;

reg xDBL_LOOPS_running;
reg T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running;

reg [7:0] counter_for_loops;
 
wire last_copy_write;
reg last_copy_write_buf;
reg [SINGLE_MEM_DEPTH_LOG-1:0] copy_counter;

assign last_copy_write = T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running & (copy_counter == (SINGLE_MEM_DEPTH-1));

always @(posedge clk or posedge rst) begin
  if (rst) begin
    last_copy_write_buf <= 1'b0;
    copy_counter <= 0;
    out_mem_t6_0_wr_en <= 1'b0;
    out_mem_t6_0_wr_addr <= 0;
  end 
  else begin
    last_copy_write_buf <= last_copy_write;
    copy_counter <= (start | last_copy_write | last_copy_write_buf) ? 0 :
                    T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? copy_counter + 1 :
                    copy_counter;
    out_mem_t6_0_wr_en <= (start | (out_mem_t6_0_wr_addr == (SINGLE_MEM_DEPTH-1))) ? 1'b0 : 
                          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? 1'b1 :
                          out_mem_t6_0_wr_en;
    out_mem_t6_0_wr_addr <= T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running ? copy_counter : out_mem_t6_0_wr_addr;
  end
end

reg controller_start;
reg xDBL_start_pre;
wire controller_done;
wire controller_busy;

// finite state machine transitions
always @(posedge clk or posedge rst) begin
  if (rst) begin
    counter_for_loops <= 8'd0; 
    state <= IDLE;
    xDBL_LOOPS_running <= 1'b0;
    T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running <= 1'b0;
    busy <= 1'b0;
    done <= 1'b0;
    controller_start <= 1'b0;
    xDBL_start_pre <= 1'b0;
  end
  else begin 
    done <= 1'b0; 
    controller_start <= 1'b0;
    xDBL_start_pre <= 1'b0;
    case (state) 
      IDLE: 
        if (start | xDBL_start_pre) begin
          state <= xDBL_LOOPS;
          xDBL_LOOPS_running <= 1'b1;
          controller_start <= 1'b1; 
          busy <= 1'b1;
        end
        else begin
          state <= IDLE;
        end

      xDBL_LOOPS: 
        if (controller_done & (counter_for_loops < (NUM_LOOPS-1))) begin
          state <= IDLE;
          xDBL_start_pre <= 1'b1;
          counter_for_loops <= counter_for_loops + 1;
        end
        else if (controller_done & (counter_for_loops == (NUM_LOOPS-1))) begin
          state <= T2_COPY_TO_T6_AND_T3_COPY_TO_T7;
          xDBL_LOOPS_running <= 1'b0;
          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running <= 1'b1;
          counter_for_loops <= 8'd0;
        end
        else begin
          state <= xDBL_LOOPS;
        end

      T2_COPY_TO_T6_AND_T3_COPY_TO_T7: 
        if (last_copy_write_buf) begin
          state <= IDLE;
          T2_COPY_TO_T6_AND_T3_COPY_TO_T7_running <= 1'b0;
          busy <= 1'b0; 
          done <= 1'b1;
        end
        else begin
          state <= T2_COPY_TO_T6_AND_T3_COPY_TO_T7;
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
  .function_encoded(8'd1),
  .start(controller_start),
  .done(controller_done),
  .busy(controller_busy), 
  .xDBL_mem_X_0_dout(xDBLe_mem_X_0_dout),
  .xDBL_mem_X_0_rd_en(xDBLe_mem_X_0_rd_en),
  .xDBL_mem_X_0_rd_addr(xDBLe_mem_X_0_rd_addr),
  .xDBL_mem_X_1_dout(xDBLe_mem_X_1_dout),
  .xDBL_mem_X_1_rd_en(xDBLe_mem_X_1_rd_en),
  .xDBL_mem_X_1_rd_addr(xDBLe_mem_X_1_rd_addr),
  .xDBL_mem_Z_0_dout(xDBLe_mem_Z_0_dout),
  .xDBL_mem_Z_0_rd_en(xDBLe_mem_Z_0_rd_en),
  .xDBL_mem_Z_0_rd_addr(xDBLe_mem_Z_0_rd_addr),
  .xDBL_mem_Z_1_dout(xDBLe_mem_Z_1_dout),
  .xDBL_mem_Z_1_rd_en(xDBLe_mem_Z_1_rd_en),
  .xDBL_mem_Z_1_rd_addr(xDBLe_mem_Z_1_rd_addr),
  .xDBL_mem_A24_0_dout(mem_A24_0_dout),
  .xDBL_mem_A24_0_rd_en(mem_A24_0_rd_en),
  .xDBL_mem_A24_0_rd_addr(mem_A24_0_rd_addr), 
  .xDBL_mem_A24_1_dout(mem_A24_1_dout),
  .xDBL_mem_A24_1_rd_en(mem_A24_1_rd_en),
  .xDBL_mem_A24_1_rd_addr(mem_A24_1_rd_addr),
  .xDBL_mem_C24_0_dout(mem_C24_0_dout),
  .xDBL_mem_C24_0_rd_en(mem_C24_0_rd_en),
  .xDBL_mem_C24_0_rd_addr(mem_C24_0_rd_addr),
  .xDBL_mem_C24_1_dout(mem_C24_1_dout),
  .xDBL_mem_C24_1_rd_en(mem_C24_1_rd_en),
  .xDBL_mem_C24_1_rd_addr(mem_C24_1_rd_addr),
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
  .out_mem_t5_0_rd_en(0),
  .out_mem_t5_0_rd_addr(0),
  .mem_t5_0_dout(mem_t5_0_dout),
  .out_mem_t5_1_rd_en(0),
  .out_mem_t5_1_rd_addr(0),
  .mem_t5_1_dout(mem_t5_1_dout),
  .out_mem_t6_0_wr_en(out_mem_t6_0_wr_en),
  .out_mem_t6_0_wr_addr(out_mem_t6_0_wr_addr),
  .out_mem_t6_0_din(out_mem_t6_0_din),
  .out_mem_t6_0_rd_en(out_mem_t6_0_rd_en),
  .out_mem_t6_0_rd_addr(out_mem_t6_0_rd_addr),
  .mem_t6_0_dout(mem_t6_0_dout),
  .out_mem_t6_1_wr_en(out_mem_t6_1_wr_en),
  .out_mem_t6_1_wr_addr(out_mem_t6_1_wr_addr),
  .out_mem_t6_1_din(out_mem_t6_1_din),
  .out_mem_t6_1_rd_en(out_mem_t6_1_rd_en),
  .out_mem_t6_1_rd_addr(out_mem_t6_1_rd_addr),
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
  .out_mem_t10_0_rd_en(0),
  .out_mem_t10_0_rd_addr(0),
  .mem_t10_0_dout(mem_t10_0_dout),
  .out_mem_t10_1_rd_en(0),
  .out_mem_t10_1_rd_addr(0),
  .mem_t10_1_dout(mem_t10_1_dout)
  ); 
 
endmodule