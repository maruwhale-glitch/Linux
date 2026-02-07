`timescale 1ns / 1ps


module tb_UART ();

    logic        PCLK;
    logic        PRESET;
    logic [31:0] PADDR;
    logic        PWRITE;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        Rx;
    logic        Tx;


    UART udt (.*);

    always #5 PCLK = ~PCLK;

    task apb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge PCLK);
            PADDR <= addr;
            PWDATA <= data;
            PWRITE <= 1'b1;
            PSEL <= 1'b1;
            PENABLE <= 1'b0;

            @(posedge PCLK);
            PENABLE <= 1'b1;

            @(posedge PCLK);
            while (PREADY == 0) begin
                @(posedge PCLK);
            end

            PSEL <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE <= 1'b0;
        end
    endtask

    initial begin
        PCLK    = 0;
        PRESET  = 1;
        PADDR   = 0;
        PWRITE  = 0;
        PENABLE = 0;
        PWDATA  = 0;
        PSEL    = 0;
        Rx      = 1;
        #10;
        PRESET = 0;
        #10;
        // ---------------------------------------------------------
        // [시나리오 1] 데이터 '0xAB'를 TX FIFO에 작성 
        // ---------------------------------------------------------
        // 주소 0x08 (2번지)에 0xAB를 씁니다.
        // 이때 Waveform을 눈여겨보세요!
        // PENABLE이 1이 되는 순간 vs odr이 바뀌는 순간의 차이를 확인하세요.
        apb_write(32'h0000_0008, 32'h0000_00AB);

        #100;
        // ---------------------------------------------------------
        // [시나리오 2] 다른 데이터 '0xCD'를 또 써보자!
        // ---------------------------------------------------------
        apb_write(32'h0000_0008, 32'h0000_00CD);
        #2000000;
        $finish;
    end

endmodule
