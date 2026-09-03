class APB_slave_user_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_slave_user_seq)

    function new(string name = "APB_slave_user_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_SLAVE", "Slave is ready with User Signals (PRUSER=0xCC, PBUSER=0xDD)", UVM_LOW)
        forever begin
            req = APB_sequence_item#()::type_id::create("req");
            start_item(req);
            req.wait_states = 0;
            req.pslverr     = 0;
            req.pruser      = 8'hCC;
            req.pbuser      = 8'hDD;
            finish_item(req);
        end
    endtask

endclass
