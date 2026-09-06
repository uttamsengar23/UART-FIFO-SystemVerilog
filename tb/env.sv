class uart_env;
    generator      gen;
    driver         drv;
    uart_monitor   mon;
    uart_ref_model rm;
    uart_sb        sb;

    mailbox #(uart_txn) gen2drv;
    mailbox #(uart_txn) drv2rm;
    mailbox #(uart_txn) drv2sb;   // declared for future use, not wired into sb currently
    mailbox #(uart_txn) rm2sb;
    mailbox #(uart_txn) mon2sb;

    virtual uart_if.DRIVER  drv_vif;
    virtual uart_if.MONITOR mon_vif;

    function new(virtual uart_if.DRIVER drv_vif, virtual uart_if.MONITOR mon_vif, int num_txns);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;

        gen2drv = new();
        drv2rm  = new();
        drv2sb  = new();
        rm2sb   = new();
        mon2sb  = new();

        gen = new(gen2drv, num_txns);
        drv = new(gen2drv, drv2sb, drv2rm);
        drv.vif = drv_vif;

        mon = new(mon_vif, mon2sb);
        rm  = new(drv2rm, rm2sb);
        sb  = new(rm2sb, mon2sb);
    endfunction

    task run();
    fork
        gen.run();
        drv.run();
        mon.run();
        rm.run();
        sb.run();
    join_any
    #(20 * 600_000);   // ~600us margin per transaction, covers 20 txns comfortably
    sb.report();
    endtask
endclass