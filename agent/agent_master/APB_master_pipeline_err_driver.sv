class APB_master_pipeline_err_driver extends APB_master_driver;
    `uvm_component_utils(APB_master_pipeline_err_driver)
    function new(string name = "APB_master_pipeline_err_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task wait_for_pready_and_finish(APB_sequence_item req);
        super.wait_for_pready_and_finish(req);
        `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Holding PENABLE high after transfer!", UVM_LOW)
        vif.drv_master_cb.PSEL    <= 1'b1;
        vif.drv_master_cb.PENABLE <= 1'b1;
        vif.drv_master_cb.PCTRLCHK <= ^{1'b1, 1'b1, req.pwrite};
    endtask
endclass
