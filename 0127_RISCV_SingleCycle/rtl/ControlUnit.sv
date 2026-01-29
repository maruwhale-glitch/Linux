`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};
    logic signals;

    assign {regFileWe} = signals;

    always_comb begin
        signals = 1'b0;
        case (opcode)
            //{regFileWe}
            `OP_TYPE_R: signals = 1'b1;  // R-TYPE
        endcase
    end

    always_comb begin
        aluControl = `ADD;
        case (opcode)
            `OP_TYPE_R: aluControl = operator;
        endcase
    end

endmodule
