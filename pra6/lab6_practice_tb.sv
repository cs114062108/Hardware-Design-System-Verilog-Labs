`timescale 1ns/1ps

module lab6_practice_tb0;

    // ---------------------------------------
    // Dump for GTKwave
    // ---------------------------------------
    initial begin
        $dumpfile("waves/pra6.vcd");
        $dumpvars(0, lab6_practice_tb0);
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
    logic ACK, Request;
    logic [3:0] Data;

    // ---------------------------------------
    // Master Unit
    // ---------------------------------------
    // Input
    logic master_rst;
    logic request_btn;
    logic [3:0] sw;

    // Output
    logic [3:0] master_LED;

    // Instantiate
    lab6_practice_master master_uut(
        .clk(master_clk),
        .rst(master_rst),
        .request_btn(request_btn),
        .sw(sw),
        .ACK(ACK),
        .Request(Request),
        .Data(Data),
        .led(master_LED)
    );

    // ---------------------------------------
    // Slave Unit
    // ---------------------------------------
    // Input
    logic slave_rst;

    // Output
    logic [3:0] slave_LED;

    // Instantiate
    lab6_practice_slave #(.COUNT(8)) slave_uut(
        .clk(slave_clk),
        .rst(slave_rst),
        .Request(Request),
        .Data(Data),
        .ACK(ACK),
        .led(slave_LED)
    );

    // ---------------------------------------
    // Test
    // ---------------------------------------
    // ---------------
    // Testcases
    // ---------------
    int unsigned test_index;
    int test_cnt = 2;
    int wait_period = 4;
    int proc_period = 14;

    logic [3:0] sws [0:3];

    initial begin
        sws[0] = 4'b0110;
        sws[1] = 4'b0111;
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
        request_btn = 1'b0;
        sw = 4'd0;

        #25;
        for (test_index = 0; test_index < test_cnt; test_index++) begin
            @(negedge clk);
            request_btn = 1'b1;
            sw = sws[test_index];

            repeat (2) @(posedge clk);
            sw = 4'd0;

            @(negedge clk);
            request_btn = 1'b0;

            repeat (proc_period) @(posedge clk);
        end

        $display("-------------------------------------------------------");

        @(negedge clk);
        for (int i = 0; i < wait_period; i++) begin
            repeat (2) @(posedge clk);
        end
        
        #1000ns;
        $finish;
    end

endmodule
