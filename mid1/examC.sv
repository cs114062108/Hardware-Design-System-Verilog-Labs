// Student ID Name

`timescale 1ns / 1ps

module exam_C (
    input logic clk,
    input logic rst_n,
    input logic push,
    input logic step,
    input logic [7:0] sw,
    output logic [3:0] DIGIT,
    output logic [6:0] DISPLAY,
    output logic [15:0] LED
);
    logic fir_clk;
    logic [28:0] fir_counter;
    
    assign LED[15] = fir_counter[28];

    // TODO: Write your code here

    

    logic [18:0] fir_y;

    fir_filter u_fir (
        .clk (fir_clk),
        .rst_n (),
        .data_in_enable (),
        .data_in (),
        .weight_0 (8'd1),
        .weight_1 (8'd2),
        .weight_2 (8'd3),
        .weight_3 (8'd4),
        .weight_4 (8'd5),
        .y (fir_y)
    );

    SevenSegment u_display (
        .clk (clk),
        .rst_n (rst_n),
        .value (fir_y[15:0]),
        .DIGIT (DIGIT),
        .DISPLAY (DISPLAY)
    );


    // Clock divider
    localparam int COUNT_MAX = 300_000_000 - 1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fir_counter <= 29'd0;
            fir_clk <= 1'b0;
        end
        else begin
            if (fir_counter == COUNT_MAX) begin
                fir_counter <= 29'd0;
                fir_clk <= 1'b1;
            end
            else begin
                fir_counter <= fir_counter + 29'd1;
                fir_clk <= 1'b0;
            end
        end
    end
endmodule


module SevenSegment (
    input logic clk,
    input logic rst_n,
    input logic [15:0] value,
    output logic [3:0] DIGIT,
    output logic [6:0] DISPLAY
);

    logic [16:0] refresh_count;
    logic [1:0] digit_select;
    logic [3:0] hex_value;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            refresh_count <= 17'd0;
        else
            refresh_count <= refresh_count + 17'd1;
    end

    assign digit_select = refresh_count[16:15];

    always_comb begin
        case (digit_select)
            2'b00: begin
                DIGIT = 4'b1110;
                hex_value = value[3:0];
            end
            2'b01: begin
                DIGIT = 4'b1101;
                hex_value = value[7:4];
            end
            2'b10: begin
                DIGIT = 4'b1011;
                hex_value = value[11:8];
            end
            default: begin
                DIGIT = 4'b0111;
                hex_value = value[15:12];
            end
        endcase

        case (hex_value)
            4'h0: DISPLAY = 7'b1000000;
            4'h1: DISPLAY = 7'b1111001;
            4'h2: DISPLAY = 7'b0100100;
            4'h3: DISPLAY = 7'b0110000;
            4'h4: DISPLAY = 7'b0011001;
            4'h5: DISPLAY = 7'b0010010;
            4'h6: DISPLAY = 7'b0000010;
            4'h7: DISPLAY = 7'b1111000;
            4'h8: DISPLAY = 7'b0000000;
            4'h9: DISPLAY = 7'b0010000;
            4'hA: DISPLAY = 7'b0001000;
            4'hB: DISPLAY = 7'b0000011;
            4'hC: DISPLAY = 7'b1000110;
            4'hD: DISPLAY = 7'b0100001;
            4'hE: DISPLAY = 7'b0000110;
            4'hF: DISPLAY = 7'b0001110;
            default: DISPLAY = 7'b1111111;
        endcase
    end
endmodule