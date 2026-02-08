`timescale 1ns / 1ps

module Uart_Rx #(
    parameter BPS = 9600
) (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       rx,
    output logic [7:0] data_out,
    output logic       rx_done
);

    typedef enum logic [1:0] {
        S_IDLE,
        S_START_BIT,
        S_DATA_BITS,
        S_STOP_BIT
    } state_t;

    state_t r_state;

    parameter DIVIDER_CNT = 100_000_000 / (BPS * 16);

    logic [ 3:0] r_bit_cnt;
    logic [ 7:0] r_data;

    logic [15:0] r_baud_cnt;
    logic        r_baud_tick;
    logic [ 3:0] r_baud_tick_cnt;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            r_baud_cnt  <= 0;
            r_baud_tick <= 0;
        end else begin
            if (r_baud_cnt == DIVIDER_CNT - 1) begin
                r_baud_cnt  <= 0;
                r_baud_tick <= 1'b1;
            end else begin
                r_baud_cnt  <= r_baud_cnt + 1;
                r_baud_tick <= 1'b0;
            end
        end
    end


    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            r_state         <= S_IDLE;
            r_baud_tick_cnt <= 0;
            r_bit_cnt       <= 0;
            r_data          <= 0;
            rx_done         <= 0;
            data_out        <= 0;
        end else begin
            case (r_state)
                S_IDLE: begin
                    rx_done <= 1'b0;
                    if (!rx) begin
                        r_state <= S_START_BIT;
                        r_baud_tick_cnt <= 0;
                    end
                end
                S_START_BIT: begin
                    if (r_baud_tick) begin
                        if (r_baud_tick_cnt == 4'd7) begin
                            r_state         <= S_DATA_BITS;
                            r_bit_cnt       <= 0;
                            r_baud_tick_cnt <= 0;
                        end else begin
                            r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                        end
                    end
                end
                S_DATA_BITS: begin
                    if (r_baud_tick) begin
                        if (r_baud_tick_cnt == 4'd15) begin
                            r_data[r_bit_cnt] <= rx;
                            r_baud_tick_cnt   <= 4'd0;
                            if (r_bit_cnt == 4'd7) begin
                                r_bit_cnt <= 0;
                                r_state   <= S_STOP_BIT;
                            end else begin
                                r_bit_cnt <= r_bit_cnt + 1;
                            end
                        end else begin
                            r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                        end
                    end
                end
                S_STOP_BIT: begin
                    if (r_baud_tick) begin
                        if (r_baud_tick_cnt == 4'd15) begin
                            r_state  <= S_IDLE;
                            data_out <= r_data;
                            rx_done  <= 1'b1;
                        end else begin
                            r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                        end
                    end
                end
                default: r_state <= S_IDLE;
            endcase
        end
    end
endmodule
