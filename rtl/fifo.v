module fifo #(
    parameter DEPTH = 8,      // number of entries
    parameter WIDTH = 8       // data width (8 bits, matches your data_in)
)(
    input clk,
    input rst,
    input wr_en,
    input [WIDTH-1:0] din,
    input rd_en,
    output [WIDTH-1:0] dout,   // FIX: combinational (FWFT) instead of registered
    output full,
    output empty
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wr_ptr, rd_ptr; // extra MSB for full/empty distinction

    assign full  = (wr_ptr[$clog2(DEPTH)] != rd_ptr[$clog2(DEPTH)]) &&
                   (wr_ptr[$clog2(DEPTH)-1:0] == rd_ptr[$clog2(DEPTH)-1:0]);
    assign empty = (wr_ptr == rd_ptr);

    // FIX: dout now reads the head-of-queue entry combinationally, so it's
    // already valid the same cycle rd_en is asserted (first-word-fall-through).
    // Before, dout was registered and only updated AFTER the pop, so whatever
    // consumed dout on the same edge it asserted rd_en got the STALE value.
    assign dout = mem[rd_ptr[$clog2(DEPTH)-1:0]];

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[$clog2(DEPTH)-1:0]] <= din;
                wr_ptr <= wr_ptr + 1;
            end
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;   // FIX: dout no longer latched here
            end
        end
    end
endmodule