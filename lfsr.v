module lfsr(input clk, 
				input rst, 
				input [5:0] seed, 
				input en, 
				output reg [5:0] rand);
	always@(posedge clk or negedge rst)
		begin
			if(rst == 1'b0)
				rand <= 6'd0;
			else
				if(en == 0)
					rand <= rand;
				else 
					rand <= {seed[4], seed[3]^seed[2], seed[2], seed[1]^seed[4], seed[0], seed[5]^seed[0]};
		end
endmodule