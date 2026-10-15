`timescale 1ns/1ps

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
    
    always_comb begin 
        if (enable) begin
            next_num = (num < COUNT - 1) ? (num + 1'b1) : 32'd0;
        end else begin
            next_num = 32'd0;
        end
    end
                    
    assign tick = enable && (num == COUNT - 1);
    
endmodule
