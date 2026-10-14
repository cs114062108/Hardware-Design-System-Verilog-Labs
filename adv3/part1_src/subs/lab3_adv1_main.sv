`timescale 1ns/1ps

// -----------------------------
// Source Files:
// part1_src
//   |_ lab3_adv1.sv
//   |_ ss_dec_handler.sv
//   |_ ss_dec.sv
// utils
//   |_ clock_divider.sv
//   |_ debounce.sv
//   |_ one_pulse.sv
//   |_ timer.sv
// -----------------------------

// -----------------------------
// Modules:
// lab3_advanced_1 (lab3_adv1.sv)
//   |_ debounce (debounce.sv)
//   |_ one_pulse (one_pulse.sv)
//   |_ timer (timer.sv)
//   |_ SSDecHandler (ss_dec_handler.sv)
//        |_ one_pulse (one_pulse.sv)
//        |_ clock_divider (clock_divider.sv)
//        |_ SevenSegDec (ss_dec.sv)
// -----------------------------

module lab3_advanced_1 (
    input  logic clk,
    input  logic rst,
    input  logic [7:0] number,
    input  logic set,
    output logic [1:0] mode_state,
    output logic [7:0] DISPLAY,
    output logic [3:0] DIGIT
);

    // ----------------------------------------------
    // Debounce then One-Pulse the push button
    // ----------------------------------------------
    logic set_db;
    debounce set_debounce(.clk(clk), .pb(set), .pb_db(set_db));

    logic set_pulse;
    one_pulse set_one_pulse(.clk(clk), .pb_in(set_db), .pb_out(set_pulse));

    // ----------------------------------------------
    // State Definitions & Next State Register
    // ----------------------------------------------
    localparam INITIAL = 2'b00;
    localparam SET1    = 2'b01;
    localparam SET2    = 2'b10;
    localparam RESULT  = 2'b11;
    
    logic [1:0] state; 
    
    FSM main_fsm(
        .clk(clk),
        .rst(rst),
        .set_pulse(set_pulse),
        .state(state)
    );

    // Mirror the current state to the two leds
    assign mode_state = state;

    // ----------------------------------------------
    // Seven Segments Display Blinker
    // ----------------------------------------------
    logic blink_rst;
    assign blink_rst = rst || set_pulse;
    logic blink_enable;
    assign blink_enable = (state == SET1) || (state == SET2);

    logic blinker;

    Blinker blink(.clk(clk), .blink_rst(blink_rst), .blink_enable(blink_enable), .blinker(blinker));

    // ----------------------------------------------
    // BCD Store & Computing Logic
    // ----------------------------------------------
    logic [3:0] raw_ten, raw_one;   // Raw Input ten, Raw Input one
    assign raw_ten = number[7:4];
    assign raw_one = number[3:0];
    
    // Forces the input 2-Digit BCD to be valid
    logic [3:0] inp_ten, inp_one;   // Input ten, Input one
    BCD_Input_Filter bcd_input_filter(
        .raw_ten(raw_ten), .raw_one(raw_one),
        .inp_ten(inp_ten), .inp_one(inp_one)
    );

    logic [7:0] bcd_val1, bcd_val2; // 2-digit 8421-BCD requires 8 bits: tens in [7:4], ones in [3:0]
    BCD_Store bcd_store(
        .clk(clk), .rst(rst),
        .state(state),
        .inp_ten(inp_ten), .inp_one(inp_one),
        .bcd_val1(bcd_val1), .bcd_val2(bcd_val2)
    );

    // Convert Binary sum to 3-Digit BCD
    logic [3:0] sum_hundreds, sum_tens, sum_ones;
    BCD_adder bcd_add(
        .bcd_val1(bcd_val1), .bcd_val2(bcd_val2),
        .sum_hundreds(sum_hundreds), .sum_tens(sum_tens), .sum_ones(sum_ones)
    );
    
    // ----------------------------------------------
    // Seven Segments: val_1 val_2 val_3 val_4
    // ----------------------------------------------
    logic [3:0] dis_val1, dis_val2, dis_val3, dis_val4;
    logic       dis_dot1, dis_dot2, dis_dot3, dis_dot4;
    logic       show1, show2, show3, show4;

    assign dis_dot1 = 1'b0;
    assign dis_dot2 = 1'b0;
    assign dis_dot3 = 1'b0;
    assign dis_dot4 = 1'b0;
    
    logic [6:0] display;
    logic dp;

    SSDecHandler ss_handler (
        .clk(clk), .rst(rst),
        .val1(dis_val1), .val2(dis_val2), .val3(dis_val3), .val4(dis_val4),
        .dot1(dis_dot1), .dot2(dis_dot2), .dot3(dis_dot3), .dot4(dis_dot4),
        .show1(show1), .show2(show2), .show3(show3), .show4(show4),
        .digit(DIGIT), .display(display), .dp(dp)
    );

    // The seven display ports in the xdc file is the opposite of my handler,
    // so reverse it
    always_comb begin
        for (int i = 0; i < 7; i++) begin
            DISPLAY[i] = display[6-i];
        end
        DISPLAY[7] = dp;
    end

    // ----------------------------------------------
    // Display Value Logic: val_1 val_2 val_3 val_4
    // ----------------------------------------------
    Display_Handle display_val_logic(
        .state(state),
        .inp_ten(inp_ten), .inp_one(inp_one),
        .bcd_val1(bcd_val1), .bcd_val2(bcd_val2),
        .sum_hundreds(sum_hundreds), .sum_tens(sum_tens), .sum_ones(sum_ones),
        .blinker(blinker),
        .dis_val1(dis_val1), .dis_val2(dis_val2), .dis_val3(dis_val3), .dis_val4(dis_val4),
        .show1(show1), .show2(show2), .show3(show3), .show4(show4)
    );

endmodule

module Blinker (
    input  logic clk,
    input  logic blink_rst,
    input  logic blink_enable,
    output logic blinker
);

    logic blink_timer;
    timer #(.COUNT(50_000_000)) blink_time(.clk(clk), .rst(blink_rst), .enable(blink_enable), .tick(blink_timer));
    
    logic next_blinker;

    always_comb begin
        if (blink_rst) begin
            next_blinker = 1'b1;
        end else if (blink_enable) begin
            next_blinker = ~blinker;
        end else begin
            next_blinker = 1'b1;
        end
    end

endmodule

module BCD_Input_Filter(
    input  logic [3:0] raw_ten,
    input  logic [3:0] raw_one,
    output logic [3:0] inp_ten,
    output logic [3:0] inp_one
);

    // Forces the input 2-Digit BCD to be valid
    assign inp_ten = (raw_ten <= 4'd9) ? raw_ten : 4'd9;
    assign inp_one = (raw_one <= 4'd9) ? raw_one : 4'd9;

endmodule
