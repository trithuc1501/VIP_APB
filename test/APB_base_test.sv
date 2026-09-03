class APB_base_test extends uvm_test;
    `uvm_component_utils(APB_base_test)
    APB_env env;
    APB_agent_config m_master_cfg;
    APB_agent_config m_slave_cfg;
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        int master_active = 1;
        int slave_active  = 1;
        if ($test$plusargs("VIP_HELP") || $test$plusargs("HELP")) begin
            $display("");
            $display("======================================================================");
            $display("                  AMBA APB5 VIP - COMMAND LINE HELP                   ");
            $display("======================================================================");
            $display("Topology Configuration:");
            $display("  +UVM_NO_MASTER       : Completely removes the VIP Master Agent");
            $display("  +UVM_NO_SLAVE        : Completely removes the VIP Slave Agent");
            $display("  +UVM_NO_SCOREBOARD   : Removes the built-in VIP SRAM Scoreboard");
            $display("");
            $display("Active/Passive Configuration:");
            $display("  +UVM_PASSIVE_MASTER  : Sets Master Agent to Monitor-Only mode");
            $display("  +UVM_PASSIVE_SLAVE   : Sets Slave Agent to Monitor-Only mode");
            $display("");
            $display("Debug & Utility:");
            $display("  +UVM_PRINT_TOPO      : Prints the UVM component hierarchy tree");
            $display("  +VIP_HELP            : Displays this help message and exits");
            $display("======================================================================");
            $display("");
            $finish;
        end
        super.build_phase(phase);
        m_master_cfg = APB_agent_config::type_id::create("m_master_cfg");
        m_slave_cfg = APB_agent_config::type_id::create("m_slave_cfg");
        if(!uvm_config_db#(virtual APB_if)::get(this, "", "vif", m_master_cfg.vif)) begin
            `uvm_fatal("BASE_TEST", "Could not get virtual APB_if from config_db")
        end
        m_slave_cfg.vif = m_master_cfg.vif;
        void'(uvm_config_db#(int)::get(this, "", "master_active", master_active));
        void'(uvm_config_db#(int)::get(this, "", "slave_active", slave_active));
        if ($test$plusargs("UVM_PASSIVE_MASTER")) master_active = 0;
        if ($test$plusargs("UVM_PASSIVE_SLAVE"))  slave_active = 0;
        m_master_cfg.is_active = (master_active) ? UVM_ACTIVE : UVM_PASSIVE;
        m_slave_cfg.is_active  = (slave_active)  ? UVM_ACTIVE : UVM_PASSIVE;
        `uvm_info("BASE_TEST", $sformatf("Configured Master as %s, Slave as %s", 
                  (master_active ? "ACTIVE" : "PASSIVE"), 
                  (slave_active ? "ACTIVE" : "PASSIVE")), UVM_LOW)
        begin
            APB_env_config env_cfg = APB_env_config::type_id::create("env_cfg");
            int en_slave = 0, en_scb = 0, no_master = 0;
            void'(uvm_config_db#(int)::get(this, "", "UVM_ENABLE_SLAVE", en_slave));
            void'(uvm_config_db#(int)::get(this, "", "UVM_ENABLE_SCOREBOARD", en_scb));
            void'(uvm_config_db#(int)::get(this, "", "UVM_NO_MASTER", no_master));
            if ($test$plusargs("UVM_ENABLE_SLAVE") || en_slave)  env_cfg.has_slave = 1;
            if ($test$plusargs("UVM_ENABLE_SCOREBOARD") || en_scb) env_cfg.has_scoreboard = 1;
            if ($test$plusargs("UVM_NO_MASTER") || no_master) env_cfg.has_master = 0;
            uvm_config_db#(APB_env_config)::set(this, "env", "env_cfg", env_cfg);
            if (env_cfg.has_master && env_cfg.has_slave) begin
                m_slave_cfg.has_monitor = 0;
            end
        end
        uvm_config_db#(APB_agent_config)::set(this, "env.master_agent*", "agent_cfg", m_master_cfg);
        uvm_config_db#(APB_agent_config)::set(this, "env.slave_agent*", "agent_cfg", m_slave_cfg);
        env = APB_env::type_id::create("env", this);
    endfunction
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.set_report_id_action_hier("SEQREQZMB", UVM_NO_ACTION);
        if ($test$plusargs("UVM_PRINT_TOPO")) begin
            uvm_top.print_topology();
        end
    endfunction
endclass
