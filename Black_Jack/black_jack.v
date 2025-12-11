module black_jack (

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
	input 		     [9:0]		SW,

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1

);

// Turn off all displays.


// DONE STANDARD PORT DECLARATION ABOVE
/* HANDLE SIGNALS FOR CIRCUIT */
wire clk;
wire rst;

assign clk = CLOCK_50;
assign rst = KEY[0];

wire [9:0]SW_db;

debounce_switches db(
.clk(clk),
.rst(rst),
.SW(SW), 
.SW_db(SW_db)
);

// VGA DRIVER
wire active_pixels; // is on when we're in the active draw space
wire frame_done;
wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need



/* variables for the asset controller */
reg [9:0] target_x;
reg [9:0] target_y;

reg [8:0] asset_x;
reg [8:0] asset_y;



/* this is where I'm adding the x, y coordinates of player's cards */

reg [9:0]card1P_target_x = 10'd63;
reg [9:0]card1P_target_y = 10'd81;

reg [9:0]card2P_target_x = 10'd82;
reg [9:0]card2P_target_y = 10'd81;

reg [9:0]card3P_target_x = 10'd73;
reg [9:0]card3P_target_y = 10'd57;

reg [9:0]card4P_target_x = 10'd46;
reg [9:0]card4P_target_y = 10'd62;

reg [9:0]card5P_target_x = 10'd100;
reg [9:0]card5P_target_y = 10'd61;



/* this is where I'm adding the x, y coordinates of dealer's cards */

reg [9:0]card1D_target_x = 10'd56;
reg [9:0]card1D_target_y = 10'd9;

reg [9:0]card2D_target_x = 10'd90;
reg [9:0]card2D_target_y = 10'd9;

reg [9:0]card3D_target_x = 10'd73;
reg [9:0]card3D_target_y = 10'd26;

reg [9:0]card4D_target_x = 10'd107;
reg [9:0]card4D_target_y = 10'd26;

reg [9:0]card5D_target_x = 10'd36;
reg [9:0]card5D_target_y = 10'd26;


// card x and y values
reg [8:0]card_asset_x = 9'd15;
reg [8:0]card_asset_y = 9'd19;

// chip x and y values
reg [8:0]chip_asset_x = 9'd12;
reg [8:0]chip_asset_y = 9'd12;



/* this is where I'm adding the x, y coordinates of the suits for the player's cards */
reg [9:0]suit_card1P_tx = 10'd69;
reg [9:0]suit_card1P_ty = 10'd90;

reg [9:0]suit_card2P_tx = 10'd88;
reg [9:0]suit_card2P_ty = 10'd90;

reg [9:0]suit_card3P_tx = 10'd79;
reg [9:0]suit_card3P_ty = 10'd66;

reg [9:0]suit_card4P_tx = 10'd52;
reg [9:0]suit_card4P_ty = 10'd71;

reg [9:0]suit_card5P_tx = 10'd106;
reg [9:0]suit_card5P_ty = 10'd70;



/* this is where I'm adding the x, y coordinates of the suits for the dealer's cards */
reg [9:0]suit_card1D_tx = 10'd62;
reg [9:0]suit_card1D_ty = 10'd18;

reg [9:0]suit_card2D_tx = 10'd96;
reg [9:0]suit_card2D_ty = 10'd18;

reg [9:0]suit_card3D_tx = 10'd79;
reg [9:0]suit_card3D_ty = 10'd35;

reg [9:0]suit_card4D_tx = 10'd113;
reg [9:0]suit_card4D_ty = 10'd35;

reg [9:0]suit_card5D_tx = 10'd45;
reg [9:0]suit_card5D_ty = 10'd35;


/* this is where I'm adding the x, y coordinates of the ranks for the player's cards */
reg [9:0]rank_card1P_tx = 10'd65;
reg [9:0]rank_card1P_ty = 10'd83;

reg [9:0]rank_card2P_tx = 10'd84;
reg [9:0]rank_card2P_ty = 10'd83;

reg [9:0]rank_card3P_tx = 10'd48;
reg [9:0]rank_card3P_ty = 10'd64;

reg [9:0]rank_card4P_tx = 10'd102;
reg [9:0]rank_card4P_ty = 10'd63;

reg [9:0]rank_card5P_tx = 10'd75;
reg [9:0]rank_card5P_ty = 10'd59;


/* this is where I'm adding the x, y coordinates of the ranks for the dealer's cards */
reg [9:0]rank_card1D_tx = 10'd58;
reg [9:0]rank_card1D_ty = 10'd11;

reg [9:0]rank_card2D_tx = 10'd92;
reg [9:0]rank_card2D_ty = 10'd11;

reg [9:0]rank_card3D_tx = 10'd75;
reg [9:0]rank_card3D_ty = 10'd28;

reg [9:0]rank_card4D_tx = 10'd109;
reg [9:0]rank_card4D_ty = 10'd28;

reg [9:0]rank_card5D_tx = 10'd41;
reg [9:0]rank_card5D_ty = 10'd28;


// rank x and y values
reg [8:0]rank_asset_x = 9'd5;
reg [8:0]rank_asset_y = 9'd5;

// suit x and y values
reg [8:0]suit_asset_x = 9'd7;
reg [8:0]suit_asset_y = 9'd8;


/* I'm going to make perameters that you should be able to plug the output of the deck into and returns a value for the suit and rank */
reg [3:0]in_ranker;
reg [1:0]in_suiter;
//reg ;


// these will be added to the initial index location inside of the mif file that is a library to the 
wire [9:0]ranker_idx_add;
wire [9:0]suiter_idx_add;
//wire ;


/* I kind of want to have a start and done variable along with some enables for the different assets */
reg cardD_en;
reg cardP_en;
reg chipD_en;
reg chipP_en;
reg suitP_en;
reg suitD_en;
reg rankP_en;
reg rankD_en;
reg replace_en;

/* making the variables to replace the background with its starting version */
reg [9:0]replace_target_y = 10'd0;
reg [9:0]replace_target_x = 10'd0;

reg [8:0]replace_asset_y = 9'd120;
reg [8:0]replace_asset_x = 9'd160;


/* this is where I'm adding the x, y coordinates of the dealer's chips */

reg [9:0]chip1D_target_x = 10'd7;
reg [9:0]chip1D_target_y = 10'd32;

reg [9:0]chip2D_target_x = 10'd9;
reg [9:0]chip2D_target_y = 10'd45;

reg [9:0]chip3D_target_x = 10'd13;
reg [9:0]chip3D_target_y = 10'd58;

reg [9:0]chip4D_target_x = 10'd19;
reg [9:0]chip4D_target_y = 10'd71;

reg [9:0]chip5D_target_x = 10'd25;
reg [9:0]chip5D_target_y = 10'd84;



/* this is where I'm adding the x, y coordingate of the player's chips */

reg [9:0]chip1P_target_x = 10'd141;
reg [9:0]chip1P_target_y = 10'd32;

reg [9:0]chip2P_target_x = 10'd139;
reg [9:0]chip2P_target_y = 10'd45;

reg [9:0]chip3P_target_x = 10'd135;
reg [9:0]chip3P_target_y = 10'd58;

reg [9:0]chip4P_target_x = 10'd129;
reg [9:0]chip4P_target_y = 10'd71;

reg [9:0]chip5P_target_x = 10'd123;
reg [9:0]chip5P_target_y = 10'd84;



// set the size for the background


// variable that can be set to high to start the FSM that reads from the ROM and writes it to the RAM
reg start_asset;

// the done statement for the asset_controller
wire done_asset;


/* I wanted to find some kind of way that I could keep track of everything that is happening
with the cards that are in hand that would allow me to change which asset I'm writing to the Ram
so I settled on the idea of basically just having a counter which is probably not the best solution
but it tends to be the first thing I try */

reg [2:0] player_hand_size = 3'd0; //should have a max of 5 for both player and dealer hand
reg [2:0] dealer_hand_size = 3'd0;

reg [2:0] player_chip_size = 3'd0; //decided to have the same naming conv for chips, should also be <= 5
reg [2:0] dealer_chip_size = 3'd0;


wire en_card;
wire [14:0]the_vga_draw_frame_write_mem_address;
wire [23:0]the_vga_draw_frame_write_mem_data;


get_suit_rank my_get_suit_rank(
	.suit_in(in_suiter),
	.rank_in(in_ranker),

	.suit_out(suiter_idx_add),
	.rank_out(ranker_idx_add)
);

asset_controller my_asset_controller(
	.clk(clk),
	.rst(rst),

	// starting the fsm - Walker
	.start(start_asset),


	// variables for the fsm - Walker
	.the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
	.the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
	
	.en_asset(en_card),
	
	.target_x(target_x),
	.target_y(target_y),
	
	.asset_assign_x(asset_x),
	.asset_assign_y(asset_y),

	// more control stuff
	.en_cardD(cardD_en),
	.en_cardP(cardP_en),
	.en_chipP(chipP_en),
	.en_chipD(chipD_en),
	.en_suitP(suitP_en),
	.en_suitD(suitD_en),
	.en_rankP(rankP_en),
	.en_rankD(rankD_en),
	.en_replace(replace_en),

	// ending the fsm
	.done(done_asset)

);

vga_frame_driver my_frame_driver(
	.clk(clk),
	.rst(rst),

	.active_pixels(active_pixels),
	.frame_done(frame_done),

	.x(x),
	.y(y),

	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),
	.VGA_B(VGA_B),
	.VGA_G(VGA_G),
	.VGA_R(VGA_R),

	/* writes to the frame buf - you need to figure out how x and y or other details provide a translation */
	.the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
	.the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
	.the_vga_draw_frame_write_a_pixel(en_card)
);


/* The logic for the blackjack project */

always@(posedge clk or negedge rst)
	begin
		in_suiter <= current_card[5:4];
		in_ranker <= current_card[3:0];//added these ^^^
		
		if (rst == 0)
			begin
				target_x <= 0;
				target_y <= 0;
				asset_x <= 0;
				asset_y <= 0;
			end
			
			else
				begin
				if (cardP_en == 1)
					begin
						asset_x <= card_asset_x;
						asset_y <= card_asset_y;
						
						if (player_hand_size == 0)
							begin
								target_x <= card1P_target_x;
								target_y<= card1P_target_y;

							end
							
						else if (player_hand_size == 1)
							begin
								target_x <= card2P_target_x;
								target_y <= card2P_target_y;

							end
							
						else if (player_hand_size == 2)
							begin
								target_x <= card3P_target_x;
								target_y <= card3P_target_y;
		 
							end
							
						else if (player_hand_size == 3)
							begin
								target_x <= card4P_target_x;
								target_y <= card4P_target_y;

							end
							
						else if (player_hand_size == 4)
							begin
								target_x <= card5P_target_x;
								target_y <= card5P_target_y;

							end
							
							/*
							reg [9:0]card1P_target_x = 10'd63;
							reg [9:0]card1P_target_y = 10'd81;

							reg [9:0]card2P_target_x = 10'd82;
							reg [9:0]card2P_target_y = 10'd81;

							reg [9:0]card3P_target_x = 10'd73;
							reg [9:0]card3P_target_y = 10'd57;

							reg [9:0]card4P_target_x = 10'd46;
							reg [9:0]card4P_target_y = 10'd62;

							reg [9:0]card5P_target_x = 10'd100;
							reg [9:0]card5P_target_y = 10'd61;
							*/
							
					end
		/*		
		reg [8:0]card_asset_x = 9'd15;
		reg [8:0]card_asset_y = 9'd19; 
		*/	
			
				else if (cardD_en == 1)
					begin
						asset_x <= card_asset_x;
						asset_y <= card_asset_y;
						
						if (dealer_hand_size == 0)
							begin
								target_x <= card1D_target_x;
								target_y <= card1D_target_y;

							end
							
						else if (dealer_hand_size == 1)
							begin
								target_x <= card2D_target_x;
								target_y <= card2D_target_y;
		 
							end
							
						else if (dealer_hand_size == 2)
							begin
								target_x <= card3D_target_x;
								target_y <= card3D_target_y;

							end
							
						else if (dealer_hand_size == 3)
							begin
								target_x <= card4D_target_x;
								target_y <= card4D_target_y;
		 
							end
							
						else if (dealer_hand_size == 4)
							begin
								target_x <= card5D_target_x;
								target_y <= card5D_target_y;

							end
					
						/*
		reg [9:0]card1D_target_x = 10'd56;
		reg [9:0]card1D_target_y = 10'd9;

		reg [9:0]card2D_target_x = 10'd90;
		reg [9:0]card2D_target_y = 10'd9;

		reg [9:0]card3D_target_x = 10'd73;
		reg [9:0]card3D_target_y = 10'd26;

		reg [9:0]card4D_target_x = 10'd107;
		reg [9:0]card4D_target_y = 10'd26;

		reg [9:0]card5D_target_x = 10'd36;
		reg [9:0]card5D_target_y = 10'd26;
						*/
						
					end
					
				else if (chipD_en == 1)
					begin
						asset_x <= chip_asset_x;
						asset_y <= chip_asset_y;
						
						if (dealer_chip_size == 0)
							begin
								target_x <= chip1D_target_x;
								target_y <= chip1D_target_y;

							end
							
						else if (dealer_chip_size == 1)
							begin
								target_x <= chip2D_target_x;
								target_y <= chip2D_target_y;

							end
							
						else if (dealer_chip_size == 2)
							begin
								target_x <= chip3D_target_x;
								target_y <= chip3D_target_y;

							end
							
						else if (dealer_chip_size == 3)
							begin
								target_x <= chip4D_target_x;
								target_y <= chip4D_target_y;

							end
							
						else if (dealer_chip_size == 4)
							begin
								target_x <= chip5D_target_x;
								target_y <= chip5D_target_y;

							end
		/*
		reg [9:0]chip1D_target_x = 10'd7;
		reg [9:0]chip1D_target_y = 10'd32;

		reg [9:0]chip2D_target_x = 10'd9;
		reg [9:0]chip2D_target_y = 10'd45;

		reg [9:0]chip3D_target_x = 10'd13;
		reg [9:0]chip3D_target_y = 10'd58;

		reg [9:0]chip4D_target_x = 10'd19;
		reg [9:0]chip4D_target_y = 10'd71;

		reg [9:0]chip5D_target_x = 10'd25;
		reg [9:0]chip5D_target_y = 10'd84;
		*/
							
					end
		/*
		reg [8:0]chip_asset_x = 9'd12;
		reg [8:0]chip_asset_y = 9'd12;
		*/
					
				else if (chipP_en == 1)
					begin
						asset_x <= chip_asset_x;
						asset_y <= chip_asset_x;
						
						if (player_chip_size == 0)
							begin
								target_x <= chip1P_target_x;
								target_y <= chip1P_target_y;

							end
							
						else if (player_chip_size == 1)
							begin
								target_x <= chip2P_target_x;
								target_y <= chip2P_target_y;

							end
							
						else if (player_chip_size == 2)
							begin
								target_x <= chip3P_target_x;
								target_y <= chip3P_target_y;

							end
							
						else if (player_chip_size == 3)
							begin
								target_x <= chip4P_target_x;
								target_y <= chip4P_target_y;

							end
							
						else if (player_chip_size == 4)
							begin
								target_x <= chip5P_target_x;
								target_y <= chip5P_target_y;

							end
		/*
		reg [9:0]chip1P_target_x = 10'd141;
		reg [9:0]chip1P_target_y = 10'd32;

		reg [9:0]chip2P_target_x = 10'd139;
		reg [9:0]chip2P_target_y = 10'd45;

		reg [9:0]chip3P_target_x = 10'd135;
		reg [9:0]chip3P_target_y = 10'd58;

		reg [9:0]chip4P_target_x = 10'd129;
		reg [9:0]chip4P_target_y = 10'd71;

		reg [9:0]chip5P_target_x = 10'd123;
		reg [9:0]chip5P_target_y = 10'd84;
		*/
							
					end
					
				else if (suitP_en == 1)
					begin
						asset_x <= suit_asset_x;
						asset_y <= suit_asset_y;
						
						if (player_hand_size == 0)
							begin
								target_x <= suit_card1P_tx;
								target_y <= suit_card1P_ty;

							end
							
						else if (player_hand_size == 1)
							begin
								target_x <= suit_card2P_tx;
								target_y <= suit_card2P_ty;

							end
							
						else if (player_hand_size == 2)
							begin
								target_x <= suit_card3P_tx;
								target_y <= suit_card3P_ty;

							end
							
						else if (player_hand_size == 3)
							begin
								target_x <= suit_card4P_tx;
								target_y <= suit_card4P_ty;

							end
							
						else if (player_hand_size == 4)
							begin
								target_x <= suit_card5P_tx;
								target_y <= suit_card5P_ty;

							end
		/*
		reg [9:0]suit_card1P_tx = 10'd69;
		reg [9:0]suit_card1P_ty = 10'd90;

		reg [9:0]suit_card2P_tx = 10'd88;
		reg [9:0]suit_card2P_ty = 10'd90;

		reg [9:0]suit_card3P_tx = 10'd79;
		reg [9:0]suit_card3P_ty = 10'd66;

		reg [9:0]suit_card4P_tx = 10'd52;
		reg [9:0]suit_card4P_ty = 10'd71;

		reg [9:0]suit_card5P_tx = 10'd106;
		reg [9:0]suit_card5P_ty = 10'd70;
		*/
							
					end
					
				else if (suitD_en == 1)
					begin
						asset_x <= suit_asset_x;
						asset_y <= suit_asset_y;
						
						if (dealer_hand_size == 0)
							begin
								target_x <= suit_card1D_tx;
								target_y <= suit_card1D_ty;

							end
							
						else if (dealer_hand_size == 1)
							begin
								target_x <= suit_card2D_tx;
								target_y <= suit_card2D_ty;

							end
							
						else if (dealer_hand_size == 2)
							begin
								target_x <= suit_card3D_tx;
								target_y <= suit_card3D_ty;
		 
							end
							
						else if (dealer_hand_size == 3)
							begin
								target_x <= suit_card4D_tx;
								target_y <= suit_card4D_ty;

							end
							
						else if (dealer_hand_size == 4)
							begin
								target_x <= suit_card5D_tx;
								target_y <= suit_card5D_ty;
		 
							end
		/*
		reg [9:0]suit_card1D_tx = 10'd62;
		reg [9:0]suit_card1D_ty = 10'd18;

		reg [9:0]suit_card2D_tx = 10'd96;
		reg [9:0]suit_card2D_ty = 10'd18;

		reg [9:0]suit_card3D_tx = 10'd79;
		reg [9:0]suit_card3D_ty = 10'd35;

		reg [9:0]suit_card4D_tx = 10'd113;
		reg [9:0]suit_card4D_ty = 10'd35;

		reg [9:0]suit_card5D_tx = 10'd45;
		reg [9:0]suit_card5D_ty = 10'd35;
		*/
					end
					
				else if (rankP_en == 1)
					begin
						asset_x <= rank_asset_x;
						asset_y <= rank_asset_y;
						
						if (player_hand_size == 0)
							begin
								target_x <= rank_card1P_tx;
								target_y <= rank_card1P_ty;

							end
							
						else if (player_hand_size == 1)
							begin
								target_x <= rank_card2P_tx;
								target_y <= rank_card2P_ty;

							end
							
						else if (player_hand_size == 2)
							begin
								target_x <= rank_card3P_tx;
								target_y <= rank_card3P_ty;

							end
							
						else if (player_hand_size == 3)
							begin
								target_x <= rank_card4P_tx;
								target_y <= rank_card4P_ty;

							end
							
						else if (player_hand_size == 4)
							begin
								target_x <= rank_card5P_tx;
								target_y <= rank_card5P_ty;

							end
		/*
		reg [9:0]rank_card1P_tx = 10'd65;
		reg [9:0]rank_card1P_ty = 10'd83;

		reg [9:0]rank_card2P_tx = 10'd84;
		reg [9:0]rank_card2P_ty = 10'd83;

		reg [9:0]rank_card3P_tx = 10'd48;
		reg [9:0]rank_card3P_ty = 10'd64;

		reg [9:0]rank_card4P_tx = 10'd102;
		reg [9:0]rank_card4P_ty = 10'd63;

		reg [9:0]rank_card5P_tx = 10'd75;
		reg [9:0]rank_card5P_ty = 10'd59;
		*/
					end
					
				else if (rankD_en == 1)
					begin
						asset_x <= rank_asset_x;
						asset_y <= rank_asset_y;
						
						if (dealer_hand_size == 0)
							begin
								target_x <= rank_card1D_tx;
								target_y <= rank_card1D_ty;

							end
							
						else if (dealer_hand_size == 1)
							begin
								target_x <= rank_card2D_tx;
								target_y <= rank_card2D_ty;

							end
							
						else if (dealer_hand_size == 2)
							begin
								target_x <= rank_card3D_tx;
								target_y <= rank_card3D_ty;

							end
							
						else if (dealer_hand_size == 3)
							begin
								target_x <= rank_card4D_tx;
								target_y <= rank_card4D_ty;

							end
							
						else if (dealer_hand_size == 4)
							begin
								target_x <= rank_card5D_tx;
								target_y <= rank_card5D_ty;

							end
		/*
		reg [9:0]rank_card1D_tx = 10'd58;
		reg [9:0]rank_card1D_ty = 10'd11;

		reg [9:0]rank_card2D_tx = 10'd92;
		reg [9:0]rank_card2D_ty = 10'd11;

		reg [9:0]rank_card3D_tx = 10'd75;
		reg [9:0]rank_card3D_ty = 10'd28;

		reg [9:0]rank_card4D_tx = 10'd109;
		reg [9:0]rank_card4D_ty = 10'd28;

		reg [9:0]rank_card5D_tx = 10'd41;
		reg [9:0]rank_card5D_ty = 10'd28;
		*/					
					end
					
				else if (replace_en == 1)
					begin
						target_x <= replace_target_x;
						target_y <= replace_target_y;
						asset_x <= replace_asset_x;
						asset_y <= replace_asset_y;
					end
					
				else
					begin
					target_x <= 0;
					target_y <= 0;
					asset_x <= 0;
					asset_y <= 0;
					end
				end

	end

	
get_suit_rank suit_and_rank(
	.suit_in(suit_in),
	.rank_in(rank_in),
	
	.suit_out(suit_out),
	.rank_out(rank_out)
);


reg [1:0]suit_in;
reg [3:0]rank_in;

wire [9:0]suit_out;
wire [9:0]rank_out;
/*-----------------------------------------------------------------------------------------------------------------------*/

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

assign LEDR[5] = start_asset;
assign LEDR[4] = done_asset;
assign LEDR[9:7] = SW[9:7];
	
wire [9:0]input_seed;
assign input_seed = SW[5:0];


/*Key assignments*/ 
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
			INIT_SPAWN_CARD = 6'd9,
			INIT_SPAWN_CARD_BUFF  = 6'd10,
			INIT_SPAWN_SUIT = 6'd11,
			INIT_SPAWN_SUIT_BUFF  = 6'd12,
			INIT_SPAWN_NUM = 6'd13,
			INIT_SPAWN_NUM_BUFF = 6'd54,
			DEAL_STEP_SECOND_CARD = 6'd14,
			DEAL_STEP_SECOND_CARD_BUFF = 6'd15,
			DEAL_STEP_SECOND_CARD_SETTLE = 6'd16,
			INIT_2_SPAWN_CARD = 6'd17,
			INIT_2_SPAWN_CARD_BUFF = 6'd18,
			INIT_2_SPAWN_SUIT = 6'd19,
			INIT_2_SPAWN_SUIT_BUFF = 6'd20,
			INIT_2_SPAWN_NUM = 6'd21,
			INIT_2_SPAWN_NUM_BUFF = 6'd55,
			CHOOSE = 6'd22,
			DEAL_STEP_MID = 6'd23,
			WAIT_PHIT = 6'd24,
			WAIT_PSTAND = 6'd25,
			
			DISPLAY_CARD = 6'd26,
			SPAWN_CARD = 6'd27,
			SPAWN_CARD_BUFF = 6'd28,
			SPAWN_SUIT = 6'd29,
			SPAWN_SUIT_BUFF = 6'd30,
			SPAWN_NUM = 6'd31,
			SPAWN_NUM_BUFF = 6'd53,
			ADD_TOTAL = 6'd32,
			IS_PBUST = 6'd33,
			IS_ACE = 6'd34,
			WAIT_ACE_CHOICE = 6'd35,
			INC_INDEX = 6'd36,
			INC_INDEX_BUFF = 6'd37,
			////////DEALER/////////
			DEALER_GET = 6'd38,
			WAIT_DHIT = 6'd39,
			WAIT_DSTAND = 6'd40,
			IS_DBUST = 6'd41,
			IS_D_ACE = 6'd42,
			WAIT_D_ACE_CHOICE = 6'd43,
			DISPLAY_DEALER_CARD = 6'd44,
			D_SPAWN_CARD = 6'd45,
			D_SPAWN_SUIT = 6'd46,
			D_SPAWN_NUM = 6'd47,	
			ADD_DEALER_TOTAL= 6'd48,
			INC_INDEX_D = 6'd49,
			INC_INDEX_D_BUFF = 6'd50,

			IS_WIN = 6'd51,
			IS_FINAL = 6'd52,
			
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
					NS = INIT_SPAWN_CARD_BUFF;
				end
				
				INIT_SPAWN_CARD_BUFF:
					NS = INIT_SPAWN_CARD;
				
				INIT_SPAWN_CARD:
					if(done_asset == 1)
						NS = INIT_SPAWN_SUIT_BUFF;
					else
						NS = INIT_SPAWN_CARD;
				
				INIT_SPAWN_SUIT_BUFF:
					NS = INIT_SPAWN_SUIT;
				
				INIT_SPAWN_SUIT: 
					if(done_asset == 1)
						NS = INIT_SPAWN_NUM_BUFF;
					else
						NS = INIT_SPAWN_SUIT;
				
				INIT_SPAWN_NUM_BUFF:
					NS = INIT_SPAWN_NUM;
				
				INIT_SPAWN_NUM:
					if(done_asset == 1)
							NS = DEAL_STEP_SECOND_CARD;
					else
						NS = INIT_SPAWN_NUM;

				
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
					NS = INIT_2_SPAWN_CARD_BUFF;
				end 
				
				
				INIT_2_SPAWN_CARD_BUFF:
					NS = INIT_2_SPAWN_CARD;
				
				INIT_2_SPAWN_CARD:
					if(done_asset == 1)
						NS = INIT_2_SPAWN_SUIT_BUFF;
					else
						NS = INIT_2_SPAWN_CARD;
				
				INIT_2_SPAWN_SUIT_BUFF:
					NS = INIT_2_SPAWN_SUIT;
				
				INIT_2_SPAWN_SUIT: 
					if(done_asset == 1)
						NS = INIT_2_SPAWN_NUM_BUFF;
					else
						NS = INIT_2_SPAWN_SUIT;
				
				INIT_2_SPAWN_NUM_BUFF:
					NS = INIT_2_SPAWN_NUM;
				
				INIT_2_SPAWN_NUM:
					if(done_asset == 1)
							NS = CHOOSE;
					else
						NS = INIT_2_SPAWN_NUM;
				
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
						NS = SPAWN_CARD_BUFF;
						
				SPAWN_CARD_BUFF:
					NS = SPAWN_CARD;
				
				SPAWN_CARD:
					if(done_asset == 1)
						NS = SPAWN_SUIT_BUFF;
					else
						NS = SPAWN_CARD;
				
				SPAWN_SUIT_BUFF:
					NS = SPAWN_SUIT;	
				
				SPAWN_SUIT: 
					if(done_asset == 1)
						NS = SPAWN_NUM_BUFF;
					else
						NS = SPAWN_SUIT;
				
				SPAWN_NUM_BUFF:
					NS = SPAWN_NUM;

				SPAWN_NUM:
					if(done_asset == 1)
						NS = ADD_TOTAL;
					else
						NS = SPAWN_NUM;
				
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
				
			D_SPAWN_CARD:
				if(done_asset == 1)
					NS = D_SPAWN_SUIT;
				else
					NS = D_SPAWN_CARD;
				
			D_SPAWN_SUIT: 
				if(done_asset == 1)
					NS = D_SPAWN_NUM;
				else
					NS = D_SPAWN_SUIT;
				
			D_SPAWN_NUM:
				if(done_asset == 1)
					NS = ADD_TOTAL;
				else
					NS = D_SPAWN_NUM;
				
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
			
			cardP_en <= 0;
			cardD_en <= 0;
			chipP_en <= 0;
			chipD_en <= 0;
			suitP_en <= 0;
			suitD_en <= 0;
			rankP_en <= 0;
			rankD_en <= 0;
			
			
			start_asset <= 1; //this was zero
			replace_en <= 1; // this was not here
					
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
						
						cardP_en <= 0;
						cardD_en <= 0;
						chipP_en <= 0;
						chipD_en <= 0;
						suitP_en <= 0;
						suitD_en <= 0;
						rankP_en <= 0;
						rankD_en <= 0;
						
						player_hand_size <= 0;
						
						
						start_asset <= 0;
						replace_en <= 0; //
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
				
				INIT_SPAWN_CARD_BUFF:
					begin
						cardP_en <= 1;
					end
				
				INIT_SPAWN_CARD:
					//if(done_asset == 0)
						begin
						start_asset <= 1;
						end
					//else
					//	begin
						//cardP_en <= 0;
						//start_asset <= 0;
					//	end
				
				INIT_SPAWN_SUIT_BUFF:
					begin
						suitP_en <= 1;
						cardP_en <= 0;
						start_asset <= 0;
					end
				
				INIT_SPAWN_SUIT: 
					//if(done_asset == 0)
						begin
						start_asset <= 1;
						end
					//else
						//begin
						//start_asset <= 0;
						//suitP_en <= 0;
						//end
				
				INIT_SPAWN_NUM_BUFF:
					begin
						rankP_en <= 1;
						start_asset <= 0;
						suitP_en <= 0;
					end
				
				INIT_SPAWN_NUM:
					//if(done_asset == 0)
						begin
						start_asset <= 1;
						end
					//else
					//	begin
					//	start_asset <= 0;
					//	rankP_en <= 0;
					//	end
				
				
				DEAL_STEP_SECOND_CARD:
				begin
					player_hand_size <= 1;
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
				
				INIT_2_SPAWN_CARD_BUFF:
					begin
						cardP_en <= 1;
					end
				
				INIT_2_SPAWN_CARD:
					if(done_asset == 0)
						begin
						start_asset <= 1;
						end
					else
						begin
						cardP_en <= 0;
						start_asset <= 0;
						end
						
				INIT_2_SPAWN_SUIT_BUFF:
					begin
						suitP_en <= 1;
					end
				
				INIT_2_SPAWN_SUIT: 
					if(done_asset == 0)
						begin
							start_asset <= 1;
						end
					else
						begin
							start_asset <= 0;
							suitP_en <= 0;
						end
				
				INIT_2_SPAWN_NUM_BUFF:
					begin
						rankP_en <= 1;
					end
				
				INIT_2_SPAWN_NUM:
					if(done_asset == 0)
						begin
							start_asset <= 1;
						end
					else
						begin
							start_asset <= 0;
							rankP_en <= 0;
						end
				
				DEAL_STEP_MID:
					begin
					player_hand_size <= player_hand_size + 1;
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
					
				SPAWN_CARD_BUFF:
					begin
						cardP_en <= 1;
					end
				
				SPAWN_CARD:
					if(done_asset == 0)
						begin
							start_asset <= 1;
						end
					else
						begin
							cardP_en <= 0;
							start_asset <= 0;
						end
				
				SPAWN_SUIT_BUFF:
					begin
						suitP_en <= 1;
					end
				
				SPAWN_SUIT: 
					if(done_asset == 0)
						begin
							start_asset <= 1;
						end
					else
						begin
							start_asset <= 0;
							suitP_en <= 0;
						end
				
				SPAWN_NUM_BUFF:
					begin
						rankP_en <= 1;
					end
				
				SPAWN_NUM:
					begin
					if(done_asset == 0)
						begin
							start_asset <= 1;
						end
					else
						begin
							start_asset <= 0;
							rankP_en <= 0;
						end
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