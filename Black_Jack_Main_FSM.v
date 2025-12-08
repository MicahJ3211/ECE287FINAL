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

reg [3:0]card_num0;
reg [3:0]card_num1;

/* Counters, activators, and other tracking for the game*/ 
reg shuffDone;
reg startShuff;

reg [4:0] playerP;
reg [4:0] dealerP;

reg [4:0] playerT;
reg [4:0] dealerT; 

assign LEDR[4:0] = playerP;
assign LEDR[9:5] = dealerP;
	
wire [9:0]input_seed;
assign input_seed = SW[9:0];
wire clk;
assign clk = CLOCK_50;

/*Key assignments*/ 
wire rst;
assign rst = KEY[3];
wire startOrHit;
assign startOrHit = ~KEY[2]; //Note that KEY[2] will act as both the continue button and hit button so we need to be careful.
wire display_control; 
assign display_control = ~KEY[0];
wire stand;
assign stand = ~KEY[1];

reg[7:0]to_display;
wire[9:0]output_number;

reg [3:0] card_num;
reg [1:0] card_suit;

reg [4:0]S;
reg [4:0]NS;

/* Module instantation*/
reg [5:0]deck_index;
reg [5:0]deck_write_data;
wire [5:0] deck_read_data;

seven_segment dig0(card_num0, seg7_dig0);
seven_segment dig1(card_num1, seg7_dig1);
seven_segment_suit dig2(card_suit, seg7_dig2);

deck memory(deck_index, clk, deck_write_data, wren, deck_read_data); // run through shuffle_deck
shuffle_deck my_deck(clk, rst, startShuff, input_seed, shuffDone);
//we will need an lfsr here 

parameter START  = 5'd0,
			WAIT_START = 5'd1,
			SEED_ENTER = 5'd2,
			WAIT_SHUFF_DONE = 5'd3,
			
			START_GAME = 5'd8,
			WAIT_START_GAME = 5'd9,
			
			SHOW_NEXT_CARD = 5'd4,
			
			
			DEAL_STEP = 5'd10,
			WAIT_PHIT = 5'd11,
			
			DISPLAY_CARD = 5'd16,
			IS_BUST = 5'd12,
			IS_ACE = 5'd13,
			WAIT_ACE_CHOICE_11 = 5'd14,
			WAIT_ACE_CHOICE_1 = 5'd26,
			WAIT_CONT = 5'd17,
			
			WAIT_PSTAND = 5'd15,
			
			DEALER_GET = 5'd18,
			WAIT_DHIT = 5'd19,
			D_IS_BUST = 5'd20,
			D_IS_ACE = 5'd21,
			WAIT_D_ACE_CHOICE = 5'd22,
			WAIT_DSTAND = 5'd23,
			IS_WIN = 5'd24,
			
			IS_FINAL = 5'd25;
			
	always@(posedge clk or negedge rst)
		if(rst == 0)
			S <= START;
		else
			S <= NS;
	
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
					NS = WAIT_SHUFF_DONE;
				else 
					NS = SEED_ENTER;
			
			WAIT_SHUFF_DONE:
				if(startOrHit == 1) // This acts as both the buffer on our slow-as-butt fingers and the check if it is done
					NS = WAIT_SHUFF_DONE;
				else 
					if(shuffDone == 1)
						NS  = START_GAME;
					else
						NS = WAIT_SHUFF_DONE;
			
			START_GAME:
				if(startOrHit == 1) 
					NS = WAIT_START_GAME;
				else 
					NS = START_GAME;
			
			WAIT_START_GAME:
				if(startOrHit == 0) 
					NS = DEAL_STEP;
				else 
					NS = WAIT_START_GAME;
					
			SHOW_NEXT_CARD: 
					NS = START_GAME;
			/*STOP HERE FOR NOW*/
			DEAL_STEP:
				if(startOrHit == 1)
					NS = WAIT_PHIT;
				else 
					if(stand == 1)
						NS = WAIT_PSTAND;
					else 
						NS = DEAL_STEP;
			
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
				if(card_num == 1)
					NS = IS_ACE;
				else
					NS = IS_BUST;
			
			IS_BUST:
				if(playerT >= 21)
					NS = DEALER_GET;
				else
					NS = WAIT_CONT;
			
			IS_ACE:
				if(startOrHit == 1) 
					NS = WAIT_ACE_CHOICE_11;
				else 
					if(stand == 1)
						NS = WAIT_ACE_CHOICE_1;
					else 
						NS = IS_ACE;
			
			/*Looking at these next two states you will see that KEY[2] is for 11 and KEY[1] is for 1.*/ 
			WAIT_ACE_CHOICE_11:
				if(startOrHit == 0) 
						NS = IS_BUST;
					else 
						NS = WAIT_ACE_CHOICE_11;
				
			WAIT_ACE_CHOICE_1:
				if(stand == 0) 
					NS = IS_BUST;
				else 
					NS = WAIT_ACE_CHOICE_1;
			
			/*WAIT_CONT:
			DEALER_GET:
			WAIT_DHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_DSTAND:
			IS_WIN:
			IS_FINAL:*/
		endcase
		
		always@(posedge clk or negedge rst)
		case(S)
			START:
				begin
					startShuff <= 0;

					playerP <= 5'b11111;
					dealerP <= 5'b11111;

					playerT <= 0;
					dealerT <= 0;
					
					deck_index <= 0;
					deck_write_data <= 0;
					
					card_num <= 0;
					card_suit <= 0;

				end
			
			WAIT_SHUFF_DONE:
			begin
			end
			
			/* WAIT_SHUFF_DONE A GOOD STATE FOR ANIMATION CHECK*/ 
			//START_GAME:
				
			WAIT_START_GAME:
				begin
					card_num <= deck_read_data >> 2;
					card_suit <= deck_read_data;
				end
			SHOW_NEXT_CARD:
				deck_index <= deck_index +1;
				
			
			//DEAL_STEP:
			/*DEAL_STEP A GOOD STATE FOR ANIMATION CHECK*/ 
			/*WAIT_PHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_PSTAND:
			DISPLAY_CARD:*/
			/* DISPLAY_CARD A GOOD STATE FOR ANIMATION CHECK*/ 
			/*WAIT_CONT:
			DEALER_GET:*/
			/* The Dealer ai will look at its total a see if it is 17 or more and if it is over 
			17 it will stand. Otherwise it will pull a card. This is how it will guess based on bicycle rules.*/
			/*WAIT_DHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_DSTAND:
			IS_WIN:
			IS_FINAL:*/
		endcase
		
		always@(*)
			begin
				card_num0 = card_num % 10;
				card_num1 = card_num / 10;
			end

			
endmodule