module shuffle_deck (
	input clk,
	input rst,
	
	// these inputs control when the FSM starts and what seed the pseudorandom number generater runs under
	input en,
	input [5:0]seed,
	input [5:0] deck_read_data,
	
	// lets the top level module know that the shuffling has concluded
	output reg done,
	
	
	//Debug variables to tell me whats happening in here
	output reg [3:0] SS,
	
	output reg enOut, 
	output reg [5:0] deck_index, 
	output reg [5:0] deck_write_data 
);


/* these variables will store the current and previous card that are being swapped with the shuffling of the deck */
reg [5: 0]previous_card;
reg [5:0]current_card;

/* these variables will store the current and previous slots that the card being swapped where in (in the memory) */
reg [5:0]previous_slot;
reg [5:0]current_slot;


/* using these variables for the information with instatiating the black_jack_deck qip and mif files */




/* counts how many times through the deck has been shuffled */ 
reg [5:0]shuffle_cnt;


/* counter for the DATA_BUFF so that I can properly replace all of the values */
reg [1:0]data_cnt;


/* counter for making the RANDOMIZE state run multiple times before moving on, because where is the fun in only randomizing once per loop */
reg [1:0] rnd_cnt;




reg [3:0]NS;
reg [3:0]S;

/* Things added by MICAH JASINSKI for qip file (there might be something redundent)*/


parameter START = 4'd0, // use this state to set initial zeroes and such

			 SEED_ENTER = 4'd1, // use this to set what the seed for the pseudorandom number generator is
			 
			 WAIT_EN = 4'd2, // this is just to wait for the enable signal from the high level module to allow the FSM to start
			 
			 RANDOMIZE = 4'd3, // this is where the pseudorandom number generator is, goes through itself twice before moving on
			 
			 FETCH_BUFF = 4'd4, // just buffers for the fetch state
			 
			 FETCH_CARD = 4'd5, // in here there will be values stored in "current_slot" and "current card"
			 
			 GET_INDEX = 4'd6, // just a buffer to let the memory settle
			 
			 DATA_BUFF = 4'd7, // the new and improved data buff, now with 0% more utility!!!
			 
			 REPLACE_CARDS = 4'd8, // replaces values in "current_slot" and "previous_slot" with each other in the memory
			 
			 RESET_VALUES = 4'd9, // resets things like "current_slot", "previous_slot", "current_card", and "previous_card" (adds 1 to shuffle_cnt)
			 
			 DONE = 4'd10;// sends the done signal to the higher level module and then goes back to the START state
			 
always@(posedge clk or negedge rst)
	begin
		if (rst == 0)
			S <= START;
			
		else
			S <= NS;
		SS <= NS;
	end

always@(*)
	case(S)
		
		START:
			NS = SEED_ENTER;
			
		SEED_ENTER:
			NS = WAIT_EN;
				
		WAIT_EN:
			begin
				if (en == 1)
					NS = RANDOMIZE;
					
				else
					NS = WAIT_EN;
			end 
					
		RANDOMIZE:
			if (rnd_cnt < 3)
				NS = RANDOMIZE;
			
			else
				NS = FETCH_BUFF;
				
		FETCH_BUFF:
			NS = FETCH_CARD;
			
		FETCH_CARD:
			NS = GET_INDEX;
			
		GET_INDEX:
			NS = DATA_BUFF;
			
		DATA_BUFF:
			begin

					if (previous_card == 6'd0)
						NS = RANDOMIZE;
					
					else
						NS = REPLACE_CARDS;
			end
		
		REPLACE_CARDS:
			if (data_cnt < 1)
				NS = GET_INDEX;
			
			else
				NS = RESET_VALUES;
			
		RESET_VALUES:
			begin
				if (shuffle_cnt < 6'd25)
					NS = RANDOMIZE;
				
				else
					NS = DONE;
			end
			
		DONE:
			NS = DONE;
	
	endcase
		
		
always@(posedge clk or negedge rst)
	if(rst == 0)
		begin
				
			deck_index <= 6'd0;
			deck_write_data <= 6'd0;
			
			previous_card <= 6'd0;
			current_card <= 6'd0;
			
			previous_slot <= 6'd0;
			current_slot <= 6'd0;
			
			shuffle_cnt <= 6'd0;
			done <= 0;
			
			rnd_cnt <= 2'd0;
			data_cnt <= 2'd0;
				
		end
	else
		case(S)
			
			START:
				begin
					
					deck_index <= 6'd0;
					deck_write_data <= 6'd0;
					
					previous_card <= 6'd0;
					current_card <= 6'd0;
					
					previous_slot <= 6'd0;
					current_slot <= 6'd0;
					
					shuffle_cnt <= 6'd0;
					done <= 0;
					
					rnd_cnt <= 2'd0;
					data_cnt <= 2'd0;
				end
				
			SEED_ENTER:
				begin
					
					// idk, something to do with the seed, might be a redundant state, I'll figure it out later
					// I figured it out, I'll assign seed to the index location in the instantiation of black_jack_deck
					deck_index <= seed;
					
				end
				
			WAIT_EN:
				begin
					
				// this is here just to wait for the 
				
				end
			
			RANDOMIZE:
				begin
					
					// randomize deck_index
					/*
					put the psuedorandom generator here, I'm pretty sure it's just some 2:1 muxes with a conditional for the last bit but I don't remember
					*/	
					
					if(deck_index > 6'd52) // loops and checks the newly updated index to make sure it is under 52 
						begin
							deck_index <= deck_index / 2;
							rnd_cnt <= rnd_cnt + 1; 
						end	
					
					if (rnd_cnt > 2) // final loop and it assigns the index to the current
						begin
							current_slot <= deck_index;
							rnd_cnt <= rnd_cnt + 1;
						end
					
					
					if(rnd_cnt == 0)
						begin
							previous_slot <= current_slot;
							rnd_cnt <= rnd_cnt + 1;
							deck_index <= {deck_index[4], deck_index[3]^deck_index[2], deck_index[2], deck_index[1]^deck_index[4], deck_index[0], deck_index[5]^deck_index[0]};
						end
						
				end
				
			FETCH_BUFF:
				begin
				
					// this is the state equivalent of a middle fielder in baseball (I was a right fielder, yes this is middle fielder slander)
					/* I've thought about it and have come to a consensus with myself, it was wrong of me to slander middle fielders, the real 
						slander should be for left fielders because if there isn't a lefty, then they just sit there and twiddle their thumbs */
						
					/* I've now reached an agreement with left and middle field, I'm now taking into account that some people in the MLB are 
						capable of placing their shots when batting and that means that almost every ball that is hit won't end up being a slugfest
						between middle and right field like I'm used to */
						
					// so I know I've been ragging on this... nevermind, still don't need anything in here... nevermind, I can still use this
					// this is back to just existing here as a stop gap for data
					
					// look at you, you finally have a purpose
					
					rnd_cnt <= 0;
				end
				
			FETCH_CARD:
				begin
				
				// I think there actually needs to be a state before this one to buffer the memory
				// ok it's there now
				current_card <= deck_read_data;

				end
				
			GET_INDEX:
				begin
				
				// a buffer [not anymore] for the data to settle before either going back to get more data, or replacing the cards to shuffle the deck
				// it's your time to shine [REDACTED], I know you've heard this words before, but now I'll show you what they truely mean "get yo ass to work boy"
				if (~(previous_card == 6'd0))
					begin
						if (data_cnt == 0)
							begin
								deck_index <= current_slot;
							end
						else
							begin
								deck_index <= previous_slot;
							end
					end
				
				else
					begin
						
						// I don't think anything need to be put here
						
					end
							
						
					
				end
				
			DATA_BUFF:
				begin
				
					// I don't wanna talk about it, it's a buffer, that's all that you need to know
					if (previous_card == 6'd0)
						begin
						
							/* setting current_card on the first run through this chain to previous_card which settles 
								while going through the second time */
							previous_card <= current_card;
							
						end
						
					else
						begin
						
							// nothing happens here, everything should be set
						
						end
				
				end
				
			REPLACE_CARDS:
				begin
				
					// okay so I underestimated the complexity of this part of the FSM and now I'm going to play patty cake with this state and DATA_BUFF
					if (data_cnt == 0)
						begin
							deck_write_data <= previous_card;
							data_cnt <= data_cnt + 1;
						end
					else
						begin
							deck_write_data <= current_card;
							data_cnt <= data_cnt + 1;
						end
						
				end
				
			RESET_VALUES:
				begin
				
				current_slot <= 6'd0;
				previous_slot <= 6'd0;
				
				current_card <= 6'd0;
				previous_card <= 6'd0;
				
				data_cnt <= 0;
				
				shuffle_cnt <= shuffle_cnt + 1;
				
				end
				
			DONE:
				begin
				
					done <= 1;
				
				end
		endcase
	
	always@(posedge clk or negedge rst)
		enOut <= en;

endmodule