`timescale 1ns/1ps

module exam_A_tb;

    localparam time CLK_PERIOD        = 10ns;
    localparam int  FLUSH_CYCLES      = 5;
    localparam real POINT_PER_PATTERN = 0.1;
    localparam real MAX_SCORE         = 30.0;

    logic        clk;
    logic        rst_n;
    logic        data_in_enable;
    logic [7:0]  data_in;
    logic [7:0]  weight_0;
    logic [7:0]  weight_1;
    logic [7:0]  weight_2;
    logic [7:0]  weight_3;
    logic [7:0]  weight_4;
    logic [18:0] y;

    logic [18:0] exp_y = 0;

    logic [7:0] last_w0;
    logic [7:0] last_w1;
    logic [7:0] last_w2;
    logic [7:0] last_w3;
    logic [7:0] last_w4;

    int unsigned checked_pattern_count;
    int unsigned passed_pattern_count;
    int unsigned failed_pattern_count;
    int unsigned file_pattern_count;
    int unsigned golden_pattern_count;
    int unsigned error_count;
    int unsigned file_line_count;
    int unsigned golden_line_count;

    real current_score;

    integer testcase_file;
    integer golden_file;
    integer scan_count;

    string testcase_line;
    string golden_line;

    int unsigned file_rst_n;
    int unsigned file_enable;
    int unsigned file_data;
    int unsigned file_w0;
    int unsigned file_w1;
    int unsigned file_w2;
    int unsigned file_w3;
    int unsigned file_w4;

    fir_filter dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .data_in_enable (data_in_enable),
        .data_in        (data_in),
        .weight_0       (weight_0),
        .weight_1       (weight_1),
        .weight_2       (weight_2),
        .weight_3       (weight_3),
        .weight_4       (weight_4),
        .y              (y)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    task automatic print_separator;
        begin
            $display("======================================================================");
        end
    endtask

    task automatic print_title(input string title);
        begin
            $display("");
            print_separator();
            $display("  %s", title);
            print_separator();
        end
    endtask

    task automatic print_progress;
        begin
            current_score = passed_pattern_count * POINT_PER_PATTERN;

            $display(
                "[PROGRESS] patterns=%0d, passed=%0d, failed=%0d, errors=%0d, score=%0.1f/%0.1f, time=%0t",
                checked_pattern_count,
                passed_pattern_count,
                failed_pattern_count,
                error_count,
                current_score,
                MAX_SCORE,
                $time
            );
        end
    endtask

    task automatic print_reset_error(
        input string       error_name,
        input int          source_line,
        input logic [18:0] actual_y,
        input logic [18:0] expected_y
    );
        begin
            $display("");
            print_separator();
            $display("  [ERROR] %s", error_name);
            print_separator();
            $display("  Pattern         : %0d", file_pattern_count);
            $display("  File line       : %0d", source_line);
            $display("  Simulation time : %0t", $time);
            $display("  Actual y        : %0d", actual_y);
            $display("  Expected y      : %0d", expected_y);
            $display("  rst_n           : %0b", rst_n);
            print_separator();
        end
    endtask

    task automatic print_data_error(
        input int          source_line,
        input logic [18:0] actual_y,
        input logic [18:0] expected_y,
        input logic        rst_value,
        input logic        enable_value,
        input logic [7:0]  data_value,
        input logic [7:0]  w0,
        input logic [7:0]  w1,
        input logic [7:0]  w2,
        input logic [7:0]  w3,
        input logic [7:0]  w4
    );
        begin
            $display("");
            print_separator();

            if (source_line > 0)
                $display("  [ERROR] FIR OUTPUT MISMATCH");
            else
                $display("  [ERROR] FIR PIPELINE FLUSH MISMATCH");

            print_separator();

            if (source_line > 0) begin
                $display("  Pattern         : %0d", file_pattern_count);
                $display("  File line       : %0d", source_line);
            end
            else begin
                $display("  Pattern         : N/A (pipeline flush)");
            end

            $display("  Simulation time : %0t", $time);
            $display("  Actual y        : %0d", actual_y);
            $display("  Expected y      : %0d", expected_y);
            $display("  rst_n           : %0b", rst_value);
            $display("  data_in_enable  : %0b", enable_value);
            $display("  data_in         : %0d", data_value);
            $display("  weights         : {%0d, %0d, %0d, %0d, %0d}",
                     w0, w1, w2, w3, w4);
            print_separator();
        end
    endtask

    // Read one expected y from golden_A.dat.
    //
    // golden_A.dat format:
    //   expected_y

    task automatic read_next_golden(
        output logic [18:0] expected_y,
        input  string       usage_name
    );
        int          local_scan_count;
        int unsigned local_expected_y;
        logic        found;

        begin
            found            = 1'b0;
            local_expected_y = 0;

            while ((found !== 1'b1) && (!$feof(golden_file))) begin
                if ($fgets(golden_line, golden_file)) begin
                    golden_line_count = golden_line_count + 1;

                    local_scan_count = $sscanf(
                        golden_line,
                        "%d",
                        local_expected_y
                    );

                    if (local_scan_count === 1) begin
                        if (local_expected_y > 19'h7FFFF) begin
                            print_title("[FATAL] INVALID GOLDEN VALUE");
                            $display("  Golden line : %0d", golden_line_count);
                            $display("  Content     : %s", golden_line);
                            $display("  Expected y  : 0 to 524287");
                            print_separator();
                            $fatal(1);
                        end

                        expected_y = local_expected_y[18:0];
                        golden_pattern_count = golden_pattern_count + 1;
                        found = 1'b1;
                    end
                end
            end

            if (found !== 1'b1) begin
                print_title("[FATAL] GOLDEN FILE ENDED EARLY");
                $display("  Missing golden value for: %s", usage_name);
                $display("  Golden values already read: %0d", golden_pattern_count);
                print_separator();
                $fatal(1);
            end
        end
    endtask

    task automatic check_no_extra_golden;
        int          local_scan_count;
        int unsigned local_expected_y;
        logic        extra_found;

        begin
            extra_found = 1'b0;

            while (!$feof(golden_file)) begin
                if ($fgets(golden_line, golden_file)) begin
                    golden_line_count = golden_line_count + 1;
                    local_scan_count = $sscanf(golden_line, "%d", local_expected_y);

                    if (local_scan_count === 1)
                        extra_found = 1'b1;
                end
            end

            if (extra_found === 1'b1) begin
                print_title("[FATAL] EXTRA GOLDEN VALUES");
                $display("  golden_A.dat contains more expected values than required.");
                $display("  Required values consumed: %0d", golden_pattern_count);
                print_separator();
                $fatal(1);
            end
        end
    endtask

    task automatic drive_and_check(
        input logic        rst_value,
        input logic        enable_value,
        input logic [7:0]  data_value,
        input logic [7:0]  w0,
        input logic [7:0]  w1,
        input logic [7:0]  w2,
        input logic [7:0]  w3,
        input logic [7:0]  w4,
        input logic [18:0] expected_y,
        input int          source_line
    );
        int unsigned error_count_before;

        begin
            error_count_before = error_count;

            @(negedge clk);

            rst_n          = rst_value;
            data_in_enable = enable_value;
            data_in        = data_value;
            weight_0       = w0;
            weight_1       = w1;
            weight_2       = w2;
            weight_3       = w3;
            weight_4       = w4;

            last_w0 = w0;
            last_w1 = w1;
            last_w2 = w2;
            last_w3 = w3;
            last_w4 = w4;

            exp_y = expected_y;

            if (rst_value === 1'b0) begin
                #1;
                if (y !== expected_y) begin
                    error_count = error_count + 1;
                    print_reset_error(
                        "ASYNCHRONOUS RESET FAILED",
                        source_line,
                        y,
                        expected_y
                    );
                end

                @(posedge clk);
                #1;

                if (y !== expected_y) begin
                    error_count = error_count + 1;
                    print_reset_error(
                        "RESET-CYCLE OUTPUT FAILED",
                        source_line,
                        y,
                        expected_y
                    );
                end
            end
            else begin
                @(posedge clk);
                #1;

                if (y !== expected_y) begin
                    error_count = error_count + 1;

                    print_data_error(
                        source_line,
                        y,
                        expected_y,
                        rst_value,
                        enable_value,
                        data_value,
                        w0,
                        w1,
                        w2,
                        w3,
                        w4
                    );
                end
            end
            if (source_line > 0) begin
                checked_pattern_count = checked_pattern_count + 1;

                if (error_count === error_count_before)
                    passed_pattern_count = passed_pattern_count + 1;
                else
                    failed_pattern_count = failed_pattern_count + 1;
            end
        end
    endtask

    integer i;
    initial begin
        logic [18:0] golden_y;
        string       golden_usage;

        rst_n          = 1'b0;
        data_in_enable = 1'b0;
        data_in        = 8'd0;
        weight_0       = 8'd0;
        weight_1       = 8'd0;
        weight_2       = 8'd0;
        weight_3       = 8'd0;
        weight_4       = 8'd0;

        last_w0 = 8'd0;
        last_w1 = 8'd0;
        last_w2 = 8'd0;
        last_w3 = 8'd0;
        last_w4 = 8'd0;

        checked_pattern_count = 0;
        passed_pattern_count  = 0;
        failed_pattern_count  = 0;
        file_pattern_count    = 0;
        golden_pattern_count  = 0;
        error_count           = 0;
        file_line_count       = 0;
        golden_line_count     = 0;
        current_score         = 0.0;

        print_title("FIR FILTER TESTBENCH START");
        $display("  DUT module       : fir_filter");
        $display("  Testbench module : exam_A_tb");
        $display("  Clock period     : %0t", CLK_PERIOD);
        $display("  Testcase file    : testcase_A.dat");
        $display("  Golden file      : golden_A.dat");
        $display("  Points/pattern   : %0.1f", POINT_PER_PATTERN);
        $display("  Maximum score    : %0.1f", MAX_SCORE);
        print_separator();

        repeat (2) @(posedge clk);

        testcase_file = $fopen("testcase_A.dat", "r");
        golden_file   = $fopen("golden_A.dat", "r");

        if (testcase_file === 0) begin
            print_title("[FATAL] TESTCASE FILE OPEN FAILED");
            $display("  Cannot open testcase_A.dat");
            $display("  Add it to Simulation Sources or place it in the XSIM working directory.");
            print_separator();
            $fatal(1);
        end

        if (golden_file === 0) begin
            print_title("[FATAL] GOLDEN FILE OPEN FAILED");
            $display("  Cannot open golden_A.dat");
            $display("  Add it to Simulation Sources or place it in the XSIM working directory.");
            print_separator();
            $fatal(1);
        end

        print_title("TESTCASE AND GOLDEN FILES OPENED SUCCESSFULLY");

        // testcase_A.dat format:
        //
        // rst_n data_in_enable data_in weight_0 weight_1 weight_2 weight_3 weight_4

        // golden_A.dat format:
        //
        // expected_y

        while ($fgets(testcase_line, testcase_file)) begin
            file_line_count = file_line_count + 1;

            scan_count = $sscanf(
                testcase_line,
                "%d %d %d %d %d %d %d %d",
                file_rst_n,
                file_enable,
                file_data,
                file_w0,
                file_w1,
                file_w2,
                file_w3,
                file_w4
            );

            if (scan_count === 8) begin
                if (
                    (file_rst_n  > 1)   ||
                    (file_enable > 1)   ||
                    (file_data   > 255) ||
                    (file_w0     > 255) ||
                    (file_w1     > 255) ||
                    (file_w2     > 255) ||
                    (file_w3     > 255) ||
                    (file_w4     > 255)
                ) begin
                    print_title("[FATAL] INVALID TESTCASE VALUE");
                    $display("  File line: %0d", file_line_count);
                    $display("  Content  : %s", testcase_line);
                    $display("  Required ranges:");
                    $display("    rst_n, data_in_enable : 0 or 1");
                    $display("    data and weights      : 0 to 255");
                    print_separator();
                    $fatal(1);
                end

                file_pattern_count = file_pattern_count + 1;
                golden_usage = $sformatf("testcase pattern %0d (file line %0d)",
                                         file_pattern_count, file_line_count);
                read_next_golden(golden_y, golden_usage);

                drive_and_check(
                    file_rst_n[0],
                    file_enable[0],
                    file_data[7:0],
                    file_w0[7:0],
                    file_w1[7:0],
                    file_w2[7:0],
                    file_w3[7:0],
                    file_w4[7:0],
                    golden_y,
                    file_line_count
                );

                if ((file_pattern_count % 50) === 0)
                    print_progress();
            end
            else if (scan_count > 0) begin
                print_title("[FATAL] INVALID TESTCASE FORMAT");
                $display("  File line       : %0d", file_line_count);
                $display("  Parsed fields   : %0d", scan_count);
                $display("  Expected fields : 8");
                $display("  Content         : %s", testcase_line);
                $display("  Required format :");
                $display("    rst_n enable data w0 w1 w2 w3 w4");
                print_separator();
                $fatal(1);
            end
        end

        $fclose(testcase_file);

        current_score = passed_pattern_count * POINT_PER_PATTERN;

        print_title("TESTCASE FILE PROCESSING COMPLETED");
        $display("  Checked patterns : %0d", checked_pattern_count);
        $display("  Passed patterns  : %0d", passed_pattern_count);
        $display("  Failed patterns  : %0d", failed_pattern_count);
        $display("  Total errors     : %0d", error_count);
        $display("  Current score    : %0.1f / %0.1f", current_score, MAX_SCORE);
        print_separator();

        if (file_pattern_count === 0) begin
            print_title("[FATAL] NO VALID TEST PATTERNS");
            $display("  testcase_A.dat contains no valid 8-field patterns.");
            print_separator();
            $fatal(1);
        end

        print_title("FLUSHING FIR PIPELINE");

        for (i = 0; i < FLUSH_CYCLES; i = i + 1) begin
            golden_usage = $sformatf("pipeline flush cycle %0d", i + 1);
            read_next_golden(golden_y, golden_usage);

            drive_and_check(
                1'b1,
                1'b0,
                8'd0,
                last_w0,
                last_w1,
                last_w2,
                last_w3,
                last_w4,
                golden_y,
                0
            );
        end

        check_no_extra_golden();
        $fclose(golden_file);

        current_score = passed_pattern_count * POINT_PER_PATTERN;

        if (error_count === 0) begin
            $display("");
            $display("######################################################################");
            $display("#                                                                    #");
            $display("#                         TEST RESULT: PASS                          #");
            $display("#                                                                    #");
            $display("######################################################################");
            $display("  Checked patterns : %0d", checked_pattern_count);
            $display("  Passed patterns  : %0d", passed_pattern_count);
            $display("  Failed patterns  : %0d", failed_pattern_count);
            $display("  Total errors     : %0d", error_count);
            $display("  Final score      : %0.1f / %0.1f", current_score, MAX_SCORE);
            $display("  Finish time      : %0t", $time);
            $display("======================================================================");
        end
        else begin
            $display("");
            $display("######################################################################");
            $display("#                                                                    #");
            $display("#                         TEST RESULT: FAIL                          #");
            $display("#                                                                    #");
            $display("######################################################################");
            $display("  Checked patterns : %0d", checked_pattern_count);
            $display("  Passed patterns  : %0d", passed_pattern_count);
            $display("  Failed patterns  : %0d", failed_pattern_count);
            $display("  Total errors     : %0d", error_count);
            $display("  Final score      : %0.1f / %0.1f", current_score, MAX_SCORE);
            $display("  Finish time      : %0t", $time);
            $display("======================================================================");
            $fatal(1);
        end

        $finish;
    end

endmodule
