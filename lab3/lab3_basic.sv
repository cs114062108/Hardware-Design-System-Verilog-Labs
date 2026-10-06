module lab3_basic (
    input logic clk,
    input logic rst,
    input logic speed,
    input logic end_count,
    output logic [15:0] led
);

    localparam INITIAL = 2'b00;
    localparam PLAY = 2'b01;
    localparam FINISH = 2'b10;

    // add your design here
    logic [1:0] state;
    logic [1:0] next_state;

    // You can uncomment and utilize the following modules as needed
    logic fast_timer, slow_timer;

    timer #(
        .COUNT(25_000_000)
    ) timer_fast (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .tick(fast_timer)
    );

    timer #(
        .COUNT(50_000_000)
    ) timer_slow (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .tick(slow_timer)
    );

    logic fin_clk;
    logic is_fin;
    assign is_fin = state == FINISH;
    logic fin_rst;
    assign fin_rst = rst || !is_fin;

    clock_divider #(
        .n(27)
    ) clock_finish (
        .clk(clk),
        .rst(fin_rst),
        .enable(is_fin),
        .clk_div(fin_clk)
    );

    // ---------------------------------------------------
    logic end_play;
    logic next_end_play;
    
    logic [11:0] runner;
    logic seperator;
    logic [2:0] counter;

    assign seperator = state == PLAY;

    logic [2:0] cnt;
    logic [2:0] next_cnt;

    always_comb begin
        case (cnt)
            2'd0: counter = 3'b000;
            2'd1: counter = 3'b100;
            2'd2: counter = 3'b110;
            2'd3: counter = 3'b111;
            default: counter = 3'b000;
        endcase
    end

    logic [11:0] next_runner;
    logic runner_timer;
    assign runner_timer = (!speed) ? slow_timer : fast_timer;

    logic [3:0] runner_cnt;
    logic [3:0] next_runner_cnt;

    always_comb begin
        if (state == PLAY) begin
            next_runner_cnt = (runner_cnt < 4'd11) ? runner_cnt + 1'b1 : 4'd0;
            if (cnt < 3'd4) begin
                next_cnt = (runner_cnt == 4'd11) ? cnt + 1'b1 : cnt;
            end else begin
                next_cnt = 3'd4;
            end
            next_end_play = (next_cnt == 3'd4);
        end else begin
            next_runner_cnt = 4'd0;
            next_cnt = 3'd0;
            next_end_play = 1'b0;
        end
    end

    always_comb begin
        for (int i = 0; i < 12; i++) begin
            runner[i] = runner_cnt == i;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            runner_cnt <= 4'd0;
            cnt <= 3'd0;
            end_play <= 1'b0;
        end else if (runner_timer) begin
            runner_cnt <= next_runner_cnt;
            cnt <= next_cnt;
            end_play <= next_end_play;
        end else if (state != PLAY) begin
            runner_cnt <= 4'd0;
            cnt <= 3'd0;
            end_play <= 1'b0;
        end
    end
    // ---------------------------------------------------

    // ---------------------------------------------------
    logic [15:0] fin_led;
    logic end_fin;
    logic next_end_fin;

    logic [2:0] flash_cnt;
    logic [2:0] next_flash_cnt;

    always_comb begin
        fin_led = (flash_cnt[0]) ? 16'hffff : 16'd0;
    end

    always_comb begin
        if (state == FINISH) begin
            next_flash_cnt = (flash_cnt < 3'd6) ? flash_cnt + 1'b1 : 3'd6;
            next_end_fin = next_flash_cnt == 3'd6;
        end else begin
            next_end_fin = 1'b0;
            next_flash_cnt = 3'd0;
        end
    end

    always_ff @(posedge fin_clk, posedge fin_rst) begin
        if (fin_rst) begin
            flash_cnt <= 3'd0;
            end_fin <= 1'b0;
        end else if (state == FINISH) begin
            flash_cnt <= next_flash_cnt;
            end_fin <= next_end_fin;
        end else begin
            flash_cnt <= 3'd0;
            end_fin <= 1'b0;
        end
    end

    // ---------------------------------------------------

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
                next_state = PLAY;
                led = 16'd0;
            end

            PLAY: begin
                led = {counter, seperator, runner};
                if (end_count || end_play) begin
                    next_state = FINISH;
                end else begin
                    next_state = PLAY;
                end
            end

            FINISH: begin
                led = fin_led;
                if (end_fin) begin
                    next_state = INITIAL;
                end else begin
                    next_state = FINISH;
                end
            end

            default: begin
                led = 16'd0;
                next_state = INITIAL;
            end
        endcase
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

module clock_divider #(
    parameter n = 10
)(
    input logic clk,
    input logic rst,
    input logic enable,
    output logic clk_div
);

    logic [n-1:0] num;
    logic [n-1:0] next_num;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            num <= {n{1'b0}};
        end else begin
            num <= next_num;
        end
    end

    assign next_num = (enable == 1'b1) ? num + 1'b1 : {n{1'b0}};
    assign clk_div = num[n-1];
endmodule
