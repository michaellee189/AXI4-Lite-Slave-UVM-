`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi4lite_intf.sv" // AXI4-Lite interface
`include "axi4lite_test.sv" // UVM test

module axi4lite_testbench;

    // Clock and reset
    logic aclk, rst_n;

    

    initial begin
        run("axi4lite_test");
    end

endmodule;