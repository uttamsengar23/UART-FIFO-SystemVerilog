class uart_sb;
    mailbox #(uart_txn) rm2sb;
    mailbox #(uart_txn) mon2sb;

    bit [7:0] act_data, exp_data;
    uart_txn act, exp;
    int num_txns = 0;

    covergroup cov;
        coverpoint exp_data {
            bins low_vals  = {[0:63]};
            bins mid_vals  = {[64:127]};
            bins high_vals = {[128:255]};
        }
    endgroup

    function new(mailbox #(uart_txn) rm2sb, mailbox #(uart_txn) mon2sb);
        this.rm2sb  = rm2sb;
        this.mon2sb = mon2sb;
        cov = new();
    endfunction

    task run();
        forever begin
            fork
                mon2sb.get(act);
                rm2sb.get(exp);
            join

            act_data = act.data_out;   // fixed: was act.data
            exp_data = exp.data;

            if (act_data == exp_data)
                $display("comparison success: exp=%0h act=%0h", exp_data, act_data);
            else
                $display("comparison FAILED: exp=%0h act=%0h", exp_data, act_data);

            cov.sample();
            num_txns++;
        end
    endtask

    function void report();
    $display("Total transactions checked: %0d", num_txns);
    $display("Functional coverage: %0.2f%%", cov.get_coverage());
    endfunction
endclass