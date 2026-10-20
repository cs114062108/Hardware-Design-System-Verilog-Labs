// You can change anything in the template, except the module I/O of lab4_basic.
typedef enum logic [1:0] {
    IDLE,
    PLAY,
    FINAL
} state_t;

// parameter IDLE = 2'd0;
// parameter PLAY = 2'd1;
// parameter FINAL = 2'd2;

module lab4_basic (
    input logic clk,
    input logic rst,
    input logic btnL,
    input logic btnR,
    input logic btnD,
    input logic btnU,
    output logic [6:0] DISPLAY,
    output logic [3:0] DIGIT,
    output logic [15:0] LED
);
    
    logic left_db, right_db, down_db, up_db;
    debounce debounce_left (.pb_debounced(left_db), .pb(btnL), .clk(clk));
    debounce debounce_right (.pb_debounced(right_db), .pb(btnR), .clk(clk));
    debounce debounce_down (.pb_debounced(down_db), .pb(btnD), .clk(clk));
    debounce debounce_up (.pb_debounced(up_db), .pb(btnU), .clk(clk));

    logic left_op, right_op, down_op, up_op;
    one_pulse one_pulse_left (.clk(clk), .pb_in(left_db), .pb_out(left_op));
    one_pulse one_pulse_right (.clk(clk), .pb_in(right_db), .pb_out(right_op));
    one_pulse one_pulse_down (.clk(clk), .pb_in(down_db), .pb_out(down_op));
    one_pulse one_pulse_up (.clk(clk), .pb_in(up_db), .pb_out(up_op));

    parameter DIR_LEFT = 2'b00;
    parameter DIR_RIGHT = 2'b01;
    parameter DIR_DOWN = 2'b10;
    parameter DIR_UP = 2'b11;
    parameter ONE_SEC = 27'd100_000_000;
    

    state_t state, next_state;
    logic [3:0] score;
    logic [3:0] lfsr;

    logic [3:0] next_lfsr;
    always_comb begin
        logic x03;
        x03 = lfsr[0] ^ lfsr[3];

        next_lfsr = {lfsr[2:0], x03};
    end

    logic [1:0] dir;
    assign dir = lfsr[1:0];

    localparam Left  = 2'b00;
    localparam Right = 2'b01;
    localparam Down  = 2'b10;
    localparam Up    = 2'b11;

    logic correct;
    logic wrong;
    logic success, next_success;

    always_comb begin
        if (state == PLAY) begin
            next_success = score == 4'd4;
            case (dir)
                Left: begin
                    correct = left_op;
                    wrong = right_op || down_op || up_op;
                end

                Right: begin
                    correct = right_op;
                    wrong = left_op || down_op || up_op;
                end

                Down: begin
                    correct = down_op;
                    wrong = left_op || right_op || up_op;
                end

                Up: begin
                    correct = up_op;
                    wrong = left_op || right_op || down_op;
                end
                
                default: begin
                    correct = 1'b0;
                    wrong = 1'b0;
                end
            endcase
        end else begin
            correct = 1'b0;
            wrong = 1'b0;
            next_success = 1'b0;
        end
    end
    

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            state <= IDLE;
            score <= 4'd0;
            lfsr <= 4'b0001;
            success <= 1'b0;
        end else begin
            state <= next_state;
            if (state == IDLE) begin
                if (right_op) begin
                    lfsr <= next_lfsr;
                end
                score <= 4'd0;
                success <= 1'b0;
            end else if (state == PLAY) begin
                if (!success) begin
                    success <= next_success;
                end
                if (correct) begin
                    lfsr <= next_lfsr;
                    score <= score + 1'b1;
                end
            end
        end
    end

    logic [15:0] fin_led;
    logic fin_end, next_fin_end;
    logic fin_timer;

    logic fin_rst;
    assign fin_rst = rst || state != FINAL;
    logic fin_enable;
    assign fin_enable = state == FINAL;

    timer fin_time(.clk(clk), .rst(fin_rst), .enable(fin_enable), .tick(fin_timer));

    logic [3:0] fin_cnt, next_fin_cnt;

    always_ff @(posedge clk or posedge fin_rst) begin
        if (fin_rst) begin
            fin_cnt <= 4'd0;
            fin_end <= 1'b0;
        end else if (fin_timer) begin
            fin_cnt <= next_fin_cnt;
            fin_end <= next_fin_end;
        end
    end

    always_comb begin
        next_fin_cnt = (fin_cnt < 4'd3) ? (fin_cnt + 1'b1) : 4'd3;
        next_fin_end = next_fin_cnt == 4'd3 && state == FINAL;
        if (success) begin
            fin_led = (!fin_cnt[0]) ? 16'hffff : 16'd0;
        end else begin
            fin_led = 16'hffff;
        end
    end

    logic [3:0] dis_num1, dis_num2, dis_num3, dis_num4;

    always_comb begin 
        case (state)
            IDLE: begin
                dis_num1 = 4'd0;
                dis_num2 = 4'd0;
                dis_num3 = 4'd0;
                dis_num4 = score;

                LED[3:0] = lfsr;
                LED[4] = 1'b0;
                LED[6:5] = 2'b00;
                LED[15:7] = 9'd0;

                if (up_op) begin
                    next_state = PLAY;
                end else begin
                    next_state = IDLE;
                end
            end
            
            PLAY: begin
                dis_num1 = 4'd0;
                dis_num2 = 4'd0;
                dis_num3 = 4'd0;
                dis_num4 = score;

                LED[3:0] = lfsr;
                LED[4] = 1'b0;
                LED[6:5] = dir;
                LED[15:7] = 9'd0;

                if (wrong || success) begin
                    next_state = FINAL;
                end else begin
                    next_state = PLAY;
                end
            end
            
            FINAL: begin
                dis_num1 = 4'd0;
                dis_num2 = 4'd0;
                dis_num3 = 4'd0;
                dis_num4 = score;

                //dis_num1 = fin_cnt; // [PLEASE COMMENT ME]: For debugging only
                
                LED = fin_led;

                if (fin_end) begin
                    next_state = IDLE;
                end else begin
                    next_state = FINAL;
                end
            end 
            
            default: begin
                dis_num1 = 4'd0;
                dis_num2 = 4'd0;
                dis_num3 = 4'd0;
                dis_num4 = 4'd0;

                LED[3:0] = lfsr;
                LED[4] = 1'b0;
                LED[6:5] = 2'b00;
                LED[15:7] = 9'd0;

                next_state = IDLE;
            end
        endcase
    end

    // display_nums logic
    logic [15:0] display_nums;
    assign display_nums = {dis_num1, dis_num2, dis_num3, dis_num4};

    SevenSegment seven_seg (
        .display(DISPLAY),
        .digit(DIGIT),
        .nums(display_nums),
        .rst(rst),
        .clk(clk)
    );

endmodule


module timer #(
    parameter COUNT = 100_000_000
) (
    input clk,
    input rst,
    input enable,
    output tick
);

    logic [31:0] cnt;
    logic [31:0] next_cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 32'd0;
        end else begin
            cnt <= next_cnt;
        end
    end

    always_comb begin
        if (!enable) begin
            next_cnt = 32'd0;
        end else begin
            next_cnt = (cnt < COUNT - 1) ? (cnt + 1'b1) : (COUNT - 1);
        end
    end

    assign tick = enable && (cnt == (COUNT - 1));

endmodule