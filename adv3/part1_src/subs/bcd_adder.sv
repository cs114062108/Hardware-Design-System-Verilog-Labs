module BCD_adder (
    input  logic [7:0] bcd_val1,
    input  logic [7:0] bcd_val2,
    output logic [3:0] sum_hundreds,
    output logic [3:0] sum_tens,
    output logic [3:0] sum_ones
);

    // Convert BCD value to 8-bit Binary
    logic [7:0] bin_val1, bin_val2; // Max input value is 99, max sum is 198, requires 8 bit
    assign bin_val1 = {4'd0, bcd_val1[7:4]} * 8'd10 + {4'd0, bcd_val1[3:0]};
    assign bin_val2 = {4'd0, bcd_val2[7:4]} * 8'd10 + {4'd0, bcd_val2[3:0]};

    // Sum in Binary
    logic [7:0] bin_sum;
    assign bin_sum = bin_val1 + bin_val2;

    // Convert Binary sum to 3-Digit BCD
    assign sum_hundreds = bin_sum / 100;
    assign sum_tens     = (bin_sum % 100) / 10;
    assign sum_ones     = bin_sum % 10;

endmodule