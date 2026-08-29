class APB_TC_FEAT_004_test extends APB_base_test;
    `uvm_component_utils(APB_TC_FEAT_004_test)
    function new(string name = "APB_TC_FEAT_004_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        APB_master_user_seq m_seq;
        APB_slave_user_seq  s_seq;
        phase.raise_objection(this);
        s_seq = APB_slave_user_seq::type_id::create("s_seq");
        m_seq = APB_master_user_seq::type_id::create("m_seq");
        `uvm_info("TEST_FEAT_004", "STARTING TEST: User Signals Routing (PAUSER, PWUSER, PRUSER, PBUSER)", UVM_LOW)
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            if (env.master_agent != null && m_master_cfg.is_active == UVM_ACTIVE) m_seq.start(env.master_agent.sqr);
        join_any
        disable fork;
        #50ns;
        phase.drop_objection(this);
    endtask
endclass
