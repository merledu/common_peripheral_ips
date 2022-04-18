/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      M.Uzair Qureshi								                                       //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    08-MARCH-2022                                                                       //
// Design Name:    Uart                                                                                //
// Module Name:    uart_fifo_rx.sv                                                                     //
// Project Name:   UART PERIPHERAL								                                                     //
// Language:       SystemVerilog			                                                                 //
//                                                                                                     //
// Description:                                                                                        //
//     -Fifo that contains the data received.                                       				           //
//       				                                                                                       //
//                                                                                                     //
// Revision Date:                                                                                      //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module gen_fifo (
    input logic clk_i,
    input logic [7:0] data_i,
    input logic rst_ni,
    input logic wr_en,
    input logic rd_en,
    input logic fifo_clear,
    output logic intr_full,
    output logic intr_empty,
    output logic [7:0] data_o
);
    logic [7:0] mem [7:0];
    logic [2:0] counter_wr;
    logic [2:0] counter1_rd;


assign intr_full = (counter_wr == 3'd7 && counter1_rd == 3'd0)? 1 : 0;
assign intr_empty = ((counter1_rd == 3'd7) || (counter1_rd == 3'd0 && counter_wr == 3'd0))? 1 : 0;

always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        counter_wr <= 0;
        counter1_rd <= 0; 
        data_o <= 0;
    end
    else if (wr_en && ~intr_full &&~rd_en) begin
      counter_wr <= counter_wr + 1; 
    end
    else if(~wr_en && ~intr_empty &&rd_en) begin
      counter1_rd <= counter1_rd + 1; 
    end
    else begin
      counter_wr <= counter_wr;
      counter1_rd <= counter1_rd;
    end


    if (wr_en) begin
        if(counter_wr <= 3'd7) begin
            mem[counter_wr] <= data_i;
        end
    end
    else if (rd_en) begin
      data_o <= mem[counter1_rd];
    end

  if (~rst_ni || fifo_clear) begin
          for (int i =0 ; i<8 ; i++) begin
              mem[i] <= 8'd0;
          end
      end 
end
endmodule