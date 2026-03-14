`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

interface counter_if (
    input logic clk
);
    logic       rst_n;
    logic       enable;
    logic [3:0] count;

    // driver clocking block
    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output rst_n;
        output enable;
    endclocking

    // driver clocking block
    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst_n;
        input enable;
        input count;
    endclocking

    modport drv_mp(clocking drv_cb, input clk);
    modport mon_mp(clocking mon_cb, input clk);

endinterface


class counter_seq_item extends uvm_sequence_item;
    rand bit       rst_n;
    rand bit       enable;
    rand int       cycles;
    logic    [3:0] count;

    constraint cycles_c {cycles inside {[1 : 20]};}

    `uvm_object_utils_begin(counter_seq_item)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(enable, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
        `uvm_field_int(count, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "counter_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "rst_n = %0b, enable = %0b, cycles = %0d, count = %0h",
            rst_n,
            enable,
            cycles,
            count
        );
    endfunction

endclass

class counter_reset_seq extends uvm_sequence #(counter_seq_item);
    `uvm_object_utils(counter_reset_seq)

    function new(string name = "counter_reset_seq");
        super.new(name);
    endfunction

    virtual task body();
        counter_seq_item item;
        item = counter_seq_item::type_id::create("item");
        start_item(item);
        item.rst_n  = 0;
        item.enable = 0;
        item.cycles = 2;
        finish_item(item);
        `uvm_info(get_type_name(), "reset done!", UVM_MEDIUM);
    endtask

endclass


class counter_count_seq extends uvm_sequence #(counter_seq_item);
    `uvm_object_utils(counter_count_seq)

    int num_transactions;

    function new(string name = "counter_count_seq");
        super.new(name);
    endfunction

    virtual task body();
        counter_seq_item item;
        for (int i = 0; i < num_transactions; i++) begin
            item = counter_seq_item::type_id::create($sformatf("item_%0d", i));
            start_item(item);
            if (!item.randomize() with {
                    rst_n == 1;
                    enable == 1;
                    cycles == 1;
                })
                `uvm_fatal(get_type_name(), "randomize failed!");
            finish_item(item);
            `uvm_info(
                get_type_name(), $sformatf(
                "[%0d/%0d] %s", i + 1, num_transactions, item.convert2string()),
                UVM_MEDIUM);

        end
    endtask

endclass

class counter_master_seq extends uvm_sequence #(counter_seq_item);
    `uvm_object_utils(counter_master_seq)

    function new(string name = "counter_master_seq");
        super.new(name);
    endfunction

    virtual task body();
        counter_reset_seq reset_seq;
        counter_count_seq count_seq;
        `uvm_info(get_type_name(), "===== scenario 1 : Reset =====", UVM_MEDIUM)
        reset_seq = counter_reset_seq::type_id::create("reset_seq");
        reset_seq.start(m_sequencer);

        `uvm_info(get_type_name(), "===== scenario 2 : Counting =====",
                  UVM_MEDIUM)
        count_seq = counter_count_seq::type_id::create("count_seq");
        count_seq.num_transactions = 1;
        count_seq.start(m_sequencer);

        `uvm_info(get_type_name(), "===== Master Sequence Done!=====",
                  UVM_MEDIUM);
    endtask

endclass

class counter_sequencer extends uvm_sequencer #(counter_seq_item);
    `uvm_component_utils(counter_sequencer)

    function new(string name = "counter_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass


class counter_driver extends uvm_driver #(counter_seq_item);
    `uvm_component_utils(counter_driver)

    virtual counter_if vif;

    function new(string name = "counter_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "vif not found");

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        counter_seq_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_item(counter_seq_item item);
        vif.drv_cb.rst_n  <= item.rst_n;
        vif.drv_cb.enable <= item.enable;
        repeat (item.cycles) @(vif.drv_cb);  // @(posedge vif.clk);
    endtask

endclass


class counter_monitor extends uvm_monitor;
    `uvm_component_utils(counter_monitor)

    virtual counter_if vif;
    counter_seq_item item;
    int expected_count;

    uvm_analysis_port #(counter_seq_item) ap;

    function new(string name = "counter_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        expected_count = 0;
        if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "vif not found");
        ap   = new("ap", this);
        item = counter_seq_item::type_id::create("item");
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            // @(posedge vif.clk);
            @(vif.mon_cb);  // clocking block 
            item.rst_n  = vif.mon_cb.rst_n;
            item.enable = vif.mon_cb.enable;
            item.count  = vif.mon_cb.count;
            `uvm_info(get_type_name, $sformatf("mon sends %s", convert2string()
                      ), UVM_MEDIUM);
            ap.write(item);  // broadcasting

            // if (!vif.mon_cb.rst_n) begin
            //     expected_count = 0;
            // end else if (vif.mon_cb.enable) begin
            //     if (vif.mon_cb.count !== expected_count) begin
            //         `uvm_error(get_type_name(), $sformatf(
            //                    "Mismatched! expect = %0d, count = %0d",
            //                    expected_count,
            //                    vif.mon_cb.count
            //                    ));
            //     end else begin
            //         // vif.count === expected_count
            //         `uvm_info(get_type_name(), $sformatf(
            //                   "Matched! expected = %0d, count = %0d",
            //                   expected_count,
            //                   vif.mon_cb.count
            //                   ), UVM_MEDIUM);
            //     end
            //     expected_count = (expected_count + 1) % 16;
            // end else begin
            //     // expected_count = expected_count;
            //     if (vif.mon_cb.count !== expected_count) begin
            //         `uvm_error(get_type_name(), $sformatf(
            //                    "Mismatched! expect = %0d, count = %0d",
            //                    expected_count,
            //                    vif.mon_cb.count
            //                    ));
            //     end else begin
            //         // vif.count === expected_count
            //         `uvm_info(get_type_name(), $sformatf(
            //                   "Matched! expected = %0d, count = %0d",
            //                   expected_count,
            //                   vif.mon_cb.count
            //                   ), UVM_MEDIUM);
            //     end
            // end
        end
    endtask
endclass


class counter_agent extends uvm_agent;
    `uvm_component_utils(counter_agent)

    counter_sequencer sqr;
    counter_driver drv;
    counter_monitor mon;
    function new(string name = "counter_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = counter_sequencer::type_id::create("sqr", this);
        drv = counter_driver::type_id::create("drv", this);
        mon = counter_monitor::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask
endclass

class counter_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(counter_scoreboard)

    uvm_analysis_imp #(counter_seq_item, counter_scoreboard) ap_imp;

    logic [3:0] expected_count;
    int match_count;
    int error_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
        expected_count = 4'hx;
        match_count = 0;
        error_count = 0;
    endfunction

    function logic [3:0] predict(logic rst_n, logic enable, logic [3:0] count);
        if (!rst_n) begin
            return 4'h0;
        end else if (enable) return count + 1;
        else return count;

    endfunction

    virtual function void write(counter_seq_item item);
        if (expected_count !== item.count) begin
            `uvm_error(get_type_name(), $sformatf(
                       "MISMATCHED ! expected_count = %0d, item.count = %0d, (rst_n = %0b, enable = %0b)",
                       expected_count,
                       item.count,
                       item.rst_n,
                       item.enable
                       ));
            error_count++;
        end else begin
            `uvm_info(get_type_name(), $sformatf(
                      "MATCH : expected_count = %0d, item.count = %0d, (rst_n = %0b, enable = %0b)",
                      expected_count,
                      item.count,
                      item.rst_n,
                      item.enable
                      ), UVM_MEDIUM);
            match_count++;
        end
        expected_count = predict(item.rst_n, item.enable, expected_count);

    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "===== Scoreboard Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "Total transactions : %0d", match_count, error_count),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Matches : %0d", match_count),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf("Errors : %0d", error_count),
                  UVM_LOW);

        if (error_count > 0)
            `uvm_error(get_type_name(), $sformatf(
                       "Test failed - %0d mismatched detected!", error_count))
        else
            `uvm_info(
                get_type_name(), $sformatf(
                "Test Passed - all transactions matched! : %0d", match_count),
                UVM_LOW);
    endfunction

endclass

class counter_subscriber extends uvm_subscriber #(counter_seq_item);
    `uvm_component_utils(counter_subscriber)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void write(counter_seq_item item);
        `uvm_info(get_type_name(), $sformatf(
                  "subscriber item %s", item.convert2string()), UVM_LOW);
    endfunction
endclass

class counter_coverage extends uvm_subscriber #(counter_seq_item);
    `uvm_component_utils(counter_coverage)

    counter_seq_item item;
    // rand bit       rst_n;
    // rand bit       enable;
    // logic    [3:0] count;

    covergroup counter_cg;
        cp_rst_n: coverpoint item.rst_n {
            bins active = {0}; bins inactive = {1};
        }

        cp_enable: coverpoint item.enable {bins on = {1}; bins off = {0};}

        cp_count: coverpoint item.count {
            bins zero = {0};
            bins low = {[1 : 7]};
            bins high = {[8 : 14]};
            bins max = {15};
        }
        cx_rst_n : cross cp_rst_n, cp_enable;
        cx_en_count : cross cp_enable, cp_count{
            // ignore_bins en_inactive = binsof (cp)
        };
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        counter_cg = new(); // instance 생성 -> "메모리에 공간이 잡힌다"는 의미
    endfunction

    virtual function void write(counter_seq_item t);
        if (t == null) return;
        item = t;
        counter_cg.sample();
        `uvm_info(get_type_name(), $sformatf(
                  "counter_cg sampled : %s", item.convert2string()), UVM_LOW);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  " Overall : %.1f%%", counter_cg.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  " rst_n : %.1f%%", counter_cg.cp_rst_n.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  " enable : %.1f%%", counter_cg.cp_enable.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  " count : %.1f%%", counter_cg.cp_count.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);
    endfunction
endclass




class counter_env extends uvm_env;
    `uvm_component_utils(counter_env)

    counter_agent agent;
    counter_scoreboard scb;
    counter_coverage cov;

    function new(string name = "counter_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = counter_agent::type_id::create("agent", this);
        scb   = counter_scoreboard::type_id::create("scb", this);
        cov   = counter_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask
endclass

class counter_test extends uvm_test;
    `uvm_component_utils(counter_test)

    counter_env env;

    function new(string name = "counter_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = counter_env::type_id::create("env", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        counter_master_seq seq;
        phase.raise_objection(this);
        seq = counter_master_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        // #100;
        uvm_top.print_topology();
        phase.drop_objection(this);
    endtask
endclass

module tb_counter ();
    bit clk;
    counter_if vif (clk);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    counter dut (
        .clk   (clk),
        .rst_n (vif.rst_n),
        .enable(vif.enable),
        .count (vif.count)
    );

    initial begin

        uvm_config_db#(virtual counter_if)::set(null, "*", "vif", vif);
        run_test("counter_test");
    end

endmodule
