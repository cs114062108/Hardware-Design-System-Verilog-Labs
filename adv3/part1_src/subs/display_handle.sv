module Display_Handle (
    input  logic [1:0] state,
    input  logic [3:0] inp_ten, inp_one,
    input  logic [7:0] bcd_val1, bcd_val2,
    input  logic [3:0] sum_hundreds, sum_tens, sum_ones,
    input  logic blinker,
    output logic [3:0] dis_val1, dis_val2, dis_val3, dis_val4,
    output logic show1, show2, show3, show4
);

    localparam INITIAL = 2'b00;
    localparam SET1    = 2'b01;
    localparam SET2    = 2'b10;
    localparam RESULT  = 2'b11;

    always_comb begin
        case (state)
            INITIAL: begin
                dis_val1 = 4'd0;
                dis_val2 = 4'd0;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                show1 = 1'b0;
                show2 = 1'b0;
                show3 = 1'b0;
                show4 = 1'b0;
            end

            SET1: begin
                dis_val1 = inp_ten;         // Live values from switches
                dis_val2 = inp_one;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                show1 = blinker;
                show2 = blinker;
                show3 = 1'b1;
                show4 = 1'b1;
            end

            SET2: begin
                dis_val1 = bcd_val1[7:4];   // BCD Value 1, already locked
                dis_val2 = bcd_val1[3:0];
                dis_val3 = inp_ten;         // Live values from switches
                dis_val4 = inp_one;

                show1 = 1'b1;
                show2 = 1'b1;
                show3 = blinker;
                show4 = blinker;
            end

            RESULT: begin
                dis_val1 = 4'd0;
                dis_val2 = sum_hundreds;
                dis_val3 = sum_tens;
                dis_val4 = sum_ones;

                show1 = 1'b1;
                show2 = 1'b1;
                show3 = 1'b1;
                show4 = 1'b1;
            end

            default: begin
                dis_val1 = 4'd0;
                dis_val2 = 4'd0;
                dis_val3 = 4'd0;
                dis_val4 = 4'd0;

                show1 = 1'b0;
                show2 = 1'b0;
                show3 = 1'b0;
                show4 = 1'b0;
            end
        endcase
    end

endmodule