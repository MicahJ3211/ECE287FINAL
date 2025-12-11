module seven_segment_suit(
	input wire[1:0]i,
	output reg[6:0]o
);

// HEX out - rewire DE1
//  ---0---
// |       |
// 5       1
// |       |
//  ---6---
// |       |
// 4       2
// |       |
//  ---3---

	always@(*)
		case(i)
			2'b00: // hearts
				o = 7'b0001011;
			2'b01: // clubs
				o = 7'b1000110;
			2'b10: // diamonds
				o = 7'b0100001;
			2'b11: // spades
				o = 7'b0010010;
				
		endcase
		
endmodule
			