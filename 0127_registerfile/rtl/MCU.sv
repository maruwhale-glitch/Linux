`timescale 1ns / 1ps

module MCU (
    input  logic clk,
    output logic reset
);
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    
    ROM u_rom (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    CPU_RV32I u_CPU_RV32I (
        .clk         (clk),
        .reset       (reset),
        .instrCode   (instrCode),
        .instrMemAddr(instrMemAddr)
    );
endmodule
