class APB_TC_ERR_002_test extends APB_base_test;
    `uvm_component_utils(APB_TC_ERR_002_test)

    function new(string name = "APB_TC_ERR_002_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_b2b_wr_rd_seq m_seq;
        APB_slave_error_seq      s_seq;
        phase.raise_objection(this);
        s_seq = APB_slave_error_seq::type_id::create("s_seq");
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            begin
                `uvm_info("TEST", "Starting 5 consecutive B2B transactions to test error recovery", UVM_LOW)
                repeat (5) begin
                    m_seq = APB_master_b2b_wr_rd_seq::type_id::create("m_seq");
                    if (env.master_agent != null && m_master_cfg.is_active == UVM_ACTIVE) m_seq.start(env.master_agent.sqr);
                end
            end
        join_any
        disable fork;
        phase.drop_objection(this);
    endtask

endclass
