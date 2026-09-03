`include "uvm_macros.svh"
import uvm_pkg::*;
`include "tb/APB_if.sv"
`include "APB_vip_pkg.sv"
import APB_vip_pkg::*;
module dummy_spi_slave (
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic PENABLE,
    input logic PWRITE,
    input logic [31:0] PADDR,
    input logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic PREADY,
    output logic PSLVERR
);
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;
    assign PRDATA = 32'hDEADBEEF;
endmodule
module tb_top_dut_slave;
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
    dummy_spi_slave dut (
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
        run_test();
    end
    initial begin
        $dumpfile("dump_dut_slave.vcd");
        $dumpvars(0, tb_top_dut_slave.vif, tb_top_dut_slave.PCLK);
    end
endmodule
