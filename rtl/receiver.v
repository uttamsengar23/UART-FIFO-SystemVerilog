module uart_receiver(
    input        clk,
    input        rst,
    input        rx,
    input        rdy_clr,
    input        clk_en,
    output reg   rdy,
    output reg [7:0] data_out
);

    parameter start_state    = 2'b00;
    parameter data_out_state = 2'b01;
    parameter stop_state     = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [3:0] index;
    reg [7:0] temp_register;

    always @(posedge clk) begin
        if (rst) begin
            rdy           <= 1'b0;
            data_out      <= 8'b0;
            state         <= start_state;
            sample        <= 4'b0;
            index         <= 4'b0;
            temp_register <= 8'b0;
        end
        else begin

            if (rdy_clr)
                rdy <= 1'b0;

            if (clk_en) begin
                case (state)

                    start_state: begin
                        if (rx == 1'b0 || sample != 4'b0)
                            sample <= sample + 1'b1;

                        if (sample == 4'hF) begin
                            state         <= data_out_state;
                            sample        <= 4'b0;
                            index         <= 4'b0;
                            temp_register <= 8'b0;
                        end
                    end

                    data_out_state: begin
                        sample <= sample + 1'b1;

                        if (sample == 4'h8) begin
                            temp_register[index] <= rx;
                            index <= index + 1'b1;
                        end

                        if (index == 4'h8 && sample == 4'hF)
                            state <= stop_state;
                    end

                    stop_state: begin
                        if (sample == 4'hF) begin
                            state    <= start_state;
                            data_out <= temp_register;
                            rdy      <= 1'b1;
                            sample   <= 4'b0;
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    default: begin
                        state <= start_state;
                    end

                endcase
            end
        end
    end

endmodule