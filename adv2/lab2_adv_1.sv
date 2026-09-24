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
    always_comb begin : EnumSubset
        // Local logic variables
        reg [5:0] sum;
        reg [5:0] best_sum;
        reg [3:0] mask;
        reg [3:0] best_mask;

        best_sum  = 6'd0;
        best_mask = 4'b0000;

        for (int i = 0; i < 16; i++) begin
            sum = 6'd0;
            mask = i[3:0];
            for (int j = 0; j < 4; j++) begin
                if (i[j]) sum = sum + vals[j];   // i[j] reads bit j of the loop index directly
            end
            if (sum <= target && sum > best_sum) begin
                best_sum  = sum;
                best_mask = mask;
            end
        end

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
