`timescale 1ns/1ps

module Lab5(
    input  wire clk,
    input  wire rst,

    // write port
    input  wire we,
    input  wire [6:0] w_addr,
    input  wire [3:0] din,

    // read port
    input  wire re,
    input  wire [6:0] r_addr,
    output wire [3:0] dout,

    // Status output
    output reg [3:0] cnt_valid
);

    lab5_practice pra5(
        .clk(clk), .rst(rst),
        .we(we), .w_addr(w_addr), .din(din),
        .re(re), .r_addr(r_addr),
        .dout(dout), .cnt_valid(cnt_valid)
    );

endmodule
