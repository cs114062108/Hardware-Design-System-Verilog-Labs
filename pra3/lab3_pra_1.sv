`timescale 1ns/1ps

// ----------------------------------------------------------------------
// Required bonus files: 
// ss_dec_handler_0.sv 
//   |_ ss_dec.sv 
//   |_ XX clock_divider.sv
// ----------------------------------------------------------------------

module lab3_pra1 (
    input logic clk,
    input logic rst,
    input logic slow,
    input logic fast,
    input logic end_light,
    output logic [15:0] led,
    output logic [3:0] digit,
    output logic [6:0] display,
    output logic dp
);

    // --------------------------------------------
    // Values to be displayed
    // --------------------------------------------
    logic [1:0]  state;
    logic [4:0]  led_cnt;
    logic [2:0]  flash_cnt;
    logic slow_clk, fast_clk;

    pra3_mod0 mod0(
        .clk(clk), .rst(rst), .slow(slow), .fast(fast), .end_light(end_light), .led(led),
        .state(state), .led_cnt(led_cnt), .flash_cnt(flash_cnt),
        .slow_clk(slow_clk), .fast_clk(fast_clk)
    );

    // --------------------------------------------
    // Define states
    // --------------------------------------------
    localparam INIT  = 2'b00;
    localparam LOAD  = 2'b01;
    localparam PLAY  = 2'b10;
    localparam FINAL = 2'b11;

    // ------------------------------------------------------------
    // Display Values on Seven Segments: val_1 val_2 val_3 val_4
    // ------------------------------------------------------------
    logic [3:0] dis_val1, dis_val2, dis_val3, dis_val4;
    logic       dis_dot1, dis_dot2, dis_dot3, dis_dot4;

    SSDecHandler0 ss_handler (
        .clk(clk), .rst(rst),
        .val1(dis_val1), .val2(dis_val2), .val3(dis_val3), .val4(dis_val4),
        .dot1(dis_dot1), .dot2(dis_dot2), .dot3(dis_dot3), .dot4(dis_dot4),
        .digit(digit), .display(display), .dp(dp)
    );
    
    always_comb begin
        case (state)
            INIT: begin
                dis_val1 = state[1];
                dis_val2 = state[0];
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                dis_dot1 = 1'b0;
                dis_dot2 = 1'b0;
                dis_dot3 = 1'b0;
                dis_dot4 = 1'b0;
            end

            LOAD: begin
                dis_val1 = state[1];
                dis_val2 = state[0];
                dis_val3 = {3'b000, led_cnt[4]};
                dis_val4 = led_cnt[3:0];

                dis_dot1 = 1'b0;
                dis_dot2 = 1'b0;
                dis_dot3 = 1'b1;
                dis_dot4 = 1'b1;
            end
            
            PLAY: begin
                dis_val1 = state[1];
                dis_val2 = state[0];
                dis_val3 = {3'b000, fast};
                dis_val4 = {3'b000, slow};

                dis_dot1 = 1'b0;
                dis_dot2 = 1'b0;
                dis_dot3 = fast_clk;
                dis_dot4 = slow_clk;
            end
            
            FINAL: begin
                dis_val1 = state[1];
                dis_val2 = state[0];
                dis_val3 = 4'd0;
                dis_val4 = {2'b00, flash_cnt};

                dis_dot1 = 1'b0;
                dis_dot2 = 1'b0;
                dis_dot3 = 1'b1;
                dis_dot4 = 1'b1;
            end

            default: begin
                dis_val1 = 4'd0;
                dis_val2 = 4'd0;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                dis_dot1 = 1'b0;
                dis_dot2 = 1'b0;
                dis_dot3 = 1'b0;
                dis_dot4 = 1'b0;
            end

        endcase
    end

endmodule
