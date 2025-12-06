`timescale 1ns / 1ps

module tb_vga_ctrl;

    reg         vga_clk;
    reg         sys_rst_n;
    reg  [15:0] pix_data;

    wire [9:0]  pix_x;
    wire [9:0]  pix_y;
    wire        hsync;
    wire        vsync; 
    wire [15:0] rgb;   

    localparam VGA_CLK_PERIOD = 40; 

    localparam H_TOTAL_CYCLES = 800;
    localparam RUN_TIME = VGA_CLK_PERIOD * H_TOTAL_CYCLES * 4; 

    localparam H_SYNC_END   = 96;
    localparam H_BP_END     = 96 + 40;     // 136
    localparam H_BORDER_END = 136 + 8;     // 144 (H_ACTIVE_START)
    localparam H_ACTIVE_END = 144 + 640;   // 784 (H_ACTIVE_END)
    
    localparam V_SYNC_END   = 2;
    localparam V_BP_END     = 2 + 25;      // 27
    localparam V_BORDER_END = 27 + 8;      // 35 (V_ACTIVE_START)

    vga_ctrl uut (
        .vga_clk(vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_data(pix_data),
        
        .pix_x(pix_x),
        .pix_y(pix_y),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    initial begin
        vga_clk = 1'b0;
        forever #(VGA_CLK_PERIOD / 2) vga_clk = ~vga_clk; 
    end

    initial begin
        // 初始化信号
        sys_rst_n = 1'b0;
        pix_data  = 16'hFFFF;
        
        $display("------------------------------------------------------------------");
        $display("T=%0t: System Reset Asserted (sys_rst_n=0). Counters expected to be 0.", $time);

        #(VGA_CLK_PERIOD * 3); 

        sys_rst_n = 1'b1;
        $display("T=%0t: System Reset Deasserted (sys_rst_n=1). Timing sequence starts.", $time);
        $display("   Checking HSync, VSync, pix_x, pix_y and RGB outputs.");

        #(RUN_TIME); 

        $display("------------------------------------------------------------------");
        $display("T=%0t: Simulation Finished. Checked 4 horizontal lines.", $time);
        $finish;
    end

    
    initial begin
        // 等待复位释放
        @(posedge sys_rst_n);

        @(posedge vga_clk);

        #1; 
        if (hsync != 1'b1) 
            $error("Verification Failed at T=%0t: HSync expected to be 1 at start of line (H=0).", $time);

        repeat(H_SYNC_END - 1) @(posedge vga_clk);
        @(posedge vga_clk); 
        
        #1;
        if (hsync != 1'b0)
            $error("Verification Failed at T=%0t: HSync expected to be 0 after H_SYNC_PULSE (H=96).", $time);
  
        repeat(H_BORDER_END - H_SYNC_END - 1) @(posedge vga_clk);
        @(posedge vga_clk); 
        
        #1;
        if (pix_x != 10'd0) 
            $error("Verification Failed at T=%0t: Pix_x expected to be 0 at H=%0d, but is %0d.", $time, H_BORDER_END - 1, pix_x);

        @(posedge vga_clk);
        #1;
        if (rgb != pix_data) 
            $error("Verification Failed at T=%0t: RGB expected to be 16'hFFFF at H=%0d, but is %0h.", $time, H_BORDER_END, rgb);

        repeat(H_ACTIVE_END - H_BORDER_END - 1) @(posedge vga_clk);
        @(posedge vga_clk); 
        
        #1;
        if (rgb != 16'h0000) 
            $error("Verification Failed at T=%0t: RGB expected to be 16'h0000 after H=%0d, but is %0h.", $time, H_ACTIVE_END, rgb);

        if (pix_x != 10'h3FF) 
            $error("Verification Failed at T=%0t: Pix_x expected to be 10'h3FF after H=%0d, but is %0d.", $time, H_ACTIVE_END, pix_x);

        repeat(H_TOTAL_CYCLES - H_ACTIVE_END - 1) @(posedge vga_clk);

        @(posedge vga_clk); 
        #1;
        if (pix_y != 10'h3FF) 
            $error("Verification Failed at T=%0t: Pix_y expected to be 10'h3FF, but is %0d.", $time, pix_y);

        if (vsync != 1'b1)
            $error("Verification Failed at T=%0t: VSync expected to be 1 at V=1.", $time);
            
    end
    
    initial begin
        $dumpfile("vga_ctrl.vcd");
        $dumpvars(0, tb_vga_ctrl);
    end

endmodule
