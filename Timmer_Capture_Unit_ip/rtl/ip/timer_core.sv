module timer_core (
  input logic         reset,
  input logic         clk,
  input logic [1:0]   add,
  //signal for timmer 
  input logic [31:0]  t_data,
  //signals for capture unit
  input bit           ren,
  input bit           wen,
  input logic         intrupt,
                      
  output logic        data_ready,
  output logic [31:0] r_data,
  input logic [1:0]   trig_sel
);
  //internal communication signals
  logic get_time;
  logic [31:0] w_data;
    
  timer timer(
    .clk(clk),
    .reset(reset),
    .t_add(add),
    .t_data(t_data),
    .get_time(get_time),
    .w_data(w_data)
  );
  
  input_capture_unit icu(
    .clk(clk),
    .reset(reset),
    .intrupt(intrupt),
    .r_add(add),
    .r_data(r_data),
    .data_ready(data_ready),
    .ren(ren),
    .w_data(w_data),
    .wen(wen),
    .get_time(get_time),
    .trig_sel(trig_sel)
  );
endmodule

