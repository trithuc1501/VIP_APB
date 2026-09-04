typedef enum bit { APB_READ = 0, APB_WRITE = 1 } apb_direction_e;

class APB_sequence_item #(
    int ADDR_WIDTH = 32,
    int DATA_WIDTH = 32,
    int USER_REQ_WIDTH = 8,
    int USER_DATA_WIDTH = 8,
    int USER_RESP_WIDTH = 8
) extends uvm_sequence_item; 
    rand bit [ADDR_WIDTH - 1:0]      paddr;
    rand apb_direction_e             pwrite;
    rand bit [DATA_WIDTH - 1:0]      pwdata;
    rand bit [(DATA_WIDTH/8) - 1:0]  pstrb;
    rand bit [2:0]                   pprot;
    rand bit                         pnse;
    rand bit pwakeup = 1;
    rand bit [USER_REQ_WIDTH - 1:0]  pauser;
    rand bit [USER_DATA_WIDTH - 1:0] pwuser;
    rand int                         delay; 
    bit [DATA_WIDTH - 1:0]           prdata;
    bit                              pslverr;
    bit [USER_DATA_WIDTH - 1:0]      pruser;
    bit [USER_RESP_WIDTH - 1:0]      pbuser;
    bit [(ADDR_WIDTH/8)-1:0]         paddrchk;
    bit                              pctrlchk;
    bit                              pselchk;
    bit                              penablechk;
    bit [(DATA_WIDTH/8)-1:0]         pwdatachk;
    bit                              pstrbchk;
    bit                              preadychk;
    bit [(DATA_WIDTH/8)-1:0]         prdatachk;
    bit                              pslverrchk;
    bit                              pwakeupchk;
    bit [((USER_REQ_WIDTH+7)/8)-1:0] pauserchk;
    bit [((USER_DATA_WIDTH+7)/8)-1:0] pwuserchk;
    bit [((USER_DATA_WIDTH+7)/8)-1:0] pruserchk;
    bit [((USER_RESP_WIDTH+7)/8)-1:0] pbuserchk;
    rand int                         wait_states;
    `uvm_object_param_utils_begin(APB_sequence_item#(ADDR_WIDTH, DATA_WIDTH, USER_REQ_WIDTH, USER_DATA_WIDTH, USER_RESP_WIDTH))
        `uvm_field_int (paddr,       UVM_ALL_ON | UVM_HEX)
        `uvm_field_enum(apb_direction_e, pwrite, UVM_ALL_ON)
        `uvm_field_int (pwdata,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pstrb,       UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pprot,       UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pnse,        UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pwakeup,     UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pauser,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pwuser,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (prdata,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pslverr,     UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pruser,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pbuser,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (paddrchk,    UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pctrlchk,    UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pselchk,     UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (penablechk,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pwdatachk,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pstrbchk,    UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (preadychk,   UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (prdatachk,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pslverrchk,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pwakeupchk,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (pauserchk,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pwuserchk,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pruserchk,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (pbuserchk,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (delay,       UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int (wait_states, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "APB_sequence_item");
        super.new(name);
    endfunction

    constraint c_align {
        paddr % (DATA_WIDTH/8) == 0;
    }
    constraint c_delays {
        delay >= 0; delay <= 10;
        wait_states >= 0; wait_states <= 10;
    }
    constraint c_read_clean {
        if (pwrite == APB_READ) {
            pwdata == 0;
            pstrb  == 0;
        }
    }
    constraint c_wr_rd {
        pwrite dist {APB_WRITE := 50, APB_READ := 50};
    }
endclass
