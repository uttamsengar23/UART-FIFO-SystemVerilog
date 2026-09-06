class uart_ref_model;
    uart_txn txn, exp;
    mailbox #(uart_txn) drv2rm;
    mailbox #(uart_txn) rm2sb;

    function new(mailbox #(uart_txn) drv2rm, mailbox #(uart_txn) rm2sb);
        this.drv2rm = drv2rm;
        this.rm2sb  = rm2sb;
    endfunction

    task run();
        forever begin
            drv2rm.get(txn);
            exp = txn;              // expected data_out == originally sent data
            rm2sb.put(exp);
            exp.display("RM : EXPECTED GENERATED");
        end
    endtask
endclass