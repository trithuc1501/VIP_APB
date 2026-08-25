class APB_master_b2b_wr_rd_seq extends uvm_sequence #(APB_sequence_item);
    `uvm_object_utils(APB_master_b2b_wr_rd_seq)

    function new(string name = "APB_master_b2b_wr_rd_seq");
        super.new(name);
    endfunction

    virtual task body();
        APB_master_single_write_seq wr_seq;
        APB_master_single_read_seq  rd_seq;
        
        bit [31:0] shared_addr = $urandom() & 32'hFFFF_FFFC;
        bit [31:0] shared_data = $urandom();

        `uvm_info("SEQ_B2B", $sformatf("Start B2B Write/Read: Addr=0x%0h", shared_addr), UVM_LOW)

        wr_seq = APB_master_single_write_seq::type_id::create("wr_seq");
        wr_seq.cfg_addr  = shared_addr;
        wr_seq.cfg_data  = shared_data;
        wr_seq.cfg_delay = 0;
        wr_seq.start(m_sequencer, this);

        rd_seq = APB_master_single_read_seq::type_id::create("rd_seq");
        rd_seq.cfg_addr  = shared_addr;
        rd_seq.cfg_delay = 0;
        rd_seq.start(m_sequencer, this);
        
        `uvm_info("SEQ_B2B", "Done B2B Write/Read", UVM_LOW)
    endtask
endclass
