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

    RegisterFile u_RegisterFile (
        .clk(clk),
        .we (regFileWe),
        .RA1(instrCode[19:15]),
        .RA2(instrCode[24:20]),
        .WA (instrCode[11:7]),
        .WD (RFWriteData),
        .RD1(RFReadData1),
        .RD2(RFReadData2)
    );

    alu u_alu (
        .aluControl(aluControl),
        .a         (RFReadData1),
        .b         (RFReadData2),
        .result    (RFWriteData)
    );

    adder u_adder (
        .a(32'd4),
        .b(instrMemAddr),
        .y(PC_4_AdderResult)
    );

    register u_PC (
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
            `ADD: result = a + b;  //ADD
            `SUB: result = a - b;  //SUB
            `SLL:
            result = a << b[4:0];  // SLL [4:0] 31비트만 표현하면 되니께 b[4:0]로 몇 번 옮길지 결정되는 거자나?
            `SRL: result = a >> b[4:0];  // SRL
            `SRA:
            result = $signed(a) >>>
                b[4:0];  // SRA 부호를 고려해서 확장.
            `SLT: result = ($signed(a) < $signed(b)) ? 1 : 0;  // SLT
            `SLU: result = a < b;  // SLU
            `XOR: result = a ^ b;  // XOR
            `OR: result = a | b;  // OR
            `AND: result = a & b;  // AND
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

    always @(posedge clk) begin
        if (we && (WA != 0)) begin
            mem[WA] <= WD;
        end
    end

    initial begin
        for(int i = 0; i<2**5; i++)begin
            mem[i] <= 0;
        end
    end


    assign RD1 = (RA1 != 0) ? mem[RA1] : 32'b0;
    assign RD2 = (RA2 != 0) ? mem[RA2] : 32'b0;
endmodule

//PC
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
