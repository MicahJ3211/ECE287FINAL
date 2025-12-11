module seven_segment(
	input wire[3:0]i,
	output reg[6:0]o
);

// HEX out - rewire DE1
//  ---6---
// |       |
// 5       1
// |       |
//  ---0---
// |       |
// 4       2
// |       |
//  ---3---
always@(*)
	begin
		case(i)
		// display 0
			4'b0000: 
				o = 7'b1000000;
			
		// displays 1
			4'b0001: 
				o = 7'b1111001;
				
		// displays 2
			4'b0010: 
				o = 7'b0100100;
				
		// displays 3
			4'b0011: 
				o = 7'b0110000;
		
		// displays 4		
			4'b0100: 
				o = 7'b0011001;
				
		// displays 5
			4'b0101: 
				o = 7'b0010010;
		
		// displays 6
			4'b0110: 
				o = 7'b0000010;
				
		// displays 7
			4'b0111: 
				o = 7'b1111000;
				
		// displays 8
			4'b1000: 
				o = 7'b0000000;
			
		// displays 9
			4'b1001: 
				o = 7'b0011000;
				
		// displays A
			4'b1010:
				o = 7'b0001000;
				
		// displays b
			4'b1011:
				o = 7'b0000011;
				
		// displays C
			4'b1100:
				o = 7'b1000110;
			
			default: 
			// displays 0
				o = 7'b1000000;
		endcase
	end



endmodule