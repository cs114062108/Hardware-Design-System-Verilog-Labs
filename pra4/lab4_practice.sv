// You can change anything in the template, except the module I/O of lab4_basic.
/*
enum logic [1:0] {
    IDLE,
    PLAY,
    FINAL
} state_t;
*/

parameter IDLE  = 2'd0;
parameter PLAY  = 2'd1;
parameter FINAL = 2'd2;

module lab4_basic (
    input logic clk,
    input logic rst,
    input logic btnL,
    input logic btnR,
    input logic btnD,
    input logic btnU,
    output logic [15:0] LED
);
    
    // -----------------------------------------
    // Debounce the rst Button
    // -----------------------------------------
    logic rst_db;
    debounce rst_debounce(.clk(clk), .pb(rst), .pb_db(rst_db));

    // -----------------------------------------
    // Debounce & One Pulse the Push Buttons
    // -----------------------------------------
    logic btnL_db;
    debounce L_db(.clk(clk), .pb(btnL), .pb_db(btnL_db));
    logic btnL_pulse;
    one_pulse L_op(.clk(clk), .pb_in(btnL_db), .pb_out(btnL_pulse));

    logic btnR_db;
    debounce R_db(.clk(clk), .pb(btnR), .pb_db(btnR_db));
    logic btnR_pulse;
    one_pulse R_op(.clk(clk), .pb_in(btnR_db), .pb_out(btnR_pulse));

    logic btnD_db;
    debounce D_db(.clk(clk), .pb(btnD), .pb_db(btnD_db));
    logic btnD_pulse;
    one_pulse D_op(.clk(clk), .pb_in(btnD_db), .pb_out(btnD_pulse));

    logic btnU_db;
    debounce U_db(.clk(clk), .pb(btnU), .pb_db(btnU_db));
    logic btnU_pulse;
    one_pulse U_op(.clk(clk), .pb_in(btnU_db), .pb_out(btnU_pulse));
    
    // -----------------------------------------
    // State & Register
    // -----------------------------------------
    logic [1:0] state;
    logic [1:0] next_state;

    always_ff @(posedge clk, posedge rst_db) begin
        if (rst_db) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // -----------------------------------------
    // LFSR Code Definitions
    // -----------------------------------------
    logic [3:0] lfsr;
    logic [3:0] next_lfsr;

    localparam Left  = 2'b00;
    localparam Right = 2'b01;
    localparam Down  = 2'b10;
    localparam Up    = 2'b11;

    logic [1:0] dir;
    assign dir = lfsr[1:0];

    // -----------------------------------------
    // Game Logic
    // -----------------------------------------
    logic correct;  // Raises if the correct button (pulse) pressed in PLAY state
    logic wrong;    // Raises if a wrong button (pulse) pressed in PLAY state

    always_comb begin
        if (state == PLAY) begin
            case (dir)
                Left: begin
                    correct = btnL_pulse;
                    wrong = (btnR_pulse || btnD_pulse || btnU_pulse);
                end

                Right: begin
                    correct = btnR_pulse;
                    wrong = (btnL_pulse || btnD_pulse || btnU_pulse);
                end

                Down: begin
                    correct = btnD_pulse;
                    wrong = (btnL_pulse || btnR_pulse || btnU_pulse);
                end

                Up: begin
                    correct = btnU_pulse;
                    wrong = (btnL_pulse || btnR_pulse || btnD_pulse);
                end

                default: begin
                    correct = 1'b0;
                    wrong = 1'b0;
                end
            endcase
        end else begin
            correct = 1'b0;
            wrong = 1'b0;
        end
    end

    // -----------------------------------------
    // LFSR Advancing
    // -----------------------------------------
    logic advance;

    always_comb begin
        case (state)
            IDLE: begin
                advance = btnR_pulse;
            end

            PLAY: begin
                advance = correct;
            end

            FINAL: begin
                advance = 1'b0;
            end

            default: begin
                advance = 1'b0;
            end
        endcase
    end
    
    always_comb begin
        logic xor03;
        xor03 = lfsr[0] ^ lfsr[3];
        
        next_lfsr = {xor03, lfsr[3:1]};
    end
    
    always_ff @(posedge clk, posedge rst_db) begin
        if (rst_db) begin
            lfsr <= 4'b0001;
        end else if (advance) begin
            lfsr <= next_lfsr;
        end
    end

    // -----------------------------------------
    // Final Timing
    // -----------------------------------------
    logic fin_timer;
    logic fin_rst;
    assign fin_rst = rst_db || (state != FINAL);
    logic fin_enable;
    assign fin_enable = state == FINAL;
    timer #(.COUNT(100_000_000)) fin_time(.clk(clk), .rst(fin_rst), .enable(fin_enable), .tick(fin_timer));

    logic [1:0] fin_cnt;
    logic [1:0] next_fin_cnt;

    logic fin_end;
    logic next_fin_end;

    always_comb begin
        if (fin_enable) begin
            next_fin_cnt = (fin_cnt < 2'd3) ? (fin_cnt + 1'b1) : 2'd3;
            next_fin_end = (next_fin_cnt == 2'd3);
        end else begin
            next_fin_cnt = 2'd0;
            next_fin_end = 1'b0;
        end
    end

    always_ff @(posedge clk or posedge fin_rst) begin
        if (fin_rst) begin
            fin_cnt <= 2'd0;
            fin_end <= 1'b0;
        end else if (fin_timer) begin
            fin_cnt <= next_fin_cnt;
            fin_end <= next_fin_end;
        end
    end

    // -----------------------------------------
    // FSM Logic & LED control
    // -----------------------------------------
    always_comb begin
        case (state)
            IDLE: begin
                LED[3:0] = lfsr;
                LED[4] = 1'b0;
                LED[6:5] = 2'b00;
                LED[15:7] = 9'd0;

                LED[15:14] = state; // out of requirement, just for viewing the state

                if (btnU_pulse) begin
                    next_state = PLAY;
                end else begin
                    next_state = IDLE;
                end
            end

            PLAY: begin
                LED[3:0] = lfsr;
                LED[4] = 1'b0;
                LED[6:5] = lfsr[1:0];
                LED[15:7] = 9'd0;

                LED[15:14] = state; // out of requirement, just for viewing the state

                if (wrong) begin
                    next_state = FINAL;
                end else begin
                    next_state = PLAY;
                end
            end

            FINAL: begin
                LED = 16'hFFFF;

                if (fin_end) begin
                    next_state = IDLE;
                end else begin
                    next_state = FINAL;
                end
            end

            default: begin
                LED = 16'd0;
                next_state = IDLE;
            end
        endcase
    end

    
endmodule
