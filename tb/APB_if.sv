import APB_vip_pkg::*;
interface APB_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_REQ_WIDTH = 8,
    parameter int USER_DATA_WIDTH = 8,
    parameter int USER_RESP_WIDTH = 8,
    parameter bit REQUIRE_ALIGNED_ADDR = 1,
    parameter bit ENABLE_LOWPOWER_CHECK = 1,
    parameter bit ENABLE_PARITY_CHECK = 1
)(
    input logic PCLK
);
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
    logic [(ADDR_WIDTH/8)-1:0] PADDRCHK;
    logic PCTRLCHK;
    logic PSELCHK;
    logic PENABLECHK;
    logic [(DATA_WIDTH/8)-1:0] PWDATACHK;
    logic PSTRBCHK;
    logic PREADYCHK;
    logic [(DATA_WIDTH/8)-1:0] PRDATACHK;
    logic PSLVERRCHK;
    logic PWAKEUPCHK;
    logic [((USER_REQ_WIDTH+7)/8)-1:0] PAUSERCHK;
    logic [((USER_DATA_WIDTH+7)/8)-1:0] PWUSERCHK;
    logic [((USER_DATA_WIDTH+7)/8)-1:0] PRUSERCHK;
    logic [((USER_RESP_WIDTH+7)/8)-1:0] PBUSERCHK;

    clocking drv_master_cb @(posedge PCLK);
        default input #1step output #0;
        input PREADY;
        input PRDATA;
        input PSLVERR;
        input PRUSER;
        input PBUSER;
        input PRDATACHK;
        input PREADYCHK;
        input PSLVERRCHK;
        input PRUSERCHK;
        input PBUSERCHK;
        output PADDRCHK;
        output PCTRLCHK;
        output PSELCHK;
        output PENABLECHK;
        output PWDATACHK;
        output PSTRBCHK;
        output PWAKEUPCHK;
        output PAUSERCHK;
        output PWUSERCHK;
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
        default input #1step output #0;
        output PREADY;
        output PRDATA;
        output PSLVERR;
        output PRUSER;
        output PBUSER;
        output PRDATACHK;
        output PREADYCHK;
        output PSLVERRCHK;
        output PRUSERCHK;
        output PBUSERCHK;
        input PADDRCHK;
        input PCTRLCHK;
        input PSELCHK;
        input PENABLECHK;
        input PWDATACHK;
        input PSTRBCHK;
        input PWAKEUPCHK;
        input PAUSERCHK;
        input PWUSERCHK;
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
        default input #1step;
        input PREADY;
        input PRDATA;
        input PSLVERR;
        input PRUSER;
        input PBUSER;
        input PADDRCHK;
        input PCTRLCHK;
        input PSELCHK;
        input PENABLECHK;
        input PWDATACHK;
        input PSTRBCHK;
        input PREADYCHK;
        input PRDATACHK;
        input PSLVERRCHK;
        input PWAKEUPCHK;
        input PAUSERCHK;
        input PWUSERCHK;
        input PRUSERCHK;
        input PBUSERCHK;
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

    property p_pctrlchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        PSEL |-> (PCTRLCHK == ^{PPROT, PWRITE, PNSE});
    endproperty
    AST_CHK_PCTRL: assert property(p_pctrlchk) else `uvm_error("APB_SVA", "PCTRLCHK Parity Error")

    property p_pselchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        PSELCHK == ^PSEL;
    endproperty
    AST_CHK_PSEL: assert property(p_pselchk) else `uvm_error("APB_SVA", "PSELCHK Parity Error")

    property p_penablechk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        PSEL |-> (PENABLECHK == ^PENABLE);
    endproperty
    AST_CHK_PENABLE: assert property(p_penablechk) else `uvm_error("APB_SVA", "PENABLECHK Parity Error")

    property p_preadychk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && PENABLE) |-> (PREADYCHK == ^PREADY);
    endproperty
    AST_CHK_PREADY: assert property(p_preadychk) else `uvm_error("APB_SVA", "PREADYCHK Parity Error")

    property p_pslverrchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && PENABLE && PREADY) |-> (PSLVERRCHK == ^PSLVERR);
    endproperty
    AST_CHK_PSLVERR: assert property(p_pslverrchk) else `uvm_error("APB_SVA", "PSLVERRCHK Parity Error")


    property p_paddrchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        PSEL |-> (PADDRCHK == APB_vip_pkg::calc_byte_parity(PADDR, ADDR_WIDTH/8));
    endproperty
    AST_CHK_01: assert property(p_paddrchk) else `uvm_error("APB_SVA", "PADDRCHK Parity Error")

    property p_pwdatachk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && PWRITE) |-> (PWDATACHK == APB_vip_pkg::calc_byte_parity(PWDATA, DATA_WIDTH/8));
    endproperty
    AST_CHK_03: assert property(p_pwdatachk) else `uvm_error("APB_SVA", "PWDATACHK Parity Error")

    property p_prdatachk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && !PWRITE && PREADY && PENABLE && !PSLVERR) |-> (PRDATACHK == APB_vip_pkg::calc_byte_parity(PRDATA, DATA_WIDTH/8));
    endproperty
    AST_CHK_04: assert property(p_prdatachk) else `uvm_error("APB_SVA", "PRDATACHK Parity Error")


    property p_pstrbchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && PWRITE) |-> (PSTRBCHK == ^PSTRB);
    endproperty
    AST_CHK_PSTRB: assert property(p_pstrbchk) else `uvm_error("APB_SVA", "PSTRBCHK Parity Error")

    property p_pwakeupchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        PWAKEUPCHK == ^PWAKEUP;
    endproperty
    AST_CHK_PWAKEUP: assert property(p_pwakeupchk) else `uvm_error("APB_SVA", "PWAKEUPCHK Parity Error")

    property p_pauserchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        PSEL |-> (PAUSERCHK == APB_vip_pkg::calc_byte_parity(PAUSER, (USER_REQ_WIDTH+7)/8));
    endproperty
    AST_CHK_PAUSER: assert property(p_pauserchk) else `uvm_error("APB_SVA", "PAUSERCHK Parity Error")

    property p_pwuserchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && PWRITE) |-> (PWUSERCHK == APB_vip_pkg::calc_byte_parity(PWUSER, (USER_DATA_WIDTH+7)/8));
    endproperty
    AST_CHK_PWUSER: assert property(p_pwuserchk) else `uvm_error("APB_SVA", "PWUSERCHK Parity Error")

    property p_pruserchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && !PWRITE && PREADY && PENABLE && !PSLVERR) |-> (PRUSERCHK == APB_vip_pkg::calc_byte_parity(PRUSER, (USER_DATA_WIDTH+7)/8));
    endproperty
    AST_CHK_PRUSER: assert property(p_pruserchk) else `uvm_error("APB_SVA", "PRUSERCHK Parity Error")

    property p_pbuserchk;
        @(posedge PCLK) disable iff (!PRESETn || !ENABLE_PARITY_CHECK)
        (PSEL && PREADY && PENABLE && !PSLVERR) |-> (PBUSERCHK == APB_vip_pkg::calc_byte_parity(PBUSER, (USER_RESP_WIDTH+7)/8));
    endproperty
    AST_CHK_PBUSER: assert property(p_pbuserchk) else `uvm_error("APB_SVA", "PBUSERCHK Parity Error")

endinterface

