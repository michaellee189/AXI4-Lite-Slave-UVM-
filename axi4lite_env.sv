class axi4lite_env extends uvm_env;

    `uvm_component_utils(axi4lite_env)
    
    function new(string name = "env", uvm_component parent);
        super.new(name, parent);
    endfunction

    axi4lite_agent agnt0;
    axi4lite_scoreboard scbd0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agnt0 = axi4lite_agent::type_id::create("agent", this);
        scbd0 = axi4lite_scoreboard::type_id::create("scoreboard", this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agnt0.mon0.mon_analysis_port.connect(scbd0.scoreboard_imp);
    endfunction
endclass