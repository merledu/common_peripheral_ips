module top_adapter (
  input logic clk_i,
  input logic rst_ni,

  // Bus Interface
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,

  input logic intrupt,
  output logic data_ready

);
  logic [1:0]add;
  //signal for timmer
  logic [31:0]t_data;
  //signals for capture unit
  bit ren;
  bit  wen;
  logic intrupt;
  logic [31:0] r_data;
  logic [1:0] trig_sel;
  timer_core timer_core(
    .clk(clk_i),
    .reset(rst_ni),

    .ren     (re),
    .wen     (we),
    .t_data  (t_data),
    .r_data  (r_data),
    .add     (add),
    
    .intrupt    (intrupt),
    .data_ready  (data_ready),
    
    .trig_sel(trig_sel)
  );
  tlul_adapter_reg #(
    .RegAw(1),
    .RegDw(32)
 ) u_reg_if (
   .clk_i,
   .rst_ni,
    
   .tl_i (tl_i),
   .tl_o (tl_o),
    
   .we_o    (wen),
   .re_o    (ren),
   .addr_o  (add),
   .wdata_o (t_data),
   //.be_o    (be),
   .rdata_i (r_data),
   //.error_i (1'b0)
);
endmodule
