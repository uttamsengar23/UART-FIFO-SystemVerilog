
interface uart_if(input logic clk, input logic rst);

    timeunit 1ns;
    timeprecision 1ps;

    logic [7:0] data_in;
    logic       wr_en;
    logic       rdy_clr;
    logic       busy;
    logic       rdy;
    logic [7:0] data_out;

    clocking drv_cb @(posedge clk);
        default input #1 output #1;

        output data_in, wr_en, rdy_clr;

        input busy, rdy, data_out;
    endclocking

    modport DRIVER (
        clocking drv_cb,
        input clk
    );

    modport MONITOR (
        input clk, rst,
        input data_in, wr_en, rdy_clr,
        input busy, rdy, data_out
    );

endinterface