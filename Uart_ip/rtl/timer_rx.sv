module timer_rx (
    input logic clk_i,
    input logic rst_ni,
    input logic [15:0] baud,
    input logic rx_done,
    input logic c_START,
    output logic rx_timeout
);
    
//logic [2:0] count_byte;
logic [15:0] b_clk_count;
logic r_rx_timeout;
logic [1:0] states;

localparam DONE_DET = 0;
localparam S_DET = 1;
localparam CLEANUP = 2;
localparam S_NDET = 3;

always @(posedge clk_i) begin
    if(~rst_ni) begin
       //count_byte <= 0;
       b_clk_count <= 0; 
       r_rx_timeout <= 0;
       states <= DONE_DET;
    end
    else begin    
        case(states)
            DONE_DET: begin
               if(rx_done == 1'b1) begin
                    states <= S_DET;
                end
                else begin
                    states <= DONE_DET;
                end 
            end

            S_DET: begin                                         
                    //count_byte <= count_byte + 1'b1;
                    if(b_clk_count < (baud - 1'b1)) begin
                        if (c_START == 1'b1) begin
                            r_rx_timeout <= 1'b0;
                            states <= CLEANUP;
                        end
                        else begin
                            //if(b_clk_count == ((baud - 1'b1)>>1) begin
                            //   r_rx_timeout <= 1'b1; 
                            //end
                            b_clk_count <= b_clk_count + 1'b1;
                            states <= S_DET;
                        end
                    end
                    else begin
                        states <= S_NDET;
                    end
            end

            S_NDET: begin
                r_rx_timeout <= 1'b1;
                states <= CLEANUP;
            end

            CLEANUP: begin
                r_rx_timeout <= 0;
                b_clk_count <= 0;
                //count_byte <= 0;
                states <= DONE_DET;
            end

        default: begin
            r_rx_timeout <= 0;
            b_clk_count <= 0;
            //count_byte <= 0; 
        end
        endcase
    end
end

assign rx_timeout = r_rx_timeout;

endmodule