class APB_agent_config extends uvm_object;
    virtual APB_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    bit has_monitor = 1;
    `uvm_object_utils(APB_agent_config)
    function new(string name = "APB_agent_config");
        super.new(name);
    endfunction
endclass
