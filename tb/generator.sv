class generator;
    mailbox #(uart_txn) gen2drv_mbx;
    int num_txns;

    function new(mailbox #(uart_txn) mbx, int n);
        gen2drv_mbx = mbx;
        num_txns    = n;
    endfunction

    task run();
        uart_txn txn;
        repeat (num_txns) begin
            txn = new();
            if (!txn.randomize())
                $fatal("Randomization failed");
            txn.display("GEN");
            gen2drv_mbx.put(txn);
        end
    endtask
endclass