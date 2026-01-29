module tb_adder ();

    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;

    adder dut (.*);

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars(0);

        a = 0;
        b = 0;
        #10;
        a = 10;
        b = 20;
        #10;
        a = 19;
        b = 2;
        #10;
        a = 30;
        b = 2;
        #10;
        a = 5;
        b = 7;

        #10 $finish;

    end



endmodule
