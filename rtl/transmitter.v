module transmitter(
    input        clk,
    input        wr_enb,
    input        enb,
    input        rst,
    input  [7:0] data_in,
    output reg   tx,
    output       busy
);

    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;

    reg [7:0] data;
    reg [2:0] index;
    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            tx    <= 1'b1;
            state <= idle_state;
            index <= 3'h0;
        end
        else begin
            case (state)

                idle_state: begin
                    if (wr_enb) begin
                        state <= start_state;
                        data  <= data_in;
                        index <= 3'h0;
                    end
                    else begin
                        state <= idle_state;
                    end
                end

                start_state: begin
                    if (enb) begin
                        tx    <= 1'b0;
                        state <= data_state;
                    end
                    else begin
                        state <= start_state;
                    end
                end

                data_state: begin
                    if (enb) begin
                        tx <= data[index];
                        if (index == 3'h7)
                            state <= stop_state;
                        else
                            index <= index + 3'h1;
                    end
                end

                stop_state: begin
                    if (enb) begin
                        tx    <= 1'b1;
                        state <= idle_state;
                    end
                end

                default: begin
                    tx    <= 1'b1;
                    state <= idle_state;
                end

            endcase
        end
    end

    assign busy = (state != idle_state);

endmodule