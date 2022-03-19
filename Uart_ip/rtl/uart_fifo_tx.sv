/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                               //
//                                                                                                     //
// Engineers:      M.Uzair Qureshi								                                       //
//                                                                                                     //
// Additional contributions by:                                                                        //
//                                                                                                     //
// Create Date:    08-MARCH-2022                                                                       //
// Design Name:    Uart                                                                                //
// Module Name:    uart_fifo_tx.sv                                                                     //
// Project Name:   UART PERIPHERAL								                                       //
// Language:       SystemVerilog			                                                           //
//                                                                                                     //
// Description:                                                                                        //
//     -Fifo that contains the data transfered.                                       				   //
//       				                                                                               //
//                                                                                                     //
// Revision Date:                                                                                      //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module uart_fifo_tx (
    input logic clk_i,
    input logic [7:0] data_i,
    input logic rst_ni,
    input logic wr_en,
    input logic rd_en,
    output logic intr_full,
    output logic intr_empty,
    input logic [2:0] intr_blevel,
    output logic wr_done,
    output logic [7:0] data_o
);
    logic [7:0] mem [7:0];
    logic [2:0] counter_wr;
    logic [2:0] counter1_rd;
    logic [2:0] r_intr_done;

assign intr_full = (counter_wr == 3'd7 && counter1_rd == 3'd0)? 1 : 0;
assign intr_empty = ((counter1_rd == 3'd7) || (counter1_rd == 3'd0 && counter_wr == 3'd0) || (counter1_rd == intr_blevel && intr_blevel > 0) )? 1 : 0;

always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        counter_wr <= 0;
        counter1_rd <= 0; 
        data_o <= 0;
        r_intr_done <= 0;
    end
    else if (wr_en && ~intr_full &&~rd_en) begin
        if (counter_wr < intr_blevel) begin
           counter_wr <= counter_wr + 1; 
        end
    end
    else if(~wr_en && ~intr_empty &&rd_en) begin
        if (counter1_rd < intr_blevel) begin
           counter1_rd <= counter1_rd + 1; 
        end
    end
    else begin
        counter_wr <= counter_wr;
        counter1_rd <= counter1_rd;
    end

    if (wr_en) begin
        if(counter_wr < intr_blevel) begin
            mem[counter_wr] <= data_i;   
            r_intr_done <= r_intr_done + 3'd1; 
        end
    end
    else if (rd_en) begin
        if (counter1_rd < intr_blevel) begin
           data_o <= mem[counter1_rd]; 
        end
    end


    if (r_intr_done == intr_blevel && r_intr_done > 0) begin
       wr_done <= 1'b1;
   end
   else begin
       wr_done <= 1'b0;
   end
   
   if (~rst_ni) begin
           for (int i =0 ; i<8 ; i++) begin
               mem[i] <= 8'd0;
           end
       end
end

endmodule