module lab2_adv_1_tb;

    timeunit 1ns;
    timeprecision 1ps;

    logic clk;
    logic rst;
    logic [3:0] val_1;
    logic [3:0] val_2;
    logic [3:0] val_3;
    logic [3:0] val_4;
    logic [5:0] target;
    logic exact;
    logic [3:0] out;

    logic [3:0] test_val_1 [0:7];
    logic [3:0] test_val_2 [0:7];
    logic [3:0] test_val_3 [0:7];
    logic [3:0] test_val_4 [0:7];
    logic [5:0] test_target [0:7];
    int unsigned test_index;

    lab2_adv_1 dut (
        .clk(clk),
        .rst(rst),
        .val_1(val_1),
        .val_2(val_2),
        .val_3(val_3),
        .val_4(val_4),
        .target(target),
        .exact(exact),
        .out(out)
    );

    int test_cnt;

    int err_cnt = 0;
    int pass_cnt;

    // clk toggles every 5 ns starting high, so rising edges land exactly on
    // multiples of 10 ns (10, 20, 30, ...). Any change to out/exact at a time
    // that is not a multiple of 10 means it changed off a rising edge.
    always @(out or exact) begin
        if ($time % 10 != 0) begin
            $display("[FAIL] out/exact changed at t=%0d, which is not a rising edge", $time);
            err_cnt += 1;
        end
    end

    // Dump for GTKwave
    initial begin
        $dumpfile("waves/adv2.vcd");
        $dumpvars(0, lab2_adv_1_tb);
    end

    // Starting high places falling edges at 5, 15, 25, ... ns and rising
    // edges at 10, 20, 30, ... ns.
    initial begin
        clk = 1'b1;
        forever #5ns clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        #15ns rst = 1'b1;
        #20ns rst = 1'b0;
    end

    initial begin
        test_val_1[0] = 4'd3;  test_val_2[0] = 4'd5;
        test_val_3[0] = 4'd9;  test_val_4[0] = 4'd11;
        test_target[0] = 6'd14;

        test_val_1[1] = 4'd3;  test_val_2[1] = 4'd5;
        test_val_3[1] = 4'd9;  test_val_4[1] = 4'd11;
        test_target[1] = 6'd0;

        test_val_1[2] = 4'd2;  test_val_2[2] = 4'd4;
        test_val_3[2] = 4'd6;  test_val_4[2] = 4'd8;
        test_target[2] = 6'd5;

        test_val_1[3] = 4'd1;  test_val_2[3] = 4'd2;
        test_val_3[3] = 4'd3;  test_val_4[3] = 4'd4;
        test_target[3] = 6'd63;

        test_val_1[4] = 4'd7;  test_val_2[4] = 4'd7;
        test_val_3[4] = 4'd7;  test_val_4[4] = 4'd7;
        test_target[4] = 6'd14;

        test_val_1[5] = 4'd15; test_val_2[5] = 4'd15;
        test_val_3[5] = 4'd1;  test_val_4[5] = 4'd1;
        test_target[5] = 6'd16;

        test_val_1[6] = 4'd0;  test_val_2[6] = 4'd0;
        test_val_3[6] = 4'd0;  test_val_4[6] = 4'd0;
        test_target[6] = 6'd0;

        test_val_1[7] = 4'd4;  test_val_2[7] = 4'd6;
        test_val_3[7] = 4'd8;  test_val_4[7] = 4'd10;
        test_target[7] = 6'd13;

        val_1 = 4'd0;
        val_2 = 4'd0;
        val_3 = 4'd0;
        val_4 = 4'd0;
        target = 6'd0;

        test_cnt = 8;

        pass_cnt = 0;

        // The first post-reset input change occurs at the falling edge at
        // 35 ns. Each later set is applied at the next falling edge.
        #35ns;
        for (test_index = 0; test_index < test_cnt; test_index = test_index + 1) begin
            val_1 = test_val_1[test_index];
            val_2 = test_val_2[test_index];
            val_3 = test_val_3[test_index];
            val_4 = test_val_4[test_index];
            target = test_target[test_index];

            @(posedge clk);
            #1ns;
            // TODO: Implement your expected-result checks here, after the sampled rising edge.
            // TODO: Also verify that both outputs change only at rising edges.
            if (test_index < test_cnt-1)
                @(negedge clk);
        end

        $display("-------------------------------------------------------");
        $display("   Result: (%0d/%0d), %0d errors detected", pass_cnt, test_cnt, err_cnt);
        $display("-------------------------------------------------------");
    end

    always @(posedge clk) begin
        #1ns;
        $display("t=%0dns\t rst=%b\t values={%0d,%0d,%0d,%0d}\t target=%0d\t out=%b\t exact=%b",
                 $time, rst, val_1, val_2, val_3, val_4, target, out, exact);
    end

    // Required total duration: exactly 120 ns.
    initial begin
        #120ns;
        $finish;
    end

endmodule
