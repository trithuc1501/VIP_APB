class APB_env extends uvm_env;
    `uvm_component_utils(APB_env)
    APB_master_agent master_agent;
    APB_slave_agent  slave_agent;
    APB_scoreboard   scoreboard;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    APB_env_config m_cfg;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(APB_env_config)::get(this, "", "env_cfg", m_cfg)) begin
            `uvm_info("ENV_CFG", "No APB_env_config found, using default (Both Master & Slave).", UVM_LOW)
            m_cfg = APB_env_config::type_id::create("m_cfg");
        end
        if (m_cfg.has_master) begin
            master_agent = APB_master_agent::type_id::create("master_agent", this);
        end
        if (m_cfg.has_slave) begin
            slave_agent = APB_slave_agent::type_id::create("slave_agent", this);
        end
        if (m_cfg.has_scoreboard) begin
            scoreboard = APB_scoreboard::type_id::create("scoreboard", this);
        end
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (m_cfg.has_scoreboard) begin
            bit connected = 0;
            if (m_cfg.has_master && master_agent.m_cfg.has_monitor) begin
                master_agent.ap.connect(scoreboard.item_export);
                connected = 1;
            end 
            else if (m_cfg.has_slave && slave_agent.m_cfg.has_monitor) begin
                slave_agent.ap.connect(scoreboard.item_export);
                connected = 1;
            end
            if (!connected) begin
                `uvm_fatal("ENV_CFG", "No monitor connected to scoreboard - check has_master/has_slave/has_monitor combination!")
            end
        end
    endfunction
endclass
