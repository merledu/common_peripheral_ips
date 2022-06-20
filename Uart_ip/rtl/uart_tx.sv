/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      M.Uzair Qureshi								                           							             //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    08-MARCH-2022                                                                       //
// Design Name:    Uart                                                                                //
// Module Name:    uart_tx.sv                                                                          //
// Project Name:   UART PERIPHERAL								                                       							 //
// Language:       SystemVerilog			                                                           			 //
//                                                                                                     //
// Description:                                                                                        //
//     -The data (a byte) is provided to the module and it trasfers the data serially. 				   			 //
//       				                                                                                			 //
//                                                                                                     //
// Revision Date:                                                                                      //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module uart_tx (
	input logic clk_i,
	input logic rst_ni,                    //active low 
	input logic tx_en_i,                   //when tx_en_i is high,enables the transfer of data
	input logic [7:0] tx_data_i,           //contains the data to be transfered
	input logic [15:0] clks_per_bit,       //numbers of clks per bit; clks_per_bit = (Frequency of i_Clock)/(Frequency of UART)         
	output logic tx_o,                     //serial transfer output signal
	output logic tx_done_o                 //high when transfer is done
);

reg [2:0] r_states;                       //contains all the states
reg [15:0] r_clk_count;                   //counts the number of clocks
reg [2:0] r_index ;                        //tells the index of data
reg [7:0] r_tx_data;                      //data is transfered from i_TX_byte to r_TX_data
reg r_tx_done;                            //this signal is high when the transfer is done

//states
localparam IDLE = 3'b000;                   //waits for tx_en signal to be high else no operation is performed
localparam START = 3'b001;                  //start bit is sent in this state
localparam DATA = 3'b010;                   //data bits are transfered in this state
localparam STOP = 3'b011;                   //stop bit is sent in this state, which shows that the data is transfered
localparam CLEANUP = 3'b100;                //tx_done signal set to high and moves back to idle state

always @(posedge clk_i or negedge rst_ni) begin
	if(~rst_ni) begin
		r_states <= IDLE;
		r_clk_count <= 16'd0;
		r_index <= 3'b000;
		r_tx_data <= 8'd0;              
		r_tx_done <= 1'b0;
		tx_o <= 1'b1;
	end
	
	else begin
		case(r_states)
			IDLE:   begin
				tx_o <= 1'b1;                   //set high initailly
				r_tx_done <= 1'b0;
				r_index <= 3'b000;
				r_clk_count <= 16'd0;
		
				if(tx_en_i == 1'b1) begin               //if transfer is enabled
						r_tx_data <= tx_data_i;     //data is transfered to register
						r_states  <= START;         //after tx_en is high state will move to START_BIT state
				end
				else begin
						r_states <= IDLE;
				end
			end
		
			START:  begin
				tx_o <= 1'b0;                   //sends start bit which is equal to 0 , to start the transfer of data
		
				if(r_clk_count < clks_per_bit - 1) begin
						r_clk_count <= r_clk_count + 16'd1;     //increment in clock count till the condition breaks
						r_states    <= START;                   //jumps backs to state START until start bit is finished
				end
				else    begin
						r_clk_count <= 16'd0;                   //resets the counter
						r_states <= DATA;                       //jumps to DATA state,where the data is transfered
				end
			end
		
			DATA: begin
				tx_o <= r_tx_data[r_index];                 //sends the data to output one by one
				if(r_clk_count < clks_per_bit - 16'd1) begin
					r_clk_count <= r_clk_count + 16'd1;
					r_states    <= DATA;                    //jumps backs to state DATA until 1 bit is sent completely
				end
				else begin
					r_clk_count <= 16'd0;
		
					if(r_index < 7)  begin              //total index of the register containing data
									r_index <= r_index + 8'd1;  //increment in index, so next bit can be transfered
									r_states <= DATA;                   //move back to state DATA to transfer next bit
							end
							else begin                              //as all bits are transfered
									r_index <= 3'd0;                //reset the index
									r_states <= STOP;                   //as all the bits are transfered , move to state STOP 
							end
					end
		
			end
		
			STOP: begin
					tx_o <= 1'b1;                               //sents the stop bit,which show that the data is transfered
					if(r_clk_count < clks_per_bit - 16'd1) begin
							r_clk_count <= r_clk_count + 16'd1;
							r_states    <= STOP;
					end
					else begin
							r_tx_done <= 1'b1;                       //this signal is high when the transfer is done
							r_clk_count <= 16'd0;                    //resets the counter
							r_states <= CLEANUP;                     //move to CLEANUP state
					end
		
			end
				
			CLEANUP: begin
				r_tx_done <= 1'b1;                            
				r_states <= IDLE;                            //sent to idle state, to clear the registers
			end
		
			default:
				r_states <= IDLE;                            //is none of the case is select,default case is IDLE
		
		endcase    
	end    
end

assign tx_done_o = r_tx_done;

endmodule