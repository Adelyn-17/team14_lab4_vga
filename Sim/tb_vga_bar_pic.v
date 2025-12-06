`timescale 1ns/1ps

module tb_vga_bar_pic;

    reg         vga_clk;
    reg         sys_rst_n;
    reg  [9:0]  pix_x;
    reg  [9:0]  pix_y;
    wire [15:0] pix_data;

    localparam COLOR_0  = 16'hF800; // 红色
    localparam COLOR_1  = 16'hFC00; // 橙色
    localparam COLOR_2  = 16'hFFE0; // 黄色
    localparam COLOR_3  = 16'h87E0; // 绿色
    localparam COLOR_4  = 16'h07FF; // 青色
    localparam COLOR_5  = 16'h001F; // 蓝色
    localparam COLOR_6  = 16'h481F; // 紫色
    localparam COLOR_7  = 16'hF81F; // 品红
    localparam COLOR_8  = 16'hFFFF; // 白色
    localparam COLOR_9  = 16'h8410; // 灰色
    
    reg [9:0]   TEST_X [0:9];
    reg [15:0]  EXPECTED_COLOR [0:9];
    
    integer i; 

    vga_bar_pic uut (
        .vga_clk   (vga_clk),
        .sys_rst_n (sys_rst_n),
        .pix_x     (pix_x),
        .pix_y     (pix_y),
        .pix_data  (pix_data)
    );

    localparam CLK_PERIOD = 40; 

    initial begin
        vga_clk = 1'b0;
        forever #(CLK_PERIOD / 2) vga_clk = ~vga_clk;
    end

    initial begin
        TEST_X[0] = 10;   EXPECTED_COLOR[0] = COLOR_0;
        TEST_X[1] = 70;   EXPECTED_COLOR[1] = COLOR_1;
        TEST_X[2] = 130;  EXPECTED_COLOR[2] = COLOR_2;
        TEST_X[3] = 195;  EXPECTED_COLOR[3] = COLOR_3;
        TEST_X[4] = 260;  EXPECTED_COLOR[4] = COLOR_4;
        TEST_X[5] = 325;  EXPECTED_COLOR[5] = COLOR_5;
        TEST_X[6] = 390;  EXPECTED_COLOR[6] = COLOR_6;
        TEST_X[7] = 450;  EXPECTED_COLOR[7] = COLOR_7;
        TEST_X[8] = 520;  EXPECTED_COLOR[8] = COLOR_8;
        TEST_X[9] = 580;  EXPECTED_COLOR[9] = COLOR_9;

        sys_rst_n = 1'b0;
        pix_x = 10'd0;
        pix_y = 10'd0;
        $display("------------------------------------------------------------------");
        $display("T=%0t: System Reset Asserted. Waiting for system stabilization...", $time);

        #(CLK_PERIOD * 2.5) sys_rst_n = 1'b1; 
        $display("T=%0t: System Reset Deasserted. Start testing...", $time);
        
        pix_y = 10'd200; 

        for (i = 0; i < 10; i = i + 1) begin
            #(CLK_PERIOD / 2); 
            pix_x = TEST_X[i];
            

            #(CLK_PERIOD); 
            
            $display("------------------------------------------------------------------");
            $display("T=%0t: Test Case %0d (Bar Index %0d)", $time, i, i);
            $display("   Input (pix_x, pix_y) = (%0d, %0d)", pix_x, pix_y);
            $display("   Expected Output (RGB565) = 0x%h", EXPECTED_COLOR[i]);
            $display("   Actual Output (pix_data) = 0x%h", pix_data);
            
            // 验证结果
            if (pix_data == EXPECTED_COLOR[i])
                $display("   --> VERRICATION PASSED: Color matches expectation.");
            else
                $display("   *** VERRICATION FAILED: Actual color 0x%h does not match expected color 0x%h.", pix_data, EXPECTED_COLOR[i]);
        end

        #(CLK_PERIOD / 2);
        pix_x = 10'd650; 
        #(CLK_PERIOD);
        $display("------------------------------------------------------------------");
        $display("T=%0t: Test Boundary Case (pix_x=650)", $time);
        $display("   Input (pix_x, pix_y) = (%0d, %0d)", pix_x, pix_y);
        $display("   Expected Output (RGB565) = 0x0000 (Default Black)");
        $display("   Actual Output (pix_data) = 0x%h", pix_data);
        if (pix_data == 16'h0000)
            $display("   --> VERRICATION PASSED: Default color is Black.");
        else
            $display("   *** VERRICATION FAILED: Actual color 0x%h is not Black.", pix_data);

        $display("------------------------------------------------------------------");
        $display("T=%0t: Simulation Finished.", $time);
        $finish;
    end

    initial begin
        $dumpfile("vga_bar_pic.vcd");
        $dumpvars(0, tb_vga_bar_pic);
    end

endmodule
