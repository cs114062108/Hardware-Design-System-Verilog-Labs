// Student ID Name
`timescale 1ns/1ps

module exam_B_tb;

    localparam time CLK_PERIOD         = 10ns;
    localparam int  FIFO_DEPTH         = 12;
    localparam int  FINAL_FLUSH_CYCLES = 1;

    localparam real POINT_PER_PATTERN = 0.1;
    localparam real MAX_SCORE         = 40.0;

    logic       clk;
    logic       rst_n;
    logic [7:0] data_in;
    logic       push_data;
    logic       pop_data;

    logic [7:0] data_out;
    logic       full;
    logic       empty;

    logic [7:0] exp_data_out;
    logic       exp_full;
    logic       exp_empty;

    // ================================================================
    // Test statistics
    // ================================================================
    int unsigned checked_pattern_count;
    int unsigned passed_pattern_count;
    int unsigned failed_pattern_count;
    int unsigned file_pattern_count;
    int unsigned golden_pattern_count;
    int unsigned error_count;
    int unsigned file_line_count;
    int unsigned golden_line_count;

    real current_score;

    // ================================================================
    // Pattern-file variables
    // ================================================================
    integer testcase_file;
    integer golden_file;
    integer scan_count;

    reg [8*512-1:0] testcase_line;
    reg [8*512-1:0] golden_line;

    int unsigned file_rst_n;
    int unsigned file_push_data;
    int unsigned file_pop_data;
    int unsigned file_data_in;

    // ================================================================
    // DUT
    // ================================================================
    FIFO dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .data_in   (data_in),
        .push_data (push_data),
        .pop_data  (pop_data),
        .data_out  (data_out),
        .full      (full),
        .empty     (empty)
    );

    // ================================================================
    // Clock generation
    // ================================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // ================================================================
    // Log helpers
    // ================================================================
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
        input string      error_name,
        input int         source_line,
        input logic [7:0] expected_data_out,
        input logic       expected_full,
        input logic       expected_empty
    );
        begin
            $display("");
            print_separator();
            $display("  [ERROR] %s", error_name);
            print_separator();
            $display("  Pattern          : %0d", file_pattern_count);
            $display("  File line        : %0d", source_line);
            $display("  Simulation time  : %0t", $time);
            $display("  Actual data_out  : %0d", data_out);
            $display("  Expected data_out: %0d", expected_data_out);
            $display("  Actual full      : %0b", full);
            $display("  Expected full    : %0b", expected_full);
            $display("  Actual empty     : %0b", empty);
            $display("  Expected empty   : %0b", expected_empty);
            $display("  rst_n            : %0b", rst_n);
            print_separator();
        end
    endtask

    task automatic print_fifo_error(
        input int         source_line,
        input logic [7:0] expected_data_out,
        input logic       expected_full,
        input logic       expected_empty,
        input logic       rst_value,
        input logic       push_value,
        input logic       pop_value,
        input logic [7:0] data_value
    );
        begin
            $display("");
            print_separator();

            if (source_line > 0)
                $display("  [ERROR] FIFO OUTPUT MISMATCH");
            else
                $display("  [ERROR] FIFO INPUT-PIPELINE FLUSH MISMATCH");

            print_separator();

            if (source_line > 0) begin
                $display("  Pattern          : %0d", file_pattern_count);
                $display("  File line        : %0d", source_line);
            end
            else begin
                $display("  Pattern          : N/A (pipeline flush)");
            end

            $display("  Simulation time  : %0t", $time);
            $display("  Actual data_out  : %0d", data_out);
            $display("  Expected data_out: %0d", expected_data_out);
            $display("  Actual full      : %0b", full);
            $display("  Expected full    : %0b", expected_full);
            $display("  Actual empty     : %0b", empty);
            $display("  Expected empty   : %0b", expected_empty);
            $display("  rst_n            : %0b", rst_value);
            $display("  push_data        : %0b", push_value);
            $display("  pop_data         : %0b", pop_value);
            $display("  data_in          : %0d", data_value);
            print_separator();
        end
    endtask


    task automatic read_next_golden(
        output logic [7:0] expected_data_out,
        output logic       expected_full,
        output logic       expected_empty,
        input  string      usage_name
    );
        int          local_scan_count;
        int unsigned local_data_out;
        int unsigned local_full;
        int unsigned local_empty;
        logic        found;

        begin
            found          = 1'b0;
            local_data_out = 0;
            local_full     = 0;
            local_empty    = 0;

            while ((found !== 1'b1) && (!$feof(golden_file))) begin
                if ($fgets(golden_line, golden_file)) begin
                    golden_line_count = golden_line_count + 1;

                    local_scan_count = $sscanf(
                        golden_line,
                        "%d %d %d",
                        local_data_out,
                        local_full,
                        local_empty
                    );

                    if (local_scan_count === 3) begin
                        if (
                            (local_data_out > 255) ||
                            (local_full     > 1)   ||
                            (local_empty    > 1)
                        ) begin
                            print_title("[FATAL] INVALID GOLDEN VALUE");
                            $display("  Golden line : %0d", golden_line_count);
                            $display("  Content     : %s", golden_line);
                            $display("  Required ranges:");
                            $display("    expected_data_out : 0 to 255");
                            $display("    expected_full     : 0 or 1");
                            $display("    expected_empty    : 0 or 1");
                            print_separator();
                            $fatal(1);
                        end

                        expected_data_out = local_data_out[7:0];
                        expected_full     = local_full[0];
                        expected_empty    = local_empty[0];

                        golden_pattern_count = golden_pattern_count + 1;
                        found = 1'b1;
                    end
                    else if (local_scan_count > 0) begin
                        print_title("[FATAL] INVALID GOLDEN FORMAT");
                        $display("  Golden line     : %0d", golden_line_count);
                        $display("  Parsed fields   : %0d", local_scan_count);
                        $display("  Expected fields : 3");
                        $display("  Content         : %s", golden_line);
                        $display("  Required format : data_out full empty");
                        print_separator();
                        $fatal(1);
                    end
                end
            end

            if (found !== 1'b1) begin
                print_title("[FATAL] GOLDEN FILE ENDED EARLY");
                $display("  Missing golden value for: %s", usage_name);
                $display("  Golden tuples already read: %0d", golden_pattern_count);
                print_separator();
                $fatal(1);
            end
        end
    endtask

    // ================================================================
    // Ensure golden_B.dat has exactly the required number of tuples.
    // ================================================================
    task automatic check_no_extra_golden;
        int          local_scan_count;
        int unsigned local_data_out;
        int unsigned local_full;
        int unsigned local_empty;
        logic        extra_found;

        begin
            extra_found = 1'b0;

            while (!$feof(golden_file)) begin
                if ($fgets(golden_line, golden_file)) begin
                    golden_line_count = golden_line_count + 1;

                    local_scan_count = $sscanf(
                        golden_line,
                        "%d %d %d",
                        local_data_out,
                        local_full,
                        local_empty
                    );

                    if (local_scan_count === 3)
                        extra_found = 1'b1;
                    else if (local_scan_count > 0) begin
                        print_title("[FATAL] INVALID GOLDEN FORMAT");
                        $display("  Golden line     : %0d", golden_line_count);
                        $display("  Parsed fields   : %0d", local_scan_count);
                        $display("  Expected fields : 3");
                        $display("  Content         : %s", golden_line);
                        print_separator();
                        $fatal(1);
                    end
                end
            end

            if (extra_found === 1'b1) begin
                print_title("[FATAL] EXTRA GOLDEN VALUES");
                $display("  golden_B.dat contains more expected tuples than required.");
                $display("  Required tuples consumed: %0d", golden_pattern_count);
                print_separator();
                $fatal(1);
            end
        end
    endtask

    task automatic drive_and_check(
        input logic       rst_value,
        input logic       push_value,
        input logic       pop_value,
        input logic [7:0] input_value,
        input logic [7:0] expected_data_out,
        input logic       expected_full,
        input logic       expected_empty,
        input int         source_line
    );
        int unsigned error_count_before;

        begin
            error_count_before = error_count;

            @(negedge clk);

            rst_n     = rst_value;
            push_data = push_value;
            pop_data  = pop_value;
            data_in   = input_value;

            exp_data_out = expected_data_out;
            exp_full = expected_full;
            exp_empty = expected_empty;

            if (rst_value === 1'b0) begin
                #1;

                if (
                    (data_out !== expected_data_out) ||
                    (full     !== expected_full)     ||
                    (empty    !== expected_empty)
                ) begin
                    error_count = error_count + 1;
                    print_reset_error(
                        "ASYNCHRONOUS RESET FAILED",
                        source_line,
                        expected_data_out,
                        expected_full,
                        expected_empty
                    );
                end

                @(posedge clk);
                #1;

                if (
                    (data_out !== expected_data_out) ||
                    (full     !== expected_full)     ||
                    (empty    !== expected_empty)
                ) begin
                    error_count = error_count + 1;
                    print_reset_error(
                        "RESET-CYCLE OUTPUT FAILED",
                        source_line,
                        expected_data_out,
                        expected_full,
                        expected_empty
                    );
                end
            end
            else begin
                @(posedge clk);
                #1;

                if (
                    (data_out !== expected_data_out) ||
                    (full     !== expected_full)     ||
                    (empty    !== expected_empty)
                ) begin
                    error_count = error_count + 1;

                    print_fifo_error(
                        source_line,
                        expected_data_out,
                        expected_full,
                        expected_empty,
                        rst_value,
                        push_value,
                        pop_value,
                        input_value
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

    // ================================================================
    // Main test process
    // ================================================================
    integer i;

    initial begin
        logic [7:0] golden_data_out;
        logic       golden_full;
        logic       golden_empty;
        string      golden_usage;

        rst_n     = 1'b0;
        push_data = 1'b0;
        pop_data  = 1'b0;
        data_in   = 8'd0;

        checked_pattern_count = 0;
        passed_pattern_count  = 0;
        failed_pattern_count  = 0;
        file_pattern_count    = 0;
        golden_pattern_count  = 0;
        error_count           = 0;
        file_line_count       = 0;
        golden_line_count     = 0;
        current_score         = 0.0;

        print_title("FIFO TESTBENCH START");
        $display("  DUT module       : FIFO");
        $display("  Testbench module : exam_B_tb");
        $display("  FIFO depth       : %0d", FIFO_DEPTH);
        $display("  Clock period     : %0t", CLK_PERIOD);
        $display("  Testcase file    : testcase_B.dat");
        $display("  Golden file      : golden_B.dat");
        $display("  Points/pattern   : %0.1f", POINT_PER_PATTERN);
        $display("  Maximum score    : %0.1f", MAX_SCORE);
        print_separator();

        repeat (2) @(posedge clk);

        testcase_file = $fopen("testcase_B.dat", "r");
        golden_file   = $fopen("golden_B.dat", "r");

        if (testcase_file === 0) begin
            print_title("[FATAL] TESTCASE FILE OPEN FAILED");
            $display("  Cannot open testcase_B.dat");
            $display("  Add it to Simulation Sources or place it in the XSIM working directory.");
            print_separator();
            $fatal(1);
        end

        if (golden_file === 0) begin
            print_title("[FATAL] GOLDEN FILE OPEN FAILED");
            $display("  Cannot open golden_B.dat");
            $display("  Add it to Simulation Sources or place it in the XSIM working directory.");
            print_separator();
            $fatal(1);
        end

        print_title("TESTCASE AND GOLDEN FILES OPENED SUCCESSFULLY");

        // testcase_B.dat format:
        //
        // rst_n push_data pop_data data_in

        // golden_B.dat format:
        //
        // expected_data_out expected_full expected_empty


        while ($fgets(testcase_line, testcase_file)) begin
            file_line_count = file_line_count + 1;

            scan_count = $sscanf(
                testcase_line,
                "%d %d %d %d",
                file_rst_n,
                file_push_data,
                file_pop_data,
                file_data_in
            );

            if (scan_count === 4) begin
                if (
                    (file_rst_n     > 1)   ||
                    (file_push_data > 1)   ||
                    (file_pop_data  > 1)   ||
                    (file_data_in   > 255)
                ) begin
                    print_title("[FATAL] INVALID TESTCASE VALUE");
                    $display("  File line: %0d", file_line_count);
                    $display("  Content  : %s", testcase_line);
                    $display("  Required ranges:");
                    $display("    rst_n, push_data, pop_data : 0 or 1");
                    $display("    data_in                    : 0 to 255");
                    print_separator();
                    $fatal(1);
                end

                file_pattern_count = file_pattern_count + 1;

                golden_usage = $sformatf(
                    "testcase pattern %0d (file line %0d)",
                    file_pattern_count,
                    file_line_count
                );

                read_next_golden(
                    golden_data_out,
                    golden_full,
                    golden_empty,
                    golden_usage
                );

                drive_and_check(
                    file_rst_n[0],
                    file_push_data[0],
                    file_pop_data[0],
                    file_data_in[7:0],
                    golden_data_out,
                    golden_full,
                    golden_empty,
                    file_line_count
                );

                if ((file_pattern_count % 50) === 0)
                    print_progress();
            end
            else if (scan_count > 0) begin
                print_title("[FATAL] INVALID TESTCASE FORMAT");
                $display("  File line       : %0d", file_line_count);
                $display("  Parsed fields   : %0d", scan_count);
                $display("  Expected fields : 4");
                $display("  Content         : %s", testcase_line);
                $display("  Required format : rst_n push_data pop_data data_in");
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
            $display("  testcase_B.dat contains no valid 4-field patterns.");
            print_separator();
            $fatal(1);
        end

        print_title("FINAL INPUT-PIPELINE FLUSH");

        for (i = 0; i < FINAL_FLUSH_CYCLES; i = i + 1) begin
            golden_usage = $sformatf("final pipeline flush cycle %0d", i + 1);

            read_next_golden(
                golden_data_out,
                golden_full,
                golden_empty,
                golden_usage
            );

            drive_and_check(
                1'b1,
                1'b0,
                1'b0,
                8'd0,
                golden_data_out,
                golden_full,
                golden_empty,
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
