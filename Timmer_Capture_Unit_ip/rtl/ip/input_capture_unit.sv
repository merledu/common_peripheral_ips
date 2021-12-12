module input_capture_unit(
  //signals for capture unit
  input logic         clk,
  input logic         reset,
  input logic         intrupt,
  input bit           ren,
  input bit           wen,
  input logic [1:0]   r_add,
  output logic        data_ready,
  output logic [31:0] r_data,
  //signal to select level triger or edge triger
  input logic [1:0]   trig_sel,
  //signals to communicate with timmer
  input logic [31:0]  w_data,
  output logic        get_time
);
  logic real_intrupt;
  
  logic pos_edge;
  logic neg_edge;
  logic  [31:0] intrupt_time ;
//calling the edge detector modules
edge_detect e_edge(
  .level(intrupt),
  .clk(clk),
  .pos_edge(pos_edge),
  .neg_edge(neg_edge)
);
  always_comb begin
    case (trig_sel)
    	2'b00:real_intrupt=intrupt;
    	2'b01:real_intrupt=pos_edge;
    	2'b10:real_intrupt=neg_edge;
    	default:real_intrupt=intrupt;
  	endcase
  end
  //logic clock;
  //assign clock=(wen==1)? wen:clk;
 
   //if read data enable get output
  assign data_ready = (ren==0)? 0:1;
  
  //getting intrupt time from timmer
  assign get_time =(real_intrupt==1 && r_add==2'b11)? 1:0;
  //storing the intrupt time or reseting at reset low
  /*always_comb begin 
    if(wen) clock=wen;
    else clock=clk;
  end*/
  always @(posedge clk )begin
    r_data <= (ren==1)? intrupt_time:32'd0; 
    intrupt_time <=(wen==1)? w_data:32'd0;
     if (reset==0)begin
    	intrupt_time<=32'd0;
     end
  end
endmodule  
