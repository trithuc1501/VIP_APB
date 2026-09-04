class APB_slave_driver extends uvm_driver #(APB_sequence_item);
    `uvm_component_utils(APB_slave_driver)
    virtual APB_if vif;
    bit [31:0] mem [int];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_signals();
        forever begin
            wait(vif.PRESETn === 1'b1);
            fork
                begin
                    forever begin
                        seq_item_port.get_next_item(req);
                        wait_for_setup();
                        wait_for_access();
                        drive_response(req);
                        finish_transaction();
                        seq_item_port.item_done();
                        req = null;
                    end
                end
                begin
                    wait(vif.PRESETn === 1'b0);
                    `uvm_warning("DRV_SLAVE", "Hardware RESET asserted mid-transaction! Aborting.")
                end
            join_any
            disable fork;
            reset_signals();
            if (req != null) begin
                seq_item_port.item_done();
                req = null;
            end
            wait(vif.PRESETn === 1'b1);
            @(vif.drv_slave_cb);
        end
    endtask

    virtual task reset_signals();
        vif.drv_slave_cb.PREADY  <= 1'b0;
        vif.drv_slave_cb.PRDATA  <= 32'h0;
        vif.drv_slave_cb.PSLVERR <= 1'b0;
        vif.drv_slave_cb.PRUSER  <= 8'h0;
        vif.drv_slave_cb.PBUSER  <= 8'h0;
        vif.drv_slave_cb.PRDATACHK <= 0;
        vif.drv_slave_cb.PREADYCHK <= 0;
        vif.drv_slave_cb.PSLVERRCHK <= 0;
        vif.drv_slave_cb.PRUSERCHK <= 0;
        vif.drv_slave_cb.PBUSERCHK <= 0;
        endtask

    virtual task wait_for_setup();
        forever begin
            @(vif.drv_slave_cb);
            if (vif.drv_slave_cb.PSEL === 1'b1 && vif.drv_slave_cb.PENABLE === 1'b0) begin
                break;
            end
        end
        `uvm_info("DRV_SLAVE", $sformatf("Detected SETUP phase to addr 0x%0h", vif.drv_slave_cb.PADDR), UVM_NONE)
    endtask

    virtual task wait_for_access();
        do begin
            @(vif.drv_slave_cb);
        end while (vif.drv_slave_cb.PENABLE === 1'b0 && vif.drv_slave_cb.PSEL === 1'b1);
    endtask

    virtual task drive_response(APB_sequence_item req);
        if (vif.drv_slave_cb.PENABLE === 1'b1) begin
            if (req.wait_states > 0) begin
                repeat (req.wait_states) begin
                    vif.drv_slave_cb.PREADY <= 1'b0;
                    vif.drv_slave_cb.PREADYCHK <= 1'b0;
                    @(vif.drv_slave_cb);
                end
            end
            vif.drv_slave_cb.PREADY <= 1'b1;
            vif.drv_slave_cb.PREADYCHK <= 1'b1;
            vif.drv_slave_cb.PRUSER <= req.pruser;
            vif.drv_slave_cb.PRUSERCHK <= calc_byte_parity(req.pruser, 2);
            vif.drv_slave_cb.PBUSER <= req.pbuser;
            vif.drv_slave_cb.PBUSERCHK <= calc_byte_parity(req.pbuser, 2);

            if (req.pslverr) begin
                vif.drv_slave_cb.PSLVERR <= 1'b1;
                vif.drv_slave_cb.PSLVERRCHK <= 1'b1;
            end else begin
                vif.drv_slave_cb.PSLVERR <= 1'b0;
                vif.drv_slave_cb.PSLVERRCHK <= 1'b0;
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
                `uvm_info("DRV_SLAVE", $sformatf("Wrote 0x%0h to 0x%0h", current_data, vif.drv_slave_cb.PADDR), UVM_NONE)
            end else begin
                logic [31:0] rdata;
                if (mem.exists(vif.drv_slave_cb.PADDR)) begin
                    rdata = mem[vif.drv_slave_cb.PADDR];
                end else begin
                    rdata = 32'hDEADBEEF;
                end
                vif.drv_slave_cb.PRDATA <= rdata;
                vif.drv_slave_cb.PRDATACHK <= calc_byte_parity(rdata, 4);
                `uvm_info("DRV_SLAVE", $sformatf("Read 0x%0h from 0x%0h", rdata, vif.drv_slave_cb.PADDR), UVM_NONE)
            end
        end
    endtask

    virtual task finish_transaction();
        @(vif.drv_slave_cb);
        reset_signals();
    endtask

endclass
