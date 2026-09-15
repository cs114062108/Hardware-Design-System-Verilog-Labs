`timescale 1ns/100ps

module lab1_2(
    input  logic clk,
    input  logic D,
    output logic Q,
    output logic Qn
);
    // Write your code here
    wire nclk, P1, Pn1;
    not (nclk, clk);
    gated_D_latch L1(.Data(D), .Gate(nclk), .P(P1), .Pn(Pn1));
    gated_D_latch L2(.Data(P1), .Gate(clk), .P(Q), .Pn(Qn));

endmodule

module gated_D_latch(
    input  logic Data,
    input  logic Gate,
    output logic P,
    output logic Pn
);
    logic Data_n, tmp1, tmp2;
    not(Data_n, Data);
    nand(tmp1, Data, Gate);
    nand(tmp2, Data_n, Gate);
    nand(P, tmp1, Pn);
    nand(Pn, tmp2, P);
endmodule
