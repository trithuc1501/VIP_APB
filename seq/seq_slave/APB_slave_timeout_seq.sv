class APB_slave_timeout_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_slave_timeout_seq)

    function new(string name = "APB_slave_timeout_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_SLAVE", "Slave is ready (Timeout Injection Mode: Wait > 100 cycles)", UVM_LOW)
        
        forever begin
            req = APB_sequence_item::type_id::create("req");
            start_item(req);
            
            req.wait_states = 105;
            req.pslverr     = 0;
            
            finish_item(req);
            
            `uvm_info("SEQ_SLAVE", "Injected 105 wait states to trigger timeout", UVM_HIGH)
        end
    endtask
endclass
