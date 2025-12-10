module shuffle_deck_v2(
	input clk,
	input rst,
	input cont,
	
	// these inputs control when the FSM starts and what seed the pseudorandom number generater runs under
	input en,
	input [5:0]seed,
	input [5:0] deck_read_data,
	
	// lets the top level module know that the shuffling has concluded
	output reg done,
	
	
	//Debug variables to tell me whats happening in here
	output reg [4:0] SS,
	
	output reg enOut, 
	output reg [5:0] deck_index, 
	output reg [5:0] deck_write_data,
	output reg wren
);


/* these variables will store the current and previous card that are being swapped with the shuffling of the deck */
reg [5:0]zero_card;
reg [5:0]temp_card;
reg [5:0]rand_card;
reg [5:0]rand_ind;

reg [16:0]shuffle_cnt;

reg [4:0]NS;
reg [4:0]S;

parameter START = 5'd0, // use this state to set initial zeroes and such

			 SEED_ENTER = 5'd1, // use this to set what the seed for the pseudorandom number generator is
			 
			 WAIT_EN = 5'd2, // this is just to wait for the enable signal from the high level module to allow the FSM to start
			 
			 ASSIGN_ZERO_CARD = 5'd3,
				
			ASSIGN_ZERO_CARD_BUFF = 5'd4,
			 
			RAND_IND = 5'd5,
			 
			SET_INDEX = 5'd6,
			
			SET_INDEX_BUFF = 5'd7,
			
			ASSIGN_RAND_CARD = 5'd8,
			
			ASSIGN_RAND_CARD_BUFF = 5'd9,
			
			ASSIGN_RAND_MEM = 5'd10,
			
			ASSIGN_RAND_MEM_BUFF = 5'd11,
			 
			SET_IND_ZERO = 5'd12,
			
			SET_IND_ZERO_BUFF = 5'd13,
			
			REASSIGN_ZERO_MEM = 5'd14,
		
			REASSIGN_ZERO_MEM_BUFF = 5'd15,
			
			INC = 5'd16,
			
			DONE = 5'd17,
			
			ERROR = 5'd18,
			
			RAND_IND_CHECK = 5'd22;
			
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
					NS = ASSIGN_ZERO_CARD;
					
				else
					NS = WAIT_EN;
			end 
			
		ASSIGN_ZERO_CARD:
			NS = ASSIGN_ZERO_CARD_BUFF;
				
		ASSIGN_ZERO_CARD_BUFF:
			NS = RAND_IND;
		 
		RAND_IND:
			NS = RAND_IND_CHECK;
		
		RAND_IND_CHECK:
			NS = SET_INDEX;
		 
		SET_INDEX:
			NS = SET_INDEX_BUFF;
		
		SET_INDEX_BUFF:
			NS = ASSIGN_RAND_CARD;
		
		ASSIGN_RAND_CARD:
			NS = ASSIGN_RAND_CARD_BUFF;
		
		ASSIGN_RAND_CARD_BUFF:
			NS = ASSIGN_RAND_MEM;
		
		ASSIGN_RAND_MEM:
			NS = ASSIGN_RAND_MEM_BUFF;
		
		ASSIGN_RAND_MEM_BUFF:
			NS = SET_IND_ZERO;
		 
		SET_IND_ZERO:
			NS = SET_IND_ZERO_BUFF;
		
		SET_IND_ZERO_BUFF:
			NS = REASSIGN_ZERO_MEM;
		
		
		REASSIGN_ZERO_MEM:
			NS = REASSIGN_ZERO_MEM_BUFF;
			
		
		REASSIGN_ZERO_MEM_BUFF:
			NS = INC;
		
		INC:
			if(shuffle_cnt > 10000)
				NS = DONE;
			else
				NS = ASSIGN_ZERO_CARD;
		
		DONE: 	
			NS = DONE;
		
		
		ERROR:
			NS = ERROR;
	
		default: NS = ERROR;
		
	endcase
	
	always@(posedge clk or negedge rst)
	if(rst == 0)
		begin
			zero_card <= 6'd0;
			temp_card <= 6'd0;
			rand_card <= 6'd0;
			rand_ind <= 6'd0;
			
			deck_index <= 6'd0;
			deck_write_data <= 6'd0;
			wren <= 0;
	
			shuffle_cnt <= 6'd0;
			done <= 0;
			
				
		end
	else
		case(S)
			
			START:
				begin
					
					zero_card <= 6'd0;
					temp_card <= 6'd0;
					rand_card <= 6'd0;
					rand_ind <= 6'd0;
					
					deck_index <= 6'd0;
					deck_write_data <= 6'd0;
					wren <= 0;
	
					shuffle_cnt <= 6'd0;
					done <= 0;
			
				end
				
			SEED_ENTER:
				begin
					
					// idk, something to do with the seed, might be a redundant state, I'll figure it out later
					// I figured it out, I'll assign seed to the index location in the instantiation of black_jack_deck
					rand_ind <= seed;
					
				end
				
			WAIT_EN:
				begin
					
				// this is here just to wait for the 
				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
				end
			ASSIGN_ZERO_CARD:
				begin
					zero_card <= deck_read_data;
				end
			
		
			ASSIGN_ZERO_CARD_BUFF:
				begin
				end
			 
			RAND_IND:
				begin
				rand_ind <= 53 * rand_ind + 3;
				//rand_ind <= {rand_ind[4], rand_ind[3]^rand_ind[2], rand_ind[2], rand_ind[1]^rand_ind[4], rand_ind[0], rand_ind[5]^rand_ind[0]};
				end
			 
			RAND_IND_CHECK:
					begin
						rand_ind <= rand_ind % 52;
					end
			
			SET_INDEX:
				begin
					deck_index <= rand_ind;
				end
			
			SET_INDEX_BUFF:
				begin
				end
			
			ASSIGN_RAND_CARD:
				begin
					rand_card <= deck_read_data;
					deck_write_data <= zero_card;
				end
			ASSIGN_RAND_CARD_BUFF:
				begin
					wren <= 1;
				end
			
			ASSIGN_RAND_MEM:
				begin

				end
			ASSIGN_RAND_MEM_BUFF:
				begin
					wren <= 0;
				end
			 
			SET_IND_ZERO:
				begin
					deck_index <= 0;
					deck_write_data <= rand_card;
				end
			
			SET_IND_ZERO_BUFF:
				begin
					wren <= 1;
				end
			
			
			REASSIGN_ZERO_MEM:
				begin

				end
				
			
			REASSIGN_ZERO_MEM_BUFF:
				begin
					wren <= 0;
				end
			
			INC:
				begin
					shuffle_cnt <= shuffle_cnt + 1;
				end
			
			DONE: 	
				begin
					done <= 1;
					wren <= 0;
				end
		endcase
endmodule
			

