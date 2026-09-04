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
        if (req.pwrite == APB_WRITE) begin
            vif.drv_master_cb.PWDATA <= req.pwdata;
            vif.drv_master_cb.PSTRB  <= req.pstrb;
            vif.drv_master_cb.PWUSER <= req.pwuser;
        end else begin
            vif.drv_master_cb.PWDATA <= 32'h0;
            vif.drv_master_cb.PSTRB  <= 4'h0;
            vif.drv_master_cb.PWUSER <= 8'h0;
        end
        vif.drv_master_cb.PADDRCHK  <= calc_byte_parity(req.paddr, 32/8);
        vif.drv_master_cb.PWDATACHK <= (req.pwrite == APB_WRITE) ? calc_byte_parity(req.pwdata, 32/8) : 0;
        vif.drv_master_cb.PCTRLCHK  <= ^{req.pprot, req.pwrite, req.pnse};
        vif.drv_master_cb.PSELCHK   <= 1'b1;
        vif.drv_master_cb.PENABLECHK <= 1'b1;
        `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Injecting PENABLE=1 during SETUP phase!", UVM_LOW)
        vif.drv_master_cb.PSTRBCHK  <= ^req.pstrb;
        vif.drv_master_cb.PWAKEUPCHK <= pwakeup_asserted;
        vif.drv_master_cb.PAUSERCHK <= calc_byte_parity(req.pauser, (8+7)/8);
        vif.drv_master_cb.PWUSERCHK <= (req.pwrite == APB_WRITE) ? calc_byte_parity(req.pwuser, (8+7)/8) : 0;
        @(vif.drv_master_cb);
    endtask
endclass
