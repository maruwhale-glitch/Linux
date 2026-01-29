module tb_riscv ();

    logic clk;
    logic reset;

    MCU dut (.*);


    always #5 clk = ~clk;

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars(0);
    end


    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;
        #50000;
        $finish;
    end

endmodule
