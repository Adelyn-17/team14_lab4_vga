`timescale 1ns/1ps

module vga_bar_pic(
    input  wire        vga_clk,
    input  wire        sys_rst_n,
    input  wire [9:0]  pix_x,
    input  wire [9:0]  pix_y,
    output reg  [15:0] pix_data
);

    // 定义10个色条的颜色（RGB565格式）
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
    
    // 屏幕参数（假设640x480分辨率）
    localparam SCREEN_WIDTH  = 10'd640;
    localparam SCREEN_HEIGHT = 10'd480;
    
    // 色条参数
    localparam NUM_BARS = 10;                    // 10个色条
    localparam BAR_WIDTH = SCREEN_WIDTH / NUM_BARS; // 每个色条宽度：64像素

    // 根据当前像素的x坐标确定属于哪个色条
    wire [3:0] bar_index;
    assign bar_index = pix_x / BAR_WIDTH;

    // 根据色条索引选择颜色
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            pix_data <= 16'h0000; // 复位时为黑色
        else begin
            case (bar_index)
                4'd0: pix_data <= COLOR_0;
                4'd1: pix_data <= COLOR_1;
                4'd2: pix_data <= COLOR_2;
                4'd3: pix_data <= COLOR_3;
                4'd4: pix_data <= COLOR_4;
                4'd5: pix_data <= COLOR_5;
                4'd6: pix_data <= COLOR_6;
                4'd7: pix_data <= COLOR_7;
                4'd8: pix_data <= COLOR_8;
                4'd9: pix_data <= COLOR_9;
                default: pix_data <= 16'h0000; // 默认为黑色
            endcase
        end
    end

endmodule