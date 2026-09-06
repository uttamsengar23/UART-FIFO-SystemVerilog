class uart_monitor;
    virtual uart_if.MONITOR vif;
    mailbox #(uart_txn) mon2sb;
    uart_txn txn;

    function new(virtual uart_if.MONITOR vif, mailbox #(uart_txn) mon2sb);
        this.vif    = vif;
        this.mon2sb = mon2sb;
    endfunction

    task run();
        forever begin
            @(posedge vif.rdy);
            txn = new();
            txn.data_out = vif.data_out;
            txn.display("MONITOR : DATA CAPTURED");
            mon2sb.put(txn);
        end
    endtask
endclass