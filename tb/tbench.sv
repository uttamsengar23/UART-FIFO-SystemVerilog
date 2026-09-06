`timescale 1ns/1ps

module testbench_top;
    logic clk, rst;

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // interface instance — connects to DUT directly (no modport restriction here)
    uart_if intf (.clk(clk), .rst(rst));

    // DUT instantiation — wired straight to the interface's signals
    uart_top dut (
        .clk      (clk),
        .rst      (rst),
        .data_in  (intf.data_in),
        .wr_en    (intf.wr_en),
        .rdy_clr  (intf.rdy_clr),
        .busy     (intf.busy),
        .rdy      (intf.rdy),
        .data_out (intf.data_out)
    );

    uart_env env;

    // testbench_top is now the ONLY driver of rst — the driver class no longer
    // touches it, so there's no port-direction conflict on intf.rst anymore.
    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end
    initial $monitor("t=%0t fifo_dout=%h fifo_rd_en=%b fifo_empty=%b", $time, dut.fifo_dout, dut.fifo_rd_en, dut.fifo_empty);

    initial begin
        env = new(intf, intf, 20);   // 20 transactions, tweak as needed
        env.run();
        $finish;
    end

    // optional: dump waveforms
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, testbench_top);
    end
endmodule