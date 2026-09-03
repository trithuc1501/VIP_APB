class APB_TC_STR_001_test extends APB_base_test;
    `uvm_component_utils(APB_TC_STR_001_test)

    function new(string name = "APB_TC_STR_001_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_stress_seq      m_seq;
        APB_slave_random_wait_seq  s_seq;
        phase.raise_objection(this);
        s_seq = APB_slave_random_wait_seq::type_id::create("s_seq");
        m_seq = APB_master_stress_seq::type_id::create("m_seq");
        m_seq.num_trans = 2000;
        `uvm_info("TEST_STR_001", "STARTING 2000-TRANSACTION STRESS TEST", UVM_LOW)
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            if (env.master_agent != null && m_master_cfg.is_active == UVM_ACTIVE) m_seq.start(env.master_agent.sqr);
        join_any
        disable fork;
        phase.drop_objection(this);
    endtask

endclass
