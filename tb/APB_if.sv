interface APB_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_REQ_WIDTH = 8,
    parameter int USER_DATA_WIDTH = 8,
    parameter int USER_RESP_WIDTH = 8  
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
    
    clocking drv_master_cb @(posedge PCLK);
        default input #1ns output #1ns;
        input PREADY;
        input PRDATA;
        input PSLVERR;
        input PRUSER;
        input PBUSER;
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

endinterface