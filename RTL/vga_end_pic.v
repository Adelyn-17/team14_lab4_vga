`timescale 1ns/1ps

module vga_end_pic(
    input  wire        vga_clk,
    input  wire        sys_rst_n,
    input  wire [9:0]  pix_x,
    input  wire [9:0]  pix_y,
    output reg  [15:0] pix_data
);

    localparam BLACK  = 16'h0000;
    localparam WHITE  = 16'hFFFF;
    
    // 放大字母尺寸（保持原宽高比）
    localparam LETTER_H = 10'd80;    // 原50 → 放大到80
    localparam LETTER_W = 10'd48;    // 原30 → 按比例放大到48（宽高比≈1.67）
    localparam GAP      = 10'd12;    // 原8 → 按比例放大到12
    localparam STROKE   = 10'd10;    // 原6 → 按比例放大到10（保持笔画比例）

    // 重新计算居中位置（640x480屏幕正中央）
    localparam TOTAL_WIDTH  = 3*LETTER_W + 2*GAP;  // 总宽度：3*48+2*12=168
    localparam X_START      = 10'd320 - (TOTAL_WIDTH/2);  // 居中X起始：320-84=236
    localparam Y_START      = 10'd240 - (LETTER_H/2);     // 居中Y起始：240-40=200


    // -------------------------- 字母区域定义（自动适配放大尺寸） --------------------------
    wire in_e_box = (pix_x >= X_START) && (pix_x < X_START + LETTER_W) &&
                    (pix_y >= Y_START) && (pix_y < Y_START + LETTER_H);
                    
    wire in_n_box = (pix_x >= X_START + LETTER_W + GAP) && 
                    (pix_x < X_START + 2*LETTER_W + GAP) &&
                    (pix_y >= Y_START) && (pix_y < Y_START + LETTER_H);
                    
    wire in_d_box = (pix_x >= X_START + 2*(LETTER_W + GAP)) && 
                    (pix_x < X_START + 3*LETTER_W + 2*GAP) &&
                    (pix_y >= Y_START) && (pix_y < Y_START + LETTER_H);


    // -------------------------- 绘制字母E（适配放大尺寸） --------------------------
    wire draw_e = in_e_box && (
        (pix_x < X_START + STROKE) ||
        (pix_y < Y_START + STROKE) ||
        (pix_y > Y_START + LETTER_H - STROKE) ||
        (pix_y > Y_START + LETTER_H/2 - STROKE/2 && pix_y < Y_START + LETTER_H/2 + STROKE/2)
    );


    // -------------------------- 绘制字母N（加粗斜线+适配放大尺寸） --------------------------
    wire [9:0] n_x_base = X_START + LETTER_W + GAP;
    wire [9:0] n_x_off = pix_x - n_x_base;
    wire [9:0] n_y_off = pix_y - Y_START;
    // 斜线宽度与笔画宽度一致
    wire n_diag = (n_y_off >= (LETTER_H * n_x_off) / LETTER_W - (STROKE/2)) &&
                  (n_y_off <= (LETTER_H * n_x_off) / LETTER_W + (STROKE/2));

    wire draw_n = in_n_box && (
        (pix_x < n_x_base + STROKE) ||
        (pix_x > n_x_base + LETTER_W - STROKE) ||
        n_diag
    );


    // -------------------------- 绘制字母D（适配放大尺寸） --------------------------
    wire [9:0] d_x_base = X_START + 2*(LETTER_W + GAP);
    wire d_left  = (pix_x >= d_x_base) && (pix_x < d_x_base + STROKE);
    wire d_top   = (pix_y >= Y_START) && (pix_y < Y_START + STROKE) && 
                   (pix_x >= d_x_base) && (pix_x < d_x_base + STROKE);
    wire d_bottom= (pix_y >= Y_START + LETTER_H - STROKE) && (pix_y < Y_START + LETTER_H) && 
                   (pix_x >= d_x_base) && (pix_x < d_x_base + STROKE);

    wire [9:0] d_arc_cx = d_x_base + STROKE;
    wire [9:0] d_arc_cy = Y_START + LETTER_H/2;
    wire [9:0] d_arc_r = LETTER_H/2;  // 弧形半径随字母高度放大
    wire [19:0] dx_sq = (pix_x - d_arc_cx) * (pix_x - d_arc_cx);
    wire [19:0] dy_sq = (pix_y - d_arc_cy) * (pix_y - d_arc_cy);
    wire d_right_arc = (dx_sq + dy_sq <= d_arc_r * d_arc_r) && 
                       (dx_sq + dy_sq >= (d_arc_r - STROKE) * (d_arc_r - STROKE));

    wire draw_d = in_d_box && (d_left || d_top || d_bottom || d_right_arc);


    // -------------------------- 输出像素 --------------------------
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            pix_data <= BLACK;
        else
            pix_data <= (draw_e || draw_n || draw_d) ? WHITE : BLACK;
    end

endmodule