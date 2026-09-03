class APB_master_penable_err_driver extends APB_master_driver;
    `uvm_component_utils(APB_master_penable_err_driver)

    function new(string name = "APB_master_penable_err_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task drive_setup_phase(APB_sequence_item req);
        vif.drv_master_cb.PSEL    <= 1'b1;
        vif.drv_master_cb.PENABLE <= 1'b1; 
        vif.drv_master_cb.PADDR   <= req.paddr;
        vif.drv_master_cb.PWRITE  <= req.pwrite;
        vif.drv_master_cb.PPROT   <= req.pprot;
        vif.drv_master_cb.PNSE    <= req.pnse;
        vif.drv_master_cb.PAUSER  <= req.pauser;
        if (req.pwrite == 1'b1) begin
            vif.drv_master_cb.PWDATA <= req.pwdata;
            vif.drv_master_cb.PSTRB  <= req.pstrb;
            vif.drv_master_cb.PWUSER <= req.pwuser;
        end else begin
            vif.drv_master_cb.PWDATA <= 32'h0;
            vif.drv_master_cb.PSTRB  <= 4'h0;
            vif.drv_master_cb.PWUSER <= 8'h0;
        end
        vif.drv_master_cb.PADDRCHK  <= ^req.paddr;
        vif.drv_master_cb.PWDATACHK <= (req.pwrite == 1'b1) ? ^req.pwdata : 1'b0;
        vif.drv_master_cb.PCTRLCHK  <= ^{1'b1, 1'b1, req.pwrite}; 
        `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Injecting PENABLE=1 during SETUP phase!", UVM_LOW)
        @(vif.drv_master_cb);
    endtask

endclass
