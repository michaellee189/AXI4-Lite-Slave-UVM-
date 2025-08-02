class axi4lite_sequence extends uvm_sequence #(axi4lite_txn);

    `uvm_object_utils(axi4lite_sequence)
    `uvm_declare_p_sequencer(axi4lite_sequencer)

    int unsigned num_seqs = 10;

    function new(string name = "axi4lite_sequence");
        super.new(name);
    endfunction

    localparam int ADDR_WIDTH = 4;
    localparam int DATA_WIDTH = 32;
    
    axi4lite_txn write_seq, read_seq;

    rand bit [ADDR_WIDTH-1:0]       addr;
    rand bit [DATA_WIDTH-1:0]       wdata;
    rand bit [(DATA_WIDTH/8)-1:0]   wstrb;

    virtual task body();

        `uvm_info("SEQ", $sformatf("Starting body of %s", this.get_name()), UVM_MEDIUM)

        for (int i = 0; i < num_seqs; i++) begin
            // Send a write request and a read request with the same address back to back
            assert(std::randomize(addr, wdata, wstrb)) else 
                $fatal(1, "Sequence failed to randomize");

            // Enforce alignment: 4-byte (32-bit)
            addr = addr & ~(DATA_WIDTH/8 - 1);

            // WRITE transaction
            write_seq = axi4lite_txn::type_id::create("write_seq");
            start_item(write_seq); // Internally calls wait_for_grant() from driver
                write_seq.write = 1;
                write_seq.addr  = addr;
                write_seq.wdata = wdata;
                write_seq.wstrb = wstrb;
            finish_item(write_seq); // Internally waits for item_done() from driver

            `uvm_info("SEQ", $sformatf("WRITE: addr=0x%08x, data=0x%08x, strb=0x%x", addr, wdata, wstrb), UVM_MEDIUM)

            // READ transaction
            read_seq = axi4lite_txn::type_id::create("read_seq");
            start_item(read_seq);
                read_seq.write = 0;
                read_seq.addr  = addr;
            finish_item(read_seq);

            `uvm_info("SEQ", $sformatf("READ : addr=0x%08x", addr), UVM_MEDIUM)
        end

    endtask

endclass