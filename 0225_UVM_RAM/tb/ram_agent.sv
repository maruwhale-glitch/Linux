`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    ram_sequencer sqr;
    ram_driver    drv;
    ram_monitor   mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = ram_monitor::type_id::create("mon", this);
        drv = ram_driver::type_id::create("drv", this);
        sqr = ram_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass  //className extends uvm_dirver

