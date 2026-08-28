class APB_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(APB_scoreboard)

    uvm_analysis_imp #(APB_sequence_item, APB_scoreboard) item_export;

    bit [31:0] ref_mem [int];

    function new(string name = "APB_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_export = new("item_export", this);
    endfunction

    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        `uvm_info("SCB_RST", "System Reset detected! Interface FSM resets.", UVM_LOW)
    endtask

    virtual function void write(APB_sequence_item item);
        
        `uvm_info("SCB", $sformatf("Scoreboard received transaction at address: 0x%0h", item.paddr), UVM_HIGH)
        
        if (item.pslverr == 1'b1) begin
            `uvm_warning("SCB_ERR", $sformatf("Transaction aborted. Slave returned ERROR (PSLVERR=1) for address 0x%0h", item.paddr))
            return;
        end

        if (item.pwrite == APB_WRITE) begin
            bit [31:0] current_data;
            if (ref_mem.exists(item.paddr)) begin
                current_data = ref_mem[item.paddr];
            end else begin
                current_data = 32'h0;
            end

            if (item.pstrb[0]) current_data[7:0]   = item.pwdata[7:0];
            if (item.pstrb[1]) current_data[15:8]  = item.pwdata[15:8];
            if (item.pstrb[2]) current_data[23:16] = item.pwdata[23:16];
            if (item.pstrb[3]) current_data[31:24] = item.pwdata[31:24];

            ref_mem[item.paddr] = current_data;
            `uvm_info("SCB_WRITE", $sformatf("Stored data 0x%0h to address 0x%0h with PSTRB=0b%0b, PPROT=0b%0b", current_data, item.paddr, item.pstrb, item.pprot), UVM_LOW)
        end
        if (item.pauser != 0 || item.pwuser != 0 || item.pruser != 0 || item.pbuser != 0) begin
            `uvm_info("SCB_USER", $sformatf("Observed User Signals -> PAUSER: 0x%0h, PWUSER: 0x%0h, PRUSER: 0x%0h, PBUSER: 0x%0h", item.pauser, item.pwuser, item.pruser, item.pbuser), UVM_LOW)
        end

        if (item.pwrite == APB_READ) begin
            if (ref_mem.exists(item.paddr)) begin
                if (ref_mem[item.paddr] == item.prdata) begin
                    `uvm_info("SCB_PASS", $sformatf("[PASSED] Address 0x%0h | Expected: 0x%0h == Actual: 0x%0h", 
                              item.paddr, ref_mem[item.paddr], item.prdata), UVM_NONE)
                end else begin
                    `uvm_error("SCB_FAIL", $sformatf("[FAILED] Address 0x%0h | Expected: 0x%0h != Actual: 0x%0h", 
                               item.paddr, ref_mem[item.paddr], item.prdata))
                end
            end else begin
                `uvm_warning("SCB_WARN", $sformatf("Read from uninitialized address: 0x%0h (Actual data: 0x%0h)", 
                             item.paddr, item.prdata))
            end
        end

    endfunction

endclass
