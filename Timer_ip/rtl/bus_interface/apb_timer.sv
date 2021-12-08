//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.12.2021 15:48:27
// Designer Name: Rehan Ejaz 
// Designe Name: APB timer Peripheral
// Module Name: apb_timer
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


module apb_timer
#(parameter APB_ADDR_WIDTH = 9,
  APB_DATA_WIDTH = 32 )(
  input  logic                      HCLK,
  input  logic                      HRESETn,
  input  logic [APB_ADDR_WIDTH-1:0] PADDR,
  input  logic               [31:0] PWDATA,
  input  logic                      PWRITE,
  input  logic                      PSEL,
  input  logic                      PENABLE,
  output logic               [31:0] PRDATA,
  output logic                      PREADY,
  output logic                      PSLVERR,

  output logic                 irq_o //  cmp interrupt
    );
  
  // Wires to connect wicth the peripheral
   
    logic [APB_ADDR_WIDTH-1:0] PADDR_p;
    logic               [31:0] PWDATA_p;
    logic                      PWRITE_p;
    logic               [31:0] PRDATA_p;
    logic                      PREADY_p;
    logic                      PSLVERR_p;


    rv_timer #(
        .AW(APB_ADDR_WIDTH),
        .DW(APB_DATA_WIDTH)
        ) timer_instance (
        .clk_i(HCLK),
        .rst_ni(HRESETn),
        .reg_we(PWRITE_p),
        .reg_re(~PWRITE_p),
        .reg_addr(PADDR_p),
        .reg_wdata(PWDATA_p),
        .reg_be(4'b1111),
        .reg_rdata(PRDATA_p),
        .reg_error(PSLVERR_p),
        .intr_timer_expired(),
        .intr_timer_expired_0_0_o(irq_o)
        );
   
    assign PREADY =1'b1;
   
    always_comb begin
     
        if(PSEL == 1'b1 && PENABLE == 1'b1 )begin
           
            PADDR_p   = PADDR    ;
            PWDATA_p  = PWDATA   ;
            PWRITE_p  = PWRITE   ; 
            PRDATA    = PRDATA_p ;
            PSLVERR   = PSLVERR_p;

        end
        else begin
            HCLK_p    = 'd0;
            HRESETn_p = 'd0;
            PADDR_p   = 'd0;
            PWDATA_p  = 'd0;
            PWRITE_p  = 'd0; 
            PRDATA    = 'd0;
            PSLVERR   = 'd0;
        end
        
    end
   
    
endmodule
