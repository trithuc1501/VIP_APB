`include "uvm_macros.svh"
import uvm_pkg::*;
`include "tb/APB_if.sv"
`include "APB_vip_pkg.sv"
import APB_vip_pkg::*;

module tb_top_loopback;
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
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_loopback.vif, tb_top_loopback.PCLK);
    end
endmodule
