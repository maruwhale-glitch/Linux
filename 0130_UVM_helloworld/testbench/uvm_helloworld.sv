import uvm_pkg::*;

class hello_world extends uvm_test;
    //hello_world를 UVM에서 실행 가능한 ‘최상위 테스트’로 선언

    `uvm_component_utils(hello_world)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST", "hello world!", UVM_MEDIUM);
        phase.drop_objection(this);
    endtask
endclass

module hello ();
    initial begin
        run_test("hello_world");
    end
endmodule
