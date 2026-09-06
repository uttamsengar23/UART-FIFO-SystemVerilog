class driver;
    uart_txn txn;
    virtual uart_if.DRIVER vif;

    mailbox #(uart_txn) gen2drv;
    mailbox #(uart_txn) drv2sb;
    mailbox #(uart_txn) drv2rm;

    function new(mailbox #(uart_txn) gen2drv, mailbox #(uart_txn) drv2sb, mailbox #(uart_txn) drv2rm);
        this.gen2drv = gen2drv;
        this.drv2sb  = drv2sb;
        this.drv2rm  = drv2rm;
    endfunction

    task reset_phase();
        // rst is now driven solely by testbench_top's own initial block —
        // the driver just holds outputs idle and waits past the reset pulse.
        vif.drv_cb.wr_en   <= 1'b0;
        vif.drv_cb.rdy_clr <= 1'b0;
        repeat (6) @(vif.drv_cb);   // waits 1 cycle longer than testbench_top's 5-cycle reset
    endtask

    task run();
        reset_phase();
        forever begin
            gen2drv.get(txn);
            send(txn);
            // FIX: only forward to the reference model when a byte was
            // actually transmitted. Previously this ran unconditionally,
            // so idle transactions (wr_en=0, ~20% of traffic) still queued
            // an "expected" entry in rm2sb with nothing to match it in
            // mon2sb (monitor only captures on real rdy pulses), desyncing
            // the scoreboard's fork/join pairing.
            if (txn.wr_en)
                drv2rm.put(txn);
        end
    endtask

    task send(uart_txn t);
        if (t.wr_en) begin
            @(vif.drv_cb);
            vif.drv_cb.data_in <= t.data;
            vif.drv_cb.wr_en   <= 1'b1;
            @(vif.drv_cb);
            vif.drv_cb.wr_en   <= 1'b0;

            wait (!vif.drv_cb.busy);
            wait (vif.drv_cb.rdy);

            t.display("DRIVER : DATA SENT");

            vif.drv_cb.rdy_clr <= 1'b1;
            @(vif.drv_cb);
            vif.drv_cb.rdy_clr <= 1'b0;   // fixed: pulse, don't leave high
        end
        else begin
            @(vif.drv_cb);  // idle cycle, wr_en randomized low
        end
    endtask
endclass