interface APB_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_REQ_WIDTH = 8,
    parameter int USER_DATA_WIDTH = 8,
    parameter int USER_RESP_WIDTH = 8
)(
    input logic PCLK
);
    bit REQUIRE_ALIGNED_ADDR = 1;
    bit ENABLE_LOWPOWER_CHECK = 1;
    bit ENABLE_PARITY_CHECK = 1;
logic PRESETn;
    logic [ADDR_WIDTH - 1:0] PADDR;
    logic [2:0] PPROT;
    logic PNSE;
    logic PSEL;
    logic PENABLE;
    logic PWRITE;
    logic [DATA_WIDTH - 1:0] PWDATA;
    logic [DATA_WIDTH/8 - 1:0] PSTRB;
    logic PREADY;
    logic [DATA_WIDTH - 1:0] PRDATA;
    logic PSLVERR;
    logic PWAKEUP;
    logic [USER_REQ_WIDTH - 1:0] PAUSER;
    logic [USER_DATA_WIDTH - 1:0] PWUSER;
    logic [USER_DATA_WIDTH - 1:0] PRUSER;
    logic [USER_RESP_WIDTH - 1:0] PBUSER;
    logic PADDRCHK;
    logic PCTRLCHK;
    logic PWDATACHK;
    logic PRDATACHK;
    logic PREADYCHK;
    clocking drv_master_cb @(posedge PCLK);
        default input #1ns output #1ns;
        input PREADY;
        input PRDATA;
        input PSLVERR;
        input PRUSER;
        input PBUSER;
        input PRDATACHK;
        input PREADYCHK;
        output PADDRCHK;
        output PCTRLCHK;
        output PWDATACHK;
        output PADDR;
        output PSEL;
        output PENABLE;
        output PWRITE;
        output PWDATA;
        output PPROT;
        output PSTRB;
        output PNSE;
        output PWAKEUP;
        output PAUSER;
        output PWUSER;
    endclocking
    clocking drv_slave_cb @(posedge PCLK);
        default input #1ns output #1ns;
        output PREADY;
        output PRDATA;
        output PSLVERR;
        output PRUSER;
        output PBUSER;
        output PRDATACHK;
        output PREADYCHK;
        input PADDRCHK;
        input PCTRLCHK;
        input PWDATACHK;
        input PADDR;
        input PSEL;
        input PENABLE;
        input PWRITE;
        input PWDATA;
        input PPROT;
        input PSTRB;
        input PNSE;
        input PWAKEUP;
        input PAUSER;
        input PWUSER;
    endclocking
    clocking mon_cb @(posedge PCLK);
        default input #1ns output #1ns;
        input PREADY;
        input PRDATA;
        input PSLVERR;
        input PRUSER;
        input PBUSER;
        input PADDRCHK;
        input PCTRLCHK;
        input PWDATACHK;
        input PRDATACHK;
        input PREADYCHK;
        input PADDR;
        input PSEL;
        input PENABLE;
        input PWRITE;
        input PWDATA;
        input PPROT;
        input PSTRB;
        input PNSE;
        input PWAKEUP;
        input PAUSER;
        input PWUSER;
    endclocking
    modport DRV_master (clocking drv_master_cb, input PCLK, PRESETn);
    modport DRV_slave (clocking drv_slave_cb, input PCLK, PRESETn);
    modport MON (clocking mon_cb, input PCLK, PRESETn);
    import uvm_pkg::*;
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
            property p_pwakeup_timing;
                @(posedge PCLK) disable iff (!PRESETn || !ENABLE_LOWPOWER_CHECK)
                $rose(PSEL) |-> $past(PWAKEUP);
            endproperty
            AST_WUP_01: assert property(p_pwakeup_timing)
                else `uvm_error("APB_SVA", "PWAKEUP was not asserted at least 1 cycle before PSEL")
            property p_paddr_alignment;
                @(posedge PCLK) disable iff (!PRESETn || !REQUIRE_ALIGNED_ADDR)
                PSEL |-> (PADDR[$clog2(DATA_WIDTH/8)-1:0] == '0);
            endproperty
            AST_ALGN_01: assert property(p_paddr_alignment) 
                else `uvm_error("APB_SVA", "PADDR is not aligned to DATA_WIDTH")
            property p_paddrchk;
                @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
                PSEL |-> (PADDRCHK == ^PADDR);
            endproperty
            AST_CHK_01: assert property(p_paddrchk)
                else `uvm_error("APB_SVA", "PADDRCHK Parity Error: Does not match ^PADDR")
            property p_pctrlchk;
                @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
                PSEL |-> (PCTRLCHK == ^{PSEL, PENABLE, PWRITE});
            endproperty
            AST_CHK_02: assert property(p_pctrlchk)
                else `uvm_error("APB_SVA", "PCTRLCHK Parity Error: Does not match ^{PSEL, PENABLE, PWRITE}")
            property p_pwdatachk;
                @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
                (PSEL && PWRITE) |-> (PWDATACHK == ^PWDATA);
            endproperty
            AST_CHK_03: assert property(p_pwdatachk)
                else `uvm_error("APB_SVA", "PWDATACHK Parity Error: Does not match ^PWDATA")
            property p_prdatachk;
                @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
                (PSEL && !PWRITE && PREADY) |-> (PRDATACHK == ^PRDATA);
            endproperty
            AST_CHK_04: assert property(p_prdatachk)
                else `uvm_error("APB_SVA", "PRDATACHK Parity Error: Does not match ^PRDATA")
            property p_preadychk;
                @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
                (PSEL && PREADY) |-> (PREADYCHK == ^{PREADY, PSLVERR});
            endproperty
            AST_CHK_05: assert property(p_preadychk)
                else `uvm_error("APB_SVA", "PREADYCHK Parity Error: Does not match ^{PREADY, PSLVERR}")
endinterface
