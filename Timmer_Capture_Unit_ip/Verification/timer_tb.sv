module timer_tb;
  logic clk;
  logic reset;
  bit ren;
  bit  wen;
 // logic [4:0] r_add;
  logic intrupt;
  logic [31:0] r_data;
  logic [1:0]add;
  logic [31:0]t_data;
  logic [1:0] trig_sel;
  logic data_ready;
  timer_core top_file(
    .clk(clk),
    .reset(reset),
    .ren(ren),
    .r_data(r_data),
    .intrupt(intrupt),
    .add(add),
    .t_data(t_data),
    .wen(wen),
    .trig_sel(trig_sel),
    .data_ready(data_ready)
  );
initial begin
  $dumpvars(0);
  clk=0;
  reset=1;
  ren=0;
  wen=0;
  intrupt=0;
  add=2'b00;
  trig_sel=2'b10;
  t_data=32'd10;
  # 100;
  add=2'b10;
  t_data=32'd50;
  # 100;
  add=2'b01;
  t_data=32'd1;
  # 200;
  add=2'b11;
  wen=1;
  intrupt=1;
  # 200;
 // wen=0;
  intrupt=0;
  # 100;
  ren=1;
  # 500;
  intrupt=1;
trig_sel=2'b01;
  # 200;
 // wen=0;
  intrupt=0;
  # 100;
  ren=1;
  # 100;
  ren=1;
  # 500;
  intrupt=1;
  trig_sel=2'b00;
  # 200;
 // wen=0;
  intrupt=0;
  # 100;
  ren=1;
  # 100;
  reset=0;
  # 100;
  $finish;
end

always # 10 clk=~clk;
  
endmodule
