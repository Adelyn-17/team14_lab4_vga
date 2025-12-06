`timescale 1ns / 1ps

module tb_pll();
    reg         sys_clk;
    reg         sys_rst_n;
    wire        vga_clk;

    localparam SYS_CLK_PERIOD = 20;
    localparam RUN_TIME       = 800; 

    pll uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .vga_clk(vga_clk)
    );

    initial begin
        sys_clk = 1'b0;
        forever #(SYS_CLK_PERIOD / 2) sys_clk = ~sys_clk; 
    end

    initial begin
        sys_rst_n = 1'b0;
        $display("------------------------------------------------------------------");
        $display("T=%0t: System Reset Asserted (sys_rst_n=0). vga_clk is expected to be 0.", $time);
     
        #(SYS_CLK_PERIOD * 3); 

        sys_rst_n = 1'b1;
        $display("T=%0t: System Reset Deasserted (sys_rst_n=1). vga_clk expected to start ticking at 25MHz.", $time);
        $display("   Expected VGA_CLK Period: %0d ns (Twice the SYS_CLK period).", SYS_CLK_PERIOD * 2);

        #(RUN_TIME); 

        $display("------------------------------------------------------------------");
        $display("T=%0t: Simulation Finished. Observed 10 stable vga_clk cycles.", $time);
        $finish;
    end

    initial begin
        $dumpfile("pll.vcd");
        $dumpvars(0, tb_pll);
    end

endmodule
