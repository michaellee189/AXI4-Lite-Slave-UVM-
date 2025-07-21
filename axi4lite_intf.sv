interface axi4lite_intf 
#(
    parameter ADDR_WIDTH = 4,   // width of address bus in bits 
    parameter DATA_WIDTH = 32,  // width of data bus in bits
    parameter REG_COUNT = 4     // # of registers
) 
(
    input logic aclk
);  

    logic rst_n

    // Write Address Channel
    logic [ADDR_WIDTH-1:0]       AWADDR,
    logic                        AWVALID,
    logic                        AWREADY,

    // Write Data Channel
    logic [DATA_WIDTH-1:0]       WDATA,
    logic [(DATA_WIDTH/8)-1:0]   WSTRB, 
    logic                        WVALID,
    logic                        WREADY,

    // Write Response Channel
    logic [1:0]                  BRESP, 
    logic                        BVALID,
    logic                        BREADY,

    // Read Address Channel
    logic [ADDR_WIDTH-1:0]       ARADDR,
    logic                        ARVALID,
    logic                        ARREADY,

    // Read Data Channel
    logic [DATA_WIDTH-1:0]       RDATA,
    logic [1:0]                  RRESP, 
    logic                        RVALID,
    logic                        RREADY

    modport tb(
        input  aclk, rst_n,
        input  AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID,
        output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY
    );

    modport dut(
        input  aclk, rst_n,
        input  AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
        output AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
    );


endinterface