/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      M.Uzair Qureshi								                                  							     //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    08-MARCH-2022                                                                       //
// Design Name:    Uart                                                                                //
// Module Name:    uart_rx.sv                                                                          //
// Project Name:   UART PERIPHERAL								                                  							     //
// Language:       SystemVerilog			                                                			           //
//                                                                                                     //
// Description:                                                                                        //
//     -This modules receives the data serially and saves the data.                    							   //
//       				                                                                         				       //
//                                                                                                     //
// Revision Date:                                                                                      //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module uart_rx (
	input logic clk_i,
	input logic rst_ni,                    //active low
	input logic rx_i,                      //serial input
	input logic rx_en_i,
	input logic [15:0] clks_per_bit,
	output logic [7:0] rx_o,                //Outputs Data recieved
	output logic rx_done_o,                    //high when the data is recieved
	output logic c_START
);

reg  [2:0] r_states;
reg [7:0] r_rx_data;
reg [15:0] r_clk_count;
reg r_rx_done;
reg [2:0] r_index;

reg r_rx_data_r;
reg r_rx_data_mr;

//states
localparam IDLE = 3'b000; 
localparam START = 3'b001;
localparam DATA = 3'b010;
localparam STOP = 3'b011;
localparam CLEANUP = 3'b100;

always @(posedge clk_i) begin
	if(~rst_ni) begin
		r_rx_data_r <= 1'b1;
		r_rx_data_mr <= 1'b1;
	end
	else begin
		if(rx_en_i == 1'b1) begin
			r_rx_data_r <= rx_i;
			r_rx_data_mr <= r_rx_data_r;
		end
		else begin
			r_rx_data_r <= 1'b1;
			r_rx_data_mr <= r_rx_data_r;
		end
	end
end

always @(posedge clk_i or negedge rst_ni) begin
	if(~rst_ni) begin                       //if reset = 0 
		r_states <= IDLE;                   //Starts jumps to IDLE
		r_clk_count <= 16'd0;               //Clock count resets
		r_rx_data <= 8'd0;                  //resets the data register
		r_index <= 3'd0;                    //resets index
		r_rx_done <= 1'b0;                           //Done signal resets
		c_START <= 1'b0;
	end
	else begin
		case(r_states)
			IDLE: begin
				r_rx_done <= 1'b0;
				r_clk_count <= 16'd0;
				r_rx_data <= 8'd0;
				r_index   <= 3'd0;

				if(r_rx_data_mr == 1'b0) begin      // Start bit detected
						r_states <= START;              //state change to START_BIT        
				end
				else begin
						r_states <= IDLE;               //if start bit is not detected, state jumps back to IDLE
				end
			end

			START: begin
				c_START = 1'b1;
				if (r_clk_count == ((clks_per_bit - 1'b1)>>1)) begin    //shifts 1 bit towards right i.e. divide by two , to check the middle of start bit if it's still low                    //start bit detected i.e. equal to 0
						if (r_rx_data_mr == 1'b0) begin                 //start bit detected i.e. equal to 0
							r_clk_count <= 16'd0;                       // reset counter, found the middle
							r_states <= DATA;                           //when start bit is detected,state shifts to  DATA_BITS
						end
						else begin
							r_states <= IDLE;                           //If start bit is not there,then it jumps back to IDLE state
						end
				end
				else begin
					r_clk_count <= r_clk_count + 16'd1;             //increment in clock count until the middle of the start bit
					r_states <= START;                              //jumps back to state start until the middle of start bit
				end
			end
	
			DATA: begin
				c_START = 1'b0;
				if (r_clk_count < (clks_per_bit - 1'b1)) begin         
					r_clk_count <= r_clk_count + 16'd1;             //Increments clock counts until next bit
					r_states <= DATA;                               //jumps to state bit until next bit
				end
				else begin
					r_clk_count <= 16'd0;                           //when 1 bit recieved, it reset the clock count
					r_rx_data[r_index] <= r_rx_data_mr;             //transfers the serial bit
				
					if(r_index < 7) begin                               //as 8 bit have to be transfered
						r_index <= r_index + 3'd1;          //increment in index till 8 bits are transfered
						r_states <= DATA;                           //jump back to DATA state till all the bits are transfered
					end
					else begin
						r_index <= 3'd0;                            //resets index
						r_states <= STOP;                               //jumps to stop state
					end
				end
			end
				
			STOP: begin
				if (r_clk_count < (clks_per_bit - 1'b1)) begin
					r_clk_count <= r_clk_count + 16'd1;             //increment till the stop bit finishes
					r_states <= STOP;                               //jumps back to STOP_BIT state
				end
				else begin
					r_rx_done <= 1'b1;                              //once the data is recieved this signal is high
					r_clk_count <= 16'd0;                           //clock count resets once the data is recived
					r_states <= CLEANUP;                            //jumps to CLEANUP state
				end
			end
	
			CLEANUP: begin
				r_rx_done <= 1'b0;
				r_states <= IDLE;                                   //jumps back to IDLE state to reset the registers
			end
	
			default:
				r_states <= IDLE;                                   //Default state is set to IDLE
		endcase
	end
end
	
assign rx_done_o = r_rx_done;                                         //signal outputs from register to output pin
assign rx_o = r_rx_data;                                         //data outputs from register to output pin

endmodule