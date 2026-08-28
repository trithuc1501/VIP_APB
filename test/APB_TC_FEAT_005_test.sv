class APB_TC_FEAT_005_test extends APB_base_test;
    `uvm_component_utils(APB_TC_FEAT_005_test)

    function new(string name = "APB_TC_FEAT_005_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_wakeup_err_seq m_seq;
        APB_slave_zero_wait_seq   s_seq;

        phase.raise_objection(this);

        s_seq = APB_slave_zero_wait_seq::type_id::create("s_seq");
        m_seq = APB_master_wakeup_err_seq::type_id::create("m_seq");
        
        `uvm_info("TEST_FEAT_005", "STARTING TEST: Low Power PWAKEUP (AST_WUP_01 Error Injection)", UVM_LOW)
        `uvm_info("TEST_FEAT_005", "EXPECTING SVA AST_WUP_01 to fire UVM_ERROR!", UVM_LOW)

        fork
            s_seq.start(env.slave_agent.sqr);
            begin
                #10ns;
                m_seq.start(env.master_agent.sqr);
            end
        join_any
        disable fork;

        #50ns;
        phase.drop_objection(this);
    endtask
endclass
