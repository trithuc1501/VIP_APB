class APB_TC_AST_005_test extends APB_base_test;
    `uvm_component_utils(APB_TC_AST_005_test)

    function new(string name = "APB_TC_AST_005_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        APB_slave_driver::type_id::set_type_override(APB_slave_pslverr_early_driver::get_type());
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_single_write_seq m_seq;
        APB_slave_random_wait_seq       s_seq;
        phase.raise_objection(this);
        s_seq = APB_slave_random_wait_seq::type_id::create("s_seq");
        m_seq = APB_master_single_write_seq::type_id::create("m_seq");
        `uvm_info("TEST_AST_005", "STARTING NEGATIVE TEST: Slave asserts PSLVERR while PREADY=0", UVM_LOW)
        `uvm_info("TEST_AST_005", "EXPECTING SVA AST_ERR_TIM to fire UVM_ERROR!", UVM_LOW)
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            if (env.master_agent != null && m_master_cfg.is_active == UVM_ACTIVE) m_seq.start(env.master_agent.sqr);
        join_any
        disable fork;
        #50ns;
        phase.drop_objection(this);
    endtask

endclass
