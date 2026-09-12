`timescale 1ns/100ps

module practice_2 (
    input  logic G,
    input  logic D,
    output logic P,
    output logic Pn
);
    // Write your code here
    wire nD, D_nand_G, G_nand_nD;

    not (nD, D);

    nand (D_nand_G, D, G);
    nand (G_nand_nD, G, nD);

    nand (P, D_nand_G, Pn);
    nand (Pn, P, G_nand_nD);

endmodule
