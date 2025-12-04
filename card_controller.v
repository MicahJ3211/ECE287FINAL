// Program Designed based off of Peter Jameison's Code and assistance from Gemini with helpling fix the logic of the code

module card_controller (

input clk,
input rst,

// starting the fsm - Walker
input start,


// variables for the fsm - Walker
output reg [14:0]the_vga_draw_frame_write_mem_address,
output reg [23:0]the_vga_draw_frame_write_mem_data,

output reg en_card,

// variables to select what the target x and y are on the screen - Walker
input [9:0]target_x,
input [9:0]target_y

);


/* the 3 signals to set to write to the picture */
reg the_vga_draw_frame_write_a_pixel;


/* this is where I'm adding the x, y coordinates of card1 - Walker */

reg [9:0]xb_card1 = 10'd53;
reg [9:0]yb_card1 = 10'd85;

reg [9:0]xe_card1 = 10'd68;
reg [9:0]ye_card1 = 10'd104;


// storing the x and y of the card
reg [9:0]asset_x;
reg [9:0]asset_y;


reg [15:0]i;

parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

/* ACTUAL VGA RESOLUTION */
parameter VGA_WIDTH = 16'd640; 
parameter VGA_HEIGHT = 16'd480;

/* Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide */
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120

/* idx_location stores all the locations in the */
reg [14:0] idx_location;


// Virtual Screen Resolution (160x120)
parameter SCREEN_HEIGHT  = 16'd120;


// card1 vars - Walker
wire [23:0]card1_out;
reg [8:0]index_card1;
	
	
	
	
/* Dimensions of the playing_card asset - Walker */
// Width: 68 - 53 = 15
// Height: 104 - 85 = 19
parameter SPRITE_WIDTH  = 16'd15;
parameter SPRITE_HEIGHT = 16'd19;
parameter TOTAL_PIXELS  = SPRITE_WIDTH * SPRITE_HEIGHT; // 285
	
	
	
	

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
			if (start == 0)
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
			if (asset_y < SPRITE_HEIGHT)
				NS = CALC_ADDR;
				
			else 
				NS = DONE;
			
				
		DONE:
			if (start == 1)
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
				idx_location <= 15'd0;				
				
				// reseting variables for the ROM assets - Walker
				asset_x <= 9'd0;
				asset_y <= 9'd0;
				
				// asset for player card 1 - Walker
				index_card1 <= 9'd0;
				
				
				en_card <= 1'd0;
			end
		
		else
			begin
				case(S)
					
					START:
						begin
						
							// reseting variables for the vga_frame_driver - Walker
							the_vga_draw_frame_write_mem_address <= 15'd0;;
							the_vga_draw_frame_write_mem_data <= 24'd0;
							idx_location <= 15'd0;							
							
							// reseting variables for the ROM assets - Walker
							asset_x <= 9'd0;
							asset_y <= 9'd0;
							
							// asset for player card 1 - Walker
							index_card1 <= 9'd0;
							
							
							en_card <= 1'd0;
							
						end
						
					IDLE:
						begin
						
							en_card <= 1'd0;
							asset_x <= 9'd0;
							asset_y <= 9'd0;
							
						end
						
						
					CALC_ADDR:
						begin
							
							en_card <= 1'd0;
							
							// ROM address
							index_card1 <= (asset_x * SPRITE_HEIGHT) + asset_y;
							
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
							the_vga_draw_frame_write_mem_data <= card1_out;
							
							en_card <= 1'd1;
						
						end
					
						
					INCREMENT:
						begin
						
							en_card <= 1'b0;

							// Move coordinate counters
							if (asset_x == SPRITE_WIDTH - 1) 
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
						
							en_card <= 1'd0;
							
						end
				endcase
			end
		end
		

// I'll instantiate the Sprites for the cards here - Walker
playing_card card1(
	index_card1,
	clk,
	card1_out
	);
	
	
endmodule	
	
	
	
	
	
	
	
	
	
	
	
/*
module card_controller (
    input clk,
    input rst,

    // Start signal from main logic
    input start,

    // Interface to VGA Frame Driver
    output reg [14:0] the_vga_draw_frame_write_mem_address,
    output reg [23:0] the_vga_draw_frame_write_mem_data,
    output reg        the_vga_draw_frame_write_a_pixel, // Replaces en_card

    // Destination Position (Top-Left of where to draw on screen)
    // You can make these inputs if you want to move the card later
    input [9:0] target_x, 
    input [9:0] target_y
);

    // ----------------------------------------------------------------------
    // SETTINGS
    // ----------------------------------------------------------------------
    
    // Virtual Screen Resolution (160x120)
    parameter SCREEN_WIDTH  = 16'd160;
    
    // Card Sprite Dimensions (Derived from your xe-xb and ye-yb)
    // Width: 68 - 53 = 15
    // Height: 104 - 85 = 19
    parameter SPRITE_WIDTH  = 16'd15;
    parameter SPRITE_HEIGHT = 16'd19;
    parameter TOTAL_PIXELS  = SPRITE_WIDTH * SPRITE_HEIGHT; // 285

    // ----------------------------------------------------------------------
    // INTERNAL SIGNALS
    // ----------------------------------------------------------------------
    
    // Counters for the Sprite (0 to 14, 0 to 18)
    reg [9:0] sprite_x;
    reg [9:0] sprite_y;

    // ROM Signals
    reg [8:0]  rom_address;
    wire [23:0] rom_data;

    // FSM States
    reg [2:0] S;
    reg [2:0] NS;

    localparam 
        START           = 3'd0,
        IDLE            = 3'd1,
        CALC_ADDR       = 3'd2, // Calculate RAM and ROM addresses
        FETCH_WAIT      = 3'd3, // Wait for ROM to provide data
        WRITE_PIXEL     = 3'd4, // Write to Framebuffer
        INCREMENT       = 3'd5, // Move to next X/Y
        DONE            = 3'd6;

    // ----------------------------------------------------------------------
    // ASSET INSTANTIATION
    // ----------------------------------------------------------------------
    
    // NOTE: This assumes 'playing_card' is a ROM with 'address' input and 'q' output
    playing_card card1 (
        .address(rom_address),
        .clock(clk),
        .q(rom_data)
    );

    // ----------------------------------------------------------------------
    // FSM NEXT STATE LOGIC
    // ----------------------------------------------------------------------
    always @(*)
    begin
        case(S)
            START: 
                NS = IDLE;
                
            IDLE: 
                if (start) NS = CALC_ADDR;
                else       NS = IDLE;

            CALC_ADDR: 
                NS = FETCH_WAIT; // Give ROM 1 cycle to respond

            FETCH_WAIT: 
                NS = WRITE_PIXEL;

            WRITE_PIXEL: 
                NS = INCREMENT;

            INCREMENT:
                if (sprite_y == SPRITE_HEIGHT) // Have we finished all rows?
                    NS = DONE;
                else
                    NS = CALC_ADDR; // Go process next pixel

            DONE: 
                if (!start) NS = IDLE; // Wait for start to go low before resetting
                else        NS = DONE;
                
            default: NS = START;
        endcase
    end

    // ----------------------------------------------------------------------
    // STATE UPDATE & OUTPUT LOGIC
    // ----------------------------------------------------------------------
    always @(posedge clk or negedge rst)
    begin
        if (rst == 0)
        begin
            S <= START;
            the_vga_draw_frame_write_mem_address <= 15'd0;
            the_vga_draw_frame_write_mem_data    <= 24'd0;
            the_vga_draw_frame_write_a_pixel     <= 1'b0;
            sprite_x    <= 10'd0;
            sprite_y    <= 10'd0;
            rom_address <= 9'd0;
        end
        else
        begin
            S <= NS;

            case(S)
                START: begin
                    the_vga_draw_frame_write_a_pixel <= 1'b0;
                    sprite_x <= 10'd0;
                    sprite_y <= 10'd0;
                end

                IDLE: begin
                    the_vga_draw_frame_write_a_pixel <= 1'b0;
                    sprite_x <= 10'd0;
                    sprite_y <= 10'd0;
                end

                CALC_ADDR: begin
                    the_vga_draw_frame_write_a_pixel <= 1'b0;

                    // 1. Calculate ROM Address (Linear: 0, 1, 2... 284)
                    // Simple linear increment based on x/y
                    rom_address <= (sprite_y * SPRITE_WIDTH) + sprite_x;

                    // 2. Calculate RAM/Screen Address (Rectangular)
                    // Formula: (Start_Y + Offset_Y) * Screen_Width + (Start_X + Offset_X)
                    the_vga_draw_frame_write_mem_address <= 
                        ((target_y + sprite_y) * SCREEN_WIDTH) + (target_x + sprite_x);
                end
                
                FETCH_WAIT: begin
                    // Just waiting for ROM data to settle on 'rom_data' wire
                    // Block RAMs usually take 1-2 cycles
                end

                WRITE_PIXEL: begin
                    // Data is now ready from ROM
                    the_vga_draw_frame_write_mem_data <= rom_data;
                    
                    // Trigger the write to the Framebuffer
                    the_vga_draw_frame_write_a_pixel <= 1'b1;
                end

                INCREMENT: begin
                    // Turn off write enable
                    the_vga_draw_frame_write_a_pixel <= 1'b0;

                    // Move coordinate counters
                    if (sprite_x == SPRITE_WIDTH - 1) begin
                        sprite_x <= 0;           // Reset X (Carriage Return)
                        sprite_y <= sprite_y + 1; // Move down Y (Line Feed)
                    end
                    else begin
                        sprite_x <= sprite_x + 1; // Move right X
                    end
                end

                DONE: begin
                    the_vga_draw_frame_write_a_pixel <= 1'b0;
                end
            endcase
        end
    end

endmodule*/