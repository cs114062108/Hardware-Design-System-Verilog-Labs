`timescale 1ns/1ps

module lab6_basic_tb0;

    // ---------------------------------------
    // Dump for GTKwave
    // ---------------------------------------
    initial begin
        $dumpfile("waves/lab6.vcd");
        $dumpvars(0, lab6_basic_tb0);
    end

    // ---------------------------------------
    // Clock
    // ---------------------------------------
    localparam int CLK_Shift = 4;

    logic clk;
    logic master_clk;
    logic slave_clk;
    
    // Starting high places falling edges at 5, 15, 25, ... ns and rising
    // edges at 10, 20, 30, ... ns.
    initial begin
        clk = 1'b1;
        forever #5ns clk = ~clk;
    end

    initial begin
        master_clk = 1'b1;
        forever #5ns master_clk = ~master_clk;
    end

    initial begin
        slave_clk = 1'b1;
        #(CLK_Shift);
        forever #5ns slave_clk = ~slave_clk;
    end

    // ---------------------------------------
    // Connect
    // ---------------------------------------
    // --- master -> slave ---
    logic start;
    logic [1:0] result;
    logic ACK;

    // --- slave -> master ---
    logic submit;
    logic [2:0] num;

    // ---------------------------------------
    // Master Unit
    // ---------------------------------------
    // Input
    logic master_rst;
    logic start_btn;
    logic [2:0] master_sw;

    // Output
    logic [2:0] master_LED;
    logic [1:0] master_state;

    // Instantiate
    lab6_basic_master #(.COUNT(4)) master_uut(
        .clk(master_clk),
        .rst(master_rst),
        .start_btn(start_btn),
        .sw(master_sw),
        .submit(submit), .num(num),                   // master <- slave
        .start(start), .result(result), .ACK(ACK),    // master -> slave
        .led(master_LED),
        .state(master_state)
    );

    // ---------------------------------------
    // Slave Unit
    // ---------------------------------------
    // Input
    logic slave_rst;
    logic submit_btn;
    logic [2:0] slave_sw;

    // Output
    logic [2:0] slave_LED;
    logic [1:0] slave_state;

    // Instantiate
    lab6_basic_slave slave_uut(
        .clk(slave_clk),
        .rst(slave_rst),
        .submit_btn(submit_btn),
        .sw(slave_sw),
        .start(start), .result(result), .ACK(ACK),    // master -> slave
        .submit(submit), .num(num),                   // master <- slave
        .led(slave_LED),
        .state(slave_state)
    );

    // ---------------------------------------
    // Test
    // ---------------------------------------
    // ---------------
    // Testcases
    // ---------------
    localparam TEST_CNT = 4;

    int unsigned test_index;
    int test_cnt = TEST_CNT;
    int wait_time = 4;
    
    int proc_periods [0:TEST_CNT-1];
    int proc_period = 8;

    logic start_btns  [0:TEST_CNT-1];
    logic submit_btns [0:TEST_CNT-1];
    logic [2:0] master_sws [0:TEST_CNT-1];
    logic [2:0] slave_sws  [0:TEST_CNT-1];

    initial begin
        start_btns[0]  = 1'b1;
        submit_btns[0] = 1'b0;
        master_sws[0]  = 3'b110;
        slave_sws[0]   = 3'b000;
        proc_periods[0] = 1;

        start_btns[1]  = 1'b0;
        submit_btns[1] = 1'b1;
        master_sws[1]  = 3'b000;
        slave_sws[1]   = 3'b001;
        proc_periods[1] = 8;

        start_btns[2]  = 1'b0;
        submit_btns[2] = 1'b1;
        master_sws[2]  = 3'b000;
        slave_sws[2]   = 3'b111;
        proc_periods[2] = 8;

        start_btns[3]  = 1'b0;
        submit_btns[3] = 1'b1;
        master_sws[3]  = 3'b000;
        slave_sws[3]   = 3'b110;
        proc_periods[3] = 8;
    end
    
    // Resets (Synchronous)
    initial begin
        master_rst = 1'b0;
        
        #6ns;   // At 6 ns
        master_rst = 1'b1;

        #6ns;   // At 12 ns
        master_rst = 1'b0;
    end

    initial begin
        slave_rst = 1'b0;
        
        #(CLK_Shift);

        #6ns;   // At 6+4 ns
        slave_rst = 1'b1;

        #6ns;   // At 12+4 ns
        slave_rst = 1'b0;
    end

    // Run
    initial begin
        start_btn = 1'b0;
        master_sw = 3'd0;

        submit_btn = 1'b0;
        slave_sw = 3'd0;

        #25;
        for (test_index = 0; test_index < test_cnt; test_index++) begin
            proc_period = proc_periods[test_index];
            
            @(negedge clk);
            start_btn = start_btns[test_index];
            submit_btn = submit_btns[test_index];
            master_sw = master_sws[test_index];
            slave_sw = slave_sws[test_index];

            repeat (2) @(posedge clk);
            start_btn = 1'b0;
            submit_btn = 1'b0;
            master_sw = 3'd0;
            slave_sw = 3'd0;

            repeat (proc_period) @(posedge clk);
        end

        $display("-------------------------------------------------------");

        @(negedge clk);
        for (int i = 0; i < wait_time; i++) begin
            repeat (2) @(posedge clk);
        end
        
        #1000ns;
        $finish;
    end

endmodule
