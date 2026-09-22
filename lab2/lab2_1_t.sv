module lab2_1_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam time CYCLE = 10ns;

    logic clk;
    logic rst;
    logic mode;
    logic signed [7:0] A;
    logic signed [7:0] B;
    logic signed [7:0] out;
    logic [1:0] status;

    // ===== TA QUICK CHECK START =====
    localparam int unsigned PATTERN_NUM = 48;

    // Pattern layout:
    // {rst, mode, A[7:0], B[7:0], expected_out[7:0], expected_status[1:0]}
    logic [27:0] patterns [0:PATTERN_NUM-1];
    logic expected_rst;
    logic expected_mode;
    logic signed [7:0] expected_out;
    logic [1:0] expected_status;
    int unsigned pattern_index;
    int unsigned pass_count;
    int unsigned failure_count = 0;
    integer pattern_file;
    bit timing_checks_enabled = 1'b0;
    realtime last_rising_edge = -1.0;

    lab2_1 dut (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .A(A),
        .B(B),
        .out(out),
        .status(status)
    );

    initial begin : load_test_patterns
        pattern_file = $fopen("pattern_A.dat", "r");
        if (pattern_file == 0)
            $fatal(1, "Lab 2 Basic 1: FAIL (cannot open pattern_A.dat; add it as a simulation source with Copy sources into project)");
        $fclose(pattern_file);
        for (pattern_index = 0; pattern_index < PATTERN_NUM; pattern_index++)
            patterns[pattern_index] = 'x;
        $readmemb("pattern_A.dat", patterns);
        for (pattern_index = 0; pattern_index < PATTERN_NUM; pattern_index++) begin
            if ((^patterns[pattern_index]) === 1'bx)
                $fatal(1, "Lab 2 Basic 1: FAIL (pattern %0d is missing or contains X/Z; expected %0d complete binary patterns)", pattern_index, PATTERN_NUM);
        end
    end
    // ===== TA QUICK CHECK END =====

    initial begin
        clk = 1'b0;
        forever #(CYCLE/2) clk = ~clk;
    end

    always @(posedge clk)
        last_rising_edge = $realtime;

    // Reject combinational, falling-edge, asynchronous-reset, and delayed updates.
    always @(out or status) begin
        #0;
        if (timing_checks_enabled && ($realtime != last_rising_edge)) begin
            failure_count = failure_count + 1;
            $display("<ERROR> out/status changed away from a rising edge at t=%0t", $time);
        end
    end

    // Prevent a stalled or non-terminating simulation from appearing successful.
    initial begin
        #((PATTERN_NUM + 10) * CYCLE);
        $fatal(1, "Lab 2 Basic 1: FAIL (simulation timeout)");
    end

    initial begin
        rst = 1'b1;
        mode = 1'b0;
        A = 8'sd0;
        B = 8'sd0;
        pass_count = 0;

        // Allow the first synchronous reset edge to resolve initial unknowns.
        @(posedge clk);
        #1ns;
        timing_checks_enabled = 1'b1;

        for (pattern_index = 0;
             pattern_index < PATTERN_NUM;
             pattern_index = pattern_index + 1) begin
            @(negedge clk);
            {expected_rst, expected_mode, A, B,
             expected_out, expected_status} = patterns[pattern_index];
            rst = expected_rst;
            mode = expected_mode;

            @(posedge clk);
            #1ns;
            if ((out !== expected_out) || (status !== expected_status)) begin
                failure_count = failure_count + 1;
                $display("<ERROR> pattern %0d: rst=%b mode=%b A=%0d B=%0d out=%0d status=%b",
                         pattern_index, rst, mode, $signed(A), $signed(B),
                         $signed(out), status);
            end else begin
                pass_count = pass_count + 1;
            end
        end

        // Establish a nonzero result, then assert reset between rising edges.
        // An asynchronous-reset implementation must fail this synchronous lab.
        @(negedge clk);
        rst = 1'b0;
        mode = 1'b0;
        A = 8'sd1;
        B = 8'sd2;
        @(posedge clk);
        #1ns;
        if ((out !== 8'sd3) || (status !== 2'b01)) begin
            failure_count = failure_count + 1;
            $display("<ERROR> reset probe setup failed: out=%0d status=%b",
                     $signed(out), status);
        end
        #1ns rst = 1'b1;
        @(posedge clk);
        #1ns;
        if ((out !== 8'sd0) || (status !== 2'b00)) begin
            failure_count = failure_count + 1;
            $display("<ERROR> synchronous reset failed: out=%0d status=%b",
                     $signed(out), status);
        end

        if ((pass_count == PATTERN_NUM) && (failure_count == 0)) begin
            $display("========================================");
            $display("  Lab 2 Basic 1: PASS (%0d/%0d)",
                     pass_count, PATTERN_NUM);
            $display("========================================");
            $finish;
        end else begin
            $fatal(1, "Lab 2 Basic 1: FAIL (%0d/%0d patterns, %0d errors)",
                   pass_count, PATTERN_NUM, failure_count);
        end
    end

endmodule
