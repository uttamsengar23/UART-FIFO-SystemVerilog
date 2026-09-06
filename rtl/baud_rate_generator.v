// Baud Rate Generator for UART
// Generates periodic enable pulses for both transmitter (TX)
// and receiver (RX) using free-running counters with synchronous reset.
module baud_rate_generator(
    input  clk,              // System clock
    input  rst,               // Synchronous active-high reset
    output tx_en,             // Transmitter enable pulse
    output rx_en              // Receiver enable pulse
);
    // Counter for generating the TX baud-rate enable
    // 13 bits are required to represent values up to 5208.
    reg [12:0] tx_counter;
    // Counter for generating the RX sampling enable
    // 10 bits are required to represent values up to 325.
    reg [9:0]  rx_counter;

    // ----------------------------------------------------
    // TX Baud Rate Counter
    // ----------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            tx_counter <= 0;
        else if (tx_counter == 5208)
            tx_counter <= 0;
        else
            tx_counter <= tx_counter + 1'b1;
    end

    // ----------------------------------------------------
    // RX Baud Rate Counter
    // ----------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            rx_counter <= 0;
        else if (rx_counter == 325)
            rx_counter <= 0;
        else
            rx_counter <= rx_counter + 1'b1;
    end

    // ----------------------------------------------------
    // TX / RX Enable Generation
    // ----------------------------------------------------
    assign tx_en = (tx_counter == 0);
    assign rx_en = (rx_counter == 0);

endmodule