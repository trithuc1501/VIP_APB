typedef enum bit { APB_READ = 0, APB_WRITE = 1 } apb_direction_e;

class APB_sequence_item extends uvm_sequence_item;
    
    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;
    parameter int USER_REQ_WIDTH = 8;
    parameter int USER_DATA_WIDTH = 8;
    parameter int USER_RESP_WIDTH = 8; 

    rand bit [ADDR_WIDTH - 1:0]      paddr;
    rand apb_direction_e             pwrite;
    rand bit [DATA_WIDTH - 1:0]      pwdata;
    rand bit [(DATA_WIDTH/8) - 1:0]  pstrb;
    rand bit [2:0]                   pprot;
    rand bit                         pnse;
    rand bit                         pwakeup;
    rand bit [USER_REQ_WIDTH - 1:0]  pauser;
    rand bit [USER_DATA_WIDTH - 1:0] pwuser;
    
    rand int                         delay; 

    bit [DATA_WIDTH - 1:0]           prdata;
    bit                              pslverr;
    bit [USER_DATA_WIDTH - 1:0]      pruser;
    bit [USER_RESP_WIDTH - 1:0]      pbuser;

    rand int                         wait_states; 
    
    bit inject_penable_err = 0;
    bit inject_psel_drop_err = 0;
    bit inject_stability_err = 0;
    bit inject_pslverr_timing_err = 0;
    bit inject_setup_ext_err = 0;
    bit inject_pipeline_err = 0;

    `uvm_object_utils_begin(APB_sequence_item)
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