// Program Designed based off of Peter Jameison's Code and assistance from Gemini with helpling fix the logic of the code

module asset_controller (

input clk,
input rst,

// starting the fsm - Walker
input start,


// variables for the fsm - Walker
output reg [14:0]the_vga_draw_frame_write_mem_address,
output reg [23:0]the_vga_draw_frame_write_mem_data,

output reg en_asset,

// variables to select what the target x and y are on the screen - Walker
input [9:0]target_x,
input [9:0]target_y,

// x and y size of the asset
input [9:0]asset_assign_x,
input [9:0]asset_assign_y,

// more control stuff
input en_cardD,
input en_cardP,
input en_chipP,
input en_chipD,
input en_suitD,
input en_suitP,
input en_rankD,
input en_rankP,
input en_replace,

// for suit and rank
input [9:0]suit_index_adjustment,
input [9:0]rank_index_adjustment,

// ending the fsm
output reg done

);


reg [15:0]i;

parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

/* ACTUAL VGA RESOLUTION */
parameter VGA_WIDTH = 16'd640; 
parameter VGA_HEIGHT = 16'd480;

/* Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide */
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120


reg [9:0]index_adjustment;
reg [8:0]index_asset;
reg [23:0]asset_out;


// Virtual Screen Resolution (160x120)
parameter SCREEN_HEIGHT  = 16'd120;


// card vars - Walker
wire [23:0]card_out;
reg [8:0]index_card;

// player chip vars
wire [23:0]chipP_out;
reg [8:0]index_chipP;

// dealer chip vars
wire [23:0]chipD_out;
reg [8:0]index_chipD;

// card suit vars
wire [23:0]suit_out;
reg [8:0]index_suit;

// card rank vars
wire [23:0]rank_out;
reg [8:0]index_rank;

// background replacement vars
wire [23:0]replace_out;
reg [8:0]index_replace;
	
	
/* Dimensions of the playing_card asset - Walker */
// Width: 68 - 53 = 15
// Height: 104 - 85 = 19
//parameter SPRITE_WIDTH  = asset_assign_x;
//parameter SPRITE_HEIGHT = asset_assign_y;
//parameter TOTAL_PIXELS  = SPRITE_WIDTH * SPRITE_HEIGHT; // 285

reg [8:0] sprite_width;
reg [8:0] sprite_height;
reg [8:0] total_pixels;
	
	
	
reg [8:0]asset_x;
reg [8:0]asset_y;


always@(*)
	begin
		
		sprite_width = asset_assign_x;
		sprite_height = asset_assign_y;
		total_pixels = sprite_width * sprite_height;

        if (en_suitP == 1 || en_suitD == 1)

				index_adjustment = suit_index_adjustment;
        else if (en_rankP == 1 || en_rankD == 1)
            index_adjustment = rank_index_adjustment;
        else   
            index_adjustment = 9'd0;

        
        if (en_cardP == 1 || en_cardD == 1)
            begin
                index_card = index_asset;
                asset_out = card_out;
            end

        else if (en_chipP == 1)
            begin
                index_chipP = index_asset;
                asset_out = chipP_out;
            end

        else if (en_chipD == 1)
            begin
                index_chipD = index_asset;
                asset_out = chipD_out;
            end

        else if (en_suitP == 1 || en_suitD == 1)
            begin
                index_suit = index_asset;
                asset_out = suit_out;
            end

        else if (en_rankP == 1 || en_rankD == 1)
            begin
                index_rank = index_asset;
                asset_out = rank_out;
            end
				
			else if (en_replace == 1)
				begin
					index_replace = index_asset;
					asset_out = replace_out;
				end
	end

// Setting my perameters and making the registers for S and NS - Walker

reg [3:0]S;
reg [3:0]NS;

parameter START = 3'd0,
			 IDLE = 3'd1,
			 FETCH_WAIT = 3'd2,
			 CALC_ADDR = 3'd3,
			 WRITE_PIXEL = 3'd4,
			 INCREMENT = 3'd5,
			 DONE = 3'd6;
			 

			 
always@(*)
	case(S)
		START: 
				NS = IDLE;
				
				
		IDLE:
			if (start == 1)
				NS = CALC_ADDR;
				
			else
				NS = IDLE;
				
				
		CALC_ADDR:
			NS = FETCH_WAIT;
			
			
		FETCH_WAIT:
			NS = WRITE_PIXEL;
			
			
		WRITE_PIXEL:
			NS = INCREMENT;
			
			
		INCREMENT:
			if (asset_y < sprite_height)
				NS = CALC_ADDR;
				
			else 
				NS = DONE;
			
				
		DONE:
			if (start == 0)
				NS = IDLE;
			
			else
				NS = DONE;
	endcase


always@(posedge clk or negedge rst)
	begin
	
		if (rst == 0)
			S <= START;
		
		else 
			S <= NS;
	end

	
	
always@(posedge clk or negedge rst)
	begin
		if (rst == 0)
			begin
				// reseting variables for the vga_frame_driver - Walker
				the_vga_draw_frame_write_mem_address <= 15'd0;
				the_vga_draw_frame_write_mem_data <= 24'd0;				
				
				// reseting variables for the ROM assets - Walker
				asset_x <= 0;
				asset_y <= 0;
				
				// asset for whatever is enabled - Walker
				index_asset <= 9'd0;
				
				
				en_asset <= 1'd0;
				done <= 1'd0;
			end
		
		else
			begin
				case(S)
					
					START:
						begin
						
							// reseting variables for the vga_frame_driver - Walker
							the_vga_draw_frame_write_mem_address <= 15'd0;;
							the_vga_draw_frame_write_mem_data <= 24'd0;							
							
							// reseting variables for the ROM assets - Walker
							asset_x <= 0;
							asset_y <= 0;
							
							// asset for whatever asset is enabled - Walker
							index_asset <= 9'd0;
							
							
							en_asset <= 1'd0;
							done <= 1'd0;
							
						end
						
					IDLE:
						begin
						
							en_asset <= 1'd0;
							asset_x <= 9'd0;
							asset_y <= 9'd0;
							done <= 1'd0;
							
						end
						
						
					CALC_ADDR:
						begin
							
							en_asset <= 1'd0;
							
							// ROM address
							index_asset <= (asset_x * sprite_height) + asset_y;
							
							// RAM address
							the_vga_draw_frame_write_mem_address <= ((target_x + asset_x) * SCREEN_HEIGHT) + (target_y + asset_y);
						
						end
						
					
					FETCH_WAIT:
						begin
						
							// used to have a buffer to wait for the memory to update to what we want - Walker
						
						end
						
						
					WRITE_PIXEL:
						begin
							
							//writing the data from the ROM
							the_vga_draw_frame_write_mem_data <= asset_out;
							
							en_asset <= 1'd1;
						
						end
					
						
					INCREMENT:
						begin
						
							en_asset <= 1'b0;

							// Move coordinate counters
							if (asset_x == sprite_width - 1) 
								begin
								
									asset_x <= 0;           // Reset X
									asset_y <= asset_y + 1; // Move down Y
									
								end
								
							else 
								begin
								
									asset_x <= asset_x + 1; // Move right X
									
								end
						
						end
						
						
					DONE:
						begin
						
							en_asset <= 1'd0;
                     done <= 1'd1;
							
						end
				endcase
			end
		end
		

// I'll instantiate the Sprites for the cards here - Walker
playing_card cards(
	index_card,
	clk,
	card_out
	);

player_chip_asset chipP(
    index_chipP,
    clk,
    chipP_out
);

dealer_chip_asset chipD(
    index_chipD,
    clk,
    chipD_out
);

rank_library ranks(
    index_rank,
    clk,
    rank_out
);

suit_library suits(
    index_suit,
    clk,
    suit_out
);

replace_background replacement(
	index_replace,
	clk,
	replace_out
);
	
	
endmodule