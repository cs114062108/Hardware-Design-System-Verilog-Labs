module lab2_adv_2_tb;

    timeunit 1ns;
    timeprecision 1ps;

    // Inputs
    logic clk;
    logic rst;
    logic [7:0] switch_input;
    logic [1:0] switch_inputtype;
    logic valid;

    // Outputs
    logic [3:0] mask;
    logic [5:0] sum;
    logic exact;

    // ---------------
    // Testcases
    // ---------------
    
    // Test inputs
    logic [7:0] test_switch_input [0:3];
    logic [1:0] test_switch_inputtype [0:3];
    logic       test_valid [0:3];

    // Expected outputs answers
    logic [3:0] ans_mask  [0:3];
    logic [5:0] ans_sum   [0:3];
    logic       ans_exact [0:3];

    logic [3:0] exp_mask;
    logic [5:0] exp_sum;
    logic       exp_exact;

    int unsigned test_index;

    // ------------------------------------
    // Instantiate the design under test
    // ------------------------------------
    lab2_adv_2 dut(
        .clk(clk),
        .rst(rst),
        .switch_input(switch_input),
        .switch_inputtype(switch_inputtype),
        .valid(valid),
        .out(mask),
        .sum(sum),
        .exact(exact)
    );

    int test_cnt;

    int err_cnt = 0;
    int pass_cnt;

    // Dump for GTKwave
    initial begin
        $dumpfile("waves/adv2_2.vcd");
        $dumpvars(0, lab2_adv_2_tb);
    end

    // Starting high places falling edges at 5, 15, 25, ... ns and rising
    // edges at 10, 20, 30, ... ns.
    initial begin
        clk = 1'b1;
        forever #5ns clk = ~clk;
    end

    // Resets
    initial begin
        rst = 1'b0;
        #4ns rst = 1'b1; // At 4 ns
        #2ns rst = 1'b0; // At 5 ns
    end

    // ---------------------
    // Testcases
    // ---------------------
    initial begin
        // Load val_1, val_2
        test_switch_input[0] = 8'b0011_0101;
        test_switch_inputtype[0] = 2'b00;
        test_valid[0] = 1'b1;

        ans_exact[0] = 1'b1;
        ans_mask[0]  = 4'b0000;
        ans_sum[0]   = 6'b000000;

        // Load val_3, val_4
        test_switch_input[1] = 8'b1001_1011;
        test_switch_inputtype[1] = 2'b01;
        test_valid[1] = 1'b1;

        ans_exact[1] = 1'b1;
        ans_mask[1]  = 4'b0000;
        ans_sum[1]   = 6'b000000;

        // Load target
        test_switch_input[2][5:0] = 6'b001110;
        test_switch_inputtype[2] = 2'b10;
        test_valid[2] = 1'b1;

        ans_exact[2] = 1'b1;
        ans_mask[2]  = 4'b0110;
        ans_sum[2]   = 6'b001110;

        // Change target
        test_switch_input[3][5:0] = 6'b111111;
        test_switch_inputtype[3] = 2'b10;
        test_valid[3] = 1'b1;

        ans_exact[3] = 1'b0;
        ans_mask[3]  = 4'b1111;
        ans_sum[3]   = 6'b011100;

        test_cnt = 4;

        pass_cnt = 0;
    end

    initial begin
        #15;
        for (test_index = 0; test_index < test_cnt; test_index++) begin
            switch_input = test_switch_input[test_index];
            switch_inputtype = test_switch_inputtype[test_index];
            valid = test_valid[test_index];

            exp_sum = ans_sum[test_index];
            exp_mask = ans_mask[test_index];
            exp_exact = ans_exact[test_index];

            @(posedge clk);
            #1ns;
            valid = 1'b0;

            if (sum !== exp_sum || mask !== exp_mask || exact !== exp_exact) begin
                $display("[FAIL] t=%0d idx=%0d: sum=%b(exp %b) mask=%b(exp %b) exact=%b(exp %b)",
                        $time, test_index, sum, exp_sum, mask, exp_mask, exact, exp_exact);
                err_cnt += 1;
            end else begin
                $display("[PASS] idx=%0d: sum=%b mask=%b exact=%b", test_index, sum, mask, exact);
                pass_cnt += 1;
            end

            if (test_index < test_cnt-1) begin
                @(negedge clk);
            end
        end

        $display("-------------------------------------------------------");
        $display("   Result: (%0d/%0d), %0d errors detected", pass_cnt, test_cnt, err_cnt);
        $display("-------------------------------------------------------");

        @(negedge clk);
        @(posedge clk);
        #20;
        $finish;
    end

    always @(posedge clk or posedge rst or negedge rst) begin
        #1ns;
        $display("t=%0dns\t rst=%b\t switches=%08b\t intype=%02b\t mask=%b\t sum=%0d (%06b) \t exact=%b",
                 $time, rst, switch_input, switch_inputtype, mask, sum, sum, exact);
    end

endmodule
