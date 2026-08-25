import uvm_pkg::*;
`include "uvm_macros.svh"

module APB_protocol_checker #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter bit REQUIRE_ALIGNED_ADDR = 0,
    parameter bit ENABLE_LOWPOWER_CHECK = 0
)(
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic PENABLE,
    input logic PREADY,
    input logic PSLVERR,
    input logic PWRITE,
    input logic [ADDR_WIDTH-1:0] PADDR,
    input logic [DATA_WIDTH-1:0] PWDATA,
    input logic [DATA_WIDTH/8-1:0] PSTRB,
    input logic [2:0] PPROT,
    input logic PNSE,
    input logic PWAKEUP,
    input logic [7:0] PAUSER,
    input logic [7:0] PWUSER
);

    property p_reset_idle;
        @(posedge PCLK) $rose(PRESETn) |-> (PSEL == 1'b0 && PENABLE == 1'b0);
    endproperty
    AST_IDLE_01: assert property(p_reset_idle) 
        else `uvm_error("APB_SVA", "PSEL/PENABLE not idle immediately after reset")

    property p_setup_penable;
        @(posedge PCLK) disable iff (!PRESETn)
        $rose(PSEL) |-> (PENABLE == 1'b0);
    endproperty
    AST_PEN_01: assert property(p_setup_penable) 
        else `uvm_error("APB_SVA", "PENABLE is not 0 during SETUP phase")

    property p_setup_to_access;
        @(posedge PCLK) disable iff (!PRESETn)
        (PSEL && !PENABLE) |=> (PSEL && PENABLE);
    endproperty
    AST_SETUP_01: assert property(p_setup_to_access)
        else `uvm_error("APB_SVA", "PSEL dropped or PENABLE did not assert exactly 1 cycle after SETUP")

    property p_psel_stability;
        @(posedge PCLK) disable iff (!PRESETn)
        (PSEL && PENABLE && !PREADY) |=> PSEL;
    endproperty
    AST_PSEL_01: assert property(p_psel_stability) 
        else `uvm_error("APB_SVA", "PSEL dropped before PREADY was asserted in ACCESS phase")

    property p_data_stability;
        @(posedge PCLK) disable iff (!PRESETn)
        (PSEL && PENABLE && !PREADY) |=> 
            $stable(PADDR) && $stable(PWRITE) && $stable(PWDATA) && 
            $stable(PSTRB) && $stable(PPROT) && $stable(PNSE) && 
            $stable(PWAKEUP) && $stable(PAUSER) && $stable(PWUSER);
    endproperty
    AST_STAB_01: assert property(p_data_stability) 
        else `uvm_error("APB_SVA", "Master changed APB5 signals during wait states (PREADY=0)")

    property p_pslverr_timing;
        @(posedge PCLK) disable iff (!PRESETn)
        PSLVERR |-> (PSEL && PENABLE && PREADY);
    endproperty
    AST_ERR_TIM: assert property(p_pslverr_timing) 
        else `uvm_error("APB_SVA", "PSLVERR asserted while PREADY is 0 or no active transfer")

    property p_no_pipelining;
        @(posedge PCLK) disable iff (!PRESETn)
        (PSEL && PENABLE && PREADY) |=> (PENABLE == 1'b0);
    endproperty
    AST_NO_PIPE: assert property(p_no_pipelining) 
        else `uvm_error("APB_SVA", "PENABLE stayed 1 after transfer completion (Pipelining violation)")

    generate
        if (ENABLE_LOWPOWER_CHECK) begin : gen_wakeup_check
            property p_pwakeup_timing;
                @(posedge PCLK) disable iff (!PRESETn)
                $rose(PSEL) |-> $past(PWAKEUP);
            endproperty
            AST_WUP_01: assert property(p_pwakeup_timing)
                else `uvm_error("APB_SVA", "PWAKEUP was not asserted at least 1 cycle before PSEL")
        end
    endgenerate

    generate
        if (REQUIRE_ALIGNED_ADDR) begin : gen_align_check
            property p_paddr_alignment;
                @(posedge PCLK) disable iff (!PRESETn)
                PSEL |-> (PADDR[$clog2(DATA_WIDTH/8)-1:0] == '0);
            endproperty
            AST_ALGN_01: assert property(p_paddr_alignment) 
                else `uvm_error("APB_SVA", "PADDR is not aligned to DATA_WIDTH")
        end
    endgenerate

endmodule

module APB_system_checker #(
    parameter int NUM_SLAVES = 4
)(
    input logic PCLK,
    input logic PRESETn,
    input logic [NUM_SLAVES-1:0] PSEL_bus
);

    property p_psel_exclusivity;
        @(posedge PCLK) disable iff (!PRESETn)
        $onehot0(PSEL_bus);
    endproperty
    AST_EXCL_01: assert property(p_psel_exclusivity)
        else `uvm_error("APB_SVA_DEC", $sformatf("Multiple slaves selected simultaneously! PSEL_bus = %b", PSEL_bus))

endmodule
