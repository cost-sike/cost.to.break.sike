module Apb3SHAKE
#(
  // defines the width of the bus which equals to the width of the keccak_top din&dout
	parameter WIDTH = 32
)
(
	input wire [0:0] io_apb_PSEL,
  input wire io_apb_PENABLE,
  output wire io_apb_PREADY,
  input wire io_apb_PWRITE,
  output wire io_apb_PSLVERROR,
  input wire [7:0] io_apb_PADDR, 
  input wire [31:0] io_apb_PWDATA,
  output reg [31:0] io_apb_PRDATA,
   
  input wire io_mainClk,
  input wire io_systemReset
);

assign io_apb_PREADY = 1'b1;
assign io_apb_PSLVERROR = 1'b0;
 
wire ctrl_doWrite; 
wire ctrl_doRead; 

assign ctrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
assign ctrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE)); 

reg cshake_rst = 1'b0;
reg cshake_din_valid = 1'b0;
wire cshake_din_ready;
reg [WIDTH-1:0] cshake_din = {WIDTH{1'b0}};
wire cshake_dout_valid;
reg cshake_dout_ready = 1'b0;
wire [WIDTH-1:0] cshake_dout; 
// reg [WIDTH-1:0] cshake_dout_buf = {WIDTH{1'b0}};

// reg cshake_dout_valid_stay = 1'b0;
// wire cshake_dout_valid_extended;
// assign cshake_dout_valid_extended = cshake_dout_valid || cshake_dout_valid_stay;

keccak_top keccak_top_inst (
	.clk(io_mainClk),
	.rst(cshake_rst),
	.din_valid(cshake_din_valid),
	.din_ready(cshake_din_ready),
  .din(cshake_din),
  .dout_valid(cshake_dout_valid),
  .dout_ready(cshake_dout_ready),
  .dout(cshake_dout)
); 


// send input in
always @ (posedge io_mainClk or posedge io_systemReset) begin
	if (io_systemReset) begin
		cshake_rst <= 1'b0;
	  cshake_din_valid <= 1'b0;
	  cshake_din <= {WIDTH{1'b0}};
    cshake_dout_ready <= 1'b0;
    // cshake_dout_valid_stay <= 1'b0;
    // cshake_dout_buf <= {WIDTH{1'b0}};
	end else begin
		cshake_rst <= 1'b0;
		// cshake_din_valid should stay for one clock cycle
		cshake_din_valid <= (cshake_din_ready == 1'b1) ? 1'b0 : cshake_din_valid;
    // cshake_dout_valid_stay <= cshake_rst ? 1'b0 :
    //                           cshake_dout_valid ? 1'b1 : 
    //                           cshake_dout_valid_stay;
    // cshake_dout_ready
    cshake_dout_ready <= (ctrl_doRead & (io_apb_PADDR == 7'b0001100)) ? 1'b1 : 1'b0;
                         // (cshake_dout_ready && cshake_dout_valid) ? 1'b0 : 
                         // cshake_dout_ready;

    // cshake_dout_buf <= (cshake_dout_ready && cshake_dout_valid) ? cshake_dout : cshake_dout_buf;
	
		case(io_apb_PADDR)
			7'b0000000: begin
	          // do nothing
	        end
	    
	    // set cshake_rst = 1
	    7'b0000100: begin
	    	if (ctrl_doWrite) begin
	    		cshake_rst <= io_apb_PWDATA[0];
          // cshake core is ready for receiving results back 
	    	end
	    end
	    
	    // set cshake_din_valid signal and send in data
	    7'b0001000: begin
	    	if (ctrl_doWrite) begin
          // when cshake_din_ready is true, cshake_din_valid stay high for one clock cycle; otherwise stay high until cshake_din_ready is true
	    		cshake_din_valid <= ((cshake_din_valid == 1'b0) || (cshake_din_ready == 1'b1));
          // cshake_din and cshake_din_valid are synchronous
	    		cshake_din <= io_apb_PWDATA;
	    	end
	    end

	    default : begin
	        end

      endcase
 end
end


// return result out 
always @ (*) begin
    io_apb_PRDATA = (32'b00000000000000000000000000000000);
    case(io_apb_PADDR)
      7'b0000000 : begin
          // do nothing
        end

      // check if the cshake core is ready to accept more data 
      7'b0000100: begin 
        if (ctrl_doRead) begin
          io_apb_PRDATA = {{31{1'b0}}, cshake_din_ready}; 
        end
      end

      
      // check if the cshake computation is finished
      7'b0001000: begin 
        if (ctrl_doRead) begin
          io_apb_PRDATA = {{31{1'b0}}, cshake_dout_valid}; 
        end
      end


      // return the cshake result
      7'b0001100: begin
        if (ctrl_doRead) begin
          // only read out the data when cshake_dout_ready and cshake_dout_valid are both true
          io_apb_PRDATA = cshake_dout;
        end
      end
     
     default : begin
        end
     endcase
  end

endmodule  