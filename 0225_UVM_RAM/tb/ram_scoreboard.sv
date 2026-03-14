`include "uvm_macros.svh"
import uvm_pkg::*;

class ram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ram_scoreboard)

    uvm_analysis_imp #(ram_seq_item, ram_scoreboard) scb_ap_imp;

    bit [31:0] ref_mem[bit [7:0]];

    int num_writes = 0;
    int num_reads = 0;
    int num_matches = 0;
    int num_errors = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_ap_imp = new("scb_ap_imp", this);
    endfunction

    virtual function void write(ram_seq_item txn);
        bit [7:0] word_addr;
        word_addr = txn.addr[9:2];

        if (txn.we) begin
            ref_mem[word_addr] = txn.wdata;
            num_writes++;
            `uvm_info(get_type_name(), $sformatf(
                                           "[스코어보드 쓰기] addr=0x%02h, wdata=0x%08h",
                                           word_addr, txn.wdata), UVM_MEDIUM)
        end else begin
            num_reads++;
            if (ref_mem.exists(word_addr)) begin
                if (txn.rdata == ref_mem[word_addr]) begin
                    num_matches++;
                    `uvm_info(
                        get_type_name(),
                        $sformatf(
                            "[스코어보드 PASS] addr=0x%02h, ref_data=0x%08h, txn_data=0x%08h",
                            word_addr, ref_mem[word_addr], txn.rdata), UVM_MEDIUM)
                end else begin
                    num_errors++;
                    `uvm_error(get_type_name(), $sformatf(
                               "[스코어보드 FAIL] addr=0x%02h, ref_data=0x%08h, txn_data=0x%08h",
                               word_addr,
                               ref_mem[word_addr],
                               txn.rdata
                               ))
                end
            end else begin
                `uvm_info(get_type_name(), $sformatf(
                          "[스코어보드 INFO] 초기화 되지 않은 주소: addr=0x%02h, txn_data=0x%08h",
                          word_addr,
                          txn.rdata
                          ), UVM_MEDIUM)

            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "=================================", UVM_LOW)
        `uvm_info(get_type_name(), "=====스코어보드 검증 결과 요약====", UVM_LOW)
        `uvm_info(get_type_name(), "=================================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" 총 쓰기 횟수 : %0d", num_writes), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" 총 읽기 횟수 : %0d", num_reads), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" 비교 성공 횟수 : %0d", num_matches), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" 비교 실패 횟수 : %0d", num_errors), UVM_LOW)
        `uvm_info(get_type_name(), "=================================", UVM_LOW)
        if (num_errors == 0) begin
            `uvm_info(get_type_name(),
                      "*** 검증 결과 : PASS *** 모든 비교가 성공 했습니다.", UVM_LOW)
        end else begin
            `uvm_info(get_type_name(), $sformatf(
                      "*** 검증 결과 : FAIL *** %0d개의 에러가 발견되었습니다.",
                      num_errors
                      ), UVM_LOW)
        end
    endfunction
endclass  //className extends uvm_dirver

