module timer(
  //signals for top
  input logic         clk,
  input logic         reset,
  input logic [1:0]   t_add,
  input logic [31:0]  t_data,
  //signals to communicate with capture unit
  input logic         get_time,
  output logic [31:0] w_data
);
  //internal signals
  logic real_clk;
  logic [31:0] delay;
  reg [31:0] mtime=32'd0;
  reg [31:0] mtimecmp;
  reg [31:0] step=32'd0;
  reg [31:0] prescaler=32'd9;
  logic [31:0] i=32'd0;
  logic [1:0] over_flow=2'd0;
  //assigning the delay or communicating with capture unit
  always_latch begin 
    if (t_add == 2'b00)begin 
      if(t_data==10) delay <=1;
      else begin
        prescaler <= t_data;
        delay <= 10%prescaler;
      end
    end
    if(get_time) begin
      w_data <=mtime;
    end
  end
  
  //dividing the clock
  always @(posedge clk ) begin
    if(i<delay) begin 
      i<= i+1;
      real_clk<=1;
    end
    else begin 
      i<=32'd0;
      real_clk<=0;
    end
  end
  //timmers functionings
  always @(posedge real_clk)  begin
    if(reset==0) mtime<=32'd0;
    else begin
      case(t_add)
        2'b01: begin
          step <= t_data;
        end
        2'b10: mtimecmp <= t_data;
        default: begin 
          mtimecmp <=32'd4294967295;
          step <=32'd1;
        end
      endcase
      if(mtime>=mtimecmp) begin 
        over_flow<=over_flow +1;
        mtime<=32'd0;
      end
      mtime <= mtime + step;
    end
  end
endmodule

