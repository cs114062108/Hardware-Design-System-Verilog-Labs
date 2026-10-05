`timescale 1ns/1ps

module Pra3_util_tb0;
    
    // Inputs
    logic clk;
    logic rst;
    logic enable;

    // Outputs
    logic div_clk;
    logic timed_clk;

    // ---------------
    // Testcases
    // ---------------
    int unsigned test_index;
    int test_cnt = 3;
    int wait_clk = 4;
    int proc_clk = 12;

    // ------------------------------------
    // Instantiate the design under test
    // ------------------------------------
    clock_divider #(.n(2)) divide_uut(.clk(clk), .rst(rst), .enable(enable), .clk_div(div_clk));
    timer #(.COUNT(5))     timer_uut(.clk(clk), .rst(rst), .enable(enable), .tick(timed_clk));

    // Dump for GTKwave
    initial begin
        $dumpfile("waves/pra3_util.vcd");
        $dumpvars(0, Pra3_util_tb0);
    end

    // Starting high places falling edges at 5, 15, 25, ... ns and rising
    // edges at 10, 20, 30, ... ns.
    initial begin
        clk = 1'b1;
        forever #5ns clk = ~clk;
    end

    // Resets
    initial begin
        enable = 1'b1;
        rst = 1'b1;
        #2ns rst = 1'b0; // At 2 ns
    end

    initial begin
        #15;
        for (int i = 0; i < proc_clk; i++) begin
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
        end

        $display("-------------------------------------------------------");

        @(negedge clk);
        for (int i = 0; i < wait_clk; i++) begin
            @(posedge clk);
            @(posedge clk);
        end
        #20;
        $finish;
    end

endmodule
