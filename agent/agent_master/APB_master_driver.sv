class APB_master_driver extends uvm_driver #(APB_sequence_item);
    `uvm_component_utils(APB_master_driver)

    virtual APB_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        vif.drv_master_cb.PSEL    <= 1'b0;
        vif.drv_master_cb.PENABLE <= 1'b0;
        vif.drv_master_cb.PWAKEUP <= 1'b0;

        forever begin
            wait(vif.PRESETn === 1'b1);
            
            fork
                begin
                    forever begin
                        seq_item_port.get_next_item(req);

                        @(vif.drv_master_cb);
                        `uvm_info("DRV_MASTER", $sformatf("Driving SETUP phase to address 0x%0h", req.paddr), UVM_NONE)
                        
                        repeat (req.delay) @(vif.drv_master_cb);

                        vif.drv_master_cb.PADDR   <= req.paddr;
                        vif.drv_master_cb.PWRITE  <= req.pwrite;
                        vif.drv_master_cb.PPROT   <= req.pprot;
                        vif.drv_master_cb.PNSE    <= req.pnse;
                        if (req.pwakeup == 1'b1 && vif.drv_master_cb.PWAKEUP !== 1'b1) begin
                            vif.drv_master_cb.PWAKEUP <= 1'b1;
                            if (req.inject_pwakeup_err) begin
                                `uvm_info("DRV_MASTER", "INJECTING ERROR: Asserting PSEL in the same cycle as PWAKEUP!", UVM_LOW)
                            end else begin
                                @(vif.drv_master_cb);
                            end
                        end else if (req.pwakeup == 1'b0) begin
                            vif.drv_master_cb.PWAKEUP <= 1'b0;
                        end

                        vif.drv_master_cb.PAUSER  <= req.pauser;
                        vif.drv_master_cb.PWUSER  <= req.pwuser;
                        
                        if (req.pwrite == APB_WRITE) begin
                            vif.drv_master_cb.PWDATA <= req.pwdata;
                            vif.drv_master_cb.PSTRB  <= req.pstrb;
                        end else begin
                            vif.drv_master_cb.PWDATA <= 0;
                            vif.drv_master_cb.PSTRB  <= 0;
                        end

                        begin
                            vif.drv_master_cb.PSEL    <= 1'b1;
                            vif.drv_master_cb.PENABLE <= req.inject_penable_err ? 1'b1 : 1'b0;

                            @(vif.drv_master_cb);
                            
                            if (req.inject_setup_ext_err) begin
                                `uvm_info("DRV_MASTER", "INJECTING ERROR: Extending SETUP phase beyond 1 cycle!", UVM_LOW)
                                @(vif.drv_master_cb); 
                            end
                            
                            `uvm_info("DRV_MASTER", "Moving to ACCESS phase (PENABLE=1)", UVM_NONE)
                            vif.drv_master_cb.PENABLE <= 1'b1;
                        end

                        begin
                            int timeout_cnt;
                            timeout_cnt = 0;
                            do begin
                                @(vif.drv_master_cb);
                                
                                if (req.inject_psel_drop_err) begin
                                    vif.drv_master_cb.PSEL <= 1'b0;
                                    `uvm_info("DRV_MASTER", "INJECTING ERROR: Dropping PSEL mid-transaction!", UVM_LOW)
                                end

                                if (req.inject_stability_err) begin
                                    vif.drv_master_cb.PADDR <= vif.drv_master_cb.PADDR ^ 32'h4;
                                    `uvm_info("DRV_MASTER", "INJECTING ERROR: Changing PADDR during wait states!", UVM_LOW)
                                end

                                timeout_cnt++;
                                if (timeout_cnt >= 100) begin
                                    `uvm_error("DRV_TIMEOUT", "APB Bus Hung! Slave failed to assert PREADY within 100 cycles.")
                                    break;
                                end
                            end while (vif.drv_master_cb.PREADY === 1'b0);
                        end

                        `uvm_info("DRV_MASTER", "Transaction completed", UVM_NONE)

                        if (req.pwrite == APB_READ) begin
                            req.prdata = vif.drv_master_cb.PRDATA;
                        end
                        
                        req.pslverr = vif.drv_master_cb.PSLVERR;
                        req.pruser  = vif.drv_master_cb.PRUSER;
                        req.pbuser  = vif.drv_master_cb.PBUSER;

                        if (req.inject_pipeline_err) begin
                            `uvm_info("DRV_MASTER", "INJECTING ERROR: Holding PENABLE high after transfer (Pipelining violation)!", UVM_LOW)
                            vif.drv_master_cb.PSEL    <= 1'b1;
                            vif.drv_master_cb.PENABLE <= 1'b1;
                        end else begin
                            vif.drv_master_cb.PSEL    <= 1'b0;
                            vif.drv_master_cb.PENABLE <= 1'b0;
                        end

                        seq_item_port.item_done();
                        req = null;
                    end
                end
                begin        
                    wait(vif.PRESETn === 1'b0);
                    `uvm_warning("DRV_MASTER", "Hardware RESET asserted mid-transaction! Aborting.")
                end
            join_any

            disable fork;
            
            @(vif.drv_master_cb);
            vif.drv_master_cb.PSEL    <= 1'b0;
            vif.drv_master_cb.PENABLE <= 1'b0;
            vif.drv_master_cb.PADDR   <= '0;
            vif.drv_master_cb.PWRITE  <= 1'b0;
            vif.drv_master_cb.PPROT   <= '0;
            vif.drv_master_cb.PNSE    <= 1'b0;
            vif.drv_master_cb.PAUSER  <= '0;
            vif.drv_master_cb.PWUSER  <= '0;
            vif.drv_master_cb.PWAKEUP <= 1'b0;
            
            if (req != null) begin
                seq_item_port.item_done();
                req = null;
            end
            
            wait(vif.PRESETn === 1'b1);
            @(vif.drv_master_cb);
        end
    endtask
endclass
