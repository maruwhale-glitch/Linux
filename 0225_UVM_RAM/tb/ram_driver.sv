`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)

    virtual ram_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),
                       "virtual interface를 config_db에서 가져올 수 없습니다!")
    endfunction

    virtual task run_phase(uvm_phase phase);
        ram_seq_item txn;

        @(vif.driver_cb);
        vif.driver_cb.we <= 0;
        vif.driver_cb.addr <= 0;
        vif.driver_cb.wdata <= 0;

        forever begin
            seq_item_port.get_next_item(txn);
            drive_txn(txn);
            seq_item_port.item_done();
        end
    endtask  //

    virtual task drive_txn(ram_seq_item txn);
        @(vif.driver_cb);
        vif.driver_cb.we    <= txn.we;
        vif.driver_cb.addr  <= txn.addr;
        vif.driver_cb.wdata <= txn.wdata;
        @(vif.driver_cb);
        vif.driver_cb.we <= 0;
    endtask  //
endclass  //className extends uvm_dirver
