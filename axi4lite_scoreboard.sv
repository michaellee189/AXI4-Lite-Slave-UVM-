class axi4lite_scoreboard extends uvm_scoreboard;

    localparam int ADDR_WIDTH = 4;
    localparam int DATA_WIDTH = 32;

    `uvm_component_utils(axi4lite_scoreboard)

    function new (string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(axi4lite_txn, axi4lite_scoreboard) scoreboard_imp;

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        scoreboard_imp = new("scoreboard_imp", this);
    endfunction

    logic [DATA_WIDTH-1:0] write_map [logic [ADDR_WIDTH-1:0]]; // associative array: allocates memory dynamically

    virtual function void write(axi4lite_txn txn);
        `uvm_info(get_type_name(), $sformatf("Received transaction: %s", txn.convert2string()),
                  UVM_MEDIUM)

        if (txn.write) begin // Write packet
            `uvm_info(get_type_name(), $sformatf("WRITE txn received: addr = 0x%08x, data = 0x%08x",
                      txn.addr, txn.wdata), UVM_MEDIUM)
            write_map[txn.addr] = txn.wdata;
        end
        
        else begin // Read packet
            `uvm_info(get_type_name(), $sformatf("READ txn received: addr = 0x%08x, data = 0x%08x",
                      txn.addr, txn.rdata), UVM_MEDIUM)
            if (write_map.exists(txn.addr)) begin
                if (txn.rdata !== write_map[txn.addr]) 
                    `uvm_error(get_type_name(), $sformatf("READ mismatch at addr 0x%08x: expected 0x%08x, got 0x%08x", 
                               txn.addr, write_map[txn.addr], txn.rdata))
                else
                    `uvm_info(get_type_name(), $sformatf("READ MATCH at addr 0x%08x: data = 0x%08x",
                              txn.addr, txn.rdata), UVM_LOW)
            end
            else 
                `uvm_warning(get_type_name(), $sformatf("READ at addr 0x%08x: no WRITE data recorded",
                             txn.addr))
        end
        
    endfunction
    

endclass