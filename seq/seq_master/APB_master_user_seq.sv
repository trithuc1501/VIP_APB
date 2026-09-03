class APB_master_user_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_user_seq)

    function new(string name = "APB_master_user_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", "Start Write with User Signals (PAUSER=0xAA, PWUSER=0xBB)", UVM_LOW)
        req = APB_sequence_item#()::type_id::create("req");
        start_item(req);
        req.pwrite = APB_WRITE;
        req.paddr  = 32'h4000;
        req.pwdata = $urandom();
        req.pstrb  = 4'b1111;
        req.delay  = 0;
        req.pauser = 8'hAA;
        req.pwuser = 8'hBB;
        finish_item(req);
        `uvm_info("SEQ_MASTER", "Done Write with User Signals", UVM_LOW)
    endtask

endclass
