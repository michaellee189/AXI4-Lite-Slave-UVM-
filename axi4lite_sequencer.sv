class axi4lite_sequencer extends uvm_sequencer #(axi4lite_txn);

    `uvm_component_utils(axi4lite_sequencer)

    function new (string name = "sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass