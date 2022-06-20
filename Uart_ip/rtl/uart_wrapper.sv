`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2022 03:55:08 PM
// Design Name: 
// Module Name: uart_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_wrapper(
//    input logic clk_in1,
//    input logic rst,
    input logic clk_i,
//     input logic clk_in1,
    input logic rst_ni
//     output logic tx_o,
//    input logic rx_i
//    output logic led_chk 
//    output logic led_chk1 =1,
//    output logic led_chk2 =1

    
    );
//      logic clk_i; 
//       logic pwrite_i;
    //   logic [31:0] pwdata_i;
    //   logic [31:0] prdata_o;
    //   logic [11:0]  paddr_i;    
    //   logic tx_o;
    //   logic rx_i;
    //   logic intr_tx;
    //   logic penable_i;
    //   logic pslverr_o;
    //   logic pready_o;
    //   logic psel_i;
    //   logic intr_rx;
   logic [11:0]count = 0;
      //logic rst_l;
//      logic led_chk = 0;

//	logic clk_i;
//	logic rst_ni;
	logic [31:0] reg_wdata;
	logic [11:0] reg_addr;
	logic reg_we;
	logic reg_re;
	logic rx_i;
	logic [31:0] reg_rdata;
	logic tx_o;
	logic intr_tx;
	logic intr_rx;
	logic intr_tx_level;
	logic intr_rx_timeout;
	logic intr_tx_full;
	logic intr_tx_empty;
	logic intr_rx_full;
	logic intr_rx_empty;
	
	
	logic [31:0] tx_input;
    
	uart_core utc(
		.clk_i(clk_i),
		.rst_ni(rst_ni), 
		.reg_we(reg_we),
		.reg_re(reg_re),
		.reg_wdata(reg_wdata),
		.reg_rdata(reg_rdata),
		.reg_addr(reg_addr),   
		.tx_o(tx_o),
		.rx_i(tx_o),
		.intr_tx(intr_tx),
		.intr_rx(intr_rx),
		.intr_tx_level(intr_tx_level),
		.intr_rx_timeout(intr_rx_timeout),
		.intr_tx_full(intr_tx_full),
		.intr_rx_full(intr_rx_full),
		.intr_rx_empty(intr_rx_empty),
		.intr_tx_empty(intr_tx_empty)
	);
    
//    clk_wiz_0 clk_gen
//         (
//          .clk_out1(clk_i),
//         .clk_in1(clk_in1)
//         );
         
//         assign rst_ni = ~rst;
         
always @(posedge clk_i) begin
    if(~rst_ni) begin
        count <= 0;
    end
    else  begin
//       if((count < 10 || intr_rx == 1'b1) && count < 30 )
//        count <= count + 1;
        
         if(count < 30 )
               count <= count + 1;
    end
end
         
always @(posedge clk_i) begin
    if(count == 12'd4) begin
        reg_we <= 1'b1;
        reg_re <= 1'b0;
        reg_addr <= 12'd0;        												//at address 0
	    reg_wdata <= 32'd43;
    end

    else if(count == 12'd5) begin
        reg_addr <= 12'd24;       												//level of tx_fifo at address 24
	    reg_wdata <= 32'd4;
    end 
    else if(count == 12'd6) begin
            reg_addr <= 12'd4; 
            reg_wdata <= 32'd85;
    end 
    else if(count == 12'd7) begin
                reg_addr <= 12'd4; 
                reg_wdata <= 32'd90;
        end 
        else if(count == 12'd8) begin
                    reg_addr <= 12'd4; 
                    reg_wdata <= 32'd65;
            end 
            else if(count == 12'd9) begin
                        reg_addr <= 12'd4; 
                        reg_wdata <= 32'd73;
                end 
                else if(count == 12'd10) begin
                            reg_addr <= 12'd4; 
                            reg_wdata <= 32'd82;
                    end 
    else if(count == 12'd11) begin
            reg_addr <= 12'd28;        												//tx_fifo read enable
	        reg_wdata <= 32'd1;
    end
    else if(count == 12'd12) begin
                reg_addr <= 12'd28;
                reg_wdata = 32'd0;
    end
//    else if(count == 12'd9) begin
//                paddr_i = 12'd24;
//                pwdata_i = 8'h0;
//    end
    else if(count == 12'd13) begin
            reg_addr <= 12'h00c;
	        reg_wdata <= 32'd1;
    end
    
     else if(count == 12'd10) begin
                reg_we <= 1'b0;
                reg_re <= 1'b1; 
                reg_addr = 12'h008;
//                tx_input <= reg_rdata;
//                led_chk <= (reg_rdata == 32'd97)? 1 : 0;
        end  
       else if(count == 12'd11) begin
           led_chk <= (reg_rdata == 32'd97)? 1 : 0;
       end
        
       
    // else if(count == 12'd10) begin
    //         paddr_i = 12'd20;
    //         pwdata_i = 1'd0;
    // end  
    // else if(count == 12'd11) begin
    //        paddr_i = 12'd28;
    //        pwdata_i = 1'd1;
    // end
    // else if(count == 12'd12) begin
    //            paddr_i = 12'd28;
    //            pwdata_i = 1'd0;
    // end        
end 

//assign rx_i = tx_o;       
endmodule
