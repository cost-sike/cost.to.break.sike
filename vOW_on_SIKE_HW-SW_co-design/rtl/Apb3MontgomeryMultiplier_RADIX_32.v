/* 
FIXME: one potential optimization:
can start the computation once oa0 and oa1 (input a) is initialized in the memory.
reason: only one coefficient of b is needed within the inner j loop.
applies to: small w, for example, w = 32, then each j loop takes round 512/32=16 cycles,
this is possibly enough for sending two coefficients ob0 and 0b1 through the APB bus. 
Other w may not work. Can explore this if we decide to use w <= 32.
*/

// RADIX = 32 = width of Bus 

module Apb3MontgomeryMultiplier 
	#(
  // fixed as 32 in this case = width of APB bus
  parameter RADIX = 32,
  // number of digits
  // WIDTH has to be a multiple of 2
  parameter WIDTH_REAL = 12,
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
  parameter RES_MEM_DEPTH_LOG = `CLOG2(RES_MEM_DEPTH),
  parameter MULT_FILE_CONST = "mem_c_1.mem",
  parameter P2_FILE_CONST = "px2.mem"
  )
  (
    input wire io_mainClk,
    input wire io_systemReset,

    input wire [0:0] io_apb_PSEL,
    input wire io_apb_PENABLE,
    output wire io_apb_PREADY,
    input wire io_apb_PWRITE,
    output wire io_apb_PSLVERROR, 
    input wire [7:0] io_apb_PADDR,
    input wire signed [31:0] io_apb_PWDATA,
    output reg signed [31:0] io_apb_PRDATA 
  );

wire ctrl_doWrite; 
wire ctrl_doRead;
assign ctrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
assign ctrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE)); 
assign io_apb_PREADY = 1'b1;
assign io_apb_PSLVERROR = 1'b0;

// busy = multiplication busy or correction busy
reg busy; 

// memory interface
  // a0, a1, b0, b1, c1 share the same registers for writing interface
reg mem_wr_en;
reg [INPUT_MEM_DEPTH_LOG-1:0] mem_wr_addr;
reg [INPUT_MEM_WIDTH-1:0] mem_din;
 
wire [INPUT_MEM_DEPTH_LOG-1:0] mem_a_0_rd_addr;
wire [INPUT_MEM_WIDTH-1:0] mem_a_0_dout;
reg mem_a_0_wr_en; 
 
wire [INPUT_MEM_DEPTH_LOG-1:0] mem_a_1_rd_addr;
wire [INPUT_MEM_WIDTH-1:0] mem_a_1_dout;
reg mem_a_1_wr_en; 
 
wire [INPUT_MEM_DEPTH_LOG-1:0] mem_b_0_rd_addr;
wire [INPUT_MEM_WIDTH-1:0] mem_b_0_dout;
reg mem_b_0_wr_en; 
 
wire [INPUT_MEM_DEPTH_LOG-1:0] mem_b_1_rd_addr;
wire [INPUT_MEM_WIDTH-1:0] mem_b_1_dout;
reg mem_b_1_wr_en; 
 
wire [INPUT_MEM_DEPTH_LOG-1:0] mem_c_1_rd_addr;
wire [INPUT_MEM_WIDTH-1:0] mem_c_1_dout;
reg mem_c_1_wr_en; 

// interface to Montgomery multiplier
reg mult_rst;
reg mult_start;
  // reading sub and add parts' results share the same set of registers
reg [RES_MEM_DEPTH_LOG-1:0] mult_rd_addr;

// sub part
wire mult_sub_done;
wire mult_sub_busy;
reg mult_sub_res_rd_en;
wire [RES_MEM_WIDTH-1:0] mult_sub_res_dout;
wire mult_sub_negative_res_need_correction;
wire [RADIX-1:0] mult_sub_res_dout_low_buf;



// add part
wire mult_add_done;
wire mult_add_busy;
reg mult_add_res_rd_en; 
wire [RES_MEM_WIDTH-1:0] mult_add_res_dout;

wire mult_sub_a_0_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_sub_a_0_rd_addr; 
wire mult_sub_a_1_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_sub_a_1_rd_addr;
wire mult_sub_b_0_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_sub_b_0_rd_addr; 
wire mult_sub_b_1_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_sub_b_1_rd_addr;
wire mult_sub_c_1_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_sub_c_1_rd_addr;

wire mult_add_a_0_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_add_a_0_rd_addr; 
wire mult_add_a_1_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_add_a_1_rd_addr;
wire mult_add_b_0_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_add_b_0_rd_addr; 
wire mult_add_b_1_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_add_b_1_rd_addr;
wire mult_add_c_1_rd_en;
wire [INPUT_MEM_DEPTH_LOG-1:0] mult_add_c_1_rd_addr;

// sub part: a0[j]*b0[i] - a1[j]*b1[i]
// add part: a0[j]*b1[i] + a1[j]*b0[i]

assign mem_a_0_rd_addr = mult_sub_a_0_rd_addr;   
assign mem_a_1_rd_addr = mem_a_0_rd_addr;
assign mem_b_0_rd_addr = mult_sub_a_1_rd_addr;
assign mem_b_1_rd_addr = mem_b_0_rd_addr;  
assign mem_c_1_rd_addr = mem_a_0_rd_addr;  

// interface to fp_adder
wire adder_start;
reg adder_digit_in_valid;
wire adder_carry_in;
wire [RADIX-1:0] adder_digit_a;
wire [RADIX-1:0] adder_digit_b;
wire adder_digit_out_valid;
wire [RADIX-1:0] adder_digit_res;
wire [RADIX-1:0] adder_digit_res_buf;
wire adder_done;
wire adder_carry_out;

// interface to consts memory storing 2*p
wire [`CLOG2(WIDTH_REAL)-1:0] px2_mem_rd_addr;
wire [RADIX-1:0] px2_mem_dout;

reg correction_running;
reg [`CLOG2(WIDTH_REAL)-1:0] correction_counter;
wire correction_done;

reg odd_even_counter; 
wire correction_mult_sub_res_wr_en;
wire correction_mult_sub_res_rd_en;
reg [RES_MEM_DEPTH_LOG-1:0] correction_mult_sub_wr_addr;
wire [RES_MEM_DEPTH_LOG-1:0] correction_mult_sub_res_rd_addr;
wire [RES_MEM_WIDTH-1:0] correction_mult_sub_res_din;

assign px2_mem_rd_addr = correction_counter;
assign correction_done = correction_mult_sub_res_wr_en & (correction_mult_sub_wr_addr == (RES_MEM_DEPTH-1));

assign correction_mult_sub_res_rd_en = correction_running & ~(odd_even_counter);
assign correction_mult_sub_res_rd_addr = (correction_counter >> 1);
assign correction_mult_sub_res_din = {adder_digit_res_buf, adder_digit_res};

assign adder_carry_in = 1'b0;
assign adder_digit_a = odd_even_counter ? mult_sub_res_dout[RES_MEM_WIDTH-1:RADIX] : mult_sub_res_dout_low_buf;
assign adder_digit_b = mult_sub_negative_res_need_correction ? px2_mem_dout : {RADIX{1'b0}}; 

assign adder_start = mult_sub_done;

always @ (posedge io_mainClk or posedge io_systemReset) begin
    if (io_systemReset) begin 
      correction_running <= 1'b0; 
      correction_counter <= {`CLOG2(WIDTH_REAL){1'b0}};
      adder_digit_in_valid <= 1'b0;
      odd_even_counter <= 1'b0;
      correction_mult_sub_wr_addr <= {RES_MEM_DEPTH_LOG{1'b0}};
      busy <= 1'b0;
    end else begin
      correction_running <= adder_start ? 1'b1 :
                            (correction_counter == (WIDTH_REAL-1)) ? 1'b0 :
                            correction_running;

      correction_counter <= adder_start | correction_done ? {`CLOG2(WIDTH_REAL){1'b0}} :
                            correction_running & (correction_counter < (WIDTH_REAL-1)) ? correction_counter + 1 :
                            correction_counter;

      adder_digit_in_valid <= correction_running;

      odd_even_counter <= adder_start | correction_done ? 1'b0 :
                          ~odd_even_counter; 

      correction_mult_sub_wr_addr <= adder_start ? {RES_MEM_DEPTH_LOG{1'b0}} :
                                     correction_mult_sub_res_wr_en ? correction_mult_sub_wr_addr + 1 :
                                     correction_mult_sub_wr_addr;

      busy <= mult_start ? 1'b1 :
              correction_done ? 1'b0 :
              busy;
    end
end 
 
 // send inputs and write to memories a0, a1, b0, b1, and c1
  always @ (posedge io_mainClk or posedge io_systemReset) begin
    if (io_systemReset) begin 
      mult_rst <= 1'b0;
      mult_start <= 1'b0; 
      mem_a_0_wr_en <= 1'b0;
      mem_a_1_wr_en <= 1'b0;
      mem_b_0_wr_en <= 1'b0;
      mem_b_1_wr_en <= 1'b0;
      mem_c_1_wr_en <= 1'b0;
      mem_wr_en <= 1'b0;
      mem_din <= {INPUT_MEM_WIDTH{1'b0}};
      mem_wr_addr <= {INPUT_MEM_DEPTH_LOG{1'b0}};
    end else begin
      // default values
      mult_rst <= 1'b0;
      mult_start <= 1'b0;
      mem_a_0_wr_en <= 1'b0;
      mem_a_1_wr_en <= 1'b0;
      mem_b_0_wr_en <= 1'b0;
      mem_b_1_wr_en <= 1'b0;
      mem_c_1_wr_en <= 1'b0;
      mem_wr_en <= 1'b0;
      mem_wr_addr <= mem_wr_en & (mem_wr_addr == (INPUT_MEM_DEPTH-1)) ? {INPUT_MEM_DEPTH_LOG{1'b0}} :
                     mem_wr_en ? mem_wr_addr + 1 :
                     mem_wr_addr; 
      mem_din <= io_apb_PWDATA;

      case(io_apb_PADDR)
        7'b0000000 : begin
          // do nothing
        end

        // set reset signal
        // start the computation
        7'b0000100 : begin
          if(ctrl_doWrite) begin 
            mult_rst <= io_apb_PWDATA[0];
            mult_start <= io_apb_PWDATA[1];
          end
        end
    
        // transfer a_0
        7'b0001000 : begin
          if(ctrl_doWrite) begin
            mem_a_0_wr_en <= 1'b1;
            mem_wr_en <= 1'b1;
          end
        end

        7'b0001100 : begin
          if(ctrl_doWrite) begin
            mem_a_1_wr_en <= 1'b1;
            mem_wr_en <= 1'b1;
          end
        end

        7'b0010000 : begin
          if(ctrl_doWrite) begin
            mem_b_0_wr_en <= 1'b1;
            mem_wr_en <= 1'b1;
          end
        end

        7'b0010100 : begin
          if(ctrl_doWrite) begin
            mem_b_1_wr_en <= 1'b1;
            mem_wr_en <= 1'b1;
          end
        end

        // 7'b0011000 : begin
        //   if(ctrl_doWrite) begin
        //     mem_c_1_wr_en <= 1'b1;
        //     mem_wr_en <= 1'b1;
        //   end
        // end
  
        default : begin
        end
      endcase
    end
  end

  always @ (posedge io_mainClk or posedge io_systemReset) begin
    if (io_systemReset) begin 
      mult_rd_addr <= {RES_MEM_DEPTH_LOG{1'b0}};
    end else begin
      mult_rd_addr <= (mult_sub_res_rd_en | mult_add_res_rd_en) & (mult_rd_addr == (RES_MEM_DEPTH-1)) ? {RES_MEM_DEPTH_LOG{1'b0}} :
                      (mult_sub_res_rd_en | mult_add_res_rd_en) ? mult_rd_addr + 1 :
                      mult_rd_addr;
    end
  end
  

  always @ (*) begin
    io_apb_PRDATA = (32'b00000000000000000000000000000000);
    mult_sub_res_rd_en = 1'b0;  
    mult_add_res_rd_en = 1'b0;
    case(io_apb_PADDR)
      7'b0000000 : begin
          // do nothing
        end
      
      // check if the computation is finished
      7'b0000100: begin 
        if (ctrl_doRead) begin
          io_apb_PRDATA = {{31{1'b0}}, busy}; 
        end
      end

      // return the sub result
      7'b0001000: begin
        if (ctrl_doRead) begin
          io_apb_PRDATA = mult_sub_res_dout[RES_MEM_WIDTH-1:RADIX]; // t[2*i]
        end
      end

      7'b0001100: begin
        if (ctrl_doRead) begin
          io_apb_PRDATA = mult_sub_res_dout[RADIX-1:0]; // t[2*i+1]
          mult_sub_res_rd_en = 1'b1;
        end
      end

      // return the add result
      7'b0010000: begin
        if (ctrl_doRead) begin
          io_apb_PRDATA = mult_add_res_dout[RES_MEM_WIDTH-1:RADIX]; // t[2*i] 
        end
      end

      7'b0010100: begin
        if (ctrl_doRead) begin
          io_apb_PRDATA = mult_add_res_dout[RADIX-1:0]; // t[2*i+1] 
          mult_add_res_rd_en = 1'b1;
        end
      end
     
     default : begin
        end
     endcase
  end

// sub: a0[j]*b0[i] - a1[j]*b1[i]
// add: a0[j]*a1[i] - b0[j]*b1[i]

Montgomery_multiplier_sub #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) Montgomery_multiplier_sub_inst (
  .rst(mult_rst),
  .clk(io_mainClk),
  .start(mult_start),
  .done(mult_sub_done),
  .busy(mult_sub_busy),
  .mem_a_0_rd_en(mult_sub_a_0_rd_en),
  .mem_a_0_rd_addr(mult_sub_a_0_rd_addr),
  .mem_a_0_dout(mem_a_0_dout),
  // valid
  .mem_a_1_rd_en(mult_sub_a_1_rd_en),
  .mem_a_1_rd_addr(mult_sub_a_1_rd_addr),
  .mem_a_1_dout(mem_b_0_dout),
  // valid
  .mem_b_0_rd_en(mult_sub_b_0_rd_en),
  .mem_b_0_rd_addr(mult_sub_b_0_rd_addr),
  .mem_b_0_dout(mem_a_1_dout),
  .mem_b_1_rd_en(mult_sub_b_1_rd_en),
  .mem_b_1_rd_addr(mult_sub_b_1_rd_addr),
  .mem_b_1_dout(mem_b_1_dout),
  .mem_c_1_rd_en(mult_sub_c_1_rd_en),
  .mem_c_1_rd_addr(mult_sub_c_1_rd_addr),
  .mem_c_1_dout(mem_c_1_dout),
  .mult_mem_res_rd_en(correction_running ? correction_mult_sub_res_rd_en : mult_sub_res_rd_en),
  .mult_mem_res_rd_addr(correction_running ? correction_mult_sub_res_rd_addr : mult_rd_addr),
  .mult_mem_res_dout(mult_sub_res_dout),
  .mult_mem_res_wr_en(correction_mult_sub_res_wr_en),
  .mult_mem_res_wr_addr(correction_mult_sub_wr_addr),
  .mult_mem_res_din(correction_mult_sub_res_din),
  .negative_res_need_correction(mult_sub_negative_res_need_correction)
  );

fp_adder #(.RADIX(RADIX), .DIGITS(WIDTH_REAL)) fp_adder_inst (
  .start(adder_start),
  .rst(mult_rst),
  .clk(io_mainClk),
  .digit_in_valid(adder_digit_in_valid),
  .carry_in(adder_carry_in),
  .digit_a(adder_digit_a),
  .digit_b(adder_digit_b),
  .digit_out_valid(adder_digit_out_valid),
  .digit_res(adder_digit_res),
  .done(adder_done),
  .carry_out(adder_carry_out)
  );

// memory storing 2*p // FIXME: can ASIC use such ROMs? 
single_port_mem #(.WIDTH(RADIX), .DEPTH(WIDTH_REAL), .FILE(P2_FILE_CONST)) single_port_mem_inst_px2 (  
  .clock(io_mainClk),
  .data(0),
  .address(px2_mem_rd_addr),
  .wr_en(1'b0),
  .q(px2_mem_dout)
  );


Montgomery_multiplier_add #(.RADIX(RADIX), .WIDTH_REAL(WIDTH_REAL)) Montgomery_multiplier_add_inst (
  .rst(mult_rst),
  .clk(io_mainClk),
  .start(mult_start),
  .done(mult_add_done),
  .busy(mult_add_busy),
  .mem_a_0_rd_en(mult_add_a_0_rd_en),
  .mem_a_0_rd_addr(mult_add_a_0_rd_addr),
  .mem_a_0_dout(mem_a_0_dout),
  // valid
  .mem_a_1_rd_en(mult_add_a_1_rd_en),
  .mem_a_1_rd_addr(mult_add_a_1_rd_addr),
  .mem_a_1_dout(mem_b_1_dout),
  // valid
  .mem_b_0_rd_en(mult_add_b_0_rd_en),
  .mem_b_0_rd_addr(mult_add_b_0_rd_addr),
  .mem_b_0_dout(mem_a_1_dout),
  .mem_b_1_rd_en(mult_add_b_1_rd_en),
  .mem_b_1_rd_addr(mult_add_b_1_rd_addr),
  .mem_b_1_dout(mem_b_0_dout),
  .mem_c_1_rd_en(mult_add_c_1_rd_en),
  .mem_c_1_rd_addr(mult_add_c_1_rd_addr),
  .mem_c_1_dout(mem_c_1_dout),
  .mult_mem_res_rd_en(mult_add_res_rd_en),
  .mult_mem_res_rd_addr(mult_rd_addr),
  .mult_mem_res_dout(mult_add_res_dout)
  );

 

// input single-port memories for oa0, oa1, ob0, and ob1
single_port_mem #(.WIDTH(INPUT_MEM_WIDTH), .DEPTH(INPUT_MEM_DEPTH)) single_port_mem_inst_a_0 (  
  .clock(io_mainClk),
  .data(mem_din),
  .address(mem_a_0_wr_en ? mem_wr_addr : mem_a_0_rd_addr),
  .wr_en(mem_a_0_wr_en),
  .q(mem_a_0_dout)
  ); 

single_port_mem #(.WIDTH(INPUT_MEM_WIDTH), .DEPTH(INPUT_MEM_DEPTH)) single_port_mem_inst_a_1 (  
  .clock(io_mainClk),
  .data(mem_din),
  .address(mem_a_1_wr_en ? mem_wr_addr : mem_a_1_rd_addr),
  .wr_en(mem_a_1_wr_en),
  .q(mem_a_1_dout)
  ); 

single_port_mem #(.WIDTH(INPUT_MEM_WIDTH), .DEPTH(INPUT_MEM_DEPTH)) single_port_mem_inst_b_0 (  
  .clock(io_mainClk),
  .data(mem_din),
  .address(mem_b_0_wr_en ? mem_wr_addr : mem_b_0_rd_addr),
  .wr_en(mem_b_0_wr_en),
  .q(mem_b_0_dout)
  ); 


single_port_mem #(.WIDTH(INPUT_MEM_WIDTH), .DEPTH(INPUT_MEM_DEPTH)) single_port_mem_inst_b_1 (  
  .clock(io_mainClk),
  .data(mem_din),
  .address(mem_b_1_wr_en ? mem_wr_addr : mem_b_1_rd_addr),
  .wr_en(mem_b_1_wr_en),
  .q(mem_b_1_dout)
  ); 


// single-port memory storing the constant, 
// FIXME: can ASIC use such ROMs? 
single_port_mem #(.WIDTH(INPUT_MEM_WIDTH), .DEPTH(INPUT_MEM_DEPTH), .FILE(MULT_FILE_CONST)) single_port_mem_inst_c_1 (  
  .clock(io_mainClk),
  .data(mem_din),
  .address(mem_c_1_wr_en ? mem_wr_addr : mem_c_1_rd_addr),
  .wr_en(mem_c_1_wr_en),
  .q(mem_c_1_dout)
  ); 

delay #(.WIDTH(1), .DELAY(3)) delay_inst_correction_mult_sub_wr_en (
  .clk(io_mainClk),
  .rst(mult_rst),
  .din(correction_mult_sub_res_rd_en),
  .dout(correction_mult_sub_res_wr_en)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_adder_digit_res_buf (
  .clk(io_mainClk),
  .rst(mult_rst),
  .din(adder_digit_res),
  .dout(adder_digit_res_buf)
  );

delay #(.WIDTH(RADIX), .DELAY(1)) delay_inst_mult_sub_res_dout_low_buf (
  .clk(io_mainClk),
  .rst(mult_rst),
  .din(mult_sub_res_dout[RADIX-1:0]),
  .dout(mult_sub_res_dout_low_buf)
  );

endmodule