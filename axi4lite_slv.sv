module axi4lite_slv
#(
    parameter ADDR_WIDTH = 4,   // width of address bus in bits 
    parameter DATA_WIDTH = 32,  // width of data bus in bits
    parameter REG_COUNT = 4     // # of registers
)
(
    axi4lite_intf.dut axi
);

    // Register File
    logic [DATA_WIDTH-1:0] regs [0:REG_COUNT-1];
    
    // Handshake Flags
    logic aw_done;
    logic w_done;
    logic b_done;
    logic ar_done;
    logic r_done;
    logic b_running;
    logic r_running;

    // Write Address Channel
    always_ff @(posedge axi.aclk or negedge axi.rst_n) begin 
        if(!axi.rst_n) begin
            aw_done <= 1'b0;
            axi.AWREADY <= 1'b1;
        end
        else begin
            // Sets write address flag and deasserts ready when handshake is complete
            if (axi.AWVALID && axi.AWREADY) begin
                aw_done <= 1'b1;
                axi.AWREADY <= 1'b0;
            end
            // Resets write address flag and reasserts ready when write response is complete
            else if (aw_done && b_done) begin
                aw_done <= 1'b0;
                axi.AWREADY <= 1'b1;
            end
        end
    end

    // Write Data Channel
    always_ff @(posedge axi.aclk or negedge axi.rst_n) begin 
        if(!axi.rst_n) begin
            w_done <= 1'b0;
            axi.WREADY <= 1'b1;
        end
        else begin
            if (axi.WVALID && axi.WREADY) begin
                w_done <= 1'b1;
                axi.WREADY <= 1'b0;
            end
            else if (w_done && b_done) begin
                w_done <= 1'b0;
                axi.WREADY <= 1'b1;
            end
        end
    end

    // Write Response Channel
    integer i,j;
    always_ff @(posedge axi.aclk or negedge axi.rst_n) begin 
        if(!axi.rst_n) begin
            b_done <= 1'b0;
            axi.BVALID <= 1'b0;
            axi.BRESP  <= 2'b00;
            b_running  <= 1'b0;
            for (i = 0; i < REG_COUNT; i++)
                regs[i] <= '0; // Clear Registers
        end
        else begin
            if (axi.BVALID && axi.BREADY) begin
                b_running <= 1'b0;
                b_done    <= 1'b1;
                axi.BVALID    <= 1'b0;
                axi.BRESP     <= 2'b00;
            end
            // Write data in the register of the received write address when both data & address handshakes are complete
            else if (aw_done && w_done && !b_done) begin
                if (!b_running) begin
                    b_running <= 1'b1;
                    if (axi.AWADDR[ADDR_WIDTH-1:2] < REG_COUNT) begin 
                        // if write address is within range
                        // AXI4-lite addresses must be byte-aligned to data width (32bit), therefor they are in multiples of 4
                        for (j = 0; j < DATA_WIDTH/8; j++) begin
                            if (axi.WSTRB[j]) // determines which bytes to write
                                regs[axi.AWADDR[ADDR_WIDTH-1:2]][8*j +: 8] <= axi.WDATA [8*j +: 8];
                        end
                        axi.BRESP <= 2'b00; // OK
                    end
                    else    
                        axi.BRESP <= 2'b10; // SLVERR
                    axi.BVALID <= 1'b1;
                end
            end
            else
                b_done    <= 1'b0;
        end
    end
    
    // Read Address Channel
    always_ff @(posedge axi.aclk or negedge axi.rst_n) begin 
        if(!axi.rst_n) begin
            ar_done <= 1'b0;
            axi.ARREADY <= 1'b1;
        end
        else begin
            if (axi.ARVALID && axi.ARREADY) begin
                ar_done <= 1'b1;
                axi.ARREADY <= 1'b0;
            end
            else if (ar_done && r_done) begin
                ar_done <= 1'b0;
                axi.ARREADY <= 1'b1;
            end
        end
    end

    // Read Response Channel
    always_ff @(posedge axi.aclk or negedge axi.rst_n) begin 
        if(!axi.rst_n) begin
            r_done     <= 1'b0;
            axi.RVALID <= 1'b0;
            axi.RRESP  <= 2'b00;
            r_running  <= 1'b0;
        end
        else begin
            if (axi.RREADY && axi.RVALID) begin
                r_done <= 1'b1;
                axi.RVALID <= 1'b0;
                axi.RRESP <= 2'b00;
            end
            else if (ar_done && !r_done) begin
                if (!r_running) begin
                    r_running <= 1'b1;
                    // Read and report the data in the register of the received read address when both data & address handshakes are complete
                    if (axi.ARADDR[ADDR_WIDTH-1:2] < REG_COUNT) begin // if read address is within range
                        axi.RDATA <= regs[axi.ARADDR[ADDR_WIDTH-1:2]];
                        axi.RRESP <= 2'b00; // OK
                    end
                    else
                        axi.RRESP <= 2'b10; // SLVERR
                    axi.RVALID <= 1'b1;
                end
            end
            else 
                r_done <= 1'b0;
        end
    end


endmodule