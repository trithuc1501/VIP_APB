class APB_master_single_read_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_single_read_seq)
    bit [31:0] cfg_addr;
    int        cfg_delay;
    bit [31:0] read_data;

    function new(string name = "APB_master_single_read_seq");
        super.new(name);
        cfg_addr  = $urandom() & 32'hFFFF_FFFC;
        cfg_delay = 0;
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", $sformatf("Start Read: Addr=0x%0h", cfg_addr), UVM_LOW)
        req = APB_sequence_item#()::type_id::create("req");
        start_item(req);
        req.pwrite = APB_READ;
        req.delay  = cfg_delay;
        req.paddr  = cfg_addr;
        req.pwdata = 32'h0;
        req.pstrb  = 4'b0000;
        finish_item(req);
        read_data = req.prdata;
        `uvm_info("SEQ_MASTER", $sformatf("Done Read Sequence. Received PRDATA = 0x%0h", read_data), UVM_LOW)
    endtask

endclass
