class APB_slave_agent extends uvm_agent;
    `uvm_component_utils(APB_slave_agent)
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    uvm_sequencer #(APB_sequence_item) sqr;
    APB_slave_driver                   drv;
    APB_monitor                        mon;
    uvm_analysis_port #(APB_sequence_item) ap;
    APB_agent_config m_cfg;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(APB_agent_config)::get(this, "", "agent_cfg", m_cfg)) begin
            `uvm_fatal("NO_CFG", "Agent cannot find config object!")
        end
        this.is_active = m_cfg.is_active;
        ap = new("ap", this);
        if (m_cfg.has_monitor) begin
            mon = APB_monitor::type_id::create("mon", this);
            mon.vif = m_cfg.vif;
        end
        if (is_active == UVM_ACTIVE) begin
            drv = APB_slave_driver::type_id::create("drv", this);
            drv.vif = m_cfg.vif;
            sqr = uvm_sequencer#(APB_sequence_item)::type_id::create("sqr", this);
        end
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (m_cfg.has_monitor && mon != null) begin
            mon.ap.connect(this.ap);
        end
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
endclass
