class APB_TC_TIM_001_test extends APB_base_test;
    `uvm_component_utils(APB_TC_TIM_001_test)


    function new(string name = "APB_TC_TIM_001_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_b2b_wr_rd_seq  m_seq;
        APB_slave_random_wait_seq s_seq;

        phase.raise_objection(this);

        m_seq = APB_master_b2b_wr_rd_seq::type_id::create("m_seq");
        s_seq = APB_slave_random_wait_seq::type_id::create("s_seq");

        fork
            s_seq.start(env.slave_agent.sqr);
            begin
                m_seq.start(env.master_agent.sqr);
            end
        join_any
        
        disable fork;
        phase.drop_objection(this);
    endtask
endclass
