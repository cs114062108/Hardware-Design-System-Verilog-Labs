`timescale 1ns/100ps
module lab1_1 (
    input  logic [1:0] a,
    input  logic [1:0] b,
    input  logic [1:0] ALUOp,
    output logic [1:0] result
);

    // Write your code here
    // ------------------------------------------------------
    // ALUOp[0] selects AND_OR or ADD_SUB, use in final mux
    // ALUOp[1] selects AND or OR, ADD or SUB, use in mux ao, b_invert, adder cin
    // ------------------------------------------------------

    // Perform AND operation and OR operation
    wire [1:0] a_and_b, a_or_b;
    and a_ab_0(a_and_b[0], a[0], b[0]);
    and a_ab_1(a_and_b[1], a[1], b[1]);

    or  o_ab_0(a_or_b[0], a[0], b[0]);
    or  o_ab_1(a_or_b[1], a[1], b[1]);

    // Select AND or OR by ALUOp[1]
    wire [1:0] and_or;
    mux ao_0(.a(a_and_b[0]), .b(a_or_b[0]), .sel(ALUOp[1]), .y(and_or[0]));
    mux ao_1(.a(a_and_b[1]), .b(a_or_b[1]), .sel(ALUOp[1]), .y(and_or[1]));

    // Invert b by ALUOp[1]
    wire [1:0] b_invert;
    xor x_b_0(b_invert[0], b[0], ALUOp[1]);
    xor x_b_1(b_invert[1], b[1], ALUOp[1]);

    // Perform ADD or SUB
    wire [1:0] a_add_b;
    adder add(.a(a), .b(b_invert), .cin(ALUOp[1]), .sum(a_add_b));

    // Finalize
    mux final_0(.a(and_or[0]), .b(a_add_b[0]), .sel(ALUOp[0]), .y(result[0]));
    mux final_1(.a(and_or[1]), .b(a_add_b[1]), .sel(ALUOp[0]), .y(result[1]));

endmodule

/* Uncomment the following code if needed */
module mux (
    input  logic a,
    input  logic b,
    input  logic sel,
    output logic y
);

    // Write your code here
    wire nsel, a_and_nsel, b_and_sel;
    not (nsel, sel);
    and (a_and_nsel, a, nsel);
    and (b_and_sel, b, sel);
    or  (y, a_and_nsel, b_and_sel);

endmodule

/* The adder below is given to you. Do not modify it. */

module adder (
    input  logic [1:0] a,
    input  logic [1:0] b,
    input  logic       cin,
    output logic [1:0] sum
);
    logic ab0, ab1, and_ab0, and_ab0_cin, c1;

    xor g_x00 (ab0, a[0], b[0]);
    xor g_x01 (sum[0], ab0, cin);
    and g_a00 (and_ab0, a[0], b[0]);
    and g_a01 (and_ab0_cin, ab0, cin);
    or  g_o00 (c1, and_ab0, and_ab0_cin);

    xor g_x10 (ab1, a[1], b[1]);
    xor g_x11 (sum[1], ab1, c1);
endmodule
