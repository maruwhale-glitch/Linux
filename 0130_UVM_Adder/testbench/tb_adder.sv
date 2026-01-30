import uvm_pkg::*;

interface adder_if (
    input bit clk
);
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface

class seq_item extends uvm_sequence_item;
    rand logic [7:0] a;
    rand logic [7:0] b;
    logic      [8:0] y;

    function new(string name = "ADDER_Seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end

endclass

class adder_sequence extends uvm_sequence #(seq_item);
    `uvm_object_utils(adder_sequence)
    seq_item adder_seq_item;

    function new(string name = "ADDER_Sequence");
        super.new(name);
    endfunction

    task body();
        adder_seq_item = seq_item::type_id::create("SEQ_ITEM");
        repeat (100) begin
            start_item(adder_seq_item);
            adder_seq_item.randomize();
            uvm_report_info("SEQ", "Data send to Driver", UVM_NONE);
            finish_item(adder_seq_item);
        end

    endtask  //

endclass

class adder_driver extends uvm_driver #(seq_item);
    `uvm_component_utils(adder_driver)

    virtual adder_if a_if;
    seq_item adder_seq_item;
    uvm_analysis_port #(seq_item) send;

    function new(string name = "ADDER_DRV", uvm_component c);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_seq_item = seq_item::type_id::create("SEQ_ITEM", this);
        if (!uvm_config_db#(virtual adder_if)::get(
                this, "", "a_if", a_if
            )) begin
            `uvm_fatal(get_name(), "Unable to access adder interface");
        end
    endfunction

    task run_phase(uvm_phase phase);
        $display("Display run phase");
        forever begin
            seq_item_port.get_next_item(adder_seq_item);
            a_if.a <= adder_seq_item.a;
            a_if.b <= adder_seq_item.b;
            @(posedge a_if.clk);
            seq_item_port.item_done();
        end
    endtask
endclass

class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)

    uvm_analysis_port #(seq_item) send;
    virtual adder_if a_if;
    seq_item adder_seq_item;

    function new(string name = "ADDER_MON", uvm_component c);
        super.new(name, c);
        send = new("WRTIE", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_seq_item = seq_item::type_id::create("SEQ_ITEM", this);
        if (!uvm_config_db#(virtual adder_if)::get(
                this, "", "a_if", a_if
            )) begin
            `uvm_fatal(get_name(), "Unable to access adder interface");
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge a_if.clk);
            adder_seq_item.a = a_if.a;
            adder_seq_item.b = a_if.b;
            adder_seq_item.y = a_if.y;
            uvm_report_info("MON", "Send data to Scoreboard", UVM_NONE);
            send.write(adder_seq_item);
        end
    endtask

endclass

class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)

    uvm_analysis_imp #(seq_item, adder_scoreboard) recv;

    function new(string name = "ADDER_SCB", uvm_component c);
        super.new(name, c);
        recv = new("READ", this);
    endfunction

    function void write(seq_item data);
        uvm_report_info("SCB", "Data received from Monitor", UVM_NONE);
        if (data.a + data.b == data.y) begin
            `uvm_info("SCB", $sformatf(
                      "PASS!, a:%0d + b:%0d == y:%0d", data.a, data.b, data.y),
                      UVM_NONE);
        end else begin
            `uvm_error("SCB", $sformatf(
                       "FAIL!, a:%0d + b:%0d != y:%0d", data.a, data.b, data.y
                       ));
        end
    endfunction

    // function void write(seq_item data);
    //     uvm_report_info("SCB", "Data received from Monitor", UVM_NONE);
    //     if (data.a + data.b == data.y) begin
    //         uvm_report_info(
    //             "SCB", $sformatf(
    //             "PASS!, a:%0d + b:%0d == y:%0d", data.a, data.b, data.y),
    //             UVM_NONE);
    //     end else begin
    //         uvm_report_info(
    //             "SCB", $sformatf(
    //             "FAIL!, a:%0d + b:%0d != y:%0d", data.a, data.b, data.y),
    //             UVM_NONE);
    //     end
    // endfunction

endclass

class adder_agent extends uvm_agent;  ///
    `uvm_component_utils(adder_agent)

    adder_monitor adder_mon;
    adder_driver adder_drv;
    uvm_sequencer #(seq_item) adder_sqr;

    function new(string name = "ADDER_AGT", uvm_component c);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        //지금 UVM이 어떤 단계(phase)를 실행 중인지”를 나타내는 핸들(객체)
        super.build_phase(phase);
        adder_mon = adder_monitor::type_id::create("adder_mon", this);
        adder_drv = adder_driver::type_id::create("adder_drv", this);
        adder_sqr =
            uvm_sequencer#(seq_item)::type_id::create("adder_sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        adder_drv.seq_item_port.connect(adder_sqr.seq_item_export);
    endfunction

endclass

class adder_environment extends uvm_env;
    `uvm_component_utils(adder_environment)

    adder_agent adder_agt;
    adder_scoreboard adder_scb;

    function new(string name = "ADDER_ENV", uvm_component c);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        //지금 UVM이 어떤 단계(phase)를 실행 중인지”를 나타내는 핸들(객체)
        super.build_phase(phase);
        adder_agt = adder_agent::type_id::create("AGT", this);
        adder_scb = adder_scoreboard::type_id::create("SCB", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        adder_agt.adder_mon.send.connect(adder_scb.recv);
    endfunction

endclass  //adder_environment extends uvm_env


class adder_test extends uvm_test;

    `uvm_component_utils(adder_test)

    adder_sequence adder_seq;
    adder_environment adder_env;

    function new(string name = "ADDER_TEST", uvm_component c);
        super.new(
            name,
            c);  //부모 클래스에 다음과 같은 정보들을 넣겠다.
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_seq = adder_sequence::type_id::create("SEQ", this);
        adder_env = adder_environment::type_id::create("ENV", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        adder_seq.start(adder_env.adder_agt.adder_sqr);
        phase.drop_objection(this);
    endtask

endclass

module tb_adder ();

    bit clk;
    always #5 clk = ~clk;

    adder_if a_if (clk);

    adder dut (
        .a(a_if.a),
        .b(a_if.b),
        .y(a_if.y)
    );

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars("0");
    end


    initial begin
        uvm_config_db#(virtual adder_if)::set(null, "*", "a_if", a_if);
        run_test("adder_test");
    end

endmodule
