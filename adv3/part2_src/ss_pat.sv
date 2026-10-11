`timescale 1ns/1ps

module SevenSegPat (
    input  logic [3:0] value,
    input  logic dot,
    input  logic show,
    output logic [7:0] display,
    output logic dp
);
    
    always_comb begin
        if (show) begin
            case (value)
                // Zero means on:  ABC_DEFG
                4'd0: display = 7'b110_1010;   // n
                4'd1: display = 7'b111_0000;   // t
                4'd2: display = 7'b110_1000;   // h
                4'd3: display = 7'b110_0011;   // u

                4'd4: display = 7'b011_0000;   // E
                4'd5: display = 7'b011_0000;   // E
                4'd6: display = 7'b011_0001;   // C
                4'd7: display = 7'b010_0100;   // S (5)
                
                4'd8: display = 7'b001_0010;   // 2
                4'd9: display = 7'b000_0001;   // 0
                4'ha: display = 7'b001_0010;   // 2
                4'hb: display = 7'b010_0000;   // 6

                default: display = 7'b111_1110;
            endcase
        end else begin
            display = 7'b111_1111;
        end
    end

    assign dp = ~dot;

endmodule
