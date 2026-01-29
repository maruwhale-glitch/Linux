`timescale 1ns / 1ps
`include "defines.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    output logic [31:0] instrMemAddr
);

    logic [31:0] RFReadData1, RFReadData2, RFWriteData;
    logic [31:0] PC_4_AdderResult;

    RegisterFile U_RegFile (
        .clk(clk),
        .we (regFileWe),
        .RA1(instrCode[19:15]),
        .RA2(instrCode[24:20]),
        .WA (instrCode[11:7]),
        .WD (RFWriteData),
        .RD1(RFReadData1),
        .RD2(RFReadData2)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a         (RFReadData1),
        .b         (RFReadData2),
        .result    (RFWriteData)
    );


    adder U_4Adder (
        .a(32'd4),
        .b(instrMemAddr),
        .y(PC_4_AdderResult)
    );

    register U_PC (
        .clk  (clk),
        .reset(reset),
        .en   (1'b1),
        .d    (PC_4_AdderResult),
        .q    (instrMemAddr)
    );
endmodule

module alu (
    input  logic [ 3:0] aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    always_comb begin
        result = 0;
        case (aluControl)
            `ADD: result = a + b;
            `SUB: result = a - b;
            `SLL: result = a << b[4:0];
            `SRL: result = a >> b[4:0];
            `SRA: result = $signed(a) >>> b[4:0];
            `SLT: result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLU: result = a < b ? 1 : 0;
            `XOR: result = a ^ b;
            `OR:  result = a | b;
            `AND: result = a & b;
        endcase
    end
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RA1,
    input  logic [ 4:0] RA2,
    input  logic [ 4:0] WA,
    input  logic [31:0] WD,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] mem[0:2**5-1];

    always_ff @(posedge clk) begin
        if (we) mem[WA] <= WD;
    end

    assign RD1 = (RA1 != 0) ? mem[RA1] : 32'b0;
    assign RD2 = (RA2 != 0) ? mem[RA2] : 32'b0;
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (en) q <= d;
        end
    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule
