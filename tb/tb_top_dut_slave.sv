`include "uvm_macros.svh"
import uvm_pkg::*;
`include "tb/APB_if.sv"
`include "APB_vip_pkg.sv"
import APB_vip_pkg::*;

module tb_top_dut_slave;
    logic PCLK;

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end
    APB_if #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ENABLE_PARITY_CHECK(0) 
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
        $dumpfile("dump_dut_slave.vcd");
        $dumpvars(0, tb_top_dut_slave.vif, tb_top_dut_slave.PCLK);
    end
endmodule
