class APB_TC_RST_001_test extends APB_base_test;
    `uvm_component_utils(APB_TC_RST_001_test)
    virtual APB_if vif;

    function new(string name = "APB_TC_RST_001_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual APB_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST", "Could not get virtual APB_if from uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST_RST", "Asserting Reset (PRESETn = 0)", UVM_LOW)
        vif.PRESETn = 1'b0;
        #50;
        `uvm_info("TEST_RST", "Deasserting Reset (PRESETn = 1)", UVM_LOW)
        vif.PRESETn = 1'b1;
        #50;
        phase.drop_objection(this);
    endtask

endclass
