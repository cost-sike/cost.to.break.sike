// multi-precision Montgomery multiplier, half of Fp^2 multiplication
// pipelined, one multiplication is done at a time
// Based on unified FIOS algorithm
// Current version only does the subtraction part, can be easily modified to support addition as well // FXIME

// inner loop: (carry_out, sum) = a_0*a_1 + b_0*b_1 + c_0*c_1 + d + carry_in

module Montgomery_multiplier_sub
#(
  // size of one digit
  // w = 8/16/32/64/128, etc
  parameter RADIX = 32,
  // number of digits
  // WIDTH has to be a multiple of 2
  parameter WIDTH_REAL = 14,
  parameter WIDTH = ((WIDTH_REAL+1)/2)*2, 
  parameter WIDTH_LOG = `CLOG2(WIDTH),
  // parameter WIDTH_REAL_IS_ODD = (WIDTH > WIDTH_REAL) ? 1 : 0, 
  // parameters for memories holding inputs
  parameter INPUT_MEM_WIDTH = RADIX,
  parameter INPUT_MEM_DEPTH = WIDTH_REAL,
  parameter INPUT_MEM_DEPTH_LOG = `CLOG2(INPUT_MEM_DEPTH),
  // t[2*i] and t[2*i+1] are stored in one memory entry
  parameter RES_MEM_WIDTH = 2*RADIX,
  parameter RES_MEM_DEPTH = WIDTH/2,
  parameter RES_MEM_DEPTH_LOG = `CLOG2(RES_MEM_DEPTH)
  )
( 
  
  input  wire rst,
  input  wire clk,
  input  wire start, // one clock high
  output wire done, // one clock high
  output wire busy,

  // memory interface with inputs  
  output wire mem_a_0_rd_en,
  output reg [INPUT_MEM_DEPTH_LOG-1:0] mem_a_0_rd_addr,
  input  wire [INPUT_MEM_WIDTH-1:0] mem_a_0_dout,

  output wire mem_a_1_rd_en,
  output reg [INPUT_MEM_DEPTH_LOG-1:0] mem_a_1_rd_addr,
  input  wire [INPUT_MEM_WIDTH-1:0] mem_a_1_dout,

  output wire mem_b_0_rd_en,
  output wire [INPUT_MEM_DEPTH_LOG-1:0] mem_b_0_rd_addr,
  input  wire [INPUT_MEM_WIDTH-1:0] mem_b_0_dout,

  output wire mem_b_1_rd_en,
  output wire [INPUT_MEM_DEPTH_LOG-1:0] mem_b_1_rd_addr,
  input  wire [INPUT_MEM_WIDTH-1:0] mem_b_1_dout,

  output wire mem_c_1_rd_en,
  output wire [INPUT_MEM_DEPTH_LOG-1:0] mem_c_1_rd_addr,
  input  wire [INPUT_MEM_WIDTH-1:0] mem_c_1_dout, 
 
  // interface with the result memory
  input  wire mult_mem_res_rd_en,
  input  wire [RES_MEM_DEPTH_LOG-1:0] mult_mem_res_rd_addr,  
  output wire [RES_MEM_WIDTH-1:0] mult_mem_res_dout,
  
  input wire mult_mem_res_wr_en,
  input  wire [RES_MEM_DEPTH_LOG-1:0] mult_mem_res_wr_addr,
  input wire [RES_MEM_WIDTH-1:0] mult_mem_res_din,

  output reg negative_res_need_correction // 1: the subtraction part's result is negative, and need correction; otherwise does not need correction
  );

wire width_real_is_odd;
assign width_real_is_odd = (WIDTH > WIDTH_REAL) ? 1'b1 : 1'b0; 

// last step_din_d
reg step_din_d_last; 

reg odd_even_counter; 
reg running;

reg [WIDTH_LOG-1:0] round_counter;
reg [`CLOG2(WIDTH+2)-1:0] step_counter; 
reg round_done;

// This version separates the logic of memory and computation fully to ensure a high Fmax
// interface with the step module
wire [RADIX-1:0] step_din_a_0;
wire [RADIX-1:0] step_din_a_1;
wire [RADIX-1:0] step_din_b_0;
wire [RADIX-1:0] step_din_b_1; 
wire [RADIX-1:0] step_din_c_0;
wire [RADIX-1:0] step_din_c_1;
wire [RADIX-1:0] step_din_d;
wire [RADIX+1:0] step_din_carry_in;
wire [RADIX-1:0] step_dout_sum;
wire [RADIX+1:0] step_dout_carry_out;

wire [RADIX-1:0] step_dout_sum_comb; // step_dout_sum <= step_dout_sum_comb;
wire [RADIX-1:0] step_dout_sum_buf;
reg [RADIX-1:0] sum_step_0_buf;
wire [RADIX+1:0] step_dout_carry_out_buf;
wire [RADIX+1:0] step_dout_carry_out_buf_buf;
 
reg mem_res_rd_running;
wire mem_res_wr_running;
wire mem_res_rd_en;
wire mem_res_wr_en;
wire [RES_MEM_WIDTH-1:0] mem_res_din;
wire [RES_MEM_DEPTH_LOG-1:0] mem_res_wr_addr;
wire [RES_MEM_DEPTH_LOG-1:0] mem_res_rd_addr;
wire [RES_MEM_WIDTH-1:0] mem_res_dout;
wire [RADIX-1:0] mem_res_dout_left; // t[2*i]
wire [RADIX-1:0] mem_res_dout_left_buf; // t[2*i+1]
wire [RADIX-1:0] mem_res_dout_right;
wire [RADIX-1:0] mem_res_dout_right_buf_buf;
 
assign busy = running;

assign mem_res_rd_en = mem_res_rd_running & (~odd_even_counter);
assign mem_res_wr_en = mem_res_wr_running & odd_even_counter;
assign mem_res_rd_addr = (step_counter < WIDTH) ? (step_counter >> 1) :
                         {RES_MEM_DEPTH_LOG{1'b0}};
assign mem_res_dout_left = mem_res_dout[RES_MEM_WIDTH-1:RADIX]; // t[2*i]
assign mem_res_dout_right = mem_res_dout[RADIX-1:0]; // t[2*i+1]

assign mem_res_din = (width_real_is_odd & (mem_res_wr_addr == (RES_MEM_DEPTH-1))) ? {{step_dout_carry_out_buf_buf[RADIX-1:0]}, {RADIX{1'b0}}} :
                     ((~width_real_is_odd) & (mem_res_wr_addr == (RES_MEM_DEPTH-1))) ? {step_dout_sum_buf, {step_dout_carry_out_buf[RADIX-1:0]}} :
                     {step_dout_sum_buf, step_dout_sum};
 
// memory interface to a_0
assign mem_a_0_rd_en = running;  
// memory interface to a_1
assign mem_a_1_rd_en = running; 
// memory interface to b_0
assign mem_b_0_rd_en = running;
assign mem_b_0_rd_addr = mem_a_0_rd_addr;
// memory interface to b_1
assign mem_b_1_rd_en = running;
assign mem_b_1_rd_addr = mem_a_1_rd_addr;
// memory interface to c_1
assign mem_c_1_rd_en = running;
assign mem_c_1_rd_addr = mem_a_0_rd_addr; 

assign step_din_c_0 = sum_step_0_buf; // 0 or mm   

assign step_din_d = (round_counter == {WIDTH_LOG{1'b0}}) ? {RADIX{1'b0}} : // first round = 0
                    (step_counter == 1) ? mem_res_dout_left :
                    odd_even_counter ? mem_res_dout_right_buf_buf :
                    mem_res_dout_left_buf;

assign step_din_carry_in = (step_counter < 2) ? {(RADIX+2){1'b0}} :
                           (step_counter == 3) ? step_dout_carry_out_buf :
                           step_dout_carry_out;

assign mult_mem_res_dout = mem_res_dout;
 
always @(posedge clk) begin
  if (rst) begin
    odd_even_counter <= 1'b0;
    running <= 1'b0;
    round_counter <= {WIDTH_LOG{1'b0}};
    step_counter <= {(`CLOG2(WIDTH+2)){1'b0}}; 
    mem_res_rd_running <= 1'b0;  
    mem_a_0_rd_addr <= {INPUT_MEM_DEPTH_LOG{1'b0}}; 
    mem_a_1_rd_addr <= {INPUT_MEM_DEPTH_LOG{1'b0}}; 
    sum_step_0_buf <= {RADIX{1'b0}}; 
    step_din_d_last <= 1'b0;
    round_done <= 1'b0; 
    negative_res_need_correction <= 1'b0;
  end
  else begin
    running <= start ? 1'b1 :
               done ? 1'b0 :
               running; 

    mem_a_0_rd_addr <= done ? {INPUT_MEM_DEPTH_LOG{1'b0}} :
                       start | (step_counter == (WIDTH+1)) ? mem_a_0_rd_addr + 1 :
                       (mem_a_0_rd_addr == (WIDTH_REAL-1)) ? {INPUT_MEM_DEPTH_LOG{1'b0}} :
                       (mem_a_0_rd_addr > 0) ? mem_a_0_rd_addr + 1 :
                       mem_a_0_rd_addr;

    step_counter <= (start | round_done | done) ? {WIDTH_LOG{1'b0}} :
                    running ? step_counter + 1 :
                    step_counter;

    round_counter <= (start | done | ((step_counter == (WIDTH+1)) & (round_counter == (WIDTH_REAL-1)))) ?  {WIDTH_LOG{1'b0}} :
                      round_done ? round_counter + 1 :
                      round_counter;

    round_done <= (step_counter == WIDTH); 

    mem_a_1_rd_addr <= (start | done) ? {INPUT_MEM_DEPTH_LOG{1'b0}} :
                       (mem_a_0_rd_addr == (WIDTH_REAL-1)) ? mem_a_1_rd_addr + 1 :
                       mem_a_1_rd_addr;

    mem_res_rd_running <= (start | (round_done & (round_counter < (WIDTH_REAL-1)))) ? 1'b1 :
                          (step_counter == (WIDTH-1)) ? 1'b0 :
                          mem_res_rd_running;

    odd_even_counter <= (start | done | round_done) ? 1'b0 :
                        running ? ~odd_even_counter :
                        odd_even_counter; 
  
    sum_step_0_buf <= (start | round_done | done) ? {RADIX{1'b0}} :
                      (step_counter == 1) ?  step_dout_sum_comb :
                      sum_step_0_buf;
    
    step_din_d_last <= (step_counter == WIDTH_REAL); 

    negative_res_need_correction <= start ? 1'b0 :
                                    done & width_real_is_odd ? mem_res_din[RES_MEM_WIDTH-1] :
                                    done & (~width_real_is_odd) ? mem_res_din[RADIX-1] :
                                    negative_res_need_correction;
 
  end
end

 
  
step_sub #(.RADIX(RADIX)) step_inst (
  .rst(rst),
  .clk(clk),
  .a_0(step_din_a_0),
  .a_1(step_din_a_1),
  .b_0(step_din_b_0),
  .b_1(step_din_b_1),
  .c_0(step_din_c_0),
  .c_1(step_din_c_1),
  .d(step_din_d),
  .d_last(step_din_d_last),
  .carry_in(step_din_carry_in),
  .sum_comb(step_dout_sum_comb),
  .sum(step_dout_sum),
  .carry_out(step_dout_carry_out)
  );


// result for multiplication  
single_port_mem #(.WIDTH(RES_MEM_WIDTH), .DEPTH(RES_MEM_DEPTH)) single_port_mem_inst_res (  
  .clock(clk),
  .data(mem_res_wr_en ? mem_res_din : mult_mem_res_din),
  .address(mem_res_wr_en ? mem_res_wr_addr : (mult_mem_res_wr_en ? mult_mem_res_wr_addr : (running ? mem_res_rd_addr : mult_mem_res_rd_addr))),
  .wr_en(mem_res_wr_en | mult_mem_res_wr_en),
  .q(mem_res_dout)
  ); 
 

delay #(.WIDTH(1), .DELAY(4)) delay_inst_mem_res_wr_running (
  .clk(clk),
  .rst(rst),
  .din(mem_res_rd_running),
  .dout(mem_res_wr_running)
  );

delay #(.WIDTH(RES_MEM_DEPTH_LOG), .DELAY(5)) delay_inst_mem_res_wr_addr (
  .clk(clk),
  .rst(rst),
  .din(mem_res_rd_addr),
  .dout(mem_res_wr_addr)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_mem_res_dout_left_buf (
  .clk(clk),
  .rst(rst),
  .din(mem_res_dout_left),
  .dout(mem_res_dout_left_buf)
  );

delay #(.WIDTH(RADIX), .DELAY(2)) delay_inst_mem_res_dout_right_buf_buf (
  .clk(clk),
  .rst(rst),
  .din(mem_res_dout_right),
  .dout(mem_res_dout_right_buf_buf)
  );

 
delay #(.WIDTH(RADIX+2), .DELAY(1)) delay_inst_step_dout_carry_out_buf (
  .clk(clk),
  .rst(rst),
  .din(step_dout_carry_out), 
  .dout(step_dout_carry_out_buf)
  ); 

delay #(.WIDTH(RADIX+2), .DELAY(1)) delay_inst_step_dout_carry_out_buf_buf (
  .clk(clk),
  .rst(rst),
  .din(step_dout_carry_out_buf), 
  .dout(step_dout_carry_out_buf_buf)
  ); 

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_step_dout_sum_buf (
  .clk(clk),
  .rst(rst),
  .din(step_dout_sum),
  .dout(step_dout_sum_buf)
  ); 

delay #(.WIDTH(1), .DELAY(2)) delay_inst_done (
  .clk(clk),
  .rst(rst),
  .din((step_counter == (WIDTH+1)) & (round_counter == (WIDTH_REAL-1))),
  .dout(done)
  ); 

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_step_din_a_0 (
  .clk(clk),
  .rst(rst),
  .din(mem_a_0_dout),
  .dout(step_din_a_0)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_step_din_a_1 (
  .clk(clk),
  .rst(rst),
  .din(mem_a_1_dout),
  .dout(step_din_a_1)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_step_din_b_0 (
  .clk(clk),
  .rst(rst),
  .din(mem_b_0_dout),
  .dout(step_din_b_0)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_step_din_b_1 (
  .clk(clk),
  .rst(rst),
  .din(mem_b_1_dout),
  .dout(step_din_b_1)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_step_din_c_1 (
  .clk(clk),
  .rst(rst),
  .din(mem_c_1_dout),
  .dout(step_din_c_1)
  ); 


endmodule