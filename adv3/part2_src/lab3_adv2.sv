`timescale 1ns/1ps

// -----------------------------
// Source Files:
// part1_src
//   |_ lab3_adv2.sv
//   |_ ss_pat_handler.sv
//   |_ ss_pat.sv
// utils
//   |_ clock_divider.sv
//   |_ debounce.sv
//   |_ one_pulse.sv
//   |_ timer.sv
// -----------------------------

module lab3_advanced_2(
    input logic clk, 
    input logic rst, 
    input logic speed,
    input logic left, 
    input logic right, 
    input logic pause,
    output logic [1:0] mode_state, 
    output logic dir,
    output logic [7:0] DISPLAY, 
    output logic [3:0] DIGIT
);

    // ----------------------------------------------------------
    // Debounce then One-Pulse the push buttons
    // ----------------------------------------------------------
    logic left_db;
    debounce left_debounce(.clk(clk), .pb(left), .pb_db(left_db));
    logic left_pulse;
    one_pulse left_one_pulse(.clk(clk), .pb_in(left_db), .pb_out(left_pulse));

    logic right_db;
    debounce right_debounce(.clk(clk), .pb(right), .pb_db(right_db));
    logic right_pulse;
    one_pulse right_one_pulse(.clk(clk), .pb_in(right_db), .pb_out(right_pulse));

    logic pause_db;
    debounce pause_debounce(.clk(clk), .pb(pause), .pb_db(pause_db));
    logic pause_pulse;
    one_pulse pause_one_pulse(.clk(clk), .pb_in(pause_db), .pb_out(pause_pulse));

    // ----------------------------------------------------------
    // State Definitions & Next State Register
    // ----------------------------------------------------------
    localparam INITIAL = 2'b00;
    localparam RUN     = 2'b01;
    localparam PAUSE   = 2'b10;

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
                next_state = RUN;
            end
            
            RUN: begin
                if (pause_pulse) begin
                    next_state = PAUSE;
                end else begin
                    next_state = RUN;
                end
            end

            PAUSE: begin
                if (pause_pulse) begin
                    next_state = RUN;
                end else begin
                    next_state = PAUSE;
                end
            end

            default: begin
                next_state = INITIAL;
            end
        endcase
    end

    // Mirror the current state to the two leds
    assign mode_state = state;

    // ----------------------------------------------------------
    // Seven Segments: val_1 val_2 val_3 val_4
    // ----------------------------------------------------------
    logic [3:0] dis_val1, dis_val2, dis_val3, dis_val4;
    logic       dis_dot1, dis_dot2, dis_dot3, dis_dot4;
    logic       show1, show2, show3, show4;

    assign dis_dot1 = 1'b0;
    assign dis_dot2 = 1'b0;
    assign dis_dot3 = 1'b0;
    assign dis_dot4 = 1'b0;
    
    logic [6:0] display;
    logic dp;

    SSPatHandler ss_handler (
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

    // ----------------------------------------------------------
    // Direction Control (left: 0, right: 1)
    // ----------------------------------------------------------
    logic next_dir;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dir <= 1'b0;
        end else begin
            dir <= next_dir;
        end
    end

    always_comb begin
        next_dir = dir;     // default: hold current direction
        if (state == RUN) begin
            if (!dir && right_pulse) begin
                next_dir = 1'b1;
            end else if (dir && left_pulse) begin
                next_dir = 1'b0;
            end
        end
    end

    // ----------------------------------------------------------
    // Marque Timer & Speed Control (0: slow 1s, 1: fast 0.5s)
    // ----------------------------------------------------------
    logic maq_rst;
    assign maq_rst = rst || (state != RUN);
    logic maq_enable;
    assign maq_enable = (state == RUN);
    
    logic slow_timer;   // 1 Hz
    logic slow_rst = maq_rst || speed;
    logic slow_enable = (maq_enable && !speed);
    timer #(.COUNT(100_000_000)) slow_time(.clk(clk), .rst(slow_rst), .enable(slow_enable), .tick(slow_timer));  // 100 MHz to 1 Hz

    logic fast_timer;   // 2 Hz
    logic fast_rst = maq_rst || !speed;
    logic fast_enable = (maq_enable && speed);
    timer #(.COUNT(50_000_000))  fast_time(.clk(clk), .rst(fast_rst), .enable(fast_enable), .tick(fast_timer));  // 100 MHz to 2 Hz

    logic maq_timer;
    assign maq_timer = (speed) ? (fast_timer) : (slow_timer);

    // ----------------------------------------------------------
    // Marque Logic
    // ----------------------------------------------------------
    localparam max_id = 4'd11;
    logic [3:0] maq_ids [3:0];
    logic [3:0] next_ids [3:0];

    always_comb begin
        // default: hold current maq state
        for (int i = 0; i < 4; i++) begin
            next_ids[i] = maq_ids[i];
        end

        if (rst) begin
            for (int i = 0; i < 4; i++) begin
                next_ids[i] = i[3:0];
            end
        end else if (state == RUN) begin
            if (!dir) begin  // direction: left, id++, round back to 0
                for (int i = 0; i < 4; i++) begin
                    next_ids[i] = (maq_ids[i] < max_id) ? (maq_ids[i] + 1'b1) : 4'd0;
                end
            end else begin   // direction: right, id--, round back to max_id
                for (int i = 0; i < 4; i++) begin
                    next_ids[i] = (maq_ids[i] > 4'd0) ? (maq_ids[i] - 1'b1) : max_id;
                end
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 4; i++) begin
                maq_ids[i] <= i[3:0];
            end
        end else if (maq_timer) begin
            for (int i = 0; i < 4; i++) begin
                maq_ids[i] <= next_ids[i];
            end
        end
    end

    // ----------------------------------------------------------
    // Display Value Logic: val_1 val_2 val_3 val_4
    // ----------------------------------------------------------
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

            RUN: begin
                dis_val1 = maq_ids[0];
                dis_val2 = maq_ids[1];
                dis_val3 = maq_ids[2];
                dis_val4 = maq_ids[3];

                show1 = 1'b1;
                show2 = 1'b1;
                show3 = 1'b1;
                show4 = 1'b1;
            end

            PAUSE: begin
                dis_val1 = maq_ids[0];
                dis_val2 = maq_ids[1];
                dis_val3 = maq_ids[2];
                dis_val4 = maq_ids[3];

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
