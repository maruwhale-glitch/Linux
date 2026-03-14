`include "uvm_macros.svh"
import uvm_pkg::*;


class ram_coverage extends uvm_subscriber #(ram_seq_item);

    `uvm_component_utils(ram_coverage)

    bit        sampled_we;
    bit [ 9:0] sampled_addr;
    bit [31:0] sampled_wdata;

    covergroup ram_cg;
        cp_we: coverpoint sampled_we;
        cp_addr: coverpoint sampled_addr;
        cp_wdata: coverpoint sampled_wdata;
    endgroup

    virtual task write(ram_seq_item t);
        sampled_we    = t.we;
        sampled_addr  = t.addr;
        sampled_wdata = t.wdata;
        ram_cg.sample();  // 몇 번 샘플링 했는지 세줌.

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "===================", UVM_LOW)
        `uvm_info(get_type_name(),
                  "=========기능 커버리지 결과 요약=========",
                  UVM_LOW)
        `uvm_info(get_type_name(), "===================", UVM_LOW)
        `uvm_info(get_type_name(),
                  $sformatf(" RAM coverage 달성률 : %.1f%%", ram_cg.get_coverage()) UVM_LOW)
        `uvm_info(get_type_name(), "===================", UVM_LOW)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction


endclass  // extends superClass
