class APB_master_random_delay_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_random_delay_seq)

    function new(string name = "APB_master_random_delay_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_master_single_write_seq wr_seq;
        APB_master_single_read_seq  rd_seq;
        `uvm_info("SEQ_MASTER", "Starting Random Delay Sequence (Multiple transfers with IDLE cycles)", UVM_LOW)
        for (int i = 1; i <= 3; i++) begin
            bit [31:0] shared_addr = $urandom() & 32'hFFFF_FFFC;
            bit [31:0] shared_data = $urandom();
            `uvm_info("SEQ_MASTER", $sformatf("--- Transaction Pair %0d ---", i), UVM_LOW)
            wr_seq = APB_master_single_write_seq::type_id::create("wr_seq");
            wr_seq.cfg_addr  = shared_addr;
            wr_seq.cfg_data  = shared_data;
            wr_seq.cfg_delay = $urandom_range(1, 5);
            wr_seq.start(m_sequencer, this);
            rd_seq = APB_master_single_read_seq::type_id::create("rd_seq");
            rd_seq.cfg_addr  = shared_addr;
            rd_seq.cfg_delay = $urandom_range(1, 5);
            rd_seq.start(m_sequencer, this);
        end
        `uvm_info("SEQ_MASTER", "Finished Random Delay Sequence", UVM_LOW)
    endtask

endclass
