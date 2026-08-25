class APB_master_err_psel_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_err_psel_seq)

    function new(string name = "APB_master_err_psel_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", "Start Error Injection Write (Dropping PSEL in ACCESS)", UVM_LOW)

        req = APB_sequence_item::type_id::create("req");
        start_item(req);
        
        req.pwrite = APB_WRITE;
        req.paddr  = 32'hBABC;
        req.pwdata = 32'hCAFE;
        req.pstrb  = 4'b1111;
        req.delay  = 0;
        
        req.inject_psel_drop_err = 1; 

        finish_item(req);
        
        `uvm_info("SEQ_MASTER", "Done Error Injection Sequence", UVM_LOW)
    endtask
endclass
