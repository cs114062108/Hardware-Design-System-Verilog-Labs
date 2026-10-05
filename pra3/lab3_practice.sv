`timescale 1ns/1ps

module lab3_practice (
    input logic clk,
    input logic rst,
    input logic slow,
    input logic fast,
    input logic end_light,
    output logic [15:0] led
);
    /* Output ports are declared as logic in SystemVerilog. */

    // add your design here

    // --------------------------------------------
    // Define states
    // --------------------------------------------
    localparam INIT  = 2'b00;
    localparam LOAD  = 2'b01;
    localparam PLAY  = 2'b10;
    localparam FINAL = 2'b11;

    logic [3:0] state;
    logic [3:0] next_state;

    // --------------------------------------------
    // Divided clocks
    // --------------------------------------------
    logic slow_clk, fast_clk;

    clock_divider #(.n(28)) slow_div(.clk(clk), .rst(rst), .enable(1'b1), .clk_div(slow_clk));
    clock_divider #(.n(27)) fast_div(.clk(clk), .rst(rst), .enable(1'b1), .clk_div(fast_clk));

    logic load_clk;
    clock_divider #(.n(24)) led_div(.clk(clk), .rst(rst), .enable(1'b1), .clk_div(load_clk));

    // --------------------------------------------
    // Led load
    // --------------------------------------------
    logic [15:0] loading_led;
    logic loaded, next_loaded;
    logic [3:0] led_cnt;      // Counts from 0 to 15, represents 16 leds
    logic [3:0] next_led_cnt;

    always_comb begin
        if (state == LOAD) begin
            next_loaded = led_cnt == 4'hf;
            next_led_cnt = (led_cnt < 4'hf) ? led_cnt+1 : 4'hf;
        end else begin
            next_loaded = 1'b0;
            next_led_cnt = 4'd0;
        end
    end

    always_ff @(posedge load_clk) begin
        if (state == LOAD) begin
            loaded <= next_loaded;
            led_cnt <= next_led_cnt;
        end else begin
            loaded <= 1'b0;
            led_cnt <= 4'd0;
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            loading_led[i] = led_cnt >= i;
        end
    end

    // --------------------------------------------
    // Led play
    // --------------------------------------------
    logic [15:0] play_led;
    logic [15:0] next_play_led;

    always_comb begin
        for (int i = 0; i < 16; i += 2) begin
            if (slow) begin
                next_play_led[i] = ~play_led[i];
            end else begin
                next_play_led[i] = 1'b0;
            end
        end
    end

    always @(posedge slow_clk) begin
        for (int i = 0; i < 16; i += 2) begin
            play_led[i] <= next_play_led[i];
        end
    end

    always_comb begin
        for (int i = 1; i < 16; i += 2) begin
            if (fast) begin
                next_play_led[i] = ~play_led[i];
            end else begin
                next_play_led[i] = 1'b0;
            end
        end
    end

    always @(posedge fast_clk) begin
        for (int i = 1; i < 16; i += 2) begin
            play_led[i] <= next_play_led[i];
        end
    end

    // --------------------------------------------
    // Next state register & async reset
    // --------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
        end else begin
            state <= next_state;
        end
    end

    // --------------------------------------------
    // Circuit logic & Next state logic
    // --------------------------------------------
    always_comb begin
        case (state)
            INIT: begin
                led = 16'hffff;
                next_state = LOAD;
            end

            LOAD: begin
                led = loading_led;
                if (loaded) begin
                    next_state = PLAY;
                end else begin
                    next_state = LOAD;
                end
            end

            PLAY: begin
                led = play_led;
                if (end_light) begin
                    next_state = FINAL;
                end else begin
                    next_state = PLAY;
                end
            end

            FINAL: begin
                next_state = INIT;
            end

            default: begin
                led = 16'hffff;
                next_state = INIT;
            end
        endcase
    end

endmodule
