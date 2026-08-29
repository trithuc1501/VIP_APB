class APB_slave_random_wait_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_slave_random_wait_seq)
    function new(string name = "APB_slave_random_wait_seq");
        super.new(name);
    endfunction
    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_SLAVE", "Slave is ready (Random Wait State Mode: 1-5 cycles)", UVM_LOW)
        forever begin
            req = APB_sequence_item#()::type_id::create("req");
            start_item(req);
            req.wait_states = $urandom_range(1, 5); 
            req.pslverr     = 0;
            finish_item(req);
            `uvm_info("SEQ_SLAVE", $sformatf("Injected %0d wait states for current transaction", req.wait_states), UVM_HIGH)
        end
    endtask
endclass
