`timescale 1ns/1ps

module lab2_1_practice (
    input  logic              clk,
    input  logic              rst,
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,
    output logic signed [7:0] out
);

    // Implement your design here.
    reg signed [8:0] safe_sum;
    reg signed [7:0] sum;
    reg signed [7:0] sum_sat;

    always_comb begin : Sat_Adder
        safe_sum = A + B;          // A and B are signed; adding them directly and letting the LHS's 9-bit width handle automatic sign-extension will not cause bugs.
        sum      = A + B;          // 8-bit version, used for non-saturated output.
        if (safe_sum > 127) begin
            sum_sat = 8'sd127;
        end else if (safe_sum < -128) begin
            sum_sat = -8'sd128;
        end else begin
            sum_sat = sum;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            out <= 7'b0;
        end else begin
            out <= sum_sat;
        end
    end

endmodule
