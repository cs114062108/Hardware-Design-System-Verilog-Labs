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
    localparam S_Init = 2'b00;
    localparam S_Ack  = 2'b01;

    logic [1:0] state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin  // sync reset
            state <= S_Init;
        end else begin
            state <= next_state;
        end
    end

    // ---------------------------------------
    // Process
    // ---------------------------------------
    always_comb begin
        case (state)
            S_Ack: begin
                ACK = 1'b1;
                led = Data;
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
            S_Init: begin
                if (Request) begin
                    next_state = S_Ack;
                end else begin
                    next_state = S_Init;
                end
            end

            S_Ack: begin
                next_state = S_Ack;
            end

            default: begin  // latch prevent
                next_state = S_Init;
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
