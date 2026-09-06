class uart_txn;
    rand bit [7:0] data;      // byte to transmit
    rand bit       wr_en;
    bit     [7:0] data_out;   // filled in by monitor after capture

    constraint c_wr_en_weight {
        wr_en dist { 1'b1 := 80, 1'b0 := 20 };
    }

    function void display(string tag = "");
        $display("[%s] data=%0h wr_en=%0b data_out=%0h", tag, data, wr_en, data_out);
    endfunction
endclass