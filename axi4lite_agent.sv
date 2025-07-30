class axi4lite_agent extends uvm_agent;

    // For reusability
    `uvm_component_utils(axi4lite_agent)
    
    function new (string name = "agent", uvm_component parent);
        super.new (name, parent);
    endfunction

    // Instantiate agent components
    axi4lite_driver drv0;
    axi4lite_monitor mon0;
    axi4lite_sequencer#(axi4lite_txn) seqr0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv0 = axi4lite_driver::type_id::create("driver", this);
        mon0 = axi4lite_monitor::type_id::create("monitor", this);
        seqr0 = axi4lite_sequencer #(axi4lite_txn)::type_id::create("sequencer", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv0.seq_item_port.connect(seqr0.seq_item_export);
    endfunction
endclass