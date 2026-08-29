class APB_TC_RST_002_test extends APB_base_test;
    `uvm_component_utils(APB_TC_RST_002_test)
    virtual APB_if vif;
    function new(string name = "APB_TC_RST_002_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual APB_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST", "Could not get virtual APB_if from uvm_config_db")
        end
    endfunction
    virtual task run_phase(uvm_phase phase);
        APB_master_single_write_seq wr_seq1, wr_seq2;
        APB_master_single_read_seq  rd_seq;
        APB_slave_random_wait_seq   s_seq;
        phase.raise_objection(this);
        s_seq = APB_slave_random_wait_seq::type_id::create("s_seq");
        fork
            if (env.slave_agent != null && m_slave_cfg.is_active == UVM_ACTIVE) s_seq.start(env.slave_agent.sqr);
            begin
                wr_seq1 = APB_master_single_write_seq::type_id::create("wr_seq1");
                wr_seq1.cfg_addr = 32'h1000;
                wr_seq1.cfg_data = 32'hAAAA_BBBB;
                `uvm_info("TEST_RST_002", "Step 1: Normal Write to Address 0x1000", UVM_LOW)
                wr_seq1.start(env.master_agent.sqr);
                fork
                    begin
                        wr_seq2 = APB_master_single_write_seq::type_id::create("wr_seq2");
                        wr_seq2.cfg_addr = 32'h2000;
                        wr_seq2.cfg_data = 32'hDEAD_DEAD;
                        `uvm_info("TEST_RST_002", "Step 2: Starting Write to Address 0x2000 (Will be aborted)", UVM_LOW)
                        wr_seq2.start(env.master_agent.sqr);
                    end
                    begin
                        #15;
                        `uvm_warning("TEST_RST_002", "INJECTING FATAL RESET MID-TRANSACTION!!! (PRESETn = 0)")
                        vif.PRESETn = 0;
                        #50;
                        `uvm_info("TEST_RST_002", "Releasing Reset (PRESETn = 1)", UVM_LOW)
                        vif.PRESETn = 1;
                    end
                join
                #20;
                `uvm_info("TEST_RST_002", "Step 3: Reading back Address 0x1000 to verify data survived Reset", UVM_LOW)
                rd_seq = APB_master_single_read_seq::type_id::create("rd_seq");
                rd_seq.cfg_addr = 32'h1000;
                rd_seq.start(env.master_agent.sqr);
            end
        join_any
        disable fork;
        phase.drop_objection(this);
    endtask
endclass
