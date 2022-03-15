module uart_core (
    input logic pclk_i,
    input logic prst_ni,
    input logic [31:0] pwdata_i,
    input logic [11:0] paddr_i,
    input logic psel_i,
    input logic pwrite_i,
    input logic rx_i,
    output logic pslverr_o,
    output logic [31:0] prdata_o,
    output logic pready_o,
    output logic tx_o,
    output logic intr_tx,
    output logic intr_rx,
    input logic penable_i,
    output logic intr_tx_level,
    output logic intr_rx_timeout,
    output logic intr_tx_full,
    output logic intr_tx_empty,
    output logic intr_rx_full,
    output logic intr_rx_empty,
    output logic c_START,
    output logic [7:0] r_rx //changed
);
//data registers
logic [7:0] tx_data;
logic [7:0] rx_data;
//logic [7:0] r_rx ;

//control registers
logic [15:0] baud;
logic tx_done;
logic rd_d;


logic rx_en;
logic tx_en;
logic rx_done;
logic tx_byte_done;
logic tx_en_fifo;
logic rd_en_fifo;
logic rd;
logic [2:0] tx_level;
logic [7:0] tx_fifo_o;
logic wr_done;
logic rx_fifo_wr;
logic rx_done_d;
logic [7:0] rx_fifo_o;
logic rd_en_rx_fifo;
logic [2:0] rx_level = 3'b0;
logic rx_wr_done;
logic tx_level_intr = 1'b0;
logic rx_timeout;
logic [2:0] count_byte = 3'b0;
logic rx_en_t;
logic pwrite_d = 1'b0;
logic wr_en_tx ;
logic rd_en_tx ;
logic [2:0] r_tx_byte_done;


uart_rx urx(
    .clk_i(pclk_i),
    .rst_ni(prst_ni),           
    .rx_i(tx_o),               
    .rx_en_i(rx_en_t),
    .clks_per_bit(baud),
    .rx_o(r_rx),            
    .rx_done_o(rx_done),  
    .c_START(c_START)             
);

uart_tx utx(
    .clk_i(pclk_i),
    .rst_ni(prst_ni),     
    .tx_en_i(tx_en),          
    .tx_data_i(tx_fifo_o), 
    .clks_per_bit(baud),              
    .tx_o(tx_o),         
    .tx_done_o(tx_byte_done)         
);

uart_fifo_tx uft(
    .clk_i(pclk_i),
    .data_i(tx_data),
    .rst_ni(prst_ni),
    .wr_en(wr_en_tx),
    .rd_en(rd),
    .intr_full(intr_tx_full),
    .intr_empty(intr_tx_empty),
    .intr_blevel(tx_level),
    .data_o(tx_fifo_o),
    .wr_done(wr_done)
);


uart_fifo_rx ufr(
    .clk_i(pclk_i),
    .data_i(rx_data),//rx_data
    .rst_ni(prst_ni),
    .wr_en(rx_fifo_wr),
    .intr_full(intr_rx_full),
    .intr_empty(intr_rx_empty),
    .rd_en(rd_en_rx_fifo),
    .data_o(rx_fifo_o),
    .wr_done(rx_wr_done)
);

timer_rx trx(
    .clk_i(pclk_i),
    .rst_ni(prst_ni),
    .baud(baud),
    .rx_done(rx_done),
    .c_START(c_START),
    .rx_timeout(rx_timeout)
);

localparam addr_baud = 12'h000;
localparam addr_tx_data = 12'h004;
localparam addr_rx_data =12'h008;
localparam addr_rx_en = 12'h00c;
localparam addr_tx_en = 12'h010 ;
localparam addr_tx_en_fifo = 12'h014;
localparam addr_tx_fifo_level = 12'h018;
localparam addr_rd_en_txfifo = 12'h01c;

always @(posedge pclk_i) begin
    if (~prst_ni) begin
        baud <= 16'd0;
        rx_en <= 1'b0;
        rx_data <= 8'd0;
        tx_en_fifo <= 0;
        tx_level <= 0;
        rd_en_fifo <= 0;
        tx_data <= 0;
        intr_tx <= 0;
        r_tx_byte_done <= 0;
        prdata_o <= 0;

    end
    else begin
        if(psel_i && penable_i && pwrite_i) begin
            case(paddr_i)
                addr_baud:
                begin
                    baud[15:0] <= pwdata_i[15:0];
                end

                addr_tx_data:
                begin
                    tx_data <= pwdata_i[7:0];
                end

                addr_rx_en:
                begin
                    rx_en <= pwdata_i[0];
                end

                addr_tx_en_fifo:
                begin
                    tx_en_fifo <= pwdata_i[0];
                end

                addr_tx_fifo_level:
                begin
                    tx_level <= pwdata_i[2:0];
                end

                addr_rd_en_txfifo:
                begin
                    rd_en_fifo <= pwdata_i[0];
                end

                default:    begin
                    baud <= 16'd0;
                    rx_en <= 1'b0;
                    rd_en_fifo <= 1'b0;
                    tx_level <= 1'b0;
                end        
            endcase
        end
        else if (psel_i && penable_i && !pwrite_i) begin
            case(paddr_i)
                addr_rx_data:
                begin
                    prdata_o [7:0] <= rx_fifo_o [7:0];
                end
                default:
                    prdata_o <= 32'd0;
            endcase   
        end 
    end
    if (rx_done) begin
        rx_data <= r_rx;
        intr_rx <= 1'b1;
    end
    else    begin
        intr_rx <= 1'b0;
    end

    if (tx_byte_done == 1'b0 && tx_done == 1'b1) begin
        r_tx_byte_done <= r_tx_byte_done + 3'd1;
    end

    if(r_tx_byte_done == tx_level && r_tx_byte_done > 0 && tx_done == 1)
    begin
        intr_tx <= 1'b1;
    end
    else begin
        intr_tx <= 0;
    end

    tx_done <= tx_byte_done;
    if (rd_en_tx == 1'b1) begin
        rd <= 1'b1;
    end
    else begin
        if (tx_byte_done == 1'b0 && tx_done == 1'b1) begin
            rd <= 1'b1;
        end
        else begin
            rd <= 1'b0;
        end
    end

    pwrite_d <= pwrite_i;
end

always @(posedge pclk_i) begin
    rd_d <= rd;
    if (rd_d == 1'b1 && rd == 1'b0 ) begin
        tx_en <= 1'b1;
    end
    else begin
       tx_en <= 1'b0; 
    end
    if (tx_level_intr == tx_level) begin
        intr_tx_level <= 1'b1;
    end
    else begin
        intr_tx_level <= 1'b0;
    end
end


always @(posedge pclk_i) begin
    rx_done_d <= rx_done;
    if(rx_done == 1'b0 && rx_done_d == 1'b1) begin
       rx_fifo_wr <= 1'b1;
    end
    else begin
        rx_fifo_wr <= 1'b0;
    end
end

  
assign rx_en_t = rx_en && ~rx_timeout;
assign intr_rx_timeout = rx_timeout;
assign pready_o = 1'b1;
assign pslverr_o = 1'b0;
assign wr_en_tx = tx_en_fifo && pwrite_d;
assign rd_en_tx = rd_en_fifo && pwrite_d;
assign rd_en_rx_fifo = (rx_timeout == 1'b1)? 1: 0;
endmodule  
  