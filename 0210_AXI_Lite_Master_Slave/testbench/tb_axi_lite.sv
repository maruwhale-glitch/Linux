
module tb_axi_lite ();

    logic        ACLK;
    logic        ARESETn;
    logic [ 3:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;
    logic [ 1:0] BRESP;
    logic        BVALID;
    logic        BREADY;
    logic [ 3:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;
    logic [31:0] RDATA;
    logic        RVALID;
    logic        RREADY;
    logic [ 1:0] RPESP;
    logic        transfer;
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic        write;
    logic [31:0] rdata;

    always #5 ACLK = ~ACLK;

    AXI_Lite_Master DUT (.*);

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars(0);
    end

    task axi_write(int addr, int data);
        addr     <= addr;
        wdata    <= data;
        write    <= 1;
        transfer <= 1;
        @(posedge ACLK);
        transfer <= 0;
        @(ready);
    endtask

    task axi_read(int addr);
        addr     <= addr;
        write    <= 0;
        transfer <= 1;
        @(posedge ACLK);
        transfer <= 0;
        @(ready);
    endtask

    initial begin
        ACLK = 0;
        ARESETn = 0;
        #10 ARESETn = 1;
        @(posedge ACLK);
        axi_write(0, 32'h0001);
        @(posedge ACLK);
        @(posedge ACLK);
        axi_write(4, 32'h0002);
        @(posedge ACLK);
        @(posedge ACLK);
        #100;
        $finish;
    end






endmodule
