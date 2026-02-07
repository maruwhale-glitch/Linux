`timescale 1ns / 1ps

module Uart_Tx #(
    parameter BPS = 9600
) (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic [7:0] tx_data,
    input  logic       tx_start,
    output logic       tx,
    output logic       tx_done,
    output logic       tx_busy
);

    parameter S_IDLE = 2'b00;
    parameter S_START_BIT = 2'b01;
    parameter S_DATA_8BITS = 2'b10;
    parameter S_STOP_BIT = 2'b11;

    parameter DIVIDER_CNT = 100_000_000 / BPS;

    logic [16:0] r_baud_cnt;
    logic        r_baud_tick;
    logic [ 1:0] r_state;
    logic [ 3:0] r_bit_cnt;
    logic [ 7:0] r_data;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            r_baud_cnt  <= 0;
            r_baud_tick <= 0;
        end else begin
            if (r_baud_cnt == DIVIDER_CNT - 1) begin
                r_baud_cnt  <= 0;
                r_baud_tick <= 1'b1;
            end else begin
                r_baud_cnt  <= r_baud_cnt + 1'b1;
                r_baud_tick <= 1'b0;
            end
        end
    end

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            tx_done   <= 0;
            tx_busy   <= 1'b0;
            r_data    <= 8'd0;
            r_state   <= S_IDLE;
            r_bit_cnt <= 4'd0;
            tx        <= 1'b1;
        end else begin
            case (r_state)
                S_IDLE: begin
                    tx_done <= 0;
                    if (tx_start) begin
                        tx_busy   <= 1'b1;
                        r_data    <= tx_data;
                        r_bit_cnt <= 4'd0;
                        r_state   <= S_START_BIT;
                    end
                end
                S_START_BIT: begin
                    if (r_baud_tick) begin
                        tx <= 1'b0;
                        r_state <= S_DATA_8BITS;
                    end
                end
                S_DATA_8BITS: begin
                    if (r_baud_tick) begin
                        tx <= r_data[r_bit_cnt];
                        if (r_bit_cnt == 4'd7) begin
                            r_state <= S_STOP_BIT;
                            r_bit_cnt <= 1'b0;
                        end else begin
                            r_bit_cnt <= r_bit_cnt + 1;
                        end
                    end
                end
                S_STOP_BIT: begin
                    if (r_baud_tick) begin
                        tx <= 1'b1;
                        tx_done <= 1'b1;
                        tx_busy <= 1'b0;
                        r_state <= S_IDLE;
                    end
                end
                default: r_state = S_IDLE;
            endcase
        end
    end
endmodule
