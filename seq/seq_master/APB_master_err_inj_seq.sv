class APB_master_err_inj_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_err_inj_seq)

    function new(string name = "APB_master_err_inj_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", "Start Error Injection Write (PENABLE=1 in SETUP)", UVM_LOW)

        req = APB_sequence_item::type_id::create("req");
        start_item(req);
        
        req.pwrite = APB_WRITE;
        req.paddr  = 32'hDEAD_0000;
        req.pwdata = 32'hBEEF;
        req.pstrb  = 4'b1111;
        req.delay  = 0;
        
        req.inject_penable_err = 1; 

        finish_item(req);
        
        `uvm_info("SEQ_MASTER", "Done Error Injection Sequence", UVM_LOW)
    endtask
endclass
