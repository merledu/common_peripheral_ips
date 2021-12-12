module edge_detect(
  input logic  level,
  input logic  clk,
  output logic pos_edge,
  output logic neg_edge
);
  logic d_level; 
  always @(posedge clk) d_level<=level;
  assign pos_edge = level && ~d_level;
  assign neg_edge = ~level && d_level;
endmodule
