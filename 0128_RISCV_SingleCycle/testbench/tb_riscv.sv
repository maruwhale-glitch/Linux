


interface ram_if (
    input logic clk,
    input logic reset
);
    logic        we;
    logic [31:0] wdata;
    logic [ 9:0] addr;
    logic [31:0] rdata;
endinterface

class transaction;
    rand logic        we;
    rand logic [ 9:0] addr;
    rand logic [31:0] wdata;
    logic      [31:0] rdata;

    task automatic print(string name);
        $display("[%0d][%s] we = %0d, addr = %0h, wdata = %0h, rdata = %0h",
                 $time, name, we, addr, wdata, rdata);
    endtask  //automatic pirint
endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event drv2gen_event;

    function new(mailbox#(transaction) gen2drv_mbox, event drv2gen_event,
                 mailbox#(transaction) gen2scb_mbox);
        this.gen2drv_mbox  = gen2drv_mbox;
        this.drv2gen_event = drv2gen_event;
        this.gen2scb_mbox  = gen2scb_mbox;
        // tr = new(); 얘는 여기서 바로 해주지 않네. 우리가 run을 돌릴 때 생성하네
    endfunction

    task automatic run(int loop);
        repeat (loop) begin
            tr = new();
            if (!tr.randomize())
                $error(
                    "Randomization failed!"
                );  //error가 뜨면 멈춘다는데? 아니고 fatal이 멈춘대
            tr.print("GEN");
            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr);
            @(drv2gen_event);
            // #10; 사실 클럭을 보면서 해야 하는데 나중에 clk 맞춰서 해볼 것.
        end
    endtask  //automatic

endclass

class driver;
    transaction tr;
    virtual ram_if r_if;
    mailbox #(transaction) gen2drv_mbox;
    event drv2gen_event;

    function new(mailbox#(transaction) gen2drv_mbox, virtual ram_if r_if,
                 event drv2gen_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.r_if = r_if;
        this.drv2gen_event = drv2gen_event;
    endfunction

    task automatic reset_drv();
        r_if.we    = 0;
        r_if.addr  = 0;
        r_if.wdata = 0;
    endtask

    task automatic run();
        forever begin
            gen2drv_mbox.get(tr);
            r_if.we    <= tr.we;
            r_if.addr  <= tr.addr;
            r_if.wdata <= tr.wdata;
            tr.print("DRV");
            @(negedge r_if.clk);
            ->drv2gen_event;
        end
    endtask  //automatic
endclass

class monitor;
    transaction tr;
    virtual ram_if r_if;
    mailbox #(transaction) mon2scb_mbox;

    function new(virtual ram_if r_if, mailbox#(transaction) mon2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
        this.r_if = r_if;
    endfunction

    task automatic run();
        forever begin
            @(posedge r_if.clk);
            tr = new();
            tr.we    = r_if.we;
            tr.addr  = r_if.addr;
            tr.wdata = r_if.wdata;
            tr.rdata = r_if.rdata;
            mon2scb_mbox.put(tr);
            tr.print("MON");
        end
    endtask  //automatic

endclass

class scoreboard;
    transaction tr_gen;
    transaction tr_mon;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;

    int cnt = 0;
    int pass_cnt = 0;  
    int fail_cnt = 0;  
    
    logic [31:0] golden_mem[0:2**10-1];

    function new(mailbox#(transaction) mon2scb_mbox,
                 mailbox#(transaction) gen2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen2scb_mbox = gen2scb_mbox;
    endfunction

    task automatic run();
        forever begin
            gen2scb_mbox.get(tr_gen);
            mon2scb_mbox.get(tr_mon);

            if (tr_mon.we == 1) begin
                if (tr_mon.wdata == tr_gen.wdata) begin
                    // Word 단위 주소 정렬 적용
                    golden_mem[tr_mon.addr[9:2]] = tr_mon.wdata;
                end
            end 
            else begin
                // 여기서 별도의 exists 체크 없이 바로 꺼내 써도 안 쓴 주소는 0이 나옵니다.
                logic [31:0] expected_data = golden_mem[tr_mon.addr[9:2]];

                if (expected_data === tr_mon.rdata) begin
                    $display("[SUCCESS] Addr:%0h | Exp:%0h | Act:%0h", 
                              tr_mon.addr, expected_data, tr_mon.rdata);
                    pass_cnt++;
                end else begin
                    $display("[FAIL] Addr:%0h | Exp:%0h | Act:%0h", 
                              tr_mon.addr, expected_data, tr_mon.rdata);
                    fail_cnt++;
                end
                cnt++; 
            end
        end
    endtask

    // Environment에서 호출할 간단한 결과 보고 함수
    function void report();
        $display("\n=======================================");
        $display("          FINAL VERIFICATION REPORT    ");
        $display("=======================================");
        $display(" Total Read Checks : %0d", cnt);
        $display(" Pass Count        : %0d", pass_cnt);
        $display(" Fail Count        : %0d", fail_cnt);
        $display("=======================================\n");
    endfunction
endclass

class environment;
    //핸들 생성
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;
    event                  drv2gen_event;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) gen2scb_mbox;
    mailbox #(transaction) mon2scb_mbox;

    function new(virtual ram_if r_if);
        gen2drv_mbox = new();
        gen2scb_mbox = new();
        mon2scb_mbox = new();
        gen = new(gen2drv_mbox, drv2gen_event, gen2scb_mbox);
        drv = new(gen2drv_mbox, r_if, drv2gen_event);
        mon = new(r_if, mon2scb_mbox);
        scb = new(mon2scb_mbox, gen2scb_mbox);
    endfunction

    task automatic run();
        // drv.reset_drv(); 이거는 지우는 게 낫다 왜일까?
        fork
            gen.run(1024);
            drv.run();
            mon.run();
            scb.run();
        join_any
        scb.report();

        #100;
        $finish;
    endtask  //automatic
endclass

module tb_riscv ();

    logic clk;
    logic reset;

    ram_if r_if (
        clk,
        reset
    );

    environment env;

    always #5 clk = ~clk;

    RAM dut (
        .clk  (r_if.clk),
        .we   (r_if.we),
        .addr (r_if.addr),
        .wdata(r_if.wdata),
        .rdata(r_if.rdata)
    );

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        clk = 0;

        env = new(r_if);
        env.run();
        #5000 $finish;
    end

endmodule
