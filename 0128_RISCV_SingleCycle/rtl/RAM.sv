module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [ 9:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] mem[0:2**10-1];

    always_ff @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wdata; //cpu쪽에서는 바이트 어드레싱으로 들어오니께
    end


    assign rdata = mem[addr[9:2]];
endmodule
