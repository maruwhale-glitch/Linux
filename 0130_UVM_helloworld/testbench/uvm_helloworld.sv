//UVM 클래스/매크로 전체 사용 선언
import uvm_pkg::*;

//hello_world를 UVM에서 실행 가능한 ‘최상위 테스트’로 선언
class hello_world extends uvm_test;

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

class CParent;
    int a;
    int b;
    int c;

    function new();
        a = 10;
        b = 20;
        c = 30;
    endfunction

    task adder(int x1, int x2);
        c = x1 + x2;
    endtask  //automatic

endclass

class Cchild extends CParent;
    int d;
    int e;
    function new();
        d = 1;
        e = 2;
    endfunction

    task print(int y);
         $display("y = %d", y);
    endtask

endclass

module hello ();
Cchild child;

    initial begin
        child = new();
        child.a = 20;
        child.b = 30;
        child.adder(child.a, child.b);
        child.print(child.c);
        // run_test("hello_world");
    end
endmodule
