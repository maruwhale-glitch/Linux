`include "uvm_macros.svh"
import uvm_pkg::*;


class ram_write_read_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_write_read_seq)

    int num_txns = 10;

    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_seq_item        txn;

        bit          [ 9:0] saved_addr [];
        bit          [31:0] saved_wdata[];
        saved_addr  = new[num_txns];
        saved_wdata = new[num_txns];
        `uvm_info(
            get_type_name(),
            $sformatf(
                "==== 쓰기 후 읽기 시퀀스 시작 (트랜젝션 %0d개)",
                num_txns), UVM_MEDIUM)

        for (int i = 0; i < num_txns; i++) begin
            txn = ram_seq_item::type_id::create($sformatf("write_txn_%0d", i));

            strat_item(txn);
            if (!txn.randomize() with {we == 1;}) begin
                `uvm_error(get_type_name(), "트랜젝션 랜덤화 실패!")
            end
            saved_addr[i]  = txn.addr;
            saved_wdata[i] = txn.wdata;
            `uvm_info(get_type_name(), $sformatf(
                      "[쓰기 %0d] %s", i, txn.convert2string()), UVM_MEDIUM)
            finish_item(txn);
        end

        // 읽기 트랜잭션 생성
        for (int i = 0; i < num_txns; i++) begin
            txn = ram_seq_item::type_id::create($sformatf("read_txn_%0d", i));

            start_item(txn);
            if (!txn.randomize() with {
                    we == 0;
                    addr == saved_addr[i];
                }) begin
                `uvm_error(get_type_name(), "트랜젝션 랜덤화 실패!")
            end
            `uvm_info(get_type_name(), $sformatf(
                      "[읽기 %0d] %s", i, txn.convert2string()), UVM_MEDIUM)
            finish_item(txn);
        end

        `uvm_info(get_type_name(),
                  "=== 쓰기 후 읽기 시퀀스 완료 ===", UVM_MEDIUM)

    endtask

endclass  //className extends uvm_dirver

class ram_random_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_random_seq)

    int num_txns = 30;

    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_seq_item txn;

        `uvm_info(get_type_name(),
                  $sformatf(
                      "==== 랜덤 시퀀스 시작 (트랜젝션 %0d개)",
                      num_txns), UVM_MEDIUM)

        for (int i = 0; i < num_txns; i++) begin
            txn = ram_seq_item::type_id::create($sformatf("write_txn_%0d", i));

            strat_item(txn);
            if (!txn.randomize()) begin
                `uvm_error(get_type_name(), "트랜젝션 랜덤화 실패!")
            end
            `uvm_info(get_type_name(), $sformatf(
                      "[랜덤 %0d] %s", i, txn.convert2string()), UVM_MEDIUM)
            finish_item(txn);
        end

        // 읽기 트랜잭션 생성
        for (int i = 0; i < num_txns; i++) begin
            txn = ram_seq_item::type_id::create($sformatf("read_txn_%0d", i));

            start_item(txn);
            if (!txn.randomize() with {
                    we == 0;
                    addr == saved_addr[i];
                }) begin
                `uvm_error(get_type_name(), "트랜젝션 랜덤화 실패!")
            end
            `uvm_info(get_type_name(), $sformatf(
                      "[읽기 %0d] %s", i, txn.convert2string()), UVM_MEDIUM)
            finish_item(txn);
        end

        `uvm_info(get_type_name(), "=== 랜덤 시퀀스 완료 ===",
                  UVM_MEDIUM)

    endtask

endclass  //className extends uvm_dirver

class ram_boundary_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_random_seq)

    int num_txns = 30;

    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_seq_item txn;

        `uvm_info(get_type_name(),
                  $sformatf(
                      "==== 랜덤 시퀀스 시작 (트랜젝션 %0d개)",
                      num_txns), UVM_MEDIUM)

        for (int i = 0; i < num_txns; i++) begin
            txn = ram_seq_item::type_id::create($sformatf("write_txn_%0d", i));

            strat_item(txn);
            if (!txn.randomize()) begin
                `uvm_error(get_type_name(), "트랜젝션 랜덤화 실패!")
            end
            `uvm_info(get_type_name(), $sformatf(
                      "[랜덤 %0d] %s", i, txn.convert2string()), UVM_MEDIUM)
            finish_item(txn);
        end

        // 읽기 트랜잭션 생성
        for (int i = 0; i < num_txns; i++) begin
            txn = ram_seq_item::type_id::create($sformatf("read_txn_%0d", i));

            start_item(txn);
            if (!txn.randomize() with {
                    we == 0;
                    addr == saved_addr[i];
                }) begin
                `uvm_error(get_type_name(), "트랜젝션 랜덤화 실패!")
            end
            `uvm_info(get_type_name(), $sformatf(
                      "[읽기 %0d] %s", i, txn.convert2string()), UVM_MEDIUM)
            finish_item(txn);
        end

        `uvm_info(get_type_name(), "=== 랜덤 시퀀스 완료 ===",
                  UVM_MEDIUM)

    endtask

endclass  //className extends uvm_dirver

