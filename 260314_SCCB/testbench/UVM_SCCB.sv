`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

// ---------------------------------------------------------
// 1. Interface
// ---------------------------------------------------------
interface SCCB_if (
    input bit clk,
    input bit reset
);

    logic       sccb_en;
    logic       sccb_start;
    logic       sccb_stop;
    logic [7:0] tx_data;
    logic       tx_done;
    logic       tx_ready;

    wire        scl;
    wire        sda;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output sccb_en, sccb_start, sccb_stop, tx_data;
        input tx_done, tx_ready, scl;
        inout sda;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input sccb_en, sccb_start, sccb_stop, tx_data;
        input tx_done, tx_ready, scl;
        input sda;
    endclocking

    modport drv_mp(clocking drv_cb, input clk, input reset);
    modport mon_mp(clocking mon_cb, input clk, input reset);
endinterface

// ---------------------------------------------------------
// 2. Sequence Item
// ---------------------------------------------------------
class sccb_seq_item extends uvm_sequence_item;
    rand logic       sccb_en;
    rand logic       sccb_start;
    rand logic       sccb_stop;
    rand logic [7:0] tx_data;

    logic            tx_done;
    logic            tx_ready;

    constraint c_default_en {sccb_en == 1'b1;}

    `uvm_object_utils_begin(sccb_seq_item)
        `uvm_field_int(sccb_en, UVM_DEFAULT)
        `uvm_field_int(sccb_start, UVM_DEFAULT)
        `uvm_field_int(sccb_stop, UVM_DEFAULT)
        `uvm_field_int(tx_data, UVM_DEFAULT)
        `uvm_field_int(tx_done, UVM_DEFAULT)
        `uvm_field_int(tx_ready, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "sccb_seq_item");
        super.new(name);
    endfunction
endclass

// ---------------------------------------------------------
// 3. Sequence 
// ---------------------------------------------------------
class sccb_tx_seq extends uvm_sequence #(sccb_seq_item);
    `uvm_object_utils(sccb_tx_seq)
    int num_txns = 400;

    function new(string name = "sccb_tx_seq");
        super.new(name);
    endfunction

    virtual task body();
        sccb_seq_item txn;
        `uvm_info(get_type_name(),
                  $sformatf("=== SCCB 전송 시퀀스 시작 (%0d개) ===",
                            num_txns), UVM_LOW)

        for (int i = 0; i < num_txns; i++) begin
            txn = sccb_seq_item::type_id::create("txn");
            start_item(txn);

            // i가 짝수면 Address 페이즈, 홀수면 Data 페이즈로 간주
            if (i % 2 == 0) begin
                // [Address Phase] 주요 레지스터 주소가 나올 확률을 높임
                if (!txn.randomize() with {
                        sccb_start == 1'b0;
                        sccb_stop == 1'b0;
                        tx_data dist {
                            8'h00 := 3,
                            8'hFF := 3,
                            [8'h01 : 8'hFE] :/ 4
                        };
                    })
                    `uvm_error(get_type_name(), "Addr 랜덤화 실패!")
            end else begin
                // [Data Phase] 주요 설정값(F1, D0 등)이 나올 확률을 높임
                if (!txn.randomize() with {
                        sccb_start == 1'b0;
                        sccb_stop == 1'b0;
                        tx_data dist {
                            8'hF1           := 30,
                            8'hD0           := 30,  // 주요 설정값
                            [8'h00 : 8'hFF] :/ 40  // 기타 값
                        };
                    })
                    `uvm_error(get_type_name(), "Data 랜덤화 실패!")
            end

            finish_item(txn);
            `uvm_info(get_type_name(), $sformatf(
                      "[SCCB 시퀀스 %0d] tx_data = 0x%02h", i, txn.tx_data),
                      UVM_MEDIUM)
            #100000;
        end
        `uvm_info(get_type_name(), "===SCCB 전송 시퀀스 완료 ===",
                  UVM_LOW)
    endtask
endclass

// ---------------------------------------------------------
// 4. Driver
// ---------------------------------------------------------
class sccb_driver extends uvm_driver #(sccb_seq_item);
    `uvm_component_utils(sccb_driver)

    virtual SCCB_if vif;
    sccb_seq_item req;
    int num_sent = 0;
    uvm_analysis_port #(sccb_seq_item) drv_port;

    function new(string name = "SCCB_DRV", uvm_component parent);
        super.new(name, parent);
        drv_port = new("drv_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual SCCB_if)::get(this, "", "SCCB_if", vif))
            `uvm_fatal(get_type_name(), "인터페이스 겟 실패")
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.drv_cb.sccb_en    <= 0;
        vif.drv_cb.sccb_start <= 0;
        vif.drv_cb.sccb_stop  <= 0;
        vif.drv_cb.tx_data    <= 0;

        forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_transfer(sccb_seq_item item);
        wait (vif.drv_cb.tx_ready == 1'b1);

        @(vif.drv_cb);
        vif.drv_cb.sccb_en    <= item.sccb_en;
        vif.drv_cb.sccb_start <= item.sccb_start;
        vif.drv_cb.sccb_stop  <= item.sccb_stop;
        vif.drv_cb.tx_data    <= item.tx_data;

        num_sent++;
        drv_port.write(item);
        `uvm_info(get_type_name(),
                  $sformatf("[Driver 전송] tx_data = 0x%02h (횟수:%0d)",
                            item.tx_data, num_sent), UVM_MEDIUM)

        @(vif.drv_cb iff vif.drv_cb.tx_ready == 1'b0);
        vif.drv_cb.sccb_en <= 0;
    endtask
endclass

// ---------------------------------------------------------
// 5. Monitor
// ---------------------------------------------------------
class sccb_monitor extends uvm_monitor;
    `uvm_component_utils(sccb_monitor)

    virtual SCCB_if vif;
    uvm_analysis_port #(sccb_seq_item) mon_port;

    function new(string name = "SCCB_MON", uvm_component parent);
        super.new(name, parent);
        mon_port = new("mon_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual SCCB_if)::get(this, "", "SCCB_if", vif))
            `uvm_fatal(get_type_name(), "인터페이스 겟 실패")
    endfunction

    virtual task run_phase(uvm_phase phase);
        sccb_seq_item item;
        logic [7:0] cap_data;

        wait (vif.reset == 1'b0);

        forever begin
            @(negedge vif.tx_ready);

            // 정확히 8개의 SCL 상승 에지에서 데이터를 읽음
            for (int i = 7; i >= 0; i--) begin
                @(posedge vif.scl);
                cap_data[i] = vif.sda;
            end

            // 9번째 비트 (Don't Care) 흐르도록 패스
            @(posedge vif.scl);

            item = sccb_seq_item::type_id::create("item");
            item.tx_data = cap_data;

            `uvm_info(get_type_name(), $sformatf(
                      "[Monitor 캡쳐] Actual = 0x%02h", item.tx_data),
                      UVM_MEDIUM)
            mon_port.write(item);
        end
    endtask
endclass

// ---------------------------------------------------------
// 6. Agent
// ---------------------------------------------------------
class sccb_agent extends uvm_agent;
    `uvm_component_utils(sccb_agent)

    uvm_sequencer #(sccb_seq_item)     seqr;
    sccb_driver                        drv;
    sccb_monitor                       mon;

    uvm_analysis_port #(sccb_seq_item) agt_drv_port;
    uvm_analysis_port #(sccb_seq_item) agt_mon_port;
    uvm_analysis_port #(sccb_seq_item) agt_cov_port;

    function new(string name = "SCCB_AGT", uvm_component parent);
        super.new(name, parent);  // [수정 완료] parnet 오타 수정
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seqr = uvm_sequencer#(sccb_seq_item)::type_id::create("seqr", this);
        drv = sccb_driver::type_id::create("drv", this);
        mon = sccb_monitor::type_id::create("mon", this);

        agt_drv_port = new("agt_drv_port", this);
        agt_mon_port = new("agt_mon_port", this);
        agt_cov_port = new("agt_cov_port", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
        drv.drv_port.connect(agt_drv_port);
        mon.mon_port.connect(agt_mon_port);
        mon.mon_port.connect(agt_cov_port);
    endfunction
endclass

// ---------------------------------------------------------
// 7. Scoreboard
// ---------------------------------------------------------
class sccb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(sccb_scoreboard)

    bit [7:0] exp_queue[$];
    int match_count = 0;
    int error_count = 0;

    uvm_analysis_imp_drv #(sccb_seq_item, sccb_scoreboard) drv_imp;
    uvm_analysis_imp_mon #(sccb_seq_item, sccb_scoreboard) mon_imp;

    function new(string name = "SCCB_SCB", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_imp = new("drv_imp", this);
        mon_imp = new("mon_imp", this);
    endfunction

    virtual function void write_drv(sccb_seq_item item);
        exp_queue.push_back(item.tx_data);
    endfunction

    virtual function void write_mon(sccb_seq_item act_item);
        bit [7:0] expected_data;
        bit [7:0] actual_data = act_item.tx_data;

        if (exp_queue.size() > 0) begin
            expected_data = exp_queue.pop_front();

            if (expected_data === actual_data) begin
                match_count++;
                `uvm_info("SCB_PASS", $sformatf(
                                          "일치! Exp=0x%02h, Act=0x%02h",
                                          expected_data, actual_data), UVM_LOW)
            end else begin
                error_count++;
                `uvm_error("SCB_FAIL", $sformatf(
                           "불일치! Exp=0x%02h, Act=0x%02h",
                           expected_data,
                           actual_data
                           ))
            end
        end else begin
            `uvm_warning("SCB_WARN",
                         "기댓값 큐가 비어있는데 선로에서 데이터가 캡쳐되었습니다.")
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("FINAL_REPORT",
                  "\n==================================================",
                  UVM_NONE)
        `uvm_info("FINAL_REPORT",
                  "            [ SCCB UVM 검증 최종 검증표 ]           ",
                  UVM_NONE)
        `uvm_info("FINAL_REPORT",
                  "==================================================",
                  UVM_NONE)
        `uvm_info(
            "FINAL_REPORT", $sformatf(
            " - 총 전송 데이터 수 : %0d 개", match_count + error_count),
            UVM_NONE)
        `uvm_info("FINAL_REPORT", $sformatf(
                  " - 일치 (PASS)       : %0d 개", match_count), UVM_NONE)
        `uvm_info("FINAL_REPORT", $sformatf(
                  " - 불일치 (FAIL)     : %0d 개", error_count), UVM_NONE)
        `uvm_info("FINAL_REPORT",
                  "--------------------------------------------------",
                  UVM_NONE)

        if (error_count == 0 && match_count > 0) begin
            `uvm_info("FINAL_REPORT", " >> TES표 RESULT      : PERFECT PASS!",
                      UVM_NONE)
        end else begin
            `uvm_error("FINAL_REPORT", " >> TEST RESULT      : FAILED")
        end
        `uvm_info("FINAL_REPORT",
                  "==================================================\n",
                  UVM_NONE)
    endfunction
endclass

// ---------------------------------------------------------
// 8. Coverage
// ---------------------------------------------------------
class sccb_coverage extends uvm_subscriber #(sccb_seq_item);
    `uvm_component_utils(sccb_coverage)

    sccb_seq_item item;

    // 추가되는 상태 변수들
    logic [7:0] last_addr;  // 직전에 들어온 주소를 저장
    bit is_addr_phase = 1; // 현재 들어온 데이터가 주소인지 데이터인지 구분 (1: 주소, 0: 데이터)

    covergroup sccb_cg;
        option.per_instance = 1;
        cp_tx_data: coverpoint item.tx_data {
            bins corner_00 = {8'h00};
            bins low = {[8'h01 : 8'h3F]};
            bins mid = {[8'h40 : 8'hBF]};
            bins high = {[8'hC0 : 8'hFE]};
            bins corner_FF = {8'hFF};
        }

    endgroup

    function new(string name = "SCCB_COV", uvm_component parent);
        super.new(name, parent);
        sccb_cg = new();
    endfunction

    virtual function void write(sccb_seq_item t);
        this.item = t;
        sccb_cg.sample();
        if (is_addr_phase) begin
            // 1) 지금 들어온 게 주소라면 저장만 하고 다음을 기다림
            last_addr = t.tx_data;
            is_addr_phase = 0;
        end else begin
            // 2) 지금 들어온 게 데이터라면, 저장해둔 주소와 함께 샘플링!
            sccb_cg.sample();
            is_addr_phase = 1;  // 다시 다음 전송은 주소 페이즈로
        end
    endfunction
endclass

// ---------------------------------------------------------
// 9. Environment
// ---------------------------------------------------------
class sccb_env extends uvm_env;
    `uvm_component_utils(sccb_env)

    sccb_agent      agt;
    sccb_scoreboard scb;
    sccb_coverage   cov;

    function new(string name = "SCCB_ENV", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = sccb_agent::type_id::create("agt", this);
        scb = sccb_scoreboard::type_id::create("scb", this);
        cov = sccb_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.agt_drv_port.connect(scb.drv_imp);
        agt.agt_mon_port.connect(scb.mon_imp);
        agt.agt_cov_port.connect(cov.analysis_export);
    endfunction
endclass

// ---------------------------------------------------------
// 10. Test
// ---------------------------------------------------------
class sccb_test extends uvm_test;
    `uvm_component_utils(sccb_test)

    sccb_env env;
    sccb_tx_seq seq;

    function new(string name = "sccb_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = sccb_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "=== SCCB UVM 테스트 시작 ===", UVM_LOW)

        seq = sccb_tx_seq::type_id::create("seq");
        seq.start(env.agt.seqr);

        // 시퀀스 종료 후 스코어보드 등 처리를 위한 약간의 여유 시간 확보
        #5000;

        `uvm_info(get_type_name(), "=== SCCB UVM 테스트 종료 ===", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

// ---------------------------------------------------------
// 11. Top Module
// ---------------------------------------------------------
module tb_SCCB_Master;
    bit clk;
    bit reset;

    always #5 clk = ~clk;

    SCCB_if vif (
        clk,
        reset
    );

    sccb_master dut (
        .clk       (clk),
        .reset     (reset),
        .sccb_en   (vif.sccb_en),
        .sccb_start(vif.sccb_start),
        .sccb_stop (vif.sccb_stop),
        .tx_data   (vif.tx_data),
        .tx_done   (vif.tx_done),
        .tx_ready  (vif.tx_ready),
        .scl       (vif.scl),
        .sda       (vif.sda)
    );

    pullup (vif.sda);
    pullup (vif.scl);

    initial begin
        $fsdbDumpfile("SCCB_wave.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        uvm_config_db#(virtual SCCB_if)::set(null, "*", "SCCB_if", vif);
        run_test("sccb_test");
    end

    initial begin
        clk   = 0;
        reset = 1;
        #20;
        reset = 0;
    end
endmodule
