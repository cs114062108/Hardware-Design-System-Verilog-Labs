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
    logic clk;
    
    // Starting high places falling edges at 5, 15, 25, ... ns and rising
    // edges at 10, 20, 30, ... ns.
    initial begin
        clk = 1'b1;
        forever #5ns clk = ~clk;
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
        .clk(clk),
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
    lab6_practice_slave #(.COUNT(2)) slave_uut(
        .clk(clk),
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
    int wait_clk = 4;
    int proc_clk = 12;

    logic [3:0] sws [0:3];

    initial begin
        sws[0] = 4'b0110;
        sws[1] = 4'b0111;
    end
    
    // Resets (Synchronous)
    initial begin
        master_rst = 1'b0;
        slave_rst = 1'b0;
        
        #6ns;   // At 1 ns
        master_rst = 1'b1;
        slave_rst = 1'b1;

        #6ns;   // At 12 ns
        master_rst = 1'b0;
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

            @(negedge clk);
            request_btn = 1'b0;

            repeat (4) @(posedge clk);
        end

        $display("-------------------------------------------------------");

        @(negedge clk);
        for (int i = 0; i < wait_clk; i++) begin
            repeat (2) @(posedge clk);
        end
        #20;
        $finish;
    end

endmodule
