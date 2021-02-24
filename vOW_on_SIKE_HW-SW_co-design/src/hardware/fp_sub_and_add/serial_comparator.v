
// compare two large input values and output the comparison result
// inputs: A, B, both are positive values
// output:
//  if A > B, res = 1
//  else,      res = 0
// output signals are all buffered already

// idea behind this module, here is a motivation sample:
// A = (a3, a2, a1, a0), B = (b3, b2, b1, b0)
// (A > B) = (a3 > b3) |
//           ((a3 == b3) & (a2 > b2)) |
//           ((a3 == b3) & (a2 == b2) & (a1 > b1)) |
//           ((a3 == b3) & (a2 == b2) & (a1 == b1) & (a0 > b0))

module serial_comparator 
#(
  parameter RADIX = 32,
  parameter DIGITS = 14
  )
(
  input wire start,
  input wire rst,
  input wire clk,

  input wire digit_valid,
  // input value A
  input wire [RADIX-1:0] digit_a, 
  // input value B
  input wire [RADIX-1:0] digit_b, 
  // comparison result
  output reg a_bigger_than_b,
  output reg done
);

reg comp_array [DIGITS-1:0];

reg [`CLOG2(DIGITS)-1:0] counter;

reg running;

reg done_buf;

wire digit_a_bigger_than_b;
wire digit_a_equal_to_b;

assign digit_a_bigger_than_b = digit_valid & (digit_a > digit_b);
assign digit_a_equal_to_b = digit_valid & (digit_a == digit_b); 

always @(posedge clk) begin
  if (rst) begin
    comp_array[0] <= 1'b0;
    comp_array[1] <= 1'b0;
    comp_array[2] <= 1'b0;
    comp_array[3] <= 1'b0;
    comp_array[4] <= 1'b0;
    comp_array[5] <= 1'b0;
    comp_array[6] <= 1'b0;
    comp_array[7] <= 1'b0;
    comp_array[8] <= 1'b0;
    comp_array[9] <= 1'b0;
    comp_array[10] <= 1'b0;
    comp_array[11] <= 1'b0;
    comp_array[12] <= 1'b0;
    comp_array[13] <= 1'b0;
  end
  else begin
    comp_array[0] <= digit_valid & (counter == 0) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[0] & digit_a_equal_to_b :
                     comp_array[0];

    comp_array[1] <= digit_valid & (counter == 1) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[1] & digit_a_equal_to_b :
                     comp_array[1];

    comp_array[2] <= digit_valid & (counter == 2) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[2] & digit_a_equal_to_b :
                     comp_array[2];

    comp_array[3] <= digit_valid & (counter == 3) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[3] & digit_a_equal_to_b :
                     comp_array[3];

    comp_array[4] <= digit_valid & (counter == 4) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[4] & digit_a_equal_to_b :
                     comp_array[4];

    comp_array[5] <= digit_valid & (counter == 5) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[5] & digit_a_equal_to_b :
                     comp_array[5];

    comp_array[6] <= digit_valid & (counter == 6) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[6] & digit_a_equal_to_b :
                     comp_array[6];

    comp_array[7] <= digit_valid & (counter == 7) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[7] & digit_a_equal_to_b :
                     comp_array[7];

    comp_array[8] <= digit_valid & (counter == 8) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[8] & digit_a_equal_to_b :
                     comp_array[8];

    comp_array[9] <= digit_valid & (counter == 9) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[9] & digit_a_equal_to_b :
                     comp_array[9];

    comp_array[10] <= digit_valid & (counter == 10) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[10] & digit_a_equal_to_b :
                     comp_array[10];

    comp_array[11] <= digit_valid & (counter == 11) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[11] & digit_a_equal_to_b :
                     comp_array[11];

    comp_array[12] <= digit_valid & (counter == 12) ? digit_a_bigger_than_b :
                     digit_valid ? comp_array[12] & digit_a_equal_to_b :
                     comp_array[12];

    comp_array[13] <= digit_valid & (counter == 13) ? digit_a_bigger_than_b : comp_array[13];
  end
end


always @(posedge clk) begin
  if (rst) begin
    running <= 1'b0;
    done_buf <= 1'b0;
    done <= 1'b0;
    a_bigger_than_b <= 1'b0;
    counter <= {`CLOG2(DIGITS){1'b0}};
  end 
  else begin
    running <= done ? 1'b0 :
               start ? 1'b1 :
               running;

    counter <= done ? {`CLOG2(DIGITS){1'b0}} :
               (start | running) & digit_valid ? counter + 1 :
               counter;

    done_buf <= digit_valid & (counter == (DIGITS-1)) ? 1'b1 : 1'b0;
    done <= done_buf;

    a_bigger_than_b <= comp_array[0] | comp_array[1] | comp_array[2] | comp_array[3] | comp_array[4] | comp_array[5] | comp_array[6] | comp_array[7] | comp_array[8] | comp_array[9] | comp_array[10] | comp_array[11] | comp_array[12] | comp_array[13];
  end
end

wire comp_array_0;
wire comp_array_1;
wire comp_array_2;
wire comp_array_3;
wire comp_array_4;
wire comp_array_5;
wire comp_array_6;
wire comp_array_7;
wire comp_array_8;
wire comp_array_9;
wire comp_array_10;
wire comp_array_11;
wire comp_array_12;
wire comp_array_13;
assign comp_array_0 = comp_array[0];
assign comp_array_1 = comp_array[1];
assign comp_array_2 = comp_array[2];
assign comp_array_3 = comp_array[3];
assign comp_array_4 = comp_array[4];
assign comp_array_5 = comp_array[5];
assign comp_array_6 = comp_array[6];
assign comp_array_7 = comp_array[7];
assign comp_array_8 = comp_array[8];
assign comp_array_9 = comp_array[9];
assign comp_array_10 = comp_array[10];
assign comp_array_11 = comp_array[11];
assign comp_array_12 = comp_array[12];
assign comp_array_13 = comp_array[13];
endmodule


