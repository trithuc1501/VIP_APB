class APB_slave_error_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_slave_error_seq)
    function new(string name = "APB_slave_error_seq");
        super.new(name);
    endfunction
    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_SLAVE", "Slave is ready (Error Injection Mode: PSLVERR=1)", UVM_LOW)
        forever begin
            req = APB_sequence_item#()::type_id::create("req");
            start_item(req);
            req.wait_states = 0;
            req.pslverr     = 1'b1;
            finish_item(req);
            `uvm_info("SEQ_SLAVE", "Injected PSLVERR=1 for current transaction", UVM_HIGH)
        end
    endtask
endclass
