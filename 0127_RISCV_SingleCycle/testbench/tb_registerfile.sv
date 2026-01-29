`timescale 1ns / 1ps

interface reg_if;
    logic        clk;
    logic        we;
    logic [ 4:0] RA1;
    logic [ 4:0] RA2;
    logic [ 4:0] WA;
    logic [31:0] WD;
    logic [31:0] RD1;
    logic [31:0] RD2;
endinterface

class transaction;
    rand logic        we;
    rand logic [ 4:0] RA1;
    rand logic [ 4:0] RA2;
    rand logic [ 4:0] WA;
    rand logic [31:0] WD;
    logic      [31:0] RD1;
    logic      [31:0] RD2;

    function new();
        we  = 0;
        RA1 = 0;
        RA2 = 0;
        WA  = 0;
        WD  = 0;
        RD1 = 0;
        RD2 = 0;
    endfunction

    task automatic print(string name);
        $display("time:%0t, name:%s we:%0d, RA1:%0d, RA2:%0d, WA:%0d, WD:%0d",
                 $time, name, we, RA1, RA2, WA, WD);
    endtask  //automatic

endclass

class driver;
    transaction t;
    virtual reg_if r_if;

    //legend register 
    logic [31:0] mem[0:2**5-1];

    function new(virtual reg_if r_if);
        this.r_if = r_if;
        this.t = new();
        for (int i = 0; i < 32; i++) mem[i] = 0;
    endfunction

    task automatic send();
        t.randomize();
        r_if.we  = t.we;
        r_if.RA1 = t.RA1;
        r_if.RA2 = t.RA2;
        r_if.WA  = t.WA;
        r_if.WD  = t.WD;
        @(posedge r_if.clk)

            if (t.we && (t.WA != 0)) begin
                mem[t.WA] = t.WD;
            end
    endtask  //automatic 

    //내가 고민한 부분이 always블록을 쓰지 못하니까 안 쓰고 어떻게 해결할 수 있는가였는데
    //task를 통해서 시간 흐름을 제어할 수 있다.

    task automatic receive();
        t.RD1 = r_if.RD1;
        t.RD2 = r_if.RD2;

        if (mem[t.RA1] == r_if.RD1) begin
            $display("pass! %0dmem[t.RA1] == %0dr_if.RD1", mem[t.RA1],
                     r_if.RD1);
        end else begin
            $display("fail RD1 Expected:%0d, RD1 Actual:%0d", mem[t.RA1],
                     r_if.RD1);
            $display("fail WA:%0d, RA1 Actual:%0d", t.WA, t.RA1);
        end
        if (mem[t.RA2] == r_if.RD2) begin
            $display("pass! %0dmem[t.RA2] == %0dr_if.RD2", mem[t.RA2],
                     r_if.RD2);
        end else begin
            $display("fail RD2 Expected:%0d, RD2 Actual:%0d", mem[t.RA2],
                     r_if.RD2);
            $display("fail WA:%0d, RA2 Actual:%0d", t.WA, t.RA2);
        end
    endtask  //automatic receive
endclass


module tb_registerfile;

    reg_if r_if ();
    driver drv;

    RegisterFile dut (
        .clk(r_if.clk),
        .we (r_if.we),
        .RA1(r_if.RA1),
        .RA2(r_if.RA2),
        .WA (r_if.WA),
        .WD (r_if.WD),
        .RD1(r_if.RD1),
        .RD2(r_if.RD2)
    );

    always #5 r_if.clk = ~r_if.clk;

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        r_if.clk = 0;
        drv = new(r_if);
        #10;
        for (int i = 0; i < 100; i++) begin
            drv.send();
            #1;
            drv.receive();
            @(negedge r_if.clk);
        end
        #10;
        $finish;
    end

endmodule
