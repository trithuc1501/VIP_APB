class APB_master_stress_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_stress_seq)
    int num_trans = 1000;
    function new(string name = "APB_master_stress_seq");
        super.new(name);
    endfunction
    virtual task body();
        APB_sequence_item req;
        bit is_write;
        bit [31:0] rand_addr;
        `uvm_info("SEQ_STRESS", $sformatf("Starting STRESS Sequence with %0d transactions...", num_trans), UVM_LOW)
        for (int i = 0; i < num_trans; i++) begin
            req = APB_sequence_item#()::type_id::create("req");
            start_item(req);
            is_write = $urandom_range(0, 1);
            rand_addr = $urandom_range(0, 32'h0FFC) & 32'hFFFF_FFFC;
            req.pwrite = is_write ? APB_WRITE : APB_READ;
            req.paddr  = rand_addr;
            req.delay  = $urandom_range(0, 3);
            if (is_write) begin
                req.pwdata = $urandom();
                req.pstrb  = $urandom_range(1, 15);
            end else begin
                req.pwdata = 0;
                req.pstrb  = 0;
            end
            req.pprot = $urandom_range(0, 7);
            finish_item(req);
            if (i > 0 && i % 250 == 0) begin
                `uvm_info("SEQ_STRESS", $sformatf("Completed %0d/%0d transactions...", i, num_trans), UVM_LOW)
            end
        end
        `uvm_info("SEQ_STRESS", "STRESS Sequence DONE!", UVM_LOW)
    endtask
endclass
