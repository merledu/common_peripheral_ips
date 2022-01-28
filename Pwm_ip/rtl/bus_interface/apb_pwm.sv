module	apb_pwm #(parameter DATA_WIDTH = 32,
                        ADDR_WIDTH = 8)(

	input   logic	     PCLK_i,	// CLK signal											
	input   logic	     PRST_ni,// Active low reset												
	input   logic	     PWRITE_i,	// write =1 write : write =0 read									
	input   logic [ADDR_WIDTH -1:0]  PADDR_i,// Adress of register to set/modify											
	input   logic [DATA_WIDTH -1:0] PWDATA_i,//	
	input   logic        PSEL_i,PENABLE_i,// Peripheral select or enable signals																			
	output  logic [DATA_WIDTH -1:0] PRDATA_o, // read channel 																								
  	output  logic        o_pwm_1, // PWM output of 1st channel 
 	output  logic        o_pwm_2, // PWM output of 2nd channel 
	output  logic     	 oe_pwm1, // PWM valid indication 
	output  logic     	 oe_pwm2, // PWM valid indication
	output  logic        PSLVERR_o,PREADY_o // Error and Ready Signals
);

logic [DATA_WIDTH -1 :0] wdata,rdata;
logic [ADDR_WIDTH -1 :0] addr;
logic write;

pwm #(
.DATA_WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH) ) 
PWM_peripheral (
.clk_i(PCLK_i),
.rst_ni(PRST_ni),
.w_en(write),
.rd_en(~write),
.wdata_i(wdata),
.addr_i(addr),
.rdata_o(rdata),
.o_pwm_1(o_pwm_1),
.o_pwm_2(o_pwm_2),
.oe_pwm1(oe_pwm1),
.oe_pwm2(oe_pwm2)
);

assign wdata = (PSEL_i && PENABLE_i)? PWDATA_i :'d0;
assign addr  = (PSEL_i && PENABLE_i)? PADDR_i  :'d0;
assign write  = (PSEL_i && PENABLE_i)? PWRITE_i  :'d0;
assign rdata  = (PSEL_i && PENABLE_i)? PRDATA_o  :'d0;

	assign PSLVERR_o = 1'b0;
	assign PREADY_o = 1'b1;

endmodule
