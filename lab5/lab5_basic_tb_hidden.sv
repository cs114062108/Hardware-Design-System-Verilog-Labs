`timescale 1ns/1ps
// Grading rule:
// Each test case is all-or-nothing. A test case receives 10 points only
// if all expected found outputs in that test case are correct.
module lab5_basic_tb_hidden;

    reg clk;
    reg rst;
    reg we;
    reg re;
    reg [7:0] din;
    wire found;

    lab5_basic basic (
        .clk   (clk),
        .rst   (rst),
        .we    (we),
        .re    (re),
        .din   (din),
        .found (found)
    );

    // ============================================================
    // Clock generation
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #4 clk = ~clk;
    end

    // ============================================================
    // Scoreboard variables
    // ============================================================
    integer total_score;
    integer testcase_score;
    integer total_testcases;
    integer passed_testcases;

    integer current_case_id;
    integer current_case_errors;
    integer current_case_patterns;

    integer total_patterns;
    integer total_errors;

    reg [8*128:1] current_case_name;

    // ============================================================
    // Start a test case
    // ============================================================
    task start_case;
        input integer case_id;
        input [8*128:1] case_name;
        begin
            current_case_id = case_id;
            current_case_name = case_name;
            current_case_errors = 0;
            current_case_patterns = 0;

            total_testcases = total_testcases + 1;

            $display("");
            $display("============================================================");
            $display("TC%0d: %0s", case_id, case_name);
            $display("============================================================");
        end
    endtask

    // ============================================================
    // End a test case
    // Each test case is all-or-nothing.
    // Full 10 points only if all patterns inside the test case pass.
    // ============================================================
    task end_case;
        begin
            if (current_case_errors == 0) begin
                total_score = total_score + testcase_score;
                passed_testcases = passed_testcases + 1;
                $display("[PASS] TC%0d passed. Score +%0d%%", current_case_id, testcase_score);
            end else begin
                $display("[FAIL] TC%0d failed with %0d error(s). Score +0%%",
                         current_case_id, current_case_errors);
            end
        end
    endtask

    // ============================================================
    // Apply one pattern and check found
    //
    // The input is applied before the rising edge.
    // The output is checked shortly after the rising edge.
    //
    // din[7:2] = data
    // din[1:0] = addr
    // ============================================================
    task apply_and_check;
        input        in_rst;
        input        in_we;
        input        in_re;
        input [7:0]  in_din;
        input        expected_found;
        input [8*160:1] description;

        begin
            @(negedge clk);
            rst = in_rst;
            we  = in_we;
            re  = in_re;
            din = in_din;

            @(posedge clk);
            #1;

            current_case_patterns = current_case_patterns + 1;
            total_patterns = total_patterns + 1;

            if (found !== expected_found) begin
                current_case_errors = current_case_errors + 1;
                total_errors = total_errors + 1;

                $display("[ERROR] TC%0d pattern %0d", current_case_id, current_case_patterns);
                $display("        %0s", description);
                $display("        rst=%0b we=%0b re=%0b din=0x%02h, expected found=%0b, got found=%0b",
                         in_rst, in_we, in_re, in_din, expected_found, found);
            end else begin
                $display("[ OK  ] TC%0d pattern %0d: %0s",
                         current_case_id, current_case_patterns, description);
            end
        end
    endtask

    // ============================================================
    // Main test sequence
    // ============================================================
    initial begin
        // Initialize signals
        rst = 1'b0;
        we  = 1'b0;
        re  = 1'b0;
        din = 8'h00;

        total_score = 0;
        testcase_score = 10;
        total_testcases = 0;
        passed_testcases = 0;
        total_patterns = 0;
        total_errors = 0;

        // Wait a little before starting
        repeat (2) @(posedge clk);

        $display("============================================================");
        $display("Grading Testbench");
        $display("There are 10 test cases. Each test case is worth 10%%.");
        $display("Each test case contains multiple input/output patterns.");
        $display("A test case gets 10%% only if all expected outputs are correct.");
        $display("============================================================");

        // ========================================================
        // Category 1: First-Slot Only, No Duplicate Data
        // 4 test cases x 10% = 40%
        //
        // Restriction:
        // - Each address uses only the first slot.
        // - No duplicate data is tested.
        // ========================================================

        // --------------------------------------------------------
        // TC01: Basic first-slot operation at addr 0,1
        // --------------------------------------------------------
        start_case(1, "First-Slot Only, No Duplicate Data: basic addr0,1 write/read");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 0, 1, 8'hA8, 0, "read data 42 at addr0 before write, expect not found");
        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0, found should hold previous 0");
        apply_and_check(0, 0, 1, 8'hA8, 1, "read data 42 at addr0 after write, expect found");
        apply_and_check(0, 0, 1, 8'hA9, 0, "read data 42 at addr1, not written, expect not found");
        apply_and_check(0, 0, 1, 8'hB8, 0, "read data 46 at addr0, not written, expect not found");
        apply_and_check(0, 0, 1, 8'hA8, 1, "read data 42 at addr0 after write, expect found");

        end_case();

        // --------------------------------------------------------
        // TC02: Basic first-slot operation at addr 0,1,2
        // --------------------------------------------------------
        start_case(2, "First-Slot Only, No Duplicate Data: basic addr0,1,2 write/read");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 0, 1, 8'hA9, 0, "read data 42 at addr1 before write, expect not found");
        apply_and_check(0, 1, 0, 8'hA9, 0, "write data 42 to addr1, found should hold previous 0");
        apply_and_check(0, 0, 1, 8'hA9, 1, "read data 42 at addr1 after write, expect found");
        apply_and_check(0, 0, 1, 8'hA8, 0, "same data at addr0 was not written, expect not found");
        apply_and_check(0, 0, 0, 8'hFF, 0, "re=0, found should hold previous 0");

        apply_and_check(0, 1, 0, 8'h00, 0, "write data 0 to addr0");
        apply_and_check(0, 0, 1, 8'h00, 1, "read data 0 at addr0, expect found");
        apply_and_check(0, 0, 0, 8'h67, 1, "re=0, found should hold previous 1");

        apply_and_check(0, 0, 1, 8'h02, 0, "read data 0 at addr2, expect not found");
        apply_and_check(0, 0, 0, 8'hBF, 0, "re=0, found should hold previous 0");
        apply_and_check(0, 0, 0, 8'hAF, 0, "re=0, found should hold previous 0");

        end_case();

        // --------------------------------------------------------
        // TC03: First slot across multiple addresses
        // --------------------------------------------------------
        start_case(3, "First-Slot Only, No Duplicate Data: one entry per address");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0");
        apply_and_check(0, 0, 1, 8'h01, 0, "read addr1 entry, expect not found");
        apply_and_check(0, 1, 0, 8'h01, 0, "write data 0 to addr1");
        apply_and_check(0, 1, 0, 8'h16, 0, "write data 5 to addr2");
        apply_and_check(0, 1, 0, 8'h3F, 0, "write data 15 to addr3");

        apply_and_check(0, 0, 1, 8'hA8, 1, "read addr0 entry, expect found");
        apply_and_check(0, 0, 1, 8'h01, 1, "read addr1 entry, expect found");
        apply_and_check(0, 0, 1, 8'hAA, 0, "read data 42 at addr2, expect not found");
        apply_and_check(0, 0, 1, 8'hAB, 0, "read data 42 at addr3, expect not found");
        apply_and_check(0, 0, 1, 8'h16, 1, "read addr2 entry, expect found");
        apply_and_check(0, 0, 1, 8'h3F, 1, "read addr3 entry, expect found");

        apply_and_check(0, 0, 1, 8'hB8, 0, "read missing data 46 at addr0, expect not found");

        end_case();

        // --------------------------------------------------------
        // TC04: Found transition behavior with first-slot only
        // --------------------------------------------------------
        start_case(4, "First-Slot Only, No Duplicate Data: found 0-to-1 and 1-to-0 transitions");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 0, 1, 8'h57, 0, "read missing data 21 at addr3, expect not found");
        apply_and_check(0, 1, 0, 8'h57, 0, "write data 21 to addr3, found should hold previous 0");
        apply_and_check(0, 0, 1, 8'h57, 1, "read data 21 at addr3, expect found");
        apply_and_check(0, 0, 1, 8'h7F, 0, "read missing data 31 at addr3, expect not found");
        apply_and_check(0, 0, 0, 8'h00, 0, "re=0, found should hold previous 0");

        end_case();

        // ========================================================
        // Category 2: No Duplicate Data
        // 3 test cases x 10% = 30%
        //
        // Restriction:
        // - Duplicate data is not tested.
        // - Each address may use more than one slot.
        // - Full-slot behavior may be tested.
        // ========================================================

        // --------------------------------------------------------
        // TC05: Two slots and full condition at addr0
        // --------------------------------------------------------
        start_case(5, "No Duplicate Data: addr0 uses two slots and rejects third value");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0, first slot");
        apply_and_check(0, 1, 0, 8'hB8, 0, "write data 46 to addr0, second slot");
        apply_and_check(0, 1, 0, 8'hE8, 0, "write data 58 to addr0, should be rejected because addr0 is full");

        apply_and_check(0, 0, 1, 8'hA8, 1, "read first value at addr0, expect found");
        apply_and_check(0, 0, 1, 8'hB8, 1, "read second value at addr0, expect found");
        apply_and_check(0, 0, 1, 8'hE8, 0, "read third rejected value at addr0, expect not found");

        end_case();

        // --------------------------------------------------------
        // TC06: Two slots and full condition at addr2
        // --------------------------------------------------------
        start_case(6, "No Duplicate Data: addr2 uses two slots and rejects third value");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 1, 0, 8'h16, 0, "write data 5 to addr2, first slot");
        apply_and_check(0, 1, 0, 8'h1A, 0, "write data 6 to addr2, second slot");
        apply_and_check(0, 1, 0, 8'h1E, 0, "write data 7 to addr2, should be rejected because addr2 is full");

        apply_and_check(0, 0, 1, 8'h1E, 0, "read rejected value at addr2, expect not found");
        apply_and_check(0, 0, 1, 8'h16, 1, "read first value at addr2, expect found");
        apply_and_check(0, 0, 1, 8'h1A, 1, "read second value at addr2, expect found");

        end_case();

        // --------------------------------------------------------
        // TC07: Multiple addresses with up to two slots
        // --------------------------------------------------------
        start_case(7, "No Duplicate Data: multiple addresses with capacity limit");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0");
        apply_and_check(0, 1, 0, 8'hB8, 0, "write data 46 to addr0");
        apply_and_check(0, 1, 0, 8'h16, 0, "write data 5 to addr2");
        apply_and_check(0, 1, 0, 8'h1A, 0, "write data 6 to addr2");

        apply_and_check(0, 0, 1, 8'hA8, 1, "read data 42 at addr0, expect found");
        apply_and_check(0, 0, 1, 8'hB8, 1, "read data 46 at addr0, expect found");
        apply_and_check(0, 0, 1, 8'h16, 1, "read data 5 at addr2, expect found");
        apply_and_check(0, 0, 1, 8'h1A, 1, "read data 6 at addr2, expect found");

        apply_and_check(0, 0, 1, 8'hE8, 0, "read missing data 58 at addr0, expect not found");
        apply_and_check(0, 0, 1, 8'h1E, 0, "read missing data 7 at addr2, expect not found");

        apply_and_check(0, 1, 0, 8'h02, 0, "write data 0 to addr2, should be rejected because addr2 is full");
        apply_and_check(0, 1, 0, 8'h01, 0, "write data 0 to addr1");
        apply_and_check(0, 0, 1, 8'h01, 1, "read data 0 at addr1, expect found");

        end_case();

        // ========================================================
        // Category 3: No Other Restriction
        // 3 test cases x 10% = 30%
        //
        // No restrictions:
        // - Duplicate data may appear.
        // - Multiple slots per address may be used.
        // - Full-slot conditions may be tested.
        // - Reset behavior may be tested.
        // - found hold behavior may be tested.
        // ========================================================

        // --------------------------------------------------------
        // TC08: Duplicate data should not consume second slot
        // --------------------------------------------------------
        start_case(8, "No Other Restriction: duplicate write should not consume slot");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0");
        apply_and_check(0, 0, 1, 8'hA8, 1, "read duplicate data 42 at addr0, expect found");
        apply_and_check(0, 1, 0, 8'hA8, 1, "duplicate write data 42 to addr0, should not consume another slot");
        apply_and_check(0, 0, 1, 8'hA9, 0, "read data 42 at addr1, expect not found");
        apply_and_check(0, 1, 0, 8'hB8, 0, "write data 46 to addr0, should still fit in second slot");
        apply_and_check(0, 0, 1, 8'hB8, 1, "read data 46 at addr0, expect found");
        apply_and_check(0, 1, 0, 8'hE8, 1, "write data 58 to addr0, should be rejected because addr0 is full");

        apply_and_check(0, 0, 1, 8'hA8, 1, "read duplicate data 42 at addr0, expect found");
        apply_and_check(0, 0, 1, 8'hB8, 1, "read data 46 at addr0, expect found");
        apply_and_check(0, 0, 1, 8'hE8, 0, "read data 58 at addr0, expect not found");
        apply_and_check(0, 0, 0, 8'h67, 0, "re=0, found should hold previous 0");

        end_case();

        // --------------------------------------------------------
        // TC09: Same data at different addresses is allowed
        // --------------------------------------------------------
        start_case(9, "No Other Restriction: same data at different addresses");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");
        apply_and_check(0, 1, 0, 8'h00, 0, "write data 0 to addr0");
        apply_and_check(0, 1, 0, 8'h00, 0, "duplicate write data 0 to addr0, should not consume another slot");
        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0");
        apply_and_check(0, 1, 0, 8'hA9, 0, "write same data 42 to addr1, should be allowed");
        apply_and_check(0, 1, 0, 8'hA8, 0, "duplicate write data 42 to addr0, should not consume another slot");

        apply_and_check(0, 0, 1, 8'hA8, 1, "read data 42 at addr0, expect found");

        apply_and_check(0, 0, 1, 8'hA9, 1, "read data 42 at addr1, expect found");
        apply_and_check(0, 0, 1, 8'hAA, 0, "read data 42 at addr2, not written, expect not found");
        apply_and_check(0, 0, 1, 8'hAB, 0, "read data 42 at addr3, not written, expect not found");

        end_case();

        // --------------------------------------------------------
        // TC10: found hold and reset clears storage
        // --------------------------------------------------------
        start_case(10, "No Other Restriction: found hold behavior and reset clears storage");

        apply_and_check(1, 0, 0, 8'h00, 0, "reset, found should be cleared to 0");

        apply_and_check(0, 1, 0, 8'hA8, 0, "write data 42 to addr0, found should hold previous 0");
        apply_and_check(0, 0, 1, 8'hA8, 1, "read data 42 at addr0, expect found");
        apply_and_check(0, 0, 0, 8'h00, 1, "re=0 after found=1, found should hold 1");
        apply_and_check(0, 0, 0, 8'hFF, 1, "re=0 again, found should still hold 1");

        apply_and_check(0, 0, 1, 8'hB8, 0, "read missing data 46 at addr0, found should become 0");
        apply_and_check(0, 0, 0, 8'hFF, 0, "re=0 after found=0, found should hold 0");

        apply_and_check(0, 1, 0, 8'hA8, 0, "duplicate write data 42 to addr0, should not consume another slot");
        apply_and_check(0, 1, 0, 8'hB8, 0, "write data 46 to addr0, found should hold previous 0");
        apply_and_check(0, 0, 1, 8'hA8, 1, "read data 42 at addr0, expect found");
        apply_and_check(0, 0, 1, 8'hC8, 0, "read miss data 50 at addr0, expect not found");
        apply_and_check(0, 0, 1, 8'hB8, 1, "read data 46 at addr0, expect found");

        apply_and_check(0, 0, 0, 8'h87, 1, "re=0 after found=1, found should hold 1");
        apply_and_check(1, 0, 0, 8'h00, 0, "reset again, found should be cleared to 0");
        apply_and_check(0, 0, 1, 8'hA8, 0, "after reset, old data 42 at addr0 should be gone");
        apply_and_check(0, 0, 1, 8'hB8, 0, "after reset, old data 46 at addr0 should be gone");

        end_case();

        // ========================================================
        // Final report
        // ========================================================
        $display("");
        $display("============================================================");
        $display("Final Grading Report");
        $display("============================================================");
        $display("Passed test cases : %0d / %0d", passed_testcases, total_testcases);
        $display("Total patterns    : %0d", total_patterns);
        $display("Total errors      : %0d", total_errors);
        $display("Final score       : %0d / 100", total_score);
        $display("============================================================");

        if (total_score == 100) begin
            $display("Result: FULL CREDIT");
        end else begin
            $display("Result: PARTIAL CREDIT");
        end

        $finish;
    end

endmodule