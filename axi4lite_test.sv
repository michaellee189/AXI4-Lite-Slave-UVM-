class axi4lite_test extends uvm_test;

    `uvm_component_utils(axi4lite_test)

    function new(string name = "test", uvm_component parent);
        super.new(name, parent);
    endfunction

    axi4lite_env env0;
    axi4lite_sequence seq0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST", "Entered build_phase", UVM_LOW)
        env0 = axi4lite_env::type_id::create("env", this);
        seq0 = axi4lite_sequence::type_id::create("sequence", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        // Make sure sequence and sequencer are not null
        if (seq0 == null)
            `uvm_fatal("TEST", "Sequence is null")
        if (env0 == null || env0.agnt0 == null || env0.agnt0.seqr0 == null)
            `uvm_fatal("TEST", "Sequencer is null")

        // Run sequence
        `uvm_info("TEST", "Starting sequence...", UVM_MEDIUM)
        seq0.start(env0.agnt0.seqr0);
        `uvm_info("TEST", "Sequence completed.", UVM_MEDIUM)

        phase.drop_objection(this);
        `uvm_info("TEST", "run_phase exited", UVM_MEDIUM);
    endtask

endclass