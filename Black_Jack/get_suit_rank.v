module get_suit_rank(
input [1:0]suit_in,
input [3:0]rank_in,

output reg [9:0]suit_out,
output reg [9:0]rank_out
);

parameter QUEEN = 9'd0, //starting position is 0 x 0
          KING = 9'd30, //starting position is 7 x 0 (6 * 5)
          JACK = 9'd65, //starting position is 14 x 0 (13 * 5)
          ACE = 9'd100, //starting position is 21 x 0 (20 * 5)
          UNO = 9'd140, //starting position is 29 x 0 (28 * 5)
          TWO = 9'd170, //starting position is 35 x 0 (34 * 5)
          THREE = 9'd210, //starting position is 43 x 0 (42 * 5)
          FOUR = 9'd240, //starting position is 49 x 0 (48 * 5)
          FIVE = 9'd275, //starting position is 56 x 0 (55 * 5)
          SIX = 9'd310, //starting position is 63 x 0 (62 * 5)
          SEVEN = 9'd345, //starting position is 70 x 0 (69 * 5)
          EIGHT = 9'd380, //starting position is 77 x 0 (76 * 5)
          NINE = 9'd415, //starting position is 84 x 0 (83 * 5)
          TEN = 9'd450; //starting position is 91 x 0 (90 * 5)

parameter SPADES = 9'd0, //starting position is 0 x 0
          CLUBS = 9'd64, //starting position is 9 x 0 (8 * 8)
          DIAMONDS = 9'd136, //starting position is 18 x 0 (17 * 8)
          HEARTS = 9'd208; // starting position is 27 x 0 (27 * 8)

always@(*)
    begin
        case(suit_in)

            00:
                suit_out = HEARTS;
            01:
                suit_out = CLUBS;
            10:
                suit_out = DIAMONDS;
            11:
                suit_out = SPADES;

        endcase

        case(rank_in)

            0001:
                rank_out = ACE;
            0010:
                rank_out = TWO;
            0011:
                rank_out = THREE;
            0100:
                rank_out = FOUR;
            0101:
                rank_out = FIVE;
            0110:
                rank_out = SIX;
            0111:
                rank_out = SEVEN;
            1000:
                rank_out = EIGHT;
            1001:
                rank_out = NINE;
            1010:
                rank_out = TEN;
            1011:
                rank_out = JACK;
            1100:
                rank_out = QUEEN;
            1101:
                rank_out = KING;

        endcase
    end
          

endmodule