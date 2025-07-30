class axi4lite_txn extends uvm_sequence_item;

    // --------------------
    // Local Parameters
    // --------------------
    localparam int ADDR_WIDTH = 4;
    localparam int DATA_WIDTH = 32;

    // ----------------------
    // Transaction Fields
    // ----------------------
    rand bit                        write;   // 1 = write, 0 = read
    rand bit [ADDR_WIDTH-1:0]       addr;    // Address (used for both AR and AW)
    rand bit [DATA_WIDTH-1:0]       wdata;   // Write data
    rand bit [(DATA_WIDTH/8)-1:0]   wstrb;   // Write strobe

    bit [DATA_WIDTH-1:0]            rdata;  // Captured from slave (read response)
    bit [1:0]                       bresp;  // Response code for write
    bit [1:0]                       rresp;  // Response code for read

    // ------------------------------------------
    // Factory Registration and Field Automation
    // ------------------------------------------
    `uvm_object_utils_begin(axi4lite_txn)
        `uvm_field_int(write,  UVM_ALL_ON)
        `uvm_field_int(addr,   UVM_ALL_ON)
        `uvm_field_int(wdata,  UVM_ALL_ON)
        `uvm_field_int(wstrb,  UVM_ALL_ON)
        `uvm_field_int(rdata,  UVM_ALL_ON)
        `uvm_field_int(resp,   UVM_ALL_ON)
    `uvm_object_utils_end

    // ---------------
    // Constructor
    // ---------------
    function new(string name);
        super.new(name);
    endfunction


endclass