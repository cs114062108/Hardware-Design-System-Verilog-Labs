module Blinker (
    input  logic clk,
    input  logic blink_rst,
    input  logic blink_enable,
    output logic blinker
);

    logic blink_timer;
    timer #(.COUNT(50_000_000)) blink_time(.clk(clk), .rst(blink_rst), .enable(blink_enable), .tick(blink_timer));
    
    logic next_blinker;

    always_comb begin
        if (blink_rst) begin
            next_blinker = 1'b1;
        end else if (blink_enable) begin
            next_blinker = ~blinker;
        end else begin
            next_blinker = 1'b1;
        end
    end

endmodule