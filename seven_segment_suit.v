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
				o = 1001000;
			2'b01: // clubs
				o = 0110000;
			2'b10: // diamonds
				o = 1000010;
			2'b11: // spades
				o = 0100100;
				
		endcase
		
endmodule
			