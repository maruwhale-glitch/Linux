`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_sequencer extends uvm_sequencer #(ram_seq_item);
    `uvm_component_utils(ram_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()
endclass  //className extends uvm_dirver

