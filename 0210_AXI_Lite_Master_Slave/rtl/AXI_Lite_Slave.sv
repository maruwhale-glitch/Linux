
    module AXI_Lite_Slave (
    //Global Signals
    input  logic        ACLK,
    input  logic        ARESETn,
    //Write Transaction, AW Channel
    input  logic [ 3:0] AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,
    //Write Transaction, W Channel
    input  logic [31:0] WDATA,
    input  logic        WVALID,
    output logic        WREADY,
    //Write Transaction, B Channel
    output logic [ 1:0] BRESP,
    output logic        BVALID,
    input  logic        BREADY,
    //READ Transaction, AR Channel
    input  logic [ 3:0] ARADDR,
    input  logic        ARVALID,
    output logic        ARREADY,
    //READ Transaction, R Channel
    output logic [31:0] RDATA,
    output logic        RVALID,
    input  logic        RREADY,
    output logic [ 1:0] RPESP
);

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    typedef enum {
        AW_IDLE,
        AW_READY
    } aw_state_t;

    aw_state_t aw_state, aw_state_next;

    always_ff @(posedge ACLK) begin
        if (ARESETn) begin
            aw_state <= AW_IDLE;
        end else begin
            aw_state <= aw_state_next;
        end
    end

    logic [3:0] r_addr;

    always_comb begin
        aw_state_next = aw_state;
        addr          = AWADDR;
        AWREADY       = 1'b0;
        case (aw_state)
            AW_IDLE: begin
                if (AWVALID) begin
                    aw_state_next = AW_READY;
                    AWREADY       = 1'b0;
                end
            end
            AW_READY: begin
                addr          = AWADDR;
                AWREADY       = 1'b1;
                aw_state_next = AW_IDLE;
            end
            default: begin
                aw_state_next = aw_state;
                addr          = AWADDR;
                AWREADY       = 1'b0;
            end
        endcase
    end
    /////////////////////////////////////////////////////////

        typedef enum {
        W_IDLE,
        W_READY
    } w_state_t;

    w_state_t w_state, w_state_next;

    always_ff @(posedge ACLK) begin
        if (ARESETn) begin
            w_state <= W_IDLE;
        end else begin
            w_state <= w_state_next;
        end
    end

    logic [31:0] r_data;

    always_comb begin
        w_state_next = w_state;
        addr          = WADDR;
        WREADY       = 1'b0;
        case (aw_state)
            W_IDLE: begin
                if (WVALID) begin
                    aw_state_next = W_READY;
                    WREADY       = 1'b0;
                end
            end
            W_READY: begin
                addr          = WADDR;
                WREADY       = 1'b1;
                w_state_next = W_IDLE;
            end
            default: begin
                w_state_next = w_state;
                addr          = WADDR;
                WREADY       = 1'b0;
            end
        endcase
    end

    always_comb begin
        case (addr)
            4'b0000: slv_reg0 = WDATA;
            4'b0010: slv_reg0 = WDATA;
            4'b0100: slv_reg0 = WDATA;
            4'b1000: slv_reg0 = WDATA;
        endcase
    end






endmodule
