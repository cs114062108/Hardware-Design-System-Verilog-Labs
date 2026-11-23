`timescale 1ns/1ps

module lab6_practice_slave #(
    parameter integer COUNT = 100_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic Request,
    input  logic [3:0] Data,

    output logic ACK,
    output logic [3:0] led
);
    
    // add your design here

    // ---------------------------------------
    // FSM (Synchronous Reset)
    // ---------------------------------------
    //localparam Init = 2'b00;
    //localparam Ack  = 2'b01;
    typedef enum logic [1:0] {Init, Ack} state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin  // sync reset
            state <= Init;
        end else begin
            state <= next_state;
        end
    end

    // ---------------------------------------
    // Ack Timing
    // ---------------------------------------
    logic ack_rst, ack_enable;
    assign ack_enable = state == Ack;
    assign ack_rst = rst || !ack_enable;

    logic ack_tick;
    timer #(.COUNT(COUNT)) ack_timer(.clk(clk), .rst(ack_rst), .enable(ack_enable), .tick(ack_tick));

    logic [2:0] ack_cnt;
    always_ff @(posedge clk) begin
        if (ack_rst) begin
            ack_cnt <= 3'd0;
        end else if (ack_tick) begin
            ack_cnt <= ack_cnt + 3'd1;
        end
    end
    
    logic ack_done;
    assign ack_done = (state == Ack) ? (ack_cnt == 3'd1) : 1'b0;

    // ---------------------------------------
    // Synchronizer
    // ---------------------------------------
    logic req_si, req_s;
    always_ff @(posedge clk) begin
        req_si <= Request;
        req_s  <= req_si;
    end

    // ---------------------------------------
    // Data Register
    // ---------------------------------------
    logic [3:0] data_reg;
    always_ff @(posedge clk) begin
        if (rst) begin
            data_reg <= 4'd0;
        end else if (state == Init && req_s) begin
            data_reg <= Data;
        end
    end

    // ---------------------------------------
    // Process & LED
    // ---------------------------------------
    always_comb begin
        case (state)
            Ack: begin
                ACK = 1'b1;
                led = data_reg;
            end

            default: begin
                ACK = 1'b0;
                led = 4'd0;
            end
        endcase
    end

    // ---------------------------------------
    // FSM Next State Logic
    // ---------------------------------------
    always_comb begin
        case (state)
            Init: begin
                if (req_s) begin
                    next_state = Ack;
                end else begin
                    next_state = Init;
                end
            end

            Ack: begin
                if (ack_done) begin
                    next_state = Init;    
                end else begin
                    next_state = Ack;
                end
            end

            default: begin  // latch prevent
                next_state = Init;
            end
        endcase
    end

endmodule

module timer #(
    parameter integer COUNT = 100_000_000
)(
    input  logic clk,
    input  logic rst,
    input  logic enable,
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
