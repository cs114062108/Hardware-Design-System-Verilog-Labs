`timescale 1ns/1ps

module lab5_basic_tb;

    reg clk = 1'b0;
    reg rst = 1'b0;
    reg we  = 1'b0;
    reg re  = 1'b0;
    reg [7:0] din = 8'd0;

    wire found;

    integer file;
    integer scan_count;
    integer line_no;
    integer pattern_no;
    integer error_count;

    integer in_rst;
    integer in_we;
    integer in_re;
    integer in_din;
    integer exp_found;

    logic expected_found;

    reg [1023:0] line;

    // Clock period = 10ns
    always #5 clk = ~clk;

    // DUT
    lab5_basic basic (
        .clk(clk),
        .rst(rst),
        .we(we),
        .re(re),
        .din(din),
        .found(found)
    );

    task check_found;
        input expected;
        begin

            expected_found = expected;

            #1;
            if (found !== expected) begin
                $display("[ERROR] Pattern %0d, line %0d", pattern_no, line_no);
                $display("        input: rst=%0d we=%0d re=%0d din=0x%02h data=%0d addr=%0d",
                         rst, we, re, din, din[7:2], din[1:0]);
                $display("        expected found=%b, got found=%b", expected, found);
                error_count = error_count + 1;
            end
            else begin
                $display("[PASS ] Pattern %0d | rst=%0d we=%0d re=%0d din=0x%02h found=%b",
                         pattern_no, rst, we, re, din, found);
            end
        end
    endtask

    initial begin
        $display("==== Simulation Starts ====");

        error_count = 0;
        line_no = 0;
        pattern_no = 0;

        // Open pattern file
        file = $fopen("input_data.dat", "r");

        if (file == 0) begin
            $display("[ERROR] Failed to open input_data.dat");
            $display("        Please put input_data.dat in the simulation working directory.");
            $finish;
        end

        // Initialize inputs
        rst = 1'b0;
        we  = 1'b0;
        re  = 1'b0;
        din = 8'd0;

        // Read pattern file line by line
        while (!$feof(file)) begin
            line = "";
            void'($fgets(line, file));
            line_no = line_no + 1;

            // Expected line format:
            // rst we re din_hex expected_found
            //
            // Example:
            // 1 0 0 00 0
            // 0 1 0 A8 0
            // 0 0 1 A8 1
            scan_count = $sscanf(line, "%d %d %d %h %d",
                                  in_rst, in_we, in_re, in_din, exp_found);

            // Skip blank lines and comment lines.
            // Lines starting with # will have scan_count == 0.
            if (scan_count == 0) begin
                // skip
            end
            else if (scan_count != 5) begin
                $display("[PATTERN ERROR] Bad format at line %0d: %s", line_no, line);
                $display("                Expected format: rst we re din_hex expected_found");
                error_count = error_count + 1;
            end
            else begin
                pattern_no = pattern_no + 1;

                // Drive inputs before positive edge
                @(negedge clk);
                rst = in_rst[0];
                we  = in_we[0];
                re  = in_re[0];
                din = in_din[7:0];

                // Optional warning only.
                // Spec says testbench will not set we and re to 1 at the same time.
                if (we && re) begin
                    $display("[WARNING] Pattern %0d, line %0d has we=1 and re=1 at the same time.", pattern_no, line_no);
                    $display("          The spec says this situation will not occur.");
                end

                // Since the design is positive-edge triggered,
                // check found after the next posedge.
                @(posedge clk);
                check_found(exp_found[0]);
            end
        end

        $fclose(file);

        if (error_count == 0) begin
            $display("========================================");
            $display("==== All Test Cases Passed! ====");
            $display("==== Total patterns = %0d ====", pattern_no);
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("==== Simulation Failed ====");
            $display("==== Total patterns = %0d, errors = %0d ====", pattern_no, error_count);
            $display("========================================");
        end

        #20;
        $finish;
    end

endmodule