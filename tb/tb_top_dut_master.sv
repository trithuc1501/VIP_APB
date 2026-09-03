`include "uvm_macros.svh"
import uvm_pkg::*;
`include "tb/APB_if.sv"
`include "APB_vip_pkg.sv"
import APB_vip_pkg::*;
module dummy_dma_master (
    input logic PCLK,
    input logic PRESETn,
    output logic PSEL,
    output logic PENABLE,
    output logic PWRITE,
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    input logic [31:0] PRDATA,
    input logic PREADY,
    input logic PSLVERR
);
    assign PSEL = 1'b0;
    assign PENABLE = 1'b0;
    assign PWRITE = 1'b0;
    assign PADDR = '0;
    assign PWDATA = '0;
endmodule
module tb_top_dut_master;
    logic PCLK;
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end
    APB_if #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32)
    ) vif(
        .PCLK(PCLK)
    );
    dummy_dma_master dut (
        .PCLK(PCLK),
        .PRESETn(vif.PRESETn),
        .PSEL(vif.PSEL),
        .PENABLE(vif.PENABLE),
        .PWRITE(vif.PWRITE),
        .PADDR(vif.PADDR),
        .PWDATA(vif.PWDATA),
        .PRDATA(vif.PRDATA),
        .PREADY(vif.PREADY),
        .PSLVERR(vif.PSLVERR)
    );
    initial begin
        vif.PRESETn = 0;
        #20;
        vif.PRESETn = 1;
    end
    initial begin
        uvm_config_db#(virtual APB_if)::set(null, "*", "vif", vif);
        uvm_config_db#(int)::set(null, "*", "UVM_ENABLE_SLAVE", 1);
        uvm_config_db#(int)::set(null, "*", "UVM_NO_MASTER", 1);
        run_test();
    end
    initial begin
        $dumpfile("dump_dut_master.vcd");
        $dumpvars(0, tb_top_dut_master.vif, tb_top_dut_master.PCLK);
    end
endmodule
