`timescale 1ns/1ps
module tb_vga_ttop;
    parameter CLK_PERIOD = 20;

    reg sys_clk;
    reg sys_rst_n;
    reg btn_next;

    wire hsync;
    wire vsync;
    wire [15:0] rgb;
    wire [1:0] btn_rst;

    localparam S_BAR = 2'b00;
    localparam S_MUST      = 2'b01;
    localparam S_END       = 2'b10;

    vga_ttop u_vga_ttop (
        .sys_clk   (clk),
        .sys_rst_n (sys_rst_n),
        .btn_next    (btn_next),
        .hsync     (hsync),
        .vsync     (vsync),
        .rgb       (rgb)
    );

    assign btn_rst = u_vga_ttop.current_state;
    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD / 2) sys_clk = ~sys_clk;
    end
    initial begin
        sys_rst_n = 1'b0;
        btn_next    = 1'b1;
        repeat (5) @(posedge sys_clk); 
        sys_rst_n = 1'b1;

        @(posedge sys_clk);
        #1_000_000;
        press_key();
        #1_000_000;
        press_key();
        #1_000_000;
        press_key();
        #1_000_000;
        press_key();
        #1_000_000;

        sys_rst_n = 1'b0;
        repeat (5) @(posedge sys_clk);
        sys_rst_n = 1'b1;
        @(posedge sys_clk);
		  #1_000_000;
        $finish;
    end

    task press_key;
    begin
        btn_next = 1'b1;
        #1000;
        btn_next = 1'b0;
        repeat (10) @(posedge sys_clk);
        btn_next = 1'b1;
        #1000;
    end
    endtask
endmodule