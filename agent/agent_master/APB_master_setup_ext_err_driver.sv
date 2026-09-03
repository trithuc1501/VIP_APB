class APB_master_setup_ext_err_driver extends APB_master_driver;
    `uvm_component_utils(APB_master_setup_ext_err_driver)

    function new(string name = "APB_master_setup_ext_err_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task drive_setup_phase(APB_sequence_item req);
        super.drive_setup_phase(req);
        `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Extending SETUP phase to 2 cycles!", UVM_LOW)
        @(vif.drv_master_cb);
    endtask

endclass
