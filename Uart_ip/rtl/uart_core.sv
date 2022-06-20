/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      M.Uzair Qureshi								                                                     //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    08-MARCH-2022                                                                       //
// Design Name:    Uart                                                                                //
// Module Name:    uarr_core.sv                                                                        //
// Project Name:   UART PERIPHERAL								                                                     //
// Language:       SystemVerilog			                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//     -Connects all the modules of uart and contains all the configurable registers  								 //
//       				                                                                                       //
//                                                                                                     //
// Revision Date:                                                                                      //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module uart_core (
	input logic clk_i,
	input logic rst_ni,
	input logic [31:0] reg_wdata,
	input logic [11:0] reg_addr,
	input logic reg_we,
	input logic reg_re,
	input logic rx_i,
	output logic [31:0] reg_rdata,
	output logic tx_o,
	output logic intr_tx,
	output logic intr_rx,
	output logic intr_tx_level,
	output logic intr_rx_timeout,
	output logic intr_tx_full,
	output logic intr_tx_empty,
	output logic intr_rx_full,
	output logic intr_rx_empty
);
//data registers
logic [7:0] tx_data = 0;
logic [7:0] rx_data ;
//logic [7:0] r_rx ;

//control registers
logic [15:0] baud = 0;
logic tx_done = 0;
logic rd_d = 0;

logic c_START;
logic [7:0] r_rx;
logic rx_en = 0;
logic tx_en = 0;
logic rx_done; 
logic tx_byte_done;
logic tx_en_fifo = 0;
logic rd_en_fifo ;
logic rd = 0;
logic [2:0] tx_level = 0;
logic [7:0] tx_fifo_o;
logic rx_fifo_wr = 0;
logic rx_done_d = 0;
logic [7:0] rx_fifo_o ;
logic rd_en_rx_fifo;
logic [2:0] rx_level = 3'd0;
logic rx_wr_done;
logic tx_level_intr = 1'b0;
logic rx_timeout;
logic [2:0] count_byte = 3'd0;
logic rx_en_t ;
logic pwrite_d = 1'b0;
logic rd_en_tx ;
logic [2:0] r_tx_byte_done = 0;
logic fifo_en;
logic tx_fifo_en;
logic fifo_tx_clear;
logic fifo_rx_clear;


logic [2:0] count = 0;

uart_rx urx(
	.clk_i(clk_i),
	.rst_ni(rst_ni),           
	.rx_i(rx_i),               
	.rx_en_i(rx_en_t),
	.clks_per_bit(baud),
	.rx_o(r_rx),            
	.rx_done_o(rx_done),  
	.c_START(c_START)             
);

uart_tx utx(
	.clk_i(clk_i),
	.rst_ni(rst_ni),     
	.tx_en_i(tx_en),          
	.tx_data_i(tx_fifo_o), 
	.clks_per_bit(baud),              
	.tx_o(tx_o),         
	.tx_done_o(tx_byte_done)         
);

gen_fifo uft(
	.clk_i(clk_i),
	.data_i(tx_data),
	.rst_ni(rst_ni),
	.wr_en(fifo_en),
	.rd_en(rd),
	.intr_full(intr_tx_full),
	.intr_empty(intr_tx_empty),
	.data_o(tx_fifo_o),
	.fifo_clear(fifo_tx_clear)
);


gen_fifo ufr(
	.clk_i(clk_i),
	.data_i(rx_data),//rx_data
	.rst_ni(rst_ni),
	.wr_en(rx_fifo_wr),
	.intr_full(intr_rx_full),
	.intr_empty(intr_rx_empty),
	.rd_en(rd_en_rx_fifo),
	.data_o(rx_fifo_o),
	.fifo_clear(fifo_rx_clear)
);

timer_rx trx(
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	.baud(baud),
	.rx_done(rx_done),
	.c_START(c_START),
	.rx_timeout(rx_timeout)
);

localparam ADDR_BAUD = 12'h000;
localparam ADDR_TX_DATA = 12'h004;
localparam ADDR_RX_DATA =12'h008;
localparam ADDR_RX_EN = 12'h00c;
localparam ADDR_TX_FIFO_CLR = 12'h010;
localparam ADDR_RX_FIFO_CLR = 12'h014;
localparam ADDR_TX_FIFO_LEVEL = 12'h018;
localparam ADDR_RD_EN_TXFIFO = 12'h01c;

always @(posedge clk_i) begin
	if (~rst_ni) begin									//When reset is set to 0, it resets all the registers(active low)
			baud <= 16'd0;
			rx_en <= 1'b0;
//			rx_data <= 8'd0;
			tx_en_fifo <= 0;
			tx_level <= 0;
			rd_en_fifo <= 0;
			tx_data <= 0;
			intr_tx <= 0;
			intr_rx <= 0;
			r_tx_byte_done <= 0;
//			reg_rdata <= 0;
			fifo_tx_clear = 0;
			fifo_rx_clear = 0;
	end
	else begin
			if (rx_timeout == 1'b1 || intr_rx_full == 1'b1) begin
        intr_rx <= 1'b1;
    end
		if(reg_we) begin														//When pwrite is set to 1 
			case(reg_addr)
				ADDR_BAUD: begin
					baud[15:0] <= reg_wdata[15:0];						//at address: ADDR_BAUD it will take data from pwdata to confire the baud rate
				end		
				
				ADDR_TX_DATA: begin
					tx_data <= reg_wdata[7:0];								//at address: ADDR_TX_DATA it will take the data to be transfered
				end
				ADDR_RX_EN:begin
					rx_en <= reg_wdata[0];										//at address: ADDR_RX_EN it will enable the receiver
				end
				ADDR_RX_FIFO_CLR: begin
					fifo_rx_clear <= reg_wdata[0];
				end
				ADDR_TX_FIFO_LEVEL: begin
					tx_level <= reg_wdata[2:0];							//at address ADDR_TX_FIFO_LEVEL it will set the tx_level
				end
				ADDR_RD_EN_TXFIFO:begin
					rd_en_fifo <= reg_wdata[0];							//at address ADDR_RD_EN_TXFIFO it will read the data from tx fifo and enable the transmitter 
				end

				ADDR_TX_FIFO_CLR: begin
					fifo_tx_clear <= reg_wdata[0];
				end
				default: begin
						baud <= 16'd0;
						rx_en <= 1'b0;
						rd_en_fifo <= 1'b0;
						tx_level <= 1'b0;
				end        
			endcase
		end	//if(reg_we)
//		else if (reg_re) begin												//when reg_re is set to high
//			case(reg_addr)
//				ADDR_RX_DATA: begin
//					reg_rdata [7:0] <= rx_fifo_o [7:0];			//at address ADDR_RX_DATA it will read the data from the rx fifo and output to reg_rdata
//				end
//				ADDR_BAUD: begin
//          reg_rdata [7:0] <= baud[15:0];                        //at address: ADDR_BAUD it will take data from pwdata to confire the baud rate
//        end        
                                
//        ADDR_RX_EN:begin
//          reg_rdata [7:0] <= rx_en;                                        //at address: ADDR_RX_EN it will enable the receiver
//        end
//        ADDR_TX_FIFO_LEVEL: begin
//           reg_rdata [7:0] <= tx_level;                            //at address ADDR_TX_FIFO_LEVEL it will set the tx_level
//        end
//        ADDR_RD_EN_TXFIFO:begin
//          reg_rdata [7:0] <= rd_en_fifo;                            //at address ADDR_RD_EN_TXFIFO it will read the data from tx fifo and enable the transmitter 
//        end
				
//			  default: 
//			    reg_rdata <= 32'd0;
//			endcase   
//		end //else if (reg_re)
	end

//		if (rx_done) begin														//when rx_done triggers 
//				rx_data <= r_rx;													//the data is transfered from the receiver to the register rx_data
//		end

		if (tx_byte_done == 1'b0 && tx_done == 1'b1) begin			//when the tranmitter transmits 1 byte from the fifo
				r_tx_byte_done <= r_tx_byte_done + 3'd1;						//counter increments
		end

		if(r_tx_byte_done == tx_level && r_tx_byte_done > 0 && tx_done == 1)				//when the tranmitter transmit all the bytes from the fifo
		begin
				intr_tx <= 1'b1;																												//intr_tx is set high
		end

		tx_done <= tx_byte_done;
//		if (rd_en_tx == 1'b1) begin																									//when transmission is enabled																															
//				rd <= 1'b1;																															 
//		end
//		else begin
//			if ((tx_byte_done == 1'b0 && tx_done == 1'b1) && tx_level > count) begin
//					rd <= 1'b1;
//					count <= count + 1;																														//rd triggers after each byte to read the next byte from tx_fifo until all the bytes are transfered
//			end
//			else begin
//					rd <= 1'b0;
//			end
//		end

		pwrite_d <= reg_we;
end

always @(posedge clk_i) begin
	rd_d <= rd;
	if (rd_d == 1'b1 && rd == 1'b0 ) begin																					
			tx_en <= 1'b1;																													//tx_en triggers when new byte is to be transfered from the tx_fifo			
	end
	else begin
		 tx_en <= 1'b0; 
	end
	if (tx_level_intr == tx_level) begin
			intr_tx_level <= 1'b1;
	end
	else begin
			intr_tx_level <= 1'b0;
	end
end


always @(posedge clk_i) begin
	rx_done_d <= rx_done;
//	if(rx_done == 1'b0 && rx_done_d == 1'b1) begin
//    if(rx_done == 1'b1) begin
//		 rx_fifo_wr <= 1'b1;																										//when each byte is received rx_fifo_wr is set high to write the byte in the rx_fifo
//	end
//	else begin
//			rx_fifo_wr <= 1'b0;
//	end

//	if (rx_timeout == 1'b1 || intr_rx_full == 1'b1) begin
//		intr_rx <= 1'b1;
//	end
	

	if (reg_addr == ADDR_TX_DATA && reg_we) begin
		fifo_en <= 1'b1;
	end
	else begin
		fifo_en <= 1'b0;
	end
end

always_comb begin
    if (rx_done) begin														//when rx_done triggers 
				rx_data = r_rx;													//the data is transfered from the receiver to the register rx_data
	end
	else begin
	   rx_data = 0;
	end
    
    if (reg_re) begin												//when reg_re is set to high
                case(reg_addr)
                    ADDR_RX_DATA: begin
                        reg_rdata [7:0] = rx_fifo_o [7:0];            //at address ADDR_RX_DATA it will read the data from the rx fifo and output to reg_rdata
                    end
                    ADDR_BAUD: begin
              reg_rdata [7:0] = baud[15:0];                        //at address: ADDR_BAUD it will take data from pwdata to confire the baud rate
            end        
                                    
            ADDR_RX_EN:begin
              reg_rdata [7:0] = rx_en;                                        //at address: ADDR_RX_EN it will enable the receiver
            end
            ADDR_TX_FIFO_LEVEL: begin
               reg_rdata [7:0] = tx_level;                            //at address ADDR_TX_FIFO_LEVEL it will set the tx_level
            end
            ADDR_RD_EN_TXFIFO:begin
              reg_rdata [7:0] = rd_en_fifo;                            //at address ADDR_RD_EN_TXFIFO it will read the data from tx fifo and enable the transmitter 
            end
                    
                  default: 
                    reg_rdata = 32'd0;
                endcase   
            end //else if (reg_re)
            else begin
                reg_rdata = 32'd0;
            end

    if(rx_done == 1'b1) begin
		 rx_fifo_wr = 1'b1;																										//when each byte is received rx_fifo_wr is set high to write the byte in the rx_fifo
	end
	else begin
			rx_fifo_wr = 1'b0;
	end
	
	if (rd_en_tx == 1'b1) begin																									//when transmission is enabled																															
                    rd = 1'b1;                                                                                                                             
            end
            else begin
                if ((tx_byte_done == 1'b0 && tx_done == 1'b1) && tx_level > count) begin
                        rd = 1'b1;
                        count = count + 1;                                                                                                                        //rd triggers after each byte to read the next byte from tx_fifo until all the bytes are transfered
                end
                else begin
                        rd = 1'b0;
                end
            end

end
	
assign rx_en_t = rx_en && ~rx_timeout;																		
assign intr_rx_timeout = rx_timeout;
assign rd_en_tx = rd_en_fifo && pwrite_d;
//assign intr_rx = (rx_timeout == 1'b1 || intr_rx_full == 1'b1)? 1: 0;
assign rd_en_rx_fifo=(reg_addr == ADDR_RX_DATA && intr_rx && reg_re)? 1:0;
//assign fifo_en = (reg_addr == ADDR_TX_DATA) ? 1'b1 : 0;
//assign tx_fifo_en = fifo_en && reg_we;
endmodule