class APB_master_psel_drop_err_driver extends APB_master_driver;
    `uvm_component_utils(APB_master_psel_drop_err_driver)

    function new(string name = "APB_master_psel_drop_err_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task wait_for_pready_and_finish(APB_sequence_item req);
        int timeout_cnt = 0;
        do begin
            @(vif.drv_master_cb);
            timeout_cnt++;
            `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Dropping PSEL during wait states!", UVM_LOW)
            vif.drv_master_cb.PSEL <= 1'b0;
            vif.drv_master_cb.PSELCHK <= 1'b0;
            if (timeout_cnt >= 100) break;
        end while (vif.drv_master_cb.PREADY === 1'b0);
        if (req.pwrite == APB_READ) begin
            req.prdata = vif.drv_master_cb.PRDATA;
            req.pruser = vif.drv_master_cb.PRUSER;
        end
        req.pbuser = vif.drv_master_cb.PBUSER;
        vif.drv_master_cb.PSEL    <= 1'b0;
        vif.drv_master_cb.PSELCHK <= 1'b0;
        vif.drv_master_cb.PENABLE <= 1'b0;
        vif.drv_master_cb.PENABLECHK <= 1'b0;
    endtask
endclass
