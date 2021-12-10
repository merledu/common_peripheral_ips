
module timer_tlul #(
  parameter int AW = 9,
  parameter int DW = 32,
  localparam int DBW = DW/8
) (

   input logic clk_i,
   input logic rst_ni,

   input  tlul_pkg::tl_h2d_t tl_i,
   output tlul_pkg::tl_d2h_t tl_o,
   
   output intr_o

);


(
  
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  rv_timer #(
    .AW (AW),
    .DW (DW),
  ) u_timer (
    .clk_i	(clk_i),
    .rst_ni	(rst_ni),
		
    .reg_we	(reg_we),
    .reg_re	(reg_re),
    .reg_addr	(reg_addr),
    .reg_wdata	(reg_wdata),
    .reg_be	(reg_be),
    .reg_rdata	(reg_rdata),
    .reg_error	(reg_error),

    .intr_timer_expired_0_0_o	(intr_o)
  );

  tlul_adapter_reg #(
     .RegAw(AW),
     .RegDw(DW)
   ) u_reg_if (
     .clk_i   (clk_i),
     .rst_ni  (rst_ni),
 
     .tl_i    (tl_i),
     .tl_o    (tl_o),
 
     .we_o    (reg_we),
     .re_o    (reg_re),
     .addr_o  (reg_addr),
     .wdata_o (reg_wdata),
     .be_o    (reg_be),
     .rdata_i (reg_rdata),
     .error_i (reg_error)
   );

endmodule