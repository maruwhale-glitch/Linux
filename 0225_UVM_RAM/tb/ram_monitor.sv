`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)

    virtual ram_if vif;

    uvm_analysis_port #(ram_seq_item) mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
        if (!uvm_config_db#(virtual ram_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),
                       "virtual interface를 config_db에서 가져올 수 없습니다!")
    endfunction

    virtual task run_phase(uvm_phase phase);
        ram_seq_item txn;

        bit prev_we;
        bit [9:0] prev_addr;
        bit [31:0] prev_wdata;

        prev_we = 0;

        forever begin
            @(vif.monitor_cb);

            if (vif.monitor_cb.we) begin
                txn       = ram_seq_item::type_id::create("mon_wr_txn");
                txn.we    = 1;
                txn.addr  = vif.monitor_cb.addr;
                txn.wdata = vif.monitor_cb.wdata;
                txn.rdata = vif.monitor_cb.rdata;

                mon_ap.write(txn);
            end

            if (prev_we && !vif.monitor_cb.we) begin
                txn = ram_seq_item::type_id::create("mon_rd_txn");
                txn.we = 0;
                txn.addr = prev_addr;
                txn.wdata = 0;
                txn.rdata = vif.monitor_cb.rdata;

                mon_ap.write(txn);
                `uvm_info(get_type_name(),
                          $sformatf("[모니터-읽기] %s", txn.convert2string()), UVM_HIGH)
            end

            prev_we    = vif.monitor_cb.we;
            prev_addr  = vif.monitor_cb.addr;
            prev_wdata = vif.monitor_cb.wdata;
        end
    endtask  //
endclass  //className extends uvm_dirver

