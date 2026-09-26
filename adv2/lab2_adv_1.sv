`timescale 1ns/1ps

module lab2_adv_1 (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] val_1,
    input  logic [3:0] val_2,
    input  logic [3:0] val_3,
    input  logic [3:0] val_4,
    input  logic [5:0] target,
    output logic       exact,
    output logic [3:0] out
);

    // Implement your design here.

    // -----------------------
    // Values
    // -----------------------
    wire [3:0] vals [4];
    assign vals[0] = val_1;
    assign vals[1] = val_2;
    assign vals[2] = val_3;
    assign vals[3] = val_4;

    reg next_exact;
    reg [3:0] next_out;

    // -----------------------------------------
    // Combinational: Enumerate all 16 subsets
    // -----------------------------------------
    reg [5:0] best_sum;
    reg [3:0] best_mask;

    EnumSubset enum_sub(
        .val_0(vals[0]), .val_1(vals[1]), .val_2(vals[2]), .val_3(vals[3]),
        .target(target), .best_sum(best_sum), .best_mask(best_mask)
    );

    always_comb begin : EnumerateSubset
        next_out   = best_mask;
        next_exact = (best_sum == target);
    end

    // ----------------------------------------------------
    // Sequential: out & excact register on clock posedge
    // ----------------------------------------------------
    always_ff @(posedge clk) begin : OutputRegister
        if (rst) begin
            out   <= 4'b0000;
            exact <= 1'b0;
        end else begin
            out   <= next_out;
            exact <= next_exact;
        end
    end

endmodule
