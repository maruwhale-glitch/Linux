`include "uvm_macros.svh"
import uvm_pkg::*;
import ram_pkg::*;

module ram_tb_top ();

    logic clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    ram_if vif (clk);

    ram u_ram (
        .clk  (clk),
        .we   (vif.we),
        .addr (vif.addr),
        .wdata(vif.wdata),
        .rdata(vif.rdata)
    );

    initial begin
        uvm_config_db#(virtual ram_if)::set(null, "*", "vif", vif);
        run_test("ram_test");
    end
endmodule
