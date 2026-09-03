class APB_master_wakeup_err_driver extends APB_master_driver;
    `uvm_component_utils(APB_master_wakeup_err_driver)

    function new(string name = "APB_master_wakeup_err_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task drive_transaction(APB_sequence_item req);
        repeat (req.delay) @(vif.drv_master_cb);
        `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Asserting PWAKEUP and PSEL simultaneously!", UVM_LOW)
        if (vif.PWAKEUP !== 1'b1) begin
            @(vif.drv_master_cb); 
            vif.drv_master_cb.PWAKEUP <= 1'b1;
        end
        drive_setup_phase(req);
        drive_access_phase(req);
        wait_for_pready_and_finish(req);
    endtask

endclass
