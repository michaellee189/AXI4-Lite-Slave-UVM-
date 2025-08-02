class axi4lite_driver extends uvm_driver #(axi4lite_txn);

    `uvm_component_utils(axi4lite_driver)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual axi4lite_intf intf;
    axi4lite_txn req;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase (phase);
        req = axi4lite_txn::type_id::create("req");
        if (!uvm_config_db #(virtual axi4lite_intf)::get(this, "", "intf", intf)) begin
            `uvm_fatal(get_type_name(), "DUT interface not found")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            `uvm_info (get_type_name(), $sformatf ("Waiting for data from sequencer"), UVM_MEDIUM)
            seq_item_port.get_next_item(req); 
            drive_item(req);
            seq_item_port.item_done(); 
        end
    endtask

    extern task drive_item(axi4lite_txn txn);

endclass

// Drives sequence received from sequencer to the interface

task axi4lite_driver::drive_item(axi4lite_txn txn); 
    if(txn.write) begin
        // Write Address Channel
        intf.AWADDR  <= txn.addr;
        intf.AWVALID <= 1;
        wait (intf.AWREADY == 1);
        intf.AWVALID <= 0;
        
        // Write Data Channel
        intf.WDATA  <= txn.wdata;
        intf.WSTRB  <= txn.wstrb;
        intf.WVALID <= 1;
        wait (intf.WREADY == 1);
        intf.WVALID <= 0;

        // Write Response Channel
        intf.BREADY <= 1;
        wait (intf.BVALID == 1);
        txn.bresp   = intf.BRESP;
        intf.BREADY <= 0;
    end
    else begin
        // Read Address Channel
        intf.ARADDR  <= txn.addr;
        intf.ARVALID <= 1;
        wait (intf.ARREADY == 1);
        intf.ARVALID <= 0;

        // Read Response Channel
        intf.RREADY <= 1;
        wait (intf.RVALID == 1);
        txn.rdata   = intf.RDATA;
        txn.rresp   = intf.RRESP;
        intf.RREADY <= 0;
    end

endtask