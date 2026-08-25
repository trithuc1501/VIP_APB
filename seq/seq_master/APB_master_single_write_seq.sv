class APB_master_single_write_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_single_write_seq)

    rand bit [31:0] cfg_addr;
    rand bit [31:0] cfg_data;
    rand int        cfg_delay;
    rand bit [3:0]  cfg_pstrb;
    rand bit [2:0]  cfg_pprot;

    constraint c_delay {
        cfg_delay inside {[1:5]};
    }

    constraint c_pstrb {
        cfg_pstrb == 4'b1111;
    }
    
    constraint c_pprot {
        cfg_pprot == 3'b000;
    }

    function new(string name = "APB_master_single_write_seq");
        super.new(name);
        cfg_addr  = $urandom() & 32'hFFFF_FFFC;
        cfg_data  = $urandom();
        cfg_delay = 0;
        cfg_pstrb = 4'b1111;
    endfunction

    virtual task body();
        APB_sequence_item req;
        `uvm_info("SEQ_MASTER", $sformatf("Start Write: Addr=0x%0h, Data=0x%0h", cfg_addr, cfg_data), UVM_LOW)

        req = APB_sequence_item::type_id::create("req");
        start_item(req);
        
        req.pwrite = APB_WRITE;
        req.delay  = cfg_delay;
        req.paddr  = cfg_addr;
        req.pwdata = cfg_data;
        req.pstrb  = cfg_pstrb;
        req.pprot  = cfg_pprot;
        req.delay  = cfg_delay;

        finish_item(req);
        
        `uvm_info("SEQ_MASTER", "Done Write Sequence", UVM_HIGH)
    endtask
endclass
