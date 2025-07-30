class axi4lite_test extends uvm_test;

    `uvm_component_utils(axi4lite_test)

    function new(string name = "test", uvm_component parent);
        super.new(name, parent);
    endfunction

    axi4lite_env env0;
    axi4lite_sequence seq0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env0 = axi4lite_env::type_id::create("env", this);
        seq0 = axi4lite_sequence::type_id::create("sequence", this);
    endfunction

    virtual task run_phase(uvm_phase phase)
        phase.raise_objection(this);
        seq0.start(env0.agnt0.seqr0);
        phase.drop_objection(this);
    endtask

endclass