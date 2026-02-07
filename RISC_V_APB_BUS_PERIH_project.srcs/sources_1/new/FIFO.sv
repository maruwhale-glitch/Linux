`timescale 1ns / 1ps

module FIFO (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       wr,
    input  logic       rd,
    input  logic [7:0] wdata,
    output logic [7:0] rdata,
    output             full,
    output             empty
);

    wire w_full, w_empty;
    wire [3:0] w_wptr, w_rptr;

    assign full  = w_full;
    assign empty = w_empty;

    register_file u_register_file (
        .PCLK (PCLK),
        .waddr(w_wptr),
        .raddr(w_rptr),
        .wdata(wdata),
        .wr   ((!w_full) & wr),
        .rd   ((!w_empty) & rd),
        .rdata(rdata)
    );

    fifo_control u_fifo_control (
        .PCLK  (PCLK),
        .PRESET(PRESET),
        .wr    (wr),
        .rd    (rd),
        .full  (w_full),
        .empty (w_empty),
        .r_ptr (w_rptr),
        .w_ptr (w_wptr)
    );

endmodule


module register_file (
    input logic PCLK,
    input logic [3:0] waddr,
    input logic [3:0] raddr,
    input logic [7:0] wdata,
    input logic rd,
    input logic wr,
    output logic [7:0] rdata
);

    logic [7:0] register_file[0:15];

    always_ff @(posedge PCLK) begin
        if (wr) begin
            register_file[waddr] <= wdata;
        end
    end

    assign rdata = register_file[raddr];

endmodule

module fifo_control (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       wr,
    input  logic       rd,
    output logic       full,
    output logic       empty,
    output       [3:0] r_ptr,
    output       [3:0] w_ptr
);

    logic c_full, n_full;
    logic c_empty, n_empty;
    logic [3:0] c_wptr, n_wptr, c_rptr, n_rptr;

    assign full  = c_full;
    assign empty = c_empty;
    assign w_ptr = c_wptr;
    assign r_ptr = c_rptr;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            c_full  <= 1'b0;
            c_empty <= 1'b1;
            c_wptr  <= 2'b00;
            c_rptr  <= 2'b00;
        end else begin
            c_full  <= n_full;
            c_empty <= n_empty;
            c_wptr  <= n_wptr;
            c_rptr  <= n_rptr;
        end
    end

    always_comb begin
        n_full  = c_full;
        n_empty = c_empty;
        n_wptr  = c_wptr;
        n_rptr  = c_rptr;
        case ({
            wr, rd
        })
            2'b01: begin
                n_full = 1'b0;
                if (!c_empty) begin
                    n_rptr = c_rptr + 1'b1;
                    if (n_rptr == c_wptr) begin
                        n_empty = 1'b1;
                    end
                end
            end
            2'b10: begin
                n_empty = 1'b0;
                if (!c_full) begin
                    n_wptr = c_wptr + 1'b1;
                    if (n_wptr == c_rptr) begin
                        n_full = 1'b1;
                    end
                end
            end
            2'b11: begin
                if (c_empty) begin
                    n_empty = 1'b0;
                    n_wptr  = c_wptr + 1'b1;
                end else if (c_full) begin
                    n_full = 1'b0;
                    n_rptr = c_rptr + 1'b1;
                end else begin
                    n_wptr = c_wptr + 1'b1;
                    n_rptr = c_rptr + 1'b1;
                end
            end
        endcase
    end
endmodule
