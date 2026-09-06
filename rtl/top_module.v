module uart_top (
    input        clk,
    input        rst,
    input  [7:0] data_in,
    input        wr_en,
    input        rdy_clr,
    output       busy,
    output       rdy,
    output [7:0] data_out
);

    wire tx_clk_en;
    wire rx_clk_en;
    wire serial_line;

    // --- FIFO signals ---
    wire       fifo_full;
    wire       fifo_empty;
    wire [7:0] fifo_dout;
    wire       fifo_rd_en;
    wire       tx_busy;

    baud_rate_generator bg (
        .clk   (clk),
        .rst   (rst),
        .tx_en (tx_clk_en),
        .rx_en (rx_clk_en)
    );

    // pop from FIFO whenever transmitter is free and FIFO has data
    assign fifo_rd_en = !tx_busy && !fifo_empty;

    fifo #(.DEPTH(8), .WIDTH(8)) tx_fifo (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),        // external writes go INTO the fifo now
        .din   (data_in),
        .rd_en (fifo_rd_en),
        .dout  (fifo_dout),
        .full  (fifo_full),
        .empty (fifo_empty)
    );

    transmitter tx_inst (
        .clk     (clk),
        .wr_enb  (fifo_rd_en),   // transmitter triggered by FIFO pop, not external wr_en
        .enb     (tx_clk_en),
        .rst     (rst),
        .data_in (fifo_dout),    // transmitter reads from FIFO output
        .tx      (serial_line),
        .busy    (tx_busy)
    );

    uart_receiver rx_inst (
        .clk      (clk),
        .rst      (rst),
        .rx       (serial_line),
        .rdy_clr  (rdy_clr),
        .clk_en   (rx_clk_en),
        .rdy      (rdy),
        .data_out (data_out)
    );

    assign busy = tx_busy;   // could OR in fifo_full later if you want busy to also reflect "can't accept new data"

endmodule