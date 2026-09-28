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

    // ---------------------------------------------------------
    // Read Switches: Synchronous read and asynchronous reset
    // ---------------------------------------------------------
    logic [3:0] val_1;  // 2'b00 (VAL12) : SW7-SW4
    logic [3:0] val_2;  // 2'b00 (VAL12) : SW3-SW0
    logic [3:0] val_3;  // 2'b01 (VAL34) : SW7-SW4
    logic [3:0] val_4;  // 2'b01 (VAL34) : SW3-SW0
    logic [5:0] target; // 2'b01 (TGT)   : SW5-SW0

    SwitchReader switch_read(
        .clk(clk), .rst(rst),
        .switch_input(switch_input), .switch_inputtype(switch_inputtype),
        .valid(valid),
        .v_1(val_1), .v_2(val_2), .v_3(val_3), .v_4(val_4), .tgt(target)
    );

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
