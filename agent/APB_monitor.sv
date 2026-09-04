class APB_monitor extends uvm_monitor;
    `uvm_component_utils(APB_monitor)
    virtual APB_if vif;
    uvm_analysis_port #(APB_sequence_item) ap;

    function new(string name = "APB_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        APB_sequence_item item;
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.PSEL === 1'b1 &&
                vif.mon_cb.PENABLE === 1'b1 &&
                vif.mon_cb.PREADY === 1'b1) begin
                item = APB_sequence_item#()::type_id::create("item");
                item.paddr   = vif.mon_cb.PADDR;
                item.pslverr = vif.mon_cb.PSLVERR;
                item.pwrite  = (vif.mon_cb.PWRITE === 1'b1) ? APB_WRITE : APB_READ;
                item.pprot   = vif.mon_cb.PPROT;
                item.pnse    = vif.mon_cb.PNSE;
                item.pwakeup = vif.mon_cb.PWAKEUP;
                item.pauser  = vif.mon_cb.PAUSER;
                item.pbuser  = vif.mon_cb.PBUSER;
                item.paddrchk   = vif.mon_cb.PADDRCHK;
                item.pctrlchk   = vif.mon_cb.PCTRLCHK;
                item.pselchk    = vif.mon_cb.PSELCHK;
                item.penablechk = vif.mon_cb.PENABLECHK;
                item.preadychk  = vif.mon_cb.PREADYCHK;
                item.pslverrchk = vif.mon_cb.PSLVERRCHK;
                item.pwakeupchk = vif.mon_cb.PWAKEUPCHK;
                item.pauserchk  = vif.mon_cb.PAUSERCHK;
                item.pbuserchk  = vif.mon_cb.PBUSERCHK;
                if (item.pwrite == APB_WRITE) begin
                    item.pwdata     = vif.mon_cb.PWDATA;
                    item.pstrb      = vif.mon_cb.PSTRB;
                    item.pwuser     = vif.mon_cb.PWUSER;
                    item.pwdatachk  = vif.mon_cb.PWDATACHK;
                    item.pstrbchk   = vif.mon_cb.PSTRBCHK;
                    item.pwuserchk  = vif.mon_cb.PWUSERCHK;
                end else begin
                    item.prdata     = vif.mon_cb.PRDATA;
                    item.pruser     = vif.mon_cb.PRUSER;
                    item.prdatachk  = vif.mon_cb.PRDATACHK;
                    item.pruserchk  = vif.mon_cb.PRUSERCHK;
                end
                ap.write(item);
                `uvm_info("APB_MON", $sformatf("Captured transaction: \n%s", item.sprint()), UVM_HIGH)
            end
        end
    endtask

endclass
