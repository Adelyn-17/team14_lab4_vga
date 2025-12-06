`timescale 1ns/1ps

module tb_vga_must_pic;

    reg         vga_clk;
    reg         sys_rst_n;
    reg  [9:0]  pix_x;
    reg  [9:0]  pix_y;
    wire [15:0] pix_data;

    integer i;
    reg [15:0] expected_data; 

    localparam BLACK = 16'h0000;
    localparam WHITE = 16'hFFFF;

    localparam Y_START  = 10'd190;
    localparam X_START  = 10'd120;
    localparam LETTER_W = 10'd90;
    localparam LETTER_H = 10'd90;
    localparam GAP      = 10'd25;
    localparam STROKE   = 10'd15;
    localparam CLK_PERIOD = 40; 

    localparam U_X_START = X_START + LETTER_W + GAP; 
    localparam S_X_START = U_X_START + LETTER_W + GAP;
    localparam T_X_START = S_X_START + LETTER_W + GAP; 

    reg [9:0] TEST_X [0:23];
    reg [9:0] TEST_Y [0:23];
    reg       EXPECTED_COLOR [0:23]; 

    vga_must_pic uut (
        .vga_clk   (vga_clk),
        .sys_rst_n (sys_rst_n),
        .pix_x     (pix_x),
        .pix_y     (pix_y),
        .pix_data  (pix_data)
    );

    initial begin
        vga_clk = 1'b0;
        forever #(CLK_PERIOD / 2) vga_clk = ~vga_clk;
    end

    initial begin
        
        TEST_X[0] = X_START + STROKE/2;       TEST_Y[0] = Y_START + 5;           EXPECTED_COLOR[0] = 1; 
        TEST_X[1] = X_START + 5;              TEST_Y[1] = Y_START + 5;           EXPECTED_COLOR[1] = 0; 
        TEST_X[2] = X_START + LETTER_W - STROKE/2; TEST_Y[2] = Y_START + 5;           EXPECTED_COLOR[2] = 1;
        TEST_X[3] = X_START + LETTER_W/2;     TEST_Y[3] = Y_START + 5;           EXPECTED_COLOR[3] = 0; 
        TEST_X[4] = 130;                      TEST_Y[4] = 250;                   EXPECTED_COLOR[4] = 1; // M - Slope 1 (WHITE)
        TEST_X[5] = 130;                      TEST_Y[5] = 200;                   EXPECTED_COLOR[5] = 0; // M - Slope 1 Above (BLACK)
        TEST_X[6] = 170;                      TEST_Y[6] = 230;                   EXPECTED_COLOR[6] = 1; // M - Slope 2 (WHITE)
        TEST_X[7] = 170;                      TEST_Y[7] = 260;                   EXPECTED_COLOR[7] = 0; // M - Slope 2 Below (BLACK)
  
        TEST_X[8] = U_X_START + 5;             TEST_Y[8] = Y_START + LETTER_H/2;  EXPECTED_COLOR[8] = 1; 
        TEST_X[9] = U_X_START + LETTER_W - 5;  TEST_Y[9] = Y_START + LETTER_H/2;  EXPECTED_COLOR[9] = 1; 
        TEST_X[10] = U_X_START + LETTER_W/2;   TEST_Y[10] = Y_START + LETTER_H - 5; EXPECTED_COLOR[10] = 1; 
        TEST_X[11] = U_X_START + LETTER_W/2;   TEST_Y[11] = Y_START + 5;          EXPECTED_COLOR[11] = 0; 
    
        TEST_X[12] = S_X_START + 5;             TEST_Y[12] = Y_START + 5;          EXPECTED_COLOR[12] = 0; 
        TEST_X[13] = S_X_START + LETTER_W/2;    TEST_Y[13] = Y_START + 5;          EXPECTED_COLOR[13] = 1; 
        TEST_X[14] = S_X_START + 5;             TEST_Y[14] = Y_START + LETTER_H/2; EXPECTED_COLOR[14] = 1; 
        TEST_X[15] = S_X_START + LETTER_W/2;    TEST_Y[15] = Y_START + LETTER_H/2; EXPECTED_COLOR[15] = 0; 
        TEST_X[16] = S_X_START + LETTER_W/2;    TEST_Y[16] = Y_START + LETTER_H - 5; EXPECTED_COLOR[16] = 1; 
        TEST_X[17] = S_X_START + 5;             TEST_Y[17] = Y_START + LETTER_H/4; EXPECTED_COLOR[17] = 1; 
        TEST_X[18] = S_X_START + LETTER_W - 5;  TEST_Y[18] = Y_START + LETTER_H/4; EXPECTED_COLOR[18] = 0; 
        TEST_X[19] = S_X_START + LETTER_W - 5;  TEST_Y[19] = Y_START + LETTER_H*3/4; EXPECTED_COLOR[19] = 1; 
  
        TEST_X[20] = T_X_START + LETTER_W/2;    TEST_Y[20] = Y_START + 5;          EXPECTED_COLOR[20] = 1; 
        TEST_X[21] = T_X_START + 5;             TEST_Y[21] = Y_START + 5;          EXPECTED_COLOR[21] = 1; 
        TEST_X[22] = T_X_START + LETTER_W/2;    TEST_Y[22] = Y_START + LETTER_H/2; EXPECTED_COLOR[22] = 1; 
        TEST_X[23] = T_X_START + LETTER_W/2 - STROKE; TEST_Y[23] = Y_START + LETTER_H/2; EXPECTED_COLOR[23] = 0; 

        sys_rst_n = 1'b0; 
        pix_x = 10'd0;
        pix_y = 10'd0;
        $display("------------------------------------------------------------------");
        $display("T=%0t: System Reset Asserted. Waiting for system stabilization...", $time);

        #(CLK_PERIOD * 2.5) sys_rst_n = 1'b1; 
        $display("T=%0t: System Reset Deasserted. Start testing 'MUST' logic...", $time);
  
        for (i = 0; i < 24; i = i + 1) begin
   
            #(CLK_PERIOD / 2); 
            pix_x = TEST_X[i];
            pix_y = TEST_Y[i];

            expected_data = EXPECTED_COLOR[i] ? WHITE : BLACK;

            #(CLK_PERIOD); 
            
            $display("------------------------------------------------------------------");
            $display("T=%0t: Test Case %0d (%s)", $time, i, EXPECTED_COLOR[i] ? "WHITE" : "BLACK");
            $display("   Input (pix_x, pix_y) = (%0d, %0d)", pix_x, pix_y);
            $display("   Expected Output (RGB565) = 0x%h", expected_data);
            $display("   Actual Output (pix_data) = 0x%h", pix_data);

            if (pix_data == expected_data)
                $display("   --> VERRICATION PASSED: Color matches expectation.");
            else
                $display("   *** VERRICATION FAILED: Actual color 0x%h does not match expected 0x%h.", pix_data, expected_data);
        end

        $display("------------------------------------------------------------------");
        $display("T=%0t: Simulation Finished.", $time);
        $finish;
    end

    initial begin
        $dumpfile("vga_must_pic.vcd");
        $dumpvars(0, tb_vga_must_pic);
    end

endmodule
