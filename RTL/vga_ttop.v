`timescale 1ns/1ps

module vga_ttop(
    input  wire        sys_clk, 
    input  wire        sys_rst_n, 
    input  wire        btn_next, 
    output wire        hsync, 
    output wire        vsync, 
    output wire [15:0] rgb       
);
    wire        vga_clk;        
    wire [9:0]  pix_x;       
    wire [9:0]  pix_y;     
    wire [15:0] pix_data;      
    wire [15:0] bar_data;
    wire [15:0] must_data;
    wire [15:0] end_data;

   
    parameter S_BAR = 2'b00;
    parameter S_MUST      = 2'b01;
    parameter S_END       = 2'b10;

 
    reg [1:0] current_state;
    reg [1:0] next_state;

    reg [19:0] debounce_cnt;
    reg        key_reg0, key_reg1, key_reg2;
    wire       key_posedge;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            key_reg0 <= 1'b1;
            key_reg1 <= 1'b1;
            key_reg2 <= 1'b1;
        end else begin
            key_reg0 <= btn_next;
            key_reg1 <= key_reg0;
            key_reg2 <= key_reg1;
        end
    end
assign key_posedge = (key_reg1 == 1'b0) && (key_reg2 == 1'b1); 


    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            current_state <= S_BAR;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S_BAR: next_state = key_posedge ? S_MUST : S_BAR;
            S_MUST:      next_state = key_posedge ? S_END  : S_MUST;
            S_END:       next_state = key_posedge ? S_BAR : S_END;
            default:     next_state = S_BAR;
        endcase
    end


    pll pll_inst (
        .sys_clk  (sys_clk),
        .sys_rst_n(sys_rst_n),
        .vga_clk  (vga_clk)
    );


    vga_bar_pic vga_bar_pic_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x    (pix_x),
	     .pix_y    (pix_y),
        .pix_data (bar_data)
    );


    vga_must_pic vga_must_pic_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x    (pix_x),
        .pix_y    (pix_y),
        .pix_data (must_data)
    );

 
    vga_end_pic vga_end_pic_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x    (pix_x),
        .pix_y    (pix_y),
        .pix_data (end_data)
    );


    vga_ctrl vga_ctrl_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_data (pix_data),
        .pix_x    (pix_x),
        .pix_y    (pix_y),
        .hsync    (hsync),
        .vsync    (vsync),
        .rgb      (rgb)
    );

    assign pix_data = (current_state == S_BAR) ? bar_data :
                      (current_state == S_MUST)      ? must_data  :
                      (current_state == S_END)       ? end_data   :
                                                       16'h0000;

endmodule