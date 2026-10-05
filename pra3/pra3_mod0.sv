`timescale 1ns/1ps

module pra3_mod0 (
    input logic clk,
    input logic rst,
    input logic slow,
    input logic fast,
    input logic end_light,
    output logic [15:0] led,
    output logic [1:0]  state,
    output logic [4:0]  led_cnt,
    output logic [2:0]  flash_cnt,
    output logic slow_clk,
    output logic fast_clk
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

    //logic [1:0] state;
    logic [1:0] next_state;

    // --------------------------------------------
    // Divided clocks & timers
    // --------------------------------------------
    //logic slow_clk, fast_clk;

    clock_divider #(.n(28)) slow_div(.clk(clk), .rst(rst), .enable(1'b1), .clk_div(slow_clk));
    clock_divider #(.n(27)) fast_div(.clk(clk), .rst(rst), .enable(1'b1), .clk_div(fast_clk));
    
    logic load_timer;    // 4 Hz
    logic is_load;
    assign is_load = (state == LOAD);
    timer #(.COUNT(25_000_000)) load_time(.clk(clk), .rst(rst), .enable(is_load), .tick(load_timer));    // 100 MHz to 4 Hz

    logic final_timer;   // 2 Hz
    logic is_final;
    assign is_final = (state == FINAL);
    timer #(.COUNT(50_000_000)) final_time(.clk(clk), .rst(rst), .enable(is_final), .tick(final_timer)); // 100 MHz to 2 Hz

    // --------------------------------------------
    // Led load
    // --------------------------------------------
    logic [15:0] load_led;
    logic end_load;

    LOAD_led led_load(.clk(clk), .rst(rst), .timer(load_timer), .is_load(is_load), .loaded(end_load), .load_led(load_led), .led_cnt(led_cnt));

    // --------------------------------------------
    // Led final
    // --------------------------------------------
    logic [15:0] final_led;
    logic end_final;

    FINAL_led led_final(.clk(clk), .rst(rst), .timer(final_timer), .is_final(is_final), .end_final(end_final), .final_led(final_led), .flash_cnt(flash_cnt));

    // --------------------------------------------
    // Led play
    // --------------------------------------------
    logic [15:0] play_led;
    logic [7:0] even_led, odd_led;

    PLAY_led_slow led_slow(.slow_clk(slow_clk), .rst(rst), .slow(slow), .even_led(even_led));
    PLAY_led_fast led_fast(.fast_clk(fast_clk), .rst(rst), .fast(fast), .odd_led(odd_led));

    always_comb begin
        for (int k = 0; k < 8; k++) begin
            play_led[2*k] = even_led[k];
            play_led[2*k+1] = odd_led[k];
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
                led = load_led;
                if (end_load) begin
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
                led = final_led;
                if (end_final) begin
                    next_state = INIT;
                end else begin
                    next_state = FINAL;
                end
            end

            default: begin
                led = 16'hffff;
                next_state = INIT;
            end
        endcase
    end

endmodule

module LOAD_led (
    input logic clk,
    input logic rst,
    input logic timer,
    input logic is_load,
    output logic loaded,
    output logic [15:0] load_led,
    output logic [4:0]  led_cnt
);

    // --------------------------------------------
    // Led load
    // --------------------------------------------
    logic next_loaded;
    //logic [4:0] led_cnt;      // Counts from 0 to 16, represents 16 leds, has 17 states
    logic [4:0] next_led_cnt;

    always_comb begin
        if (is_load) begin
            next_loaded = led_cnt == 5'd16;
            next_led_cnt = (led_cnt < 5'd16) ? led_cnt + 1'b1 : 5'd16;
        end else begin
            next_loaded = 1'b0;
            next_led_cnt = 5'd0;
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            load_led[i] = led_cnt >= i+1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            loaded <= 1'b0;
            led_cnt <= 5'd0;
        end else if (timer) begin
            loaded <= next_loaded;
            led_cnt <= next_led_cnt;
        end else if (!is_load) begin
            loaded <= 1'b0;
            led_cnt <= 5'd0;
        end
    end

endmodule

module FINAL_led (
    input logic clk,
    input logic rst,
    input logic timer,
    input logic is_final,
    output logic end_final,
    output logic [15:0] final_led,
    output logic [2:0]  flash_cnt
);
    
    // --------------------------------------------
    // Led final
    // --------------------------------------------
    logic next_ended;
    //logic [2:0] flash_cnt;
    logic [2:0] next_flash_cnt;

    always_comb begin
        if (is_final) begin
            next_ended = next_flash_cnt == 3'd6;
            next_flash_cnt = (flash_cnt < 3'd6) ? flash_cnt + 1'b1 : 3'd6;
        end else begin
            next_ended = 1'b0;
            next_flash_cnt = 3'd0;
        end
    end

    // cnt even (0,2,4) -> ON phase; cnt odd (1,3,5) -> OFF phase
    assign final_led = flash_cnt[0] ? 16'h0000 : 16'hffff;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            end_final <= 1'b0;
            flash_cnt <= 2'd0;
        end else if (timer) begin
            end_final <= next_ended;
            flash_cnt <= next_flash_cnt;
        end else if (!is_final) begin
            end_final <= 1'b0;
            flash_cnt <= 2'd0;
        end
    end

endmodule

module PLAY_led_slow (
    input logic slow_clk,
    input logic rst,
    input logic slow,
    output logic [7:0] even_led
);

    logic [7:0] next_even_led;

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            if (slow) begin
                next_even_led[i] = ~even_led[i];
            end else begin
                next_even_led[i] = 1'b0;
            end
        end
    end

    always @(posedge slow_clk) begin
        for (int i = 0; i < 8; i++) begin
            even_led[i] <= next_even_led[i];
        end
    end

endmodule

module PLAY_led_fast (
    input logic fast_clk,
    input logic rst,
    input logic fast,
    output logic [7:0] odd_led
);

    logic [7:0] next_odd_led;

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            if (fast) begin
                next_odd_led[i] = ~odd_led[i];
            end else begin
                next_odd_led[i] = 1'b0;
            end
        end
    end

    always @(posedge fast_clk) begin
        for (int i = 0; i < 8; i++) begin
            odd_led[i] <= next_odd_led[i];
        end
    end

endmodule

