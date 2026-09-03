class APB_env_config extends uvm_object;
    `uvm_object_utils(APB_env_config)
    bit has_master = 1;
    bit has_slave  = 0;
    bit has_scoreboard = 0; 
    function new(string name = "APB_env_config");
        super.new(name);
    endfunction
endclass
