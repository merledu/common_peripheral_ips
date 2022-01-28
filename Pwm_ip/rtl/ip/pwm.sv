module	pwm #(parameter DATA_WIDTH = 32,
                        ADDR_WIDTH = 8)(

	input   logic	     clk_i,	// CLK signal											
	input   logic	     rst_ni,// Active low reset												
	input   logic	     w_en,rd_en,										
	input   logic [ADDR_WIDTH -1:0]  addr_i,// Adress of register to set/modify											
	input   logic [DATA_WIDTH -1:0] wdata_i,//																				
	output  logic [DATA_WIDTH -1:0] rdata_o, // read channel 																								
  	output  logic        o_pwm_1, // PWM output of 1st channel 
 	output  logic        o_pwm_2, // PWM output of 2nd channel 
	output  logic     	 oe_pwm1, // PWM valid indication 
	output  logic     	 oe_pwm2 // PWM valid indication


);
////////////////////control logic////////////////////////////
localparam  adr_ctrl_1	 =	0,  /// Parameters Defined 
		   adr_divisor_1 =	4,
		   adr_period_1	 =	8,
		   adr_DC_1		 =	12;

localparam  adr_ctrl_2	 =	16,
		   adr_divisor_2 =	20,
		   adr_period_2	 =	24,
		   adr_DC_2		 =	28;

	reg [2:0] ctrl_1=0;   // Registers Defined
	reg [2:0] ctrl_2=0;
	reg [DATA_WIDTH -1:0] period_1=0;
	reg [DATA_WIDTH -1:0] period_2=0;
	reg [DATA_WIDTH -1:0] DC_1=0;
	reg [DATA_WIDTH -1:0] DC_2=0;
	reg [DATA_WIDTH -1:0] divisor_1=0;
	reg [DATA_WIDTH -1:0] divisor_2=0;

	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			ctrl_1    <= 3'd0;
			ctrl_2    <= 3'd0;
			period_1  <=  'd0;
			period_2  <=  'd0;
			divisor_1 <=  'd0;
			divisor_2 <=  'd0;
			DC_1      <=  'd0;
			DC_2      <=  'd0;
		end
		else if (w_en) begin
			case (addr_i)
				adr_ctrl_1: ctrl_1       <= wdata_i[2:0];
				adr_ctrl_2: ctrl_2       <= wdata_i[2:0];
				adr_divisor_1: divisor_1 <= wdata_i[DATA_WIDTH -1:0];
				adr_divisor_2: divisor_2 <= wdata_i[DATA_WIDTH -1:0];
				adr_period_1: period_1   <= wdata_i[DATA_WIDTH -1:0];
				adr_period_2: period_2   <= wdata_i[DATA_WIDTH -1:0];
				adr_DC_1: DC_1           <= wdata_i[DATA_WIDTH -1:0];
				adr_DC_2: DC_2           <= wdata_i[DATA_WIDTH -1:0];				
			endcase
		end
	end
	
	
	wire pwm_1,pwm_2;
	assign pwm_1   = ctrl_1[1];
	assign pwm_2   = ctrl_2[1];
	
	reg clock_p1;
	reg clock_p2;
	reg [DATA_WIDTH -1:0] counter_p1;
	reg [DATA_WIDTH -1:0] counter_p2;
	reg [DATA_WIDTH -1:0] period_counter1;
	reg [DATA_WIDTH -1:0] period_counter2;
	reg pts_1;
	reg pts_2;
	
	always @(posedge clk_i or negedge rst_ni) begin
			if (~rst_ni) begin
				clock_p1   <= 1'd0;
				clock_p2   <= 1'd0;
				counter_p1 <=  'd0;
				counter_p2 <=  'd0;
			end
			else begin
				if (pwm_1) begin
					counter_p1 <= counter_p1 + 'd1;
					if (counter_p1 == (divisor_1 - 1)) begin
						counter_p1 <=  'd0;
						clock_p1 <= ~clock_p1;
					end
				end
				if (pwm_2) begin
					counter_p2 <= counter_p2 + 'd1;
					if (counter_p2 == (divisor_2 - 1)) begin
						counter_p2 <= 'd0;
						clock_p2 <= ~clock_p2;
					end
			    end
	        end
	end	

	always @(posedge clock_p1 or negedge rst_ni) begin
			if (!rst_ni) begin
				pts_1           <= 1'b0;
				oe_pwm1         <= 1'b0;
				period_counter1 <=  'd0;
			end
			else if (ctrl_1[0]) begin
					if (pwm_1) begin
						oe_pwm1             <= 1'b1;
						if (period_counter1 >= period_1)
							period_counter1 <= 'd0;
						else
							period_counter1 <= period_counter1 + 'd1;
						if (period_counter1 < DC_1)
							pts_1 <= 1'b1;
						else
							pts_1 <= 1'b0;
					end
			end
    end
	always @(posedge clock_p2 or negedge rst_ni)
			if (!rst_ni) begin
				pts_2 <= 1'b0;
				oe_pwm2 <= 1'b0;
				period_counter2 <= 'd0;
			end
			else if (ctrl_2[0]) begin
				if (pwm_2) begin
					oe_pwm2 <= 1'b1;
					if (period_counter2 >= period_2)
						period_counter2 <= 'd0;
					else
						period_counter2 <= period_counter2 + 'd1;
					if (period_counter2 < DC_2)
						pts_2 <= 1'b1;
					else
						pts_2 <= 1'b0;
				end
			end 

	assign o_pwm_1 = (ctrl_1[2] ? pts_1 : 1'b0);
	assign o_pwm_2 = (ctrl_2[2] ? pts_2 : 1'b0);
	always_comb
	if(rd_en ==1'b0) 
	rdata_o = (addr_i == adr_ctrl_1 ? {13'h0, ctrl_1} : (addr_i == adr_divisor_1 ? divisor_1 : (addr_i == adr_period_1 ? period_1 : (addr_i == adr_DC_1 ? DC_1 : (addr_i == adr_DC_2 ? DC_2 : (addr_i == adr_period_2 ? period_2 : (addr_i == adr_divisor_2 ? divisor_2 : (addr_i == adr_ctrl_2 ? {13'h0, ctrl_2} :32'd0))))))));
	else
	rdata_o = 'd0;
endmodule
