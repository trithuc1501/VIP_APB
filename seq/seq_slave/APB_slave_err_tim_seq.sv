class APB_slave_err_tim_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_slave_err_tim_seq)

    function new(string name = "APB_slave_err_tim_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_SLAVE", "Slave is ready (Negative Test: Asserting PSLVERR early)", UVM_LOW)
        
        forever begin
            req = APB_sequence_item::type_id::create("req");
            start_item(req);
            
            req.wait_states = 3;
            req.pslverr = 0;
            
            req.inject_pslverr_timing_err = 1; 
            
            finish_item(req);
        end
    endtask
endclass
