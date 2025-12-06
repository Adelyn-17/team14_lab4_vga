`timescale 1ns/1ps

module tb_vga_end_pic;

    reg         vga_clk;
    reg         sys_rst_n;
    reg  [9:0]  pix_x;
    reg  [9:0]  pix_y;
    wire [15:0] pix_data;

    integer i;
    reg [15:0] expected_data;

    localparam BLACK = 16'h0000;
    localparam WHITE = 16'hFFFF;

    localparam LETTER_H = 10'd80;
    localparam LETTER_W = 10'd48;
    localparam GAP      = 10'd12;
    localparam STROKE   = 10'd10;
    
    localparam TOTAL_WIDTH = 3*LETTER_W + 2*GAP; 
    localparam X_START  = 10'd320 - (TOTAL_WIDTH/2); 
    localparam Y_START  = 10'd240 - (LETTER_H/2);
    localparam CLK_PERIOD = 40;

    localparam N_X_START = X_START + LETTER_W + GAP;
    localparam D_X_START = X_START + 2*(LETTER_W + GAP); 

    reg [9:0] TEST_X [0:19];
    reg [9:0] TEST_Y [0:19];
    reg       EXPECTED_COLOR [0:19]; 

    vga_end_pic uut (
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
        // --- E (X_START=236, Y_START=200, W=48, H=80, STROKE=10) ---
        TEST_X[0] = X_START + STROKE/2;       TEST_Y[0] = Y_START + LETTER_H/2;    EXPECTED_COLOR[0] = 1; // E Left Bar
        TEST_X[1] = X_START + LETTER_W/2;     TEST_Y[1] = Y_START + STROKE/2;      EXPECTED_COLOR[1] = 1; // E Top Bar
        TEST_X[2] = X_START + LETTER_W/2;     TEST_Y[2] = Y_START + LETTER_H/2;    EXPECTED_COLOR[2] = 1; // E Middle Bar
        TEST_X[3] = X_START + LETTER_W/2;     TEST_Y[3] = Y_START + LETTER_H - 5;  EXPECTED_COLOR[3] = 1; // E Bottom Bar
        TEST_X[4] = X_START + LETTER_W - 5;   TEST_Y[4] = Y_START + 5;             EXPECTED_COLOR[4] = 0; // E Top Right Gap
        // --- N (N_X_START=296) ---
        TEST_X[5] = N_X_START + 5;            TEST_Y[5] = Y_START + 5;             EXPECTED_COLOR[5] = 1; // N Left Bar Top
        TEST_X[6] = N_X_START + LETTER_W - 5; TEST_Y[6] = Y_START + 5;             EXPECTED_COLOR[6] = 1; // N Right Bar Top
        TEST_X[7] = N_X_START + 5;            TEST_Y[7] = Y_START + LETTER_H - 5;  EXPECTED_COLOR[7] = 1; // N Left Bar Bottom
        TEST_X[8] = N_X_START + LETTER_W - 5; TEST_Y[8] = Y_START + LETTER_H - 5;  EXPECTED_COLOR[8] = 1; // N Right Bar Bottom
        TEST_X[9] = N_X_START + LETTER_W/2;   TEST_Y[9] = Y_START + LETTER_H/2;    EXPECTED_COLOR[9] = 1; // N Diagonal Center (Approx)
        TEST_X[10] = N_X_START + STROKE;      TEST_Y[10] = Y_START + STROKE;       EXPECTED_COLOR[10] = 0; // N Inner Top Gap
        // --- D (D_X_START=356) ---
        TEST_X[11] = D_X_START + STROKE/2;    TEST_Y[11] = Y_START + LETTER_H/2;   EXPECTED_COLOR[11] = 1; // D Left Bar
        TEST_X[12] = D_X_START + 25;          TEST_Y[12] = Y_START + 5;            EXPECTED_COLOR[12] = 1; // D Top Arc 
        TEST_X[13] = D_X_START + 25;          TEST_Y[13] = Y_START + LETTER_H - 5; EXPECTED_COLOR[13] = 1; // D Bottom Arc
        TEST_X[14] = D_X_START + LETTER_W - 8; TEST_Y[14] = Y_START + LETTER_H/2;   EXPECTED_COLOR[14] = 1; // D Right Arc Center (400, 240)
        TEST_X[15] = D_X_START + 15;         TEST_Y[15] = Y_START + LETTER_H/2;   EXPECTED_COLOR[15] = 0; // D Inner Gap 
        TEST_X[16] = D_X_START + LETTER_W/2;  TEST_Y[16] = Y_START + 5;            EXPECTED_COLOR[16] = 0; // D Top Right Corner Gap (Not part of bar)
        // --- Gaps and Outer Space ---
        TEST_X[17] = X_START + LETTER_W + STROKE; TEST_Y[17] = Y_START + LETTER_H/2; EXPECTED_COLOR[17] = 0; // Gap between E and N
        TEST_X[18] = N_X_START + LETTER_W + STROKE; TEST_Y[18] = Y_START + LETTER_H/2; EXPECTED_COLOR[18] = 0; // Gap between N and D
        TEST_X[19] = 10'd10;                  TEST_Y[19] = 10'd10;                 EXPECTED_COLOR[19] = 0; // Far outside (Black background)

        sys_rst_n = 1'b0; 
        pix_x = 10'd0;
        pix_y = 10'd0;
        $display("------------------------------------------------------------------");
        $display("T=%0t: System Reset Asserted. Waiting for stabilization...", $time);

        #(CLK_PERIOD * 2.5) sys_rst_n = 1'b1; 
        $display("T=%0t: System Reset Deasserted. Start testing 'END' logic...", $time);
 
        for (i = 0; i < 20; i = i + 1) begin

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
        $display("T=%0t: Simulation Finished. Total time is appropriate for key points check.", $time);
        $finish;
    end

    initial begin
        $dumpfile("vga_end_pic.vcd");
        $dumpvars(0, tb_vga_end_pic);
    end

endmodule
