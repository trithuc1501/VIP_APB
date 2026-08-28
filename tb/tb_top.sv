`include "uvm_macros.svh"
import uvm_pkg::*;

`include "tb/APB_if.sv"

`include "APB_vip_pkg.sv"
import APB_vip_pkg::*;

module tb_top;

    logic PCLK;

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    APB_if vif(
        .PCLK(PCLK)
    );

    `include "tb/APB_sva_checkers.sv"

    APB_protocol_checker #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .REQUIRE_ALIGNED_ADDR(1),
        .ENABLE_LOWPOWER_CHECK(1)
    ) sva_checker (
        .PCLK(PCLK),
        .PRESETn(vif.PRESETn),
        .PSEL(vif.PSEL),
        .PENABLE(vif.PENABLE),
        .PREADY(vif.PREADY),
        .PSLVERR(vif.PSLVERR),
        .PWRITE(vif.PWRITE),
        .PADDR(vif.PADDR),
        .PWDATA(vif.PWDATA),
        .PSTRB(vif.PSTRB),
        .PPROT(vif.PPROT),
        .PNSE(vif.PNSE),
        .PWAKEUP(vif.PWAKEUP),
        .PAUSER(vif.PAUSER),
        .PWUSER(vif.PWUSER)
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
        $dumpvars(0, tb_top.vif, tb_top.PCLK);
    end

endmodule
