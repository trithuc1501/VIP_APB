class APB_base_test extends uvm_test;
    `uvm_component_utils(APB_base_test)

    APB_env env;
    APB_agent_config m_master_cfg;
    APB_agent_config m_slave_cfg;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        m_master_cfg = APB_agent_config::type_id::create("m_master_cfg");
        m_slave_cfg = APB_agent_config::type_id::create("m_slave_cfg");

        if(!uvm_config_db#(virtual APB_if)::get(this, "", "vif", m_master_cfg.vif)) begin
            `uvm_fatal("BASE_TEST", "Could not get virtual APB_if from config_db")
        end
        
        m_slave_cfg.vif = m_master_cfg.vif;

        m_master_cfg.is_active = UVM_ACTIVE;
        m_slave_cfg.is_active = UVM_ACTIVE;

        uvm_config_db#(APB_agent_config)::set(this, "env.master_agent*", "agent_cfg", m_master_cfg);
        uvm_config_db#(APB_agent_config)::set(this, "env.slave_agent*", "agent_cfg", m_slave_cfg);

        env = APB_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.set_report_id_action_hier("SEQREQZMB", UVM_NO_ACTION);
    endfunction
endclass
