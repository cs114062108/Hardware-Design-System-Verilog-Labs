`timescale 1ns/100ps

module lab1_2_t();
    logic clk = 1, D;
    logic Q, Qn, expected_Q, expected_Qn;

    //====================================
    // TODO
    // Connect your lab1_2 module here with "clk", "D", "Q", and "Qn".
    // Please connect it by port name but not order
    // (WARNING: You are only permitted to write code in this section. Do not modify any other part of the testbench.)

    lab1_2 mod1_2(.clk(clk), .D(D), .Q(Q), .Qn(Qn));
    //====================================

    golden_2 golden_DFF(.clk(clk), .D(D), .Q(expected_Q), .Qn(expected_Qn));

    // Data input D: 0 -> 1 -> 1 -> 0 -> 0 -> 1 -> 0 -> 1, ...
    parameter LEN = 20;
    logic [0:LEN-1] D_pattern = 20'b0110_0101_1010_1111_0000;

    logic [0:LEN-1] student_Qs;
    logic [0:LEN-1] student_Qns;
    logic [0:LEN-1] golden_Qs;
    logic [0:LEN-1] golden_Qns;
    integer q_errors, qn_errors, i;

    always #5 clk = ~clk; // clock signal, period 10ns

    initial begin
        q_errors = 0;
        qn_errors = 0;

        // Warm-up cycle: drive D = 0 through one rising edge so that both the
        // DUT and the golden model start the checked cycles in a known state.
        D = 1'b0;
        @(posedge clk);

        for (i = 0; i < LEN; i = i + 1) begin
            #1; // small delay for DFF to read the correct input
            D = D_pattern[i];
            #1; // small delay to ensure output is ready
            student_Qs[i] = Q;
            student_Qns[i] = Qn;
            golden_Qs[i] = expected_Q;
            golden_Qns[i] = expected_Qn;
            if (Q !== expected_Q) q_errors = q_errors + 1;
            if (Qn !== expected_Qn) qn_errors = qn_errors + 1;

            #8; // wait till next rising-edge
        end

        if (q_errors === 0 && qn_errors === 0) $display("[SUCCESS]: All tests passed successfully!");
        else begin
            $display("[ERROR]: Q correct: %0d/%0d, Qn correct: %0d/%0d", LEN - q_errors, LEN, LEN - qn_errors, LEN);

            $write("     Data input D: %b", D_pattern[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", D_pattern[i]);
            $write("\n");

            $write("    Your output Q: %b", student_Qs[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", student_Qs[i]);
            $write("\n");

            $write("   Your output Qn: %b", student_Qns[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", student_Qns[i]);
            $write("\n");

            $write(" Correct output Q: %b", golden_Qs[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", golden_Qs[i]);
            $write("\n");

            $write("Correct output Qn: %b", golden_Qns[0]);
            for (i = 1; i < LEN; i = i + 1) $write(" -> %b", golden_Qns[i]);
            $write("\n");
        end
        $finish;
    end
endmodule

module golden_2 (
    input  logic clk,
    input  logic D,
    output logic Q,
    output logic Qn
);
    assign Qn = ~Q;
    always @(posedge clk) Q <= D;
endmodule
