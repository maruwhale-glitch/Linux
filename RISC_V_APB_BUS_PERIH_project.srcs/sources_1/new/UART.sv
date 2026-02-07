`timescale 1ns / 1ps

module UART (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [31:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // External Signals
    input  logic        Rx,
    output logic        Tx
);

    logic [7:0] w_rx_data;
    logic [7:0] w_tx_data;
    logic w_tx_fifo_full ;
    logic w_rx_fifo_empty;
    logic w_rx_fifo_full ;
    logic w_tx_fifo_wr   ;
    logic w_rx_fifo_rd   ;

    APB_SlaveIntf_UART U_APB_SlaveIntf_UART (
        .PCLK         (PCLK),
        .PRESET       (PRESET),
        .PADDR        (PADDR),
        .PWRITE       (PWRITE),
        .PENABLE      (PENABLE),
        .PWDATA       (PWDATA),
        .PSEL         (PSEL),
        .PRDATA       (PRDATA),
        .PREADY       (PREADY),
        //Internal Signals
        .idr          (w_rx_data),
        .odr          (w_tx_data),
        .tx_fifo_full (w_tx_fifo_full),
        .rx_fifo_empty(w_rx_fifo_empty),
        .rx_fifo_full (w_rx_fifo_full),
        .tx_fifo_wr   (w_tx_fifo_wr),
        .rx_fifo_rd   (w_rx_fifo_rd)
    );

    UART_TOP U_UART_TOP (
        .PCLK         (PCLK),
        .PRESET       (PRESET),
        .Rx           (Rx),
        .Tx           (Tx),
        .rx_data      (w_rx_data),
        .tx_data      (w_tx_data),
        .tx_fifo_full (w_tx_fifo_full),
        .rx_fifo_empty(w_rx_fifo_empty),
        .rx_fifo_full (w_rx_fifo_full),
        .tx_fifo_wr   (w_tx_fifo_wr),
        .rx_fifo_rd   (w_rx_fifo_rd)
    );

endmodule

module UART_TOP (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       Rx,
    output logic       Tx,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       tx_fifo_full,
    output logic       rx_fifo_empty,
    output logic       rx_fifo_full,
    input  logic       tx_fifo_wr,
    input  logic       rx_fifo_rd
);

    wire [7:0] w_rx_data;
    wire w_rx_done;

    wire [7:0] w_tx_rdata;
    wire w_tx_busy;


    Uart_Rx #(
        .BPS(9600)
    ) u_uart_rx (
        .PCLK    (PCLK),
        .PRESET  (PRESET),
        .rx      (Rx),
        .data_out(w_rx_data),
        .rx_done (w_rx_done)
    );

    FIFO u_FIFO_RX (
        .PCLK  (PCLK),
        .PRESET(PRESET),
        .wr    (w_rx_done),
        .rd    (rx_fifo_rd),
        .wdata (w_rx_data),
        .rdata (rx_data),
        .full  (rx_fifo_full),
        .empty (rx_fifo_empty)
    );

    FIFO u_FIFO_TX (
        .PCLK  (PCLK),
        .PRESET(PRESET),
        .wr    (tx_fifo_wr),
        .rd    ((!w_tx_busy) & (!w_tx_empty)),
        .wdata (tx_data),
        .rdata (w_tx_rdata),
        .full  (tx_fifo_full),
        .empty (w_tx_empty)
    );

    Uart_Tx #(
        .BPS(9600)
    ) u_uart_tx (
        .PCLK    (PCLK),
        .PRESET  (PRESET),
        .tx_data (w_tx_rdata),
        .tx_start(!w_tx_empty),
        .tx      (Tx),
        .tx_done (),
        .tx_busy (w_tx_busy)
    );
endmodule

module APB_SlaveIntf_UART (
    input  logic        PCLK,
    input  logic        PRESET,
    input  logic [31:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    //Internal Signals
    input  logic [ 7:0] idr,
    output logic [ 7:0] odr,
    input  logic        tx_fifo_full,
    input  logic        rx_fifo_empty,
    input  logic        rx_fifo_full,
    output logic        tx_fifo_wr,
    output logic        rx_fifo_rd
);  

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    assign odr = slv_reg2[7:0];

    // assign tx_fifo_wr = (PSEL & PENABLE & PWRITE & (PADDR[3:2] == 2'd2) & ~tx_fifo_full );
    assign tx_fifo_wr=(PSEL & PENABLE & PWRITE & (PADDR[3:2] == 2'd2) & ~tx_fifo_full & PREADY);
    assign rx_fifo_rd=(PSEL & PENABLE & !PWRITE & (PADDR[3:2] == 2'd1) & ~rx_fifo_empty);

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            PREADY <= 1'b0;
            if (PSEL & PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        //2'd0: slv_reg0 <= PWDATA;
                        //2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    case (PADDR[3:2])
                        2'd0:
                        PRDATA <= {
                            29'b0, rx_fifo_empty, rx_fifo_full, tx_fifo_full
                        };
                        2'd1: PRDATA <= {24'd0, idr};
                        2'd2: PRDATA <= slv_reg2;
                        2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end
        end
    end
endmodule
