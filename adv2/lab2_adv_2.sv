`timescale 1ns/1ps

module lab2_adv_2 (
    input logic clk,
    input logic rst,
    input logic [7:0] switch_input,
    input logic [1:0] switch_inputtype,
    input logic valid,
    output logic [3:0] out,
    output logic [5:0] sum,
    output logic exact
);

    // Implement your design here.

    // --------------------------------
    // Define input types
    // --------------------------------
    localparam VAL12 = 2'b00; // Load val_1 from SW7–SW4 and val_2 from SW3–SW0
    localparam VAL34 = 2'b01; // Load val_3 from SW7–SW4 and val_4 from SW3–SW0
    localparam TGT   = 2'b10; // Load target from SW5–SW0
    localparam LATCH = 2'b11; // Reserved — load nothing (latch everything)

    // ----------------------------------------------------------------------
    // Registers: Stores the inputs
    //            Loaded from switches when valid=1 at rising edge
    //            rst is asynchronous here, must be in the sensitivity list
    // ----------------------------------------------------------------------
    reg [3:0] val_1;  // 2'b00 (VAL12) : SW7-SW4
    reg [3:0] val_2;  // 2'b00 (VAL12) : SW3-SW0
    reg [3:0] val_3;  // 2'b01 (VAL34) : SW7-SW4
    reg [3:0] val_4;  // 2'b01 (VAL34) : SW3-SW0
    reg [5:0] target; // 2'b01 (TGT)   : SW5-SW0

    always_ff @(posedge clk or posedge rst) begin : InputRegister
        if (rst) begin
            val_1  <= 4'd0;
            val_2  <= 4'd0;
            val_3  <= 4'd0;
            val_4  <= 4'd0;
            target <= 6'd0;
        end else if (valid) begin
            case (switch_inputtype)
                VAL12: begin
                    val_1 <= switch_input[7:4];
                    val_2 <= switch_input[3:0];
                end

                VAL34: begin
                    val_3 <= switch_input[7:4];
                    val_4 <= switch_input[3:0];
                end

                TGT: begin
                    target <= switch_input[5:0];
                end

                default: ;  // 2'b11 (LATCH): Reserved — load nothing (latch everything)
            endcase
        end
    end

    // -----------------------
    // Values
    // -----------------------
    wire [3:0] vals [4];
    assign vals[0] = val_1;
    assign vals[1] = val_2;
    assign vals[2] = val_3;
    assign vals[3] = val_4;

    // ---------------------------------------------
    // Solver Logic: Reuse Enum Subset Submodule
    // ---------------------------------------------
    wire [5:0] best_sum;
    wire [3:0] best_mask;

    EnumSubset enum_sub(
        .val_0(vals[0]), .val_1(vals[1]), .val_2(vals[2]), .val_3(vals[3]),
        .target(target), .best_sum(best_sum), .best_mask(best_mask)
    );

    // Outputs mirror the solver directly, so they update
    // immediately once the async reset clears the registers.
    assign out   = best_mask;
    assign sum   = best_sum;
    assign exact = (best_sum == target);

endmodule
