module BCD_Store (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] state,
    input  logic [3:0] inp_ten,
    input  logic [3:0] inp_one,
    output logic [7:0] bcd_val1,
    output logic [7:0] bcd_val2
);

    localparam INITIAL = 2'b00;
    localparam SET1    = 2'b01;
    localparam SET2    = 2'b10;
    localparam RESULT  = 2'b11;

    // Get input values and latch them
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            bcd_val1 <= 8'd0;
            bcd_val2 <= 8'd0;
        end else if (state == INITIAL) begin
            bcd_val1 <= 8'd0;
            bcd_val2 <= 8'd0;
        end else begin
            if (state == SET1) begin
                bcd_val1 <= {inp_ten, inp_one};
            end else if (state == SET2) begin
                bcd_val2 <= {inp_ten, inp_one};
            end
        end
    end

endmodule