`timescale 1ns / 1ps

module fp_add_and_compare_tb;

parameter RADIX = `RADIX;
parameter DIGITS = `DIGITS;

// inputs
reg rst = 1'b0;
reg clk = 1'b0;
reg start = 1'b0;

reg digit_in_valid = 1'b0;
reg carry_in = 1'b0;
reg [RADIX-1:0] digit_a = 0;
reg [RADIX-1:0] digit_b = 0;

wire digit_out_valid;
wire [RADIX-1:0] digit_res; 
wire a_plus_b_bigger_than_const;
wire done;
wire carry_out;

reg clk_double = 1'b0;

fp_add_and_compare #(.RADIX(RADIX), .DIGITS(DIGITS)) DUT (
  .start(start),
  .rst(rst),
  .clk(clk),
  .digit_in_valid(digit_in_valid),
  .carry_in(carry_in),
  .digit_a(digit_a),
  .digit_b(digit_b),
  .digit_out_valid(digit_out_valid),
  .digit_res(digit_res),
  .a_plus_b_bigger_than_const(a_plus_b_bigger_than_const),
  .done(done),
  .carry_out(carry_out)
  );

initial
  begin
    $dumpfile("fp_add_and_compare_tb.vcd");
    $dumpvars(0, fp_add_and_compare_tb);
  end

integer start_time = 0; 
integer file_a;
integer file_b;
integer scan_file_a;
integer scan_file_b;
integer file_res;
integer file_comp;
integer i;

initial
  begin
    rst <= 1'b0;
    start <= 1'b0; 
    # 45;
    rst <= 1'b1;
    # 20;
    rst <= 1'b0;
    # 100;
    start <= 1'b1;
    start_time = $time;
    $display("\nstart computation");
    # 10;
    start <= 1'b0;

    # 10;
    $display("\nloading inputs a and b");

    // load element a
    file_a = $fopen("Sage_mem_a.txt", "r");
    // load element b
    file_b = $fopen("Sage_mem_b.txt", "r"); 

    // write to result memory
    file_res = $fopen("Simulation_add_res.txt", "w");

    while (!$feof(file_a)) begin
      @(negedge clk);
      for (i=0; i < DIGITS; i=i+1) begin
        // # 40;
        scan_file_a = $fscanf(file_a, "%x\n", digit_a); 
        scan_file_b = $fscanf(file_b, "%x\n", digit_b);
        digit_in_valid <= 1'b1;
        #10;
        digit_in_valid <= 1'b0; 
      end 
    end
    $fclose(file_a);
    $fclose(file_b); 
    $fclose(file_res);

    file_comp = $fopen("Simulation_comp_res.txt", "w");

    // computation finishes
    @(posedge done);
    $display("\ncomptation finished in %0d cycles", ($time-start_time)/10);
    if (a_plus_b_bigger_than_const == 1) begin
      $display("\nSimulation comparison result: a is bigger than b.\n");
      $fwrite(file_comp, "(a+b) is bigger than 2p.\n");
    end
    else begin
      $display("\nSimulation comparison result: a is NOT bigger than b.\n");
      $fwrite(file_comp, "(a+b) is NOT bigger than 2p.\n");
    end

    # 10;
    $fclose(file_comp);

    #1000;
    $finish;
end

always @(clk_double)
  begin 
    if (digit_out_valid) begin
      $fwrite(file_res, "%x\n", digit_res);
    end
  end

// initial begin
//   @(posedge digit_out_valid);
//   for (i=0; i < DIGITS; i=i+1) begin
//     $fwrite(file_res, "%x\n", digit_res);
//     # 10;
//   end
// end

always 
  # 5 clk = !clk;

always @(posedge clk)
  clk_double <= !clk_double;

endmodule 