`timescale 1ns/100ps
module practice_1 (
    input  logic A,
    input  logic B,
    input  logic C,
    output logic out
);

    // Write your code here
    wire A_and_B, A_or_B;

    and (A_and_B, A, B);
    or  (A_or_B, A, B);
    
    mux Mux(.a(A_and_B), .b(A_or_B), .c(C), .y(out));

endmodule

module mux (
    input  logic a,
    input  logic b,
    input  logic c,
    output logic y
);

    // Write your code here
    wire nc, and_a_nc, and_b_c;

    not (nc, c);
    and (and_a_nc, a, nc);
    and (and_b_c, b, c);
    or  (y, and_a_nc, and_b_c);

endmodule
