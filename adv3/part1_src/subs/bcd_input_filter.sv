module BCD_Input_Filter(
    input  logic [3:0] raw_ten,
    input  logic [3:0] raw_one,
    output logic [3:0] inp_ten,
    output logic [3:0] inp_one
);

    // Forces the input 2-Digit BCD to be valid
    assign inp_ten = (raw_ten <= 4'd9) ? raw_ten : 4'd9;
    assign inp_one = (raw_one <= 4'd9) ? raw_one : 4'd9;

endmodule