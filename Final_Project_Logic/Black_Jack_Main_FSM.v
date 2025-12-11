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


wire [6:0]seg7_dig0;
wire [6:0]seg7_dig1;
wire [6:0]seg7_dig2;
wire [6:0]seg7_dig3;
wire [6:0]seg7_dig4;
wire [6:0]seg7_dig5;

assign HEX0 = seg7_dig0;
assign HEX1 = seg7_dig1;
assign HEX2 = seg7_dig2; // constant 0
assign HEX3 = seg7_dig3;
assign HEX4 = seg7_dig4;
assign HEX5 = seg7_dig5; // constant 0

reg [4:0] playerP;
reg [4:0] dealerP;

assign LEDR[3:0] = playerP;
assign LEDR[5:4] = dealerP;
assign LEDR[9:6] = S;
	
wire [9:0]input_seed;
assign input_seed = SW[9:0];
wire clk;
assign clk = CLOCK_50;
wire rst;
assign rst = KEY[3];
wire startOrHit;
assign startOrHit = ~KEY[2];
wire display_control; // {00 = sum, 1 =  }
assign display_control = KEY[0];
wire stand; // {00 = sum, 1 =  }
assign stand = KEY[1];

reg[7:0]to_display;
wire[9:0]output_number;

reg [4:0]S;
reg [4:0]NS;

/* signals to popcount */
reg start_pop_count; // signal to tell algorithm to start

parameter START = 5'd0,
			WAIT_START = 5'd1,
			SEED_ENTER = 5'd2,
			WAIT_ENTER = 5'd3,
			RANDOMIZE = 5'd4,
			REPLACE_CARD = 5'd5,
			SHUFF_BUFF = 5'd6,
			SEARCH_CARD = 5'd7,
			START_GAME = 5'd8,
			WAIT_START_GAME = 5'd9,
			
			DEAL_STEP = 5'd10,
			WAIT_PHIT = 5'd11,
			
			IS_BUST = 5'd12,
			IS_ACE = 5'd13,
			WAIT_ACE_CHOICE = 5'd14,
			
			WAIT_PSTAND = 5'd15,
			
			DISPLAY_CARD = 5'd16,
			WAIT_CONT = 5'd17,
			
			DEALER_GET = 5'd18,
			WAIT_DHIT = 5'd19,
			IS_BUST = 5'd20,
			IS_ACE = 5'd21,
			WAIT_ACE_CHOICE = 5'd22,
			WAIT_DSTAND = 5'd23,
			IS_WIN = 5'd24,
			
			IS_FINAL = 5'd25;
			
	alway@(posedge clk or negedge rst)
		if(rst == 0)
			S <= START;
		else
			S <= NS;
	always@(*)
		case(S)
			START:
			WAIT_START:
			SEED_ENTER:
			WAIT_ENTER:
			RANDOMIZE:
			REPLACE_CARD:
			SHUFF_BUFF:
			SEARCH_CARD:
			START_GAME:
			WAIT_START_GAME:
			DEAL_STEP:
			WAIT_PHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_PSTAND:
			DISPLAY_CARD:
			WAIT_CONT:
			DEALER_GET:
			WAIT_DHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_DSTAND:
			IS_WIN:
			IS_FINAL:
		endcase
		
		always@(posedge clk or negedge rst)
		case(S)
			START:
			WAIT_START:
			SEED_ENTER:
			WAIT_ENTER:
			RANDOMIZE:
			REPLACE_CARD:
			SHUFF_BUFF:
			SEARCH_CARD:
			START_GAME:
			WAIT_START_GAME:
			DEAL_STEP:
			WAIT_PHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_PSTAND:
			DISPLAY_CARD:
			WAIT_CONT:
			DEALER_GET:
			WAIT_DHIT:
			IS_BUST:
			IS_ACE:
			WAIT_ACE_CHOICE:
			WAIT_DSTAND:
			IS_WIN:
			IS_FINAL:
		endcase

			
endmodule