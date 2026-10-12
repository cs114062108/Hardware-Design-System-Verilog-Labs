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

module debounce #(
    parameter n = 4
) (
    output logic pb_db, // output after being debounced
    input  logic pb,    // input from a pushbutton
    input  logic clk
);

    logic [n-1:0] shift_reg;  // use shift_reg to filter the bounce

    always_ff @(posedge clk) begin
        shift_reg <= {shift_reg[n-2:0], pb};
    end

    assign pb_db = (shift_reg == {n{1'b1}}) ? 1'b1 : 1'b0;

endmodule

module one_pulse (
    input  logic clk,
    input  logic pb_in,
    output logic pb_out
);

	logic pb_in_delay;

	always_ff @(posedge clk) begin
		pb_out <= (pb_in & ~pb_in_delay);
		pb_in_delay <= pb_in;
	end
	
endmodule

module timer #(
    parameter integer COUNT = 100_000_000
)(
    input logic clk,
    input logic rst,
    input logic enable,
    output logic tick
);

    logic [31:0] num;
    logic [31:0] next_num;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            num <= 32'd0;
        end else begin
            num <= next_num;
        end
    end

    assign next_num = (enable == 1'b0) ? 32'd0 :
                      (num == COUNT - 1) ? 32'd0 :
                      num + 1'b1;
    assign tick = enable && (num == COUNT - 1);
    
endmodule

module SSDecHandler #(
    parameter n = 16
) (
    input logic clk,
    input logic rst,
    input logic [3:0] val1,
    input logic [3:0] val2,
    input logic [3:0] val3,
    input logic [3:0] val4,
    input logic dot1,
    input logic dot2,
    input logic dot3,
    input logic dot4,
    input logic show1,
    input logic show2,
    input logic show3,
    input logic show4,
    output logic [3:0] digit,
    output logic [6:0] display,
    output logic dp
);

    logic rst_pulse;
    one_pulse pulse(.clk(clk), .pb_in(rst), .pb_out(rst_pulse));
    
    logic div_clk;
    clock_divider #(.n(n)) clk_divide(
        .clk(clk), .rst(rst_pulse), .enable(1'b1), .clk_div(div_clk)
    );

    logic [7:0] dis_1;
    logic [7:0] dis_2;
    logic [7:0] dis_3;
    logic [7:0] dis_4;

    logic dp_1;
    logic dp_2;
    logic dp_3;
    logic dp_4;

    SevenSegDec SS1(.value(val1), .dot(dot1), .show(show1), .display(dis_1), .dp(dp_1));
    SevenSegDec SS2(.value(val2), .dot(dot2), .show(show2), .display(dis_2), .dp(dp_2));
    SevenSegDec SS3(.value(val3), .dot(dot3), .show(show3), .display(dis_3), .dp(dp_3));
    SevenSegDec SS4(.value(val4), .dot(dot4), .show(show4), .display(dis_4), .dp(dp_4));
    
    localparam FISRT  = 4'b0111;
    localparam SECOND = 4'b1011;
    localparam THIRD  = 4'b1101;
    localparam FOURTH = 4'b1110;

    logic [3:0] val;
    logic [3:0] next_digit;

    always_ff @(posedge div_clk) begin
        digit <= next_digit;
    end

    always_comb begin
        case (digit)
            FISRT: begin
               display = dis_1;
               dp = dp_1;
               val = 4'd1;
               next_digit = SECOND;
            end

            SECOND: begin
                display = dis_2;
                dp = dp_2;
                val = 4'd2;
                next_digit = THIRD;
            end

            THIRD: begin
                display = dis_3;
                dp = dp_3;
                val = 4'd3;
                next_digit = FOURTH;
            end

            FOURTH: begin
                display = dis_4;
                dp = dp_4;
                val = 4'd4;
                next_digit = FISRT;
            end

            default: begin
                display = 7'b111_1111;
                dp = 1'b1;
                val = 4'd0;
                next_digit = FISRT;
            end
        endcase
    end

endmodule

module SevenSegDec (
    input  logic [3:0] value,
    input  logic dot,
    input  logic show,
    output logic [7:0] display,
    output logic dp
);
    
    always_comb begin
        if (show) begin
            case (value)
                // Zero means on:  ABC_DEFG
                4'd0: display = 7'b000_0001;
                4'd1: display = 7'b100_1111;
                4'd2: display = 7'b001_0010;
                4'd3: display = 7'b000_0110;
                4'd4: display = 7'b100_1100;
                4'd5: display = 7'b010_0100;
                4'd6: display = 7'b010_0000;
                4'd7: display = 7'b000_1111;
                4'd8: display = 7'b000_0000;
                4'd9: display = 7'b000_0100;

                // I'm just gonna write the hex part here,
                // cause I don't wanna write a new module 
                // with almost the save logic except these mappings
                // Zero means on:  ABC_DEFG
                4'ha: display = 7'b000_1000;
                4'hb: display = 7'b110_0000;
                4'hc: display = 7'b011_0001;
                4'hd: display = 7'b100_0010;
                4'he: display = 7'b011_0000;
                4'hf: display = 7'b011_1000;

                default: display = 7'b111_1110;
            endcase
        end else begin
            display = 7'b111_1111;
        end
    end

    assign dp = ~dot;

endmodule
