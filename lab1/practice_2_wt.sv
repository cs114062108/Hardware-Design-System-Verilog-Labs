`timescale 1ns/100ps

module practice_2_wt();
    logic G, D;
    logic P, Pn, expected_P, expected_Pn;

    //====================================
    // TODO
    // Connect your practice_2 module here with "G", "D", "P", and "Pn".
    // Please connect it by port name but not order
    practice_2 p2(.G(G), .D(D), .P(P), .Pn(Pn));
    //====================================

    golden_2 golden_latch(.G(G), .D(D), .P(expected_P), .Pn(expected_Pn));

    // ------------------------------------
    // Dump for gtkwave
    // ------------------------------------
    initial begin
        $dumpfile("waves/lab1_2.vcd");
        $dumpvars(0, practice_2_wt);
    end
    // ------------------------------------

    parameter LEN = 9;
    logic [0:LEN-1] G_pattern = 9'b011001100; // Gate input G: 0 -> 1 -> 1 -> 0 -> 0 -> 1 -> 1 -> 0 -> 0
    logic [0:LEN-1] D_pattern = 9'b001101001; // Data input D: 0 -> 0 -> 1 -> 1 -> 0 -> 1 -> 0 -> 0 -> 1

    logic [0:LEN-1] student_Ps;
    logic [0:LEN-1] student_Pns;
    logic [0:LEN-1] golden_Ps;
    logic [0:LEN-1] golden_Pns;
    integer error_count, i;

    initial begin

        // Monitor
        $display("-------------------------------");
        $display("Time\t G D | P Pn | exP exPn");
        $display("-------------------------------");
        $monitor("%0dns\t %b %b | %b %b  |  %b   %b ", $time, G, D, P, Pn, expected_P, expected_Pn);

        error_count = 0;
        for (i = 0; i < LEN; i = i + 1) begin
            G = G_pattern[i];
            D = D_pattern[i];

            // Check the outputs
            #1; // small delay to ensure output is ready
            student_Ps[i] = P;
            student_Pns[i] = Pn;
            golden_Ps[i] = expected_P;
            golden_Pns[i] = expected_Pn;
            if (P !== expected_P) error_count = error_count + 1;
            if (Pn !== expected_Pn) error_count = error_count + 1;

            #9;
        end
        
        $display("-------------------------------");

        if (error_count === 0) $display("[SUCCESS]: All tests passed successfully!");
        else begin
            $display("[ERROR]: There were %0d errors.", error_count);

            $write("     Gate input G: %b", G_pattern[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", G_pattern[i]);
            $write("\n");

            $write("     Data input D: %b", D_pattern[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", D_pattern[i]);
            $write("\n");

            $write("    Your output P: %b", student_Ps[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", student_Ps[i]);
            $write("\n");

            $write("   Your output Pn: %b", student_Pns[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", student_Pns[i]);
            $write("\n");

            $write(" Correct output P: %b", golden_Ps[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", golden_Ps[i]);
            $write("\n");

            $write("Correct output Pn: %b", golden_Pns[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", golden_Pns[i]);
            $write("\n");
        end

        $finish;
    end

endmodule

module golden_2(
    input  logic G,
    input  logic D,
    output logic P,
    output logic Pn
);
    assign Pn = ~P;
    always @(G or D) if (G) P <= D;
endmodule
