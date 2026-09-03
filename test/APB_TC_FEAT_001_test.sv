class APB_TC_FEAT_001_test extends APB_base_test;
    `uvm_component_utils(APB_TC_FEAT_001_test)

    function new(string name = "APB_TC_FEAT_001_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_single_write_seq wr_seq;
        APB_master_single_read_seq  rd_seq;
        APB_slave_b2b_seq           s_seq;
        phase.raise_objection(this);
        s_seq = APB_slave_b2b_seq::type_id::create("s_seq");
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            begin
                `uvm_info("TEST_FEAT_001", "Step 1: Write Full Word (PSTRB=4'b1111) to 0x4000 with data 0xFFFFFFFF", UVM_LOW)
                wr_seq = APB_master_single_write_seq::type_id::create("wr_seq1");
                wr_seq.cfg_addr = 32'h4000;
                wr_seq.cfg_data = 32'hFFFF_FFFF;
                wr_seq.cfg_pstrb = 4'b1111;
                wr_seq.start(env.master_agent.sqr);
                `uvm_info("TEST_FEAT_001", "Step 2: Partial Write (PSTRB=4'b1010) to 0x4000 with data 0x11223344", UVM_LOW)
                wr_seq = APB_master_single_write_seq::type_id::create("wr_seq2");
                wr_seq.cfg_addr = 32'h4000;
                wr_seq.cfg_data = 32'h1122_3344;
                wr_seq.cfg_pstrb = 4'b1010;
                wr_seq.start(env.master_agent.sqr);
                `uvm_info("TEST_FEAT_001", "Step 3: Read back 0x4000 to verify partial write", UVM_LOW)
                rd_seq = APB_master_single_read_seq::type_id::create("rd_seq");
                rd_seq.cfg_addr = 32'h4000;
                rd_seq.start(env.master_agent.sqr);
            end
        join_any
        disable fork;
        phase.drop_objection(this);
    endtask

endclass
