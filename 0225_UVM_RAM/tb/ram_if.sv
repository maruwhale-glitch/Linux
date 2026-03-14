interface ram_if (
    input logic clk
);
    logic        we;
    logic [ 9:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;

    clocking driver_cb @(posedge clk);
        output we;
        output addr;
        output wdata;
        input rdata;
    endclocking

    clocking monitor_cb @(posedge clk);
        input we;
        input addr;
        input wdata;
        input rdata;
    endclocking

    modport driver_mp(clocking driver_cb);
    modport monitor_mp(clocking monitor_cb);
endinterface  //ram_if (input logic clk)
