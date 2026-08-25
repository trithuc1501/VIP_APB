class APB_TC_FEAT_003_test extends APB_base_test;
    `uvm_component_utils(APB_TC_FEAT_003_test)


    function new(string name = "APB_TC_FEAT_003_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_master_single_write_seq wr_seq;
        APB_slave_b2b_seq           s_seq;

        phase.raise_objection(this);

        s_seq = APB_slave_b2b_seq::type_id::create("s_seq");
        
        fork
            s_seq.start(env.slave_agent.sqr);
            begin
                `uvm_info("TEST_FEAT_003", "Starting PPROT coverage loop (000 to 111)", UVM_LOW)
                
                for (int i = 0; i < 8; i++) begin
                    wr_seq = APB_master_single_write_seq::type_id::create("wr_seq");
                    
                    wr_seq.cfg_pprot = i;
                    wr_seq.cfg_pstrb = 4'b1111;
                    
                    `uvm_info("TEST_FEAT_003", $sformatf("Driving Write Transaction with PPROT=0b%0b", i), UVM_LOW)
                    wr_seq.start(env.master_agent.sqr);
                end

            end
        join_any
        disable fork;

        phase.drop_objection(this);
    endtask
endclass
