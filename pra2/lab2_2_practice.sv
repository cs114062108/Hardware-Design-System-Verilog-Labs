`timescale 1ns/1ps

module lab2_2_practice (
    input  logic       clk,
    input  logic       rst,
    input  logic       load,
    input  logic [7:0] N,
    output logic [7:0] out,
    output logic       done
);

    // Implement your design here.
    
    // FSM State Definitions
    localparam IDLE = 2'b00;
    localparam PROC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    reg  [7:0] num;
    wire [7:0] next_num;

    // Sequential: State Register
    always_ff @(posedge clk) begin
        state <= next_state;
    end

    // Combinational: Next State Logic
    always_comb begin
        case (state)
            IDLE: begin
                if (load) begin
                    next_state = PROC;
                end else begin
                    next_state = IDLE;
                end
            end

            PROC: begin
                if (next_num == 8'd0) begin
                    next_state = DONE;
                end else begin
                    next_state = PROC;
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Combinational: Next num down-counting logic
    assign next_num = (num > 0) ? (num - 1) : 8'd0;

    // Sequential: Register num
    always_ff @(posedge clk) begin
        if (rst) begin
            num <= 8'd0;          // moved reset here so num itself resets
        end else if (load) begin
            num <= N;
        end else begin
            num <= next_num;
        end
    end

    // Combinational: out always mirrors num with no extra delay
    assign out = num;

    // Combinational: Raise done flag on DONE state
    assign done = (state == DONE) ? 1'b1 : 1'b0;

endmodule
