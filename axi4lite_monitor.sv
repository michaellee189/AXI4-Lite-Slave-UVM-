class axi4lite_monitor extends uvm_monitor;

    `uvm_component_utils(axi4lite_monitor);

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual axi4lite_intf intf;

    uvm_analysis_port #(axi4lite_txn) mon_analysis_port;

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        mon_analysis_port = new ("mon_analysis_port", this);
        if (!uvm_config_db #(virtual axi4lite_intf)::get(this, "", "intf", intf)) begin
            `uvm_fatal (get_type_name(), "DUT interface not found")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join_none
    endtask

    // Function for monitoring one entire write transaction
    task monitor_write();
        forever begin
            @ (posedge intf.aclk);
            if (intf.AWVALID && intf.AWREADY && intf.WVALID && intf.WREADY) begin
                axi4lite_txn mon_txn = axi4lite_txn::type_id::create("write_txn", this);
                mon_txn.write = 1;
                mon_txn.addr  = intf.AWADDR;
                mon_txn.wdata = intf.WDATA;
                mon_txn.wstrb = intf.WSTRB;
            
                // Wait for write response
                do @ (posedge intf.aclk);
                while (!(intf.BVALID && intf.BREADY));
                mon_txn.bresp = intf.BRESP;
                mon_analysis_port.write(mon_txn);
            end
        end
    endtask

    // Function for monitoring one entire read transaction
    task monitor_read();
        forever begin
            @ (posedge intf.aclk);
            if (intf.ARVALID && intf.ARREADY) begin
                axi4lite_txn mon_txn = axi4lite_txn::type_id::create("read_txn", this);
                mon_txn.write = 0;
                mon_txn.addr  = intf.ARADDR;
            
                // Wait for read response
                do @ (posedge intf.aclk);
                while (!(intf.RVALID && intf.RREADY));
                mon_txn.rdata = intf.RDATA;
                mon_txn.rresp = intf.RRESP;
                mon_analysis_port.write(mon_txn);
            end
        end
    endtask

endclass
