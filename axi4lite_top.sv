`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

module axi4lite_top;

    logic aclk, rst_n;

    initial begin: gen_aclk
        aclk = 0;
        forever #5 aclk = ~aclk; // 100MHz Clock
    end: gen_aclk

    initial begin: gen_rst_n
        rst_n = 0;                            
        repeat (5) @(posedge aclk);        
        rst_n = 1;                            
    end: gen_rst_n

    axi4lite_intf intf(aclk, rst_n);

    axi4lite_slv dut(intf);

    initial begin
        $display("Running testbench...");
        uvm_config_db#(virtual axi4lite_intf)::set(null, "", "intf", intf);
        run_test("axi4lite_test");
    	uvm_top.print_topology();
    end

endmodule