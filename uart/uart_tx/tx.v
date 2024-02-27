module tx (clk_fpga, clk_uart, data, tx, flag); //output data

	input clk_uart;
	input clk_fpga;
	input [7:0] data;
	
	output reg tx;
	output reg flag;
	
	integer counter, i, j;
	
	reg [7:0] data_out;
	reg start;
	reg st;
	
	
	initial begin
		
		j = 0;
		st = 0;
		tx = 1'b1;
		counter = 0;
		i = 0;
		start = 0;
		
	end
	
	
	always @(posedge clk_uart) begin
	
		if (start == 0) i = i + 1;
		else i = 1000;
		
		if (i >= 1000) start = 1;
		
		if (start == 1) begin
			counter <= counter + 1;
			if (counter == 11) begin
				counter <= 1;
			end
			
			case (counter)
				1: begin tx = 0; flag = 0; end
				
				2: begin tx = data_out[0]; end
				3: begin tx = data_out[1]; end 
				4: begin tx = data_out[2]; end 
				5: begin tx = data_out[3]; end
				6: begin tx = data_out[4]; end
				7: begin tx = data_out[5]; end
				8: begin tx = data_out[6]; end
				9: begin tx = data_out[7]; end
				
				10: begin tx = 1; data_out <= data; flag = 1; end 		//stop bit
			endcase
		end
		
	end
	
	
endmodule


