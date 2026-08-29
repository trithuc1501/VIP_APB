class APB_slave_pslverr_early_driver extends APB_slave_driver;
    `uvm_component_utils(APB_slave_pslverr_early_driver)
    function new(string name = "APB_slave_pslverr_early_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task drive_response(APB_sequence_item req);
        if (vif.drv_slave_cb.PENABLE === 1'b1) begin
            if (req.wait_states > 0) begin
                repeat (req.wait_states) begin
                    vif.drv_slave_cb.PREADY <= 1'b0;
                    `uvm_info("DRV_OVR", "FACTORY OVERRIDE: Asserting PSLVERR early during wait state!", UVM_LOW)
                    vif.drv_slave_cb.PSLVERR <= 1'b1;
                    @(vif.drv_slave_cb);
                end
            end
            vif.drv_slave_cb.PREADY <= 1'b1;
            vif.drv_slave_cb.PRUSER <= req.pruser;
            vif.drv_slave_cb.PBUSER <= req.pbuser;
            if (req.pslverr) begin
                vif.drv_slave_cb.PSLVERR <= 1'b1;
                vif.drv_slave_cb.PREADYCHK <= ^{1'b1, 1'b1};
            end else begin
                vif.drv_slave_cb.PSLVERR <= 1'b0;
                vif.drv_slave_cb.PREADYCHK <= ^{1'b1, 1'b0};
            end
            if (vif.drv_slave_cb.PWRITE === 1'b1) begin
                bit [31:0] current_data;
                if (mem.exists(vif.drv_slave_cb.PADDR)) begin
                    current_data = mem[vif.drv_slave_cb.PADDR];
                end else begin
                    current_data = 32'h0;
                end
                for (int i = 0; i < 4; i++) begin
                    if (vif.drv_slave_cb.PSTRB[i] == 1'b1) begin
                        current_data[i*8 +: 8] = vif.drv_slave_cb.PWDATA[i*8 +: 8];
                    end
                end
                mem[vif.drv_slave_cb.PADDR] = current_data;
            end else begin
                if (mem.exists(vif.drv_slave_cb.PADDR)) begin
                    vif.drv_slave_cb.PRDATA <= mem[vif.drv_slave_cb.PADDR];
                    vif.drv_slave_cb.PRDATACHK <= ^mem[vif.drv_slave_cb.PADDR];
                end else begin
                    vif.drv_slave_cb.PRDATA <= 32'hDEADBEEF;
                    vif.drv_slave_cb.PRDATACHK <= ^32'hDEADBEEF;
                end
            end
        end
    endtask
endclass
