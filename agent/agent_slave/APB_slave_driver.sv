class APB_slave_driver extends uvm_driver #(APB_sequence_item);
    `uvm_component_utils(APB_slave_driver)

    virtual APB_if vif;
    bit [31:0] mem [int];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        vif.drv_slave_cb.PREADY  <= 1'b0;
        vif.drv_slave_cb.PRDATA  <= 0;
        vif.drv_slave_cb.PSLVERR <= 1'b0;

        forever begin
            wait(vif.PRESETn === 1'b1);

            fork
                begin
                    forever begin
                        seq_item_port.get_next_item(req);

                        forever begin
                            @(vif.drv_slave_cb);
                            if (vif.drv_slave_cb.PSEL === 1'b1 && vif.drv_slave_cb.PENABLE === 1'b0) begin
                                break;
                            end
                        end
                        
                        `uvm_info("DRV_SLAVE", $sformatf("Detected SETUP phase to addr 0x%0h", vif.drv_slave_cb.PADDR), UVM_NONE)

                        do begin
                            @(vif.drv_slave_cb);
                        end while (vif.drv_slave_cb.PENABLE === 1'b0 && vif.drv_slave_cb.PSEL === 1'b1);

                        if (vif.drv_slave_cb.PENABLE === 1'b1) begin
                            if (req.wait_states > 0) begin
                                repeat (req.wait_states) begin
                                    vif.drv_slave_cb.PREADY <= 1'b0;
                                    
                                    if (req.inject_pslverr_timing_err) begin
                                        `uvm_info("DRV_SLAVE", "INJECTING ERROR: Asserting PSLVERR early during wait state!", UVM_LOW)
                                        vif.drv_slave_cb.PSLVERR <= 1'b1;
                                    end
                                    @(vif.drv_slave_cb);
                                end
                            end
                            vif.drv_slave_cb.PREADY <= 1'b1;

                            if (req.pslverr) begin
                                vif.drv_slave_cb.PSLVERR <= 1'b1;
                                `uvm_info("DRV_SLAVE", "INJECTING PSLVERR", UVM_LOW)
                            end else begin
                                vif.drv_slave_cb.PSLVERR <= 1'b0;
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
                                if (mem.exists(vif.drv_slave_cb.PADDR)) begin
                                    vif.drv_slave_cb.PRDATA <= mem[vif.drv_slave_cb.PADDR];
                                end else begin
                                    vif.drv_slave_cb.PRDATA <= 32'hDEADBEEF;
                                end
                                `uvm_info("DRV_SLAVE", $sformatf("Read 0x%0h from 0x%0h", vif.drv_slave_cb.PRDATA, vif.drv_slave_cb.PADDR), UVM_NONE)
                            end
                        end

                        @(vif.drv_slave_cb);
                        vif.drv_slave_cb.PREADY  <= 1'b0;
                        vif.drv_slave_cb.PSLVERR <= 1'b0;
                        vif.drv_slave_cb.PRDATA  <= 0;

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
            
            @(vif.drv_slave_cb);
            vif.drv_slave_cb.PREADY  <= 1'b0;
            vif.drv_slave_cb.PRDATA  <= 32'h0;
            vif.drv_slave_cb.PSLVERR <= 1'b0;
            
            if (req != null) begin
                seq_item_port.item_done();
                req = null;
            end
            
            wait(vif.PRESETn === 1'b1);
            @(vif.drv_slave_cb);
        end
    endtask
endclass
