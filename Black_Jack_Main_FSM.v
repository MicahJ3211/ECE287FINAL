module FinalProjectLogic(
	//////////// ADC //////////
	//output		          		ADC_CONVST,
	//output		          		ADC_DIN,
	//input 		          		ADC_DOUT,
	//output		          		ADC_SCLK,

	//////////// Audio //////////
	//input 		          		AUD_ADCDAT,
	//inout 		          		AUD_ADCLRCK,
	//inout 		          		AUD_BCLK,
	//output		          		AUD_DACDAT,
	//inout 		          		AUD_DACLRCK,
	//output		          		AUD_XCK,

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		          		DRAM_LDQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_UDQM,
	//output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	//output		          		FPGA_I2C_SCLK,
	//inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	//inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	//inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	//output		          		VGA_BLANK_N,
	//output		     [7:0]		VGA_B,
	//output		          		VGA_CLK,
	//output		     [7:0]		VGA_G,
	//output		          		VGA_HS,
	//output		     [7:0]		VGA_R,
	//output		          		VGA_SYNC_N,
	//output		          		VGA_VS,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1
);

//	Turn on all display
	//assign	HEX0		=	7'h00;
	//assign	HEX1		=	7'h00;
	//assign	HEX2		=	7'h00;
	//assign	HEX3		=	7'h00;
	//assign	HEX4		=	7'h00;
	//assign	HEX5		=	7'h00;
	//assign	GPIO_0		=	36'hzzzzzzzzz;
	//assign	GPIO_1		=	36'hzzzzzzzzz;
	//assign LEDR[9:0] = 10'd0;

/* SEVEN SEG STUFF*/ 
wire [6:0]seg7_dig0;
wire [6:0]seg7_dig1;
wire [6:0]seg7_dig2;
wire [6:0]seg7_dig3;
wire [6:0]seg7_dig4;
wire [6:0]seg7_dig5;

assign HEX0 = seg7_dig0;
assign HEX1 = seg7_dig1;
assign HEX2 = seg7_dig2; 
assign HEX3 = seg7_dig3;
assign HEX4 = seg7_dig4;
assign HEX5 = seg7_dig5;


/* Counters, activators, and other tracking for the game*/ 
wire shuffDone;
reg startShuff;
wire [4:0] SS;
wire shuffEn;

reg [4:0] playerP;
reg [4:0] dealerP;

reg [4:0] playerT;
reg [4:0] dealerT; 

assign LEDR[4:0] = playerP;
assign LEDR[9:5] = dealerP;
	
wire [9:0]input_seed;
assign input_seed = SW[5:0];
wire clk;
assign clk = CLOCK_50;

/*Key assignments*/ 
wire rst;
assign rst = KEY[3];
wire startOrHit;
assign startOrHit = ~KEY[2]; //Note that KEY[2] will act as both the continue button and hit button so we need to be careful.
wire [3:0] display_control; 
assign display_control = SW[9:6]; //~KEY[0];
wire stand;
assign stand = ~KEY[1];

reg[7:0]to_display;
wire[9:0]output_number;

//wire [3:0] card_num;
reg [1:0] card_suit;
reg [3:0] card_num0;
reg [3:0] card_num1;
reg [3:0] card_num;

reg [6:0]debug_num0;
reg [6:0]debug_num1;

reg [5:0]S;
reg [5:0]NS;

/* Module instantation*/
wire [5:0] deck_read_data;
/*CARD*/
seven_segment dig0(card_num0, seg7_dig0);
seven_segment dig1(card_num1, seg7_dig1);
seven_segment_suit dig2(card_suit, seg7_dig2);
/*STATE*/
seven_segment dig4(debug_num0, seg7_dig4);
seven_segment dig5(debug_num1, seg7_dig5);

reg [5:0] deck_index;
reg [5:0] deck_write_data;
reg wren;

wire [5:0] shuffle_deck_index;
wire [5:0] shuffle_deck_write_data;
wire [5:0] shuffle_wren;

reg [5:0] show_card_index;
reg [5:0] show_read_data;
reg [5:0] current_card;

reg [29:0] playerHand;
reg [29:0] dealerHand;

reg done;

deck memory(deck_index, clk, deck_write_data, wren, deck_read_data); // run through shuffle_deck

shuffle_deck_v2 my_deck_v2(.clk(clk), 
							.rst(rst), 
							.cont(startOrHit),
							.en(startShuff), 
							.deck_read_data(deck_read_data),
							.seed(input_seed), 
							.done(shuffDone), 
							.SS(SS),
							.deck_index(shuffle_deck_index), 
							.deck_write_data(shuffle_deck_write_data), 
							.enOut(shuffEn),
							.wren(shuffle_wren)
							);

parameter START  = 6'd0,
			WAIT_START = 6'd1,	
			SEED_ENTER = 6'd2,
			START_SHUFF = 6'd3,
			WAIT_SHUFF_DONE = 6'd4,
			
			START_GAME = 6'd5,
			WAIT_START_GAME = 6'd6,
			/////////PLAYER////////
			DEAL_STEP_FIRST_CARD = 6'd7,
			DEAL_STEP_FIRST_CARD_BUFF = 6'd8,
			DEAL_STEP_SECOND_CARD = 6'd9,
			DEAL_STEP_SECOND_CARD_BUFF = 6'd10,
			DEAL_STEP_SECOND_CARD_SETTLE = 6'd11,
			CHOOSE = 6'd12,
			DEAL_STEP_MID = 6'd13,
			WAIT_PHIT = 6'd14,
			WAIT_PSTAND = 6'd15,
			
			DISPLAY_CARD = 6'd16,
			ADD_TOTAL = 6'd17,
			IS_PBUST = 6'd18,
			IS_ACE = 6'd19,
			WAIT_ACE_CHOICE = 6'd20,
			INC_INDEX = 6'd22,
			INC_INDEX_BUFF = 6'd23,
			////////DEALER/////////
			DEALER_GET = 6'd24,
			WAIT_DHIT = 6'd25,
			WAIT_DSTAND = 6'd26,
			IS_DBUST = 6'd27,
			IS_D_ACE = 6'd28,
			WAIT_D_ACE_CHOICE = 6'd29,
			DISPLAY_DEALER_CARD = 6'd30,	
			ADD_DEALER_TOTAL= 6'd31,
			INC_INDEX_D = 6'd32,
			INC_INDEX_D_BUFF = 6'd33,

			IS_WIN = 6'd34,
			IS_FINAL = 6'd35,
			
			ERROR = 6'd63; 
			
	always@(posedge clk or negedge rst)
		if(rst == 0)
			S <= START;
		else
			S <= NS;
//-----------------------------------------------------------------------------------------------	
	always@(*)
		case(S)
			START:
				if(startOrHit == 1)
					NS = WAIT_START;
				else 
					NS = START;
			
			WAIT_START:
				if(startOrHit == 0)
					NS = SEED_ENTER;
				else 
					NS = WAIT_START;
			
			SEED_ENTER:
				if(startOrHit == 1) 
					NS = START_SHUFF;
				else 
					NS = SEED_ENTER;
			
			START_SHUFF:
				begin
					NS = WAIT_SHUFF_DONE;
					wren = shuffle_wren;
					deck_write_data = shuffle_deck_write_data;
					deck_index = shuffle_deck_index;
				end
			
			WAIT_SHUFF_DONE:
				begin
					if(startOrHit == 1) // This acts as both the buffer on our slow-as-butt fingers and the check if it is done
						NS = WAIT_SHUFF_DONE;
					else 
						if(shuffDone == 1)
							NS  = START_GAME;
						else
							NS = WAIT_SHUFF_DONE;
				
					wren = shuffle_wren;
					deck_write_data = shuffle_deck_write_data;
					deck_index = shuffle_deck_index;
				end
			
			START_GAME:
				begin
					if(startOrHit == 1) 
						NS = WAIT_START_GAME;
					else 
						NS = START_GAME;
				end
			WAIT_START_GAME:
				begin
					if(startOrHit == 0) 
						NS = DEAL_STEP_FIRST_CARD;
					else 
						NS = WAIT_START_GAME;
				end
//////////////////////PLAYER/////////////////////////////////			
			DEAL_STEP_FIRST_CARD:
				begin
					deck_index = show_card_index;
					NS = DEAL_STEP_FIRST_CARD_BUFF;
				end 
				
				DEAL_STEP_FIRST_CARD_BUFF:
				begin
					deck_index = show_card_index;
					NS = DEAL_STEP_SECOND_CARD;
				end
				
				DEAL_STEP_SECOND_CARD:
				begin
					deck_index = show_card_index;
					NS = DEAL_STEP_SECOND_CARD_BUFF;
				end 
				
				DEAL_STEP_SECOND_CARD_BUFF:

				begin
					deck_index =show_card_index;
					NS = DEAL_STEP_SECOND_CARD_SETTLE;
				end
				
				DEAL_STEP_SECOND_CARD_SETTLE:
				begin
					deck_index = show_card_index;
					NS = CHOOSE;
				end 
				
				DEAL_STEP_MID:
					NS = CHOOSE;
				
				CHOOSE:
					if(startOrHit == 1)
						NS = WAIT_PHIT;
					else
						if(stand == 1)
							NS = WAIT_PSTAND;
						else
							 NS = CHOOSE;
			
			WAIT_PHIT:
				if(startOrHit == 0) 
					NS = DISPLAY_CARD;
				else 
					NS = WAIT_PHIT;
			
			WAIT_PSTAND:
				if(stand == 0) 
					NS = DEALER_GET;
				else 
					NS = WAIT_PSTAND;
			
			DISPLAY_CARD:
				if((current_card & 6'b001111) == 1)
					NS = IS_ACE;
				else
					NS = ADD_TOTAL;
			
			ADD_TOTAL:
				NS = IS_PBUST;
			
			IS_PBUST:
				if(playerT >= 21)
					NS = DEALER_GET;
				else
					NS = INC_INDEX;
			
			INC_INDEX:
				begin
				deck_index = show_card_index;
				NS = INC_INDEX_BUFF;
				end
				
			INC_INDEX_BUFF:
				begin
				deck_index = show_card_index;
				NS = DEAL_STEP_MID;
				end
			
			IS_ACE:
				if(startOrHit == 1) 
					NS = WAIT_ACE_CHOICE;
				else 
					if(stand == 1)
						NS = WAIT_ACE_CHOICE;
					else 
						NS = IS_ACE;
			
			/*Looking at these next two states you will see that KEY[2] is for 11 and KEY[1] is for 1.*/ 
			WAIT_ACE_CHOICE:
				if(startOrHit == 0) 
						NS = IS_PBUST;
					else 
						NS = WAIT_ACE_CHOICE;
				
					
/////////DEALER/////////////////////////////////////////////////////////////////////////////
			DEALER_GET:
			begin
				deck_index = show_card_index;
				if(startOrHit == 0)
					NS = DEALER_GET;
				else if(dealerT < 17)
					NS = WAIT_DHIT;
				else
					NS = WAIT_DSTAND;
			end
			
			WAIT_DHIT:
			begin
				deck_index = show_card_index;
				if(startOrHit == 0)
					NS = DISPLAY_DEALER_CARD;
				else
					NS = WAIT_DHIT;
			end
			
			WAIT_DSTAND:
				begin
				deck_index = show_card_index;
				if(startOrHit == 0)
					NS = IS_WIN;
				else
					NS = WAIT_DSTAND;
				end
		
			IS_ACE:
				NS = WAIT_ACE_CHOICE;
			
			WAIT_ACE_CHOICE:
				NS = ADD_DEALER_TOTAL;
				
			
			DISPLAY_DEALER_CARD:
				begin
				deck_index = show_card_index;
				if((current_card & 6'b001111) == 1)
					NS = IS_D_ACE;
				else
					NS = ADD_DEALER_TOTAL;
				end
				
			IS_D_ACE:
				NS = WAIT_D_ACE_CHOICE;
				
			
			WAIT_D_ACE_CHOICE:
				NS = IS_DBUST;
			
			ADD_DEALER_TOTAL:
				begin
				deck_index = show_card_index;
				NS = IS_DBUST; 
				end
				
			IS_DBUST:
				begin
				deck_index = show_card_index;
				if(dealerT >= 21)
					NS = IS_WIN;
				else
					NS = INC_INDEX_D;
				end
			
			INC_INDEX_D:
				begin
				deck_index = show_card_index;
				NS = INC_INDEX_D_BUFF;
				end
				
			INC_INDEX_D_BUFF:
				begin
				deck_index = show_card_index;
				NS = DEALER_GET;
				end
			
			IS_WIN:
				if(playerP >= 4)
					NS = IS_FINAL;
				else
					NS = SEED_ENTER;
			IS_FINAL:
				NS = IS_FINAL;
			
			default:
				begin
				wren = 1'b0;
				deck_write_data = 6'b0;
				deck_index = 6'b0;
				end
		endcase
//------------------------------------------------------------------------------------------------------------------		
		always@(posedge clk or negedge rst)
		if(rst == 0)
			begin
			startShuff <= 0;

			playerP <= 0;
			dealerP <= 0;

			playerT <= 0;
			dealerT <= 0;
			show_card_index <= 0;
			dealerHand <= 0;
			playerHand <= 0;
			
			done <= 0;
					
			end
		else
			case(S)
				START:
					begin
						startShuff <= 0;

						playerP <= 0;
						dealerP <= 0;

						playerT <= 0;
						dealerT <= 0;
						show_card_index <= 0;
						dealerHand <= 0;
						playerHand <= 0;
						
						done <= 0;
					end
				
				START_SHUFF:
				begin
					startShuff <= startShuff + 1;
				end
				
				WAIT_SHUFF_DONE:
					begin 
					end
				
				/* WAIT_SHUFF_DONE A GOOD STATE FOR ANIMATION CHECK*/ 
				START_GAME:
					begin
					end
					
				WAIT_START_GAME:
					begin
					end
					
////////////////// PLAYER ////////////////////////////////////
				DEAL_STEP_FIRST_CARD:
				/*DEAL_STEP A GOOD STATE FOR ANIMATION CHECK*/ 
				begin
					current_card <= deck_read_data;
					show_card_index <= show_card_index + 1;
				end 
				
				DEAL_STEP_FIRST_CARD_BUFF: 
				begin
				
				end
				
				DEAL_STEP_SECOND_CARD:
				begin
					playerHand <= {playerHand[23:0], current_card};
					playerT <= playerT + (current_card & 6'b001111);
					current_card <= deck_read_data;
				end 
				
				DEAL_STEP_SECOND_CARD_BUFF:
				/*DEAL_STEP A GOOD STATE FOR ANIMATION CHECK*/ 
				begin
				end
				
				DEAL_STEP_SECOND_CARD_SETTLE:
				/*DEAL_STEP A GOOD STATE FOR ANIMATION CHECK*/ 
				begin
					playerHand <= {playerHand[23:0], current_card};
					playerT <= playerT + (current_card & 6'b001111);
				end 
				
				DEAL_STEP_MID:
					begin
					current_card <= deck_read_data; 
					end
				
				
				WAIT_PHIT:
				begin		
				end
				
				WAIT_PSTAND:
				begin
				end
				
				IS_PBUST:
				begin 
					if (playerT >= 21)
						playerT <= 0;
				end
				
				IS_ACE:
					begin
					end
				
				WAIT_ACE_CHOICE:
					begin
						if(startOrHit == 1)
							playerT <= playerT + 11;
						else
							playerT <= playerT + 1;
							
					end 
				
				WAIT_PSTAND:
					begin
					end 
				
				DISPLAY_CARD:
				/* DISPLAY_CARD A GOOD STATE FOR ANIMATION CHECK*/ 
					begin
						show_read_data <= current_card;
						playerHand <= {playerHand[23:0], current_card};
					end
					
				IS_PBUST:
				begin 
					if (playerT >= 21)
						playerT <= 0;
				end
				
				ADD_TOTAL:
					begin
						playerT <= playerT + (current_card & 6'b001111);
					end	
					
				INC_INDEX:
					begin 
						show_card_index <= show_card_index + 1;
					end
					
				INC_INDEX_BUFF:
				begin
				end
///////////////////DEALER/////////////////////////					
				/* The Dealer ai will look at its total a see if it is 17 or more and if it is over 
				17 it will stand. Otherwise it will pull a card. This is how it will guess based on bicycle rules.*/
				DEALER_GET:
					begin
					current_card <= deck_read_data; 	
					end
					
				WAIT_DHIT:
				begin		
				end
				
				WAIT_DSTAND:
				begin
				end
				
				IS_DBUST:
				begin 
					if (dealerT >= 21)
						dealerT <= 0;
				end
				
				/*IS_ACE:
					begin
					end
				
				WAIT_ACE_CHOICE:
					begin
					end */
				
				WAIT_DSTAND:
					begin
					end 
				
				DISPLAY_DEALER_CARD:
				/* DISPLAY_CARD A GOOD STATE FOR ANIMATION CHECK*/ 
					begin
						show_read_data <= current_card;
						dealerHand <= {dealerHand[23:0], current_card};
					end
				
				ADD_DEALER_TOTAL:
					begin
						dealerT <= dealerT + card_num;
					end	
					
				INC_INDEX_D:
					begin 
						show_card_index <= show_card_index + 1;
					end
				INC_INDEX_D_BUFF:
					begin
					end
					
				IS_WIN:
					begin
					playerT <= 0;
					dealerT <= 0;
					show_card_index <= 0;
					dealerHand <= 0;
					playerHand <= 0;
					
					if(playerT > dealerT)
						playerP <= playerP + 1;
					else if(playerT < dealerT)
							dealerP <= dealerP + 1;
					end
				
				IS_FINAL:
					begin
							done <= 1;
					end
			endcase
//----------------------------------------------------------------------------------------------------------		
		always@(*)
			begin
				card_num0 = (show_read_data & 6'b001111) % 10;
				card_num1 = (show_read_data & 6'b001111) / 10;
				card_suit = (show_read_data & 6'b110000) >> 4;
				card_num = (show_read_data & 6'b001111);
				case(display_control)
					4'b0000:
					begin
						debug_num0 = playerT % 10;
						debug_num1 = playerT / 10;
					end
					
					4'b0001:
					begin
						debug_num0 = dealerT % 10;
						debug_num1 = dealerT / 10;
					end
					
					4'b0010:
					begin
						debug_num0 = (playerHand[29:24] & 6'b001111) % 10;
						debug_num1 = (playerHand[29:24] & 6'b001111) / 10;
					end
					
					4'b0011:
					begin
						debug_num0 = (playerHand[23:18] & 6'b001111) % 10;
						debug_num1 = (playerHand[23:18] & 6'b001111) / 10;
					end
					
					4'b0100:
					begin
						debug_num0 = (playerHand[17:12] & 6'b001111) % 10;
						debug_num1 = (playerHand[17:12] & 6'b001111) / 10;
					end
					
					4'b0101:
					begin
						debug_num0 = (playerHand[11:6] & 6'b001111) % 10;
						debug_num1 = (playerHand[11:6] & 6'b001111) / 10;
					end
					
					4'b0110:
					begin
						debug_num0 = (playerHand[5:0] & 6'b001111) % 10;
						debug_num1 = (playerHand[5:0] & 6'b001111) / 10;
					end
					
					4'b0111:
					begin
						debug_num0 = S % 10;
						debug_num1 = S / 10;
					end
					
					4'b1000:
					begin
						debug_num0 = playerT % 10;
						debug_num1 = playerT / 10;
					end
					
					4'b1001:
					begin
						debug_num0 = dealerT % 10;
						debug_num1 = dealerT / 10;
					end
					
					4'b1010:
					begin
						debug_num0 = (dealerHand[29:24] & 6'b001111) % 10;
						debug_num1 = (dealerHand[29:24] & 6'b001111) / 10;
					end
					
					4'b1011:
					begin
						debug_num0 = (dealerHand[23:18] & 6'b001111) % 10;
						debug_num1 = (dealerHand[23:18] & 6'b001111) / 10;
					end
					
					4'b1100:
					begin
						debug_num0 = (dealerHand[17:12] & 6'b001111) % 10;
						debug_num1 = (dealerHand[17:12] & 6'b001111) / 10;
					end
					
					4'b1101:
					begin
						debug_num0 = (dealerHand[11:6] & 6'b001111) % 10;
						debug_num1 = (dealerHand[11:6] & 6'b001111) / 10;
					end
					
					4'b1110:
					begin
						debug_num0 = (dealerHand[5:0] & 6'b001111) % 10;
						debug_num1 = (dealerHand[5:0] & 6'b001111) / 10;
					end
					
					4'b1111:
					begin
						debug_num0 = S % 10;
						debug_num1 = S / 10;
					end
				endcase
			end

			
endmodule