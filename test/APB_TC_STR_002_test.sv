class APB_TC_STR_002_test extends APB_base_test;
    `uvm_component_utils(APB_TC_STR_002_test)
    function new(string name = "APB_TC_STR_002_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    virtual task run_phase(uvm_phase phase);
        APB_master_stress_seq      m_seq;
        APB_slave_random_wait_seq  s_seq;
        virtual APB_if             vif;
        phase.raise_objection(this);
        if (!uvm_config_db#(virtual APB_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST_STR_002", "Could not get virtual APB_if from uvm_config_db!")
        end
        s_seq = APB_slave_random_wait_seq::type_id::create("s_seq");
        m_seq = APB_master_stress_seq::type_id::create("m_seq");
        m_seq.num_trans = 500;
        `uvm_info("TEST_STR_002", "STARTING RANDOM RESET STRESS TEST (500 TRANSACTIONS)", UVM_LOW)
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            if (env.master_agent != null && m_master_cfg.is_active == UVM_ACTIVE) m_seq.start(env.master_agent.sqr);
            begin
                forever begin
                    #($urandom_range(50, 250) * 1ns);
                    `uvm_warning("TEST_STR_002", "BOMB PLANTED! INJECTING ASYNC RESET MID-SIMULATION!!!")
                    vif.PRESETn = 1'b0;
                    #($urandom_range(10, 20) * 5ns);
                    vif.PRESETn = 1'b1;
                    `uvm_info("TEST_STR_002", "Reset Released. System should recover automatically.", UVM_LOW)
                end
            end
        join_any
        disable fork;
        phase.drop_objection(this);
    endtask
endclass
