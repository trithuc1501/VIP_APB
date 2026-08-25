class APB_master_err_stab_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_err_stab_seq)

    function new(string name = "APB_master_err_stab_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", "Start Error Injection (Corrupting PADDR during wait states)", UVM_LOW)

        req = APB_sequence_item::type_id::create("req");
        start_item(req);
        
        req.pwrite = APB_WRITE;
        req.paddr  = 32'hAAAA_BBB8;
        req.pwdata = 32'h0123_4567;
        req.pstrb  = 4'b1111;
        req.delay  = 0;
        
        req.inject_stability_err = 1; 

        finish_item(req);
        
        `uvm_info("SEQ_MASTER", "Done Error Injection Sequence", UVM_LOW)
    endtask
endclass
