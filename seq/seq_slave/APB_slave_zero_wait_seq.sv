class APB_slave_zero_wait_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_slave_zero_wait_seq)
    function new(string name = "APB_slave_zero_wait_seq");
        super.new(name);
    endfunction
    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_SLAVE", "Slave is ready (0 wait states)", UVM_LOW)
        forever begin
            req = APB_sequence_item#()::type_id::create("req");
            start_item(req);
            req.wait_states = 0;
            req.pslverr     = 0;
            finish_item(req);
        end
    endtask
endclass
