`timescale 1ns / 1ps

module ROM (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:2**10-1];

    initial begin
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011;// add x4, x2, x1
    end

    assign data = rom[addr[31:2]];
endmodule
