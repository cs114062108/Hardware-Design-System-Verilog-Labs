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

    logic [1:0] state, next_state;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= INITIAL;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            INITIAL: begin
                next_state = SET1;
            end

            SET1: begin
                if (set_pulse) begin
                    next_state = SET2;
                end else begin
                    next_state = SET1;
                end
            end

            SET2: begin
                if (set_pulse) begin
                    next_state = RESULT;
                end else begin
                    next_state = SET2;
                end
            end

            RESULT: begin
                if (set_pulse) begin
                    next_state = SET1;
                end else begin
                    next_state = RESULT;
                end
            end

            default: begin
                next_state = INITIAL;
            end
        endcase
    end

    // Mirror the current state to the two leds
    assign mode_state = state;

    // ----------------------------------------------
    // Seven Segments Display Blinker
    // ----------------------------------------------
    logic blink_timer;
    logic blink_rst;
    assign blink_rst = rst || set_pulse;
    logic blink_enable;
    assign blink_enable = (state == SET1) || (state == SET2);
    timer #(.COUNT(50_000_000)) blink_time(.clk(clk), .rst(blink_rst), .enable(blink_enable), .tick(blink_timer));

    logic blinker;
    logic next_blinker;

    always_comb begin
        if (rst) begin
            next_blinker = 1'b1;
        end else if (blink_enable) begin
            next_blinker = ~blinker;
        end else begin
            next_blinker = 1'b1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            blinker <= 1'b1;
        end else if (blink_timer) begin
            blinker <= next_blinker;
        end else if (!blink_enable) begin
            blinker <= 1'b1;
        end
    end

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
    // Computing Logic
    // ----------------------------------------------
    logic [3:0] raw_ten, raw_one;   // Raw Input ten, Raw Input one
    assign raw_ten = number[7:4];
    assign raw_one = number[3:0];
    
    // Forces the input 2-Digit BCD to be valid
    logic [3:0] inp_ten, inp_one;   // Input ten, Input one
    assign inp_ten = (raw_ten <= 4'd9) ? raw_ten : 4'd9;
    assign inp_one = (raw_one <= 4'd9) ? raw_one : 4'd9;

    logic [7:0] bcd_val1, bcd_val2; // 2-digit 8421-BCD requires 8 bits: tens in [7:4], ones in [3:0]

    // Get input values and latch them
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            bcd_val1 <= 8'd0;
            bcd_val2 <= 8'd0;
        end else if (state == INITIAL) begin
            bcd_val1 <= 8'd0;
            bcd_val2 <= 8'd0;
        end else begin
            if (state == SET1) begin
                bcd_val1 <= {inp_ten, inp_one};
            end else if (state == SET2) begin
                bcd_val2 <= {inp_ten, inp_one};
            end
        end
    end

    // Convert BCD value to 8-bit Binary
    logic [7:0] bin_val1, bin_val2; // Max input value is 99, max sum is 198, requires 8 bit
    assign bin_val1 = {4'd0, bcd_val1[7:4]} * 8'd10 + {4'd0, bcd_val1[3:0]};
    assign bin_val2 = {4'd0, bcd_val2[7:4]} * 8'd10 + {4'd0, bcd_val2[3:0]};

    // Sum in Binary
    logic [7:0] bin_sum;
    assign bin_sum = bin_val1 + bin_val2;

    // Convert Binary sum to 3-Digit BCD
    logic [3:0] sum_hundreds, sum_tens, sum_ones;
    assign sum_hundreds = bin_sum / 100;
    assign sum_tens     = (bin_sum % 100) / 10;
    assign sum_ones     = bin_sum % 10;

    // ----------------------------------------------
    // Display Value Logic: val_1 val_2 val_3 val_4
    // ----------------------------------------------
    always_comb begin
        case (state)
            INITIAL: begin
                dis_val1 = 4'd0;
                dis_val2 = 4'd0;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                show1 = 1'b0;
                show2 = 1'b0;
                show3 = 1'b0;
                show4 = 1'b0;
            end

            SET1: begin
                dis_val1 = inp_ten;         // Live values from switches
                dis_val2 = inp_one;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                show1 = blinker;
                show2 = blinker;
                show3 = 1'b1;
                show4 = 1'b1;
            end

            SET2: begin
                dis_val1 = bcd_val1[7:4];   // BCD Value 1, already locked
                dis_val2 = bcd_val1[3:0];
                dis_val3 = inp_ten;         // Live values from switches
                dis_val4 = inp_one;

                show1 = 1'b1;
                show2 = 1'b1;
                show3 = blinker;
                show4 = blinker;
            end

            RESULT: begin
                dis_val1 = 4'd0;
                dis_val2 = sum_hundreds;
                dis_val3 = sum_tens;
                dis_val4 = sum_ones;

                show1 = 1'b1;
                show2 = 1'b1;
                show3 = 1'b1;
                show4 = 1'b1;
            end

            default: begin
                dis_val1 = 4'd0;
                dis_val2 = 4'd0;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                show1 = 1'b0;
                show2 = 1'b0;
                show3 = 1'b0;
                show4 = 1'b0;
            end
        endcase
    end

endmodule
