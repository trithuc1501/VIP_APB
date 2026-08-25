class APB_env extends uvm_env;
    `uvm_component_utils(APB_env)

    APB_master_agent master_agent;
    APB_slave_agent  slave_agent;
    APB_scoreboard   scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        master_agent = APB_master_agent::type_id::create("master_agent", this);
        slave_agent = APB_slave_agent::type_id::create("slave_agent", this);
        scoreboard = APB_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        master_agent.mon.ap.connect(scoreboard.item_export);
    endfunction

endclass
