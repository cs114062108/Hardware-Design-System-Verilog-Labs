`timescale 1ns/1ps

module lab2_1 (
    input  logic              clk,
    input  logic              rst,
    input  logic              mode,
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,
    output logic signed [7:0] out,
    output logic        [1:0] status
);

    // Implement your design here.
    localparam ZERO = 2'b00;
    localparam POS = 2'b01;
    localparam NEG = 2'b10;
    localparam SAT = 2'b11;

    reg signed [8:0] safe_add;
    reg signed [7:0] add;
    reg signed [7:0] sat_add;

    always_comb begin : Sat_Add
        if (!mode) begin
            safe_add = A + B;
            add = A + B;
        end else begin
            safe_add = A - B;
            add = A - B;
        end

        if (safe_add > 127) begin
            sat_add = 8'sd127;
        end else if (safe_add < -128) begin
            sat_add = -8'sd128;
        end else begin
            sat_add = add;
        end
    end

    reg [1:0] sta;

    always_comb begin
        if (safe_add > 127 || safe_add < -128) begin
            sta = SAT;
        end else if (sat_add > 0) begin
            sta = POS;
        end else if (sat_add < 0) begin
            sta = NEG;
        end else begin
            sta = ZERO;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            out <= 8'sd0;
            status <= ZERO;
        end else begin
            out <= sat_add;
            status <= sta;
        end
    end

endmodule
