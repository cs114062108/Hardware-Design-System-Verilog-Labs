`timescale 1ns/100ps
module lab1_1_t ();

    parameter DELAY = 5;
    logic [1:0] result;
    logic [1:0] a, b;
    logic [1:0] ALUOp;

    //====================================
    // TODO
    // Connect your lab1_1 module here with "a", "b", "ALUOp", "result"
    // Please connect it by port name but not order, or you will get no points for this part.
    // (WARNING: You are only permitted to write code in this section. Do not modify any other part of the testbench.)
    lab1_1 mod1_1(.a(a), .b(b), .ALUOp(ALUOp), .result(result));
    //====================================

    logic [1:0] answer;
    integer i, error_count;
    initial begin
        $display("===== Simulation ======");
        error_count = 0;
        {ALUOp, a, b} = 6'b000000;

        for (i = 0; i < 64; i = i + 1) begin

            {ALUOp, a, b} = i;
            #DELAY;
            case (ALUOp)
                2'b00: answer = a & b; // AND
                2'b01: answer = a | b; // OR
                2'b10: answer = a + b; // ADD
                2'b11: answer = a - b; // SUB
                default: answer = 2'b00; // Default case
            endcase

            if (result !== answer) begin
                $display("Error: a=%b, b=%b, ALUOp=%b, result=%b", a, b, ALUOp, result);
                $display("Correct answer should be: result=%b", answer);
                error_count = error_count + 1;
            end else begin
                $display("Correct: a=%b, b=%b, ALUOp=%b, result=%b", a, b, ALUOp, result);
            end

        end

        if (error_count === 0) begin
            $display("===== All Correct ======");
        end else begin
            $display("===== There are %d errors ======", error_count);
        end
        $finish;
    end


endmodule
