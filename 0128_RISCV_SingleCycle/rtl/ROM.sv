`timescale 1ns / 1ps

module ROM (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:2**10-1];

    initial begin
        rom[1] = 32'h123450b7;
        rom[2] = 32'h00000117;
        rom[3] = 32'h008001ef;
        rom[4] = 32'h0ff00213;
        rom[5] = 32'h00100213;
        rom[6] = 32'h004002ef;
        rom[7] = 32'h00028367;
        rom[8] = 32'h0ff00393;
        rom[9] = 32'h00200393;
    end

    assign data = rom[addr[31:2]];
endmodule
// # ---------------------------------------------------------
// # Step 1: LUI (Load Upper Immediate) 테스트
// # ---------------------------------------------------------
// lui  x1, 0x12345     # x1 = 0x12345000

// # ---------------------------------------------------------
// # Step 2: AUIPC (Add Upper Immediate to PC) 테스트
// # ---------------------------------------------------------
// auipc x2, 0x0        # x2 = 현재 PC

// # ---------------------------------------------------------
// # Step 3: JAL (Jump and Link) 테스트
// # ---------------------------------------------------------
// jal  x3, LABEL_1     # LABEL_1으로 점프
// addi x4, x0, 0xFF    # (건너뛰어야 함)

// LABEL_1:
// addi x4, x0, 0x01    # x4 = 1

// # ---------------------------------------------------------
// # Step 4: JALR (Jump and Link Register) 테스트
// # ---------------------------------------------------------
// jal  x5, LABEL_2     # LABEL_2로 점프하여 x5에 return address 저장

// LABEL_2:
// jalr x6, x5, 0       # x5(return address)로 돌아가기
// addi x7, x0, 0xFF    # (건너뛰어야 함)