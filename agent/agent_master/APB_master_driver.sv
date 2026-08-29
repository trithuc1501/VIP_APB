class APB_master_driver extends uvm_driver #(APB_sequence_item);
    `uvm_component_utils(APB_master_driver)
    virtual APB_if vif;
    function new(string name = "APB_master_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual APB_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV_MASTER", "Could not get virtual interface")
        end
    endfunction
    virtual task run_phase(uvm_phase phase);
        reset_signals();
        forever begin
            wait(vif.PRESETn === 1'b1);
            fork
                begin
                    forever begin
                        seq_item_port.get_next_item(req);
                        drive_transaction(req);
                        seq_item_port.item_done();
                    end
                end
                begin
                    wait(vif.PRESETn === 1'b0);
                    `uvm_warning("DRV_MASTER", "Hardware RESET asserted mid-transaction! Aborting.")
                end
            join_any
            disable fork;
            reset_signals();
            if (req != null) begin
                seq_item_port.item_done();
            end
        end
    endtask
    virtual task reset_signals();
        vif.drv_master_cb.PSEL    <= 1'b0;
        vif.drv_master_cb.PENABLE <= 1'b0;
        vif.drv_master_cb.PWAKEUP <= 1'b0;
        vif.drv_master_cb.PADDRCHK  <= 1'b0;
        vif.drv_master_cb.PWDATACHK <= 1'b0;
        vif.drv_master_cb.PCTRLCHK  <= 1'b0;
        vif.drv_master_cb.PADDR <= 0;
        vif.drv_master_cb.PWRITE <= 0;
        vif.drv_master_cb.PWDATA <= 0;
        vif.drv_master_cb.PSTRB <= 0;
        vif.drv_master_cb.PPROT <= 0;
        vif.drv_master_cb.PNSE <= 0;
        vif.drv_master_cb.PAUSER <= 0;
        vif.drv_master_cb.PWUSER <= 0;
    endtask
    virtual task drive_transaction(APB_sequence_item req);
        repeat (req.delay) @(vif.drv_master_cb);
        if (vif.PWAKEUP !== 1'b1) begin
            vif.drv_master_cb.PWAKEUP <= 1'b1;
            @(vif.drv_master_cb);
            @(vif.drv_master_cb); 
        end
        drive_setup_phase(req);
        drive_access_phase(req);
        wait_for_pready_and_finish(req);
    endtask
    virtual task drive_setup_phase(APB_sequence_item req);
        vif.drv_master_cb.PSEL    <= 1'b1;
        vif.drv_master_cb.PENABLE <= 1'b0;
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
        vif.drv_master_cb.PADDRCHK  <= ^req.paddr;
        vif.drv_master_cb.PWDATACHK <= (req.pwrite == APB_WRITE) ? ^req.pwdata : 1'b0;
        vif.drv_master_cb.PCTRLCHK  <= ^{1'b1, 1'b0, req.pwrite};
        @(vif.drv_master_cb);
    endtask
    virtual task drive_access_phase(APB_sequence_item req);
        vif.drv_master_cb.PENABLE <= 1'b1;
        vif.drv_master_cb.PCTRLCHK <= ^{1'b1, 1'b1, req.pwrite};
    endtask
    virtual task wait_for_pready_and_finish(APB_sequence_item req);
        int timeout_cnt = 0;
        do begin
            @(vif.drv_master_cb);
            timeout_cnt++;
            if (timeout_cnt >= 100) begin
                `uvm_error("DRV_TIMEOUT", "APB Bus Hung! Slave failed to assert PREADY within 100 cycles.")
                break;
            end
        end while (vif.drv_master_cb.PREADY === 1'b0);
        if (req.pwrite == APB_READ) begin
            req.prdata = vif.drv_master_cb.PRDATA;
            req.pruser = vif.drv_master_cb.PRUSER;
        end
        req.pbuser = vif.drv_master_cb.PBUSER;
        vif.drv_master_cb.PSEL    <= 1'b0;
        vif.drv_master_cb.PENABLE <= 1'b0;
        vif.drv_master_cb.PCTRLCHK <= 1'b0;
    endtask
endclass
