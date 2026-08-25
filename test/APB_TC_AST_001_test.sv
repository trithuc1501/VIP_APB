class APB_TC_AST_001_test extends APB_base_test;
    `uvm_component_utils(APB_TC_AST_001_test)


    function new(string name = "APB_TC_AST_001_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_err_inj_seq     m_seq;
        APB_slave_zero_wait_seq    s_seq;

        phase.raise_objection(this);

        s_seq = APB_slave_zero_wait_seq::type_id::create("s_seq");
        m_seq = APB_master_err_inj_seq::type_id::create("m_seq");
        
        `uvm_info("TEST_AST_001", "STARTING NEGATIVE TEST: Injecting PENABLE=1 in SETUP phase", UVM_LOW)
        `uvm_info("TEST_AST_001", "EXPECTING SVA to fire UVM_ERROR!", UVM_LOW)
        
        fork
            s_seq.start(env.slave_agent.sqr);
            m_seq.start(env.master_agent.sqr);
        join_any
        disable fork;

        #50ns;
        phase.drop_objection(this);
    endtask
endclass
