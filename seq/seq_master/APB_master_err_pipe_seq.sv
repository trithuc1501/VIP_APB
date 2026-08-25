class APB_master_err_pipe_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_err_pipe_seq)

    function new(string name = "APB_master_err_pipe_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", "Start Error Injection (Pipelining / Skipping SETUP)", UVM_LOW)

        req = APB_sequence_item::type_id::create("req");
        start_item(req);
        
        req.pwrite = APB_WRITE;
        req.paddr  = 32'hDEAD_BEEC;
        req.pwdata = 32'hBADD_CAFE;
        req.pstrb  = 4'b1111;
        req.delay  = 0;
        
        req.inject_pipeline_err = 1; 

        finish_item(req);
        
        `uvm_info("SEQ_MASTER", "Done Error Injection Sequence", UVM_LOW)
    endtask
endclass
