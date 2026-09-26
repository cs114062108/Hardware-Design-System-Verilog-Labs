`timescale 1ns/1ps

module EnumSubset(
    input  logic [3:0] val_0,
    input  logic [3:0] val_1,
    input  logic [3:0] val_2,
    input  logic [3:0] val_3,
    input  logic [5:0] target,
    output logic [5:0] best_sum,
    output logic [3:0] best_mask
);

    // -----------------------
    // Values
    // -----------------------
    wire [3:0] vals [4];
    assign vals[0] = val_0;
    assign vals[1] = val_1;
    assign vals[2] = val_2;
    assign vals[3] = val_3;
    
    // Logic Variables
    reg [5:0] sum;
    reg [3:0] mask;
    
    // -----------------------------------------
    // Combinational: Enumerate all 16 subsets
    // -----------------------------------------
    always_comb begin
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
    end

endmodule
