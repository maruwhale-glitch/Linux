`include "uvm_macros.svh"
import uvm_pkg::*;


class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase)
        
    endtask
endclass  // extends superClass
