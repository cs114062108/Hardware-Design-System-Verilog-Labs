`timescale 1ns/1ps

module lab2_2 (
    input  logic       clk,
    input  logic       rst,
    input  logic       load,
    input  logic [7:0] N,
    output logic [7:0] out,
    output logic       done
);

    // Implement your design here.
    localparam IDLE = 2'b00;
    localparam PROC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    reg [7:0] num;
    wire [7:0] next_num;

    always_comb begin
        case (state)
            IDLE: begin
                if (load) begin
                    if (N == 0) begin
                        next_state = DONE;
                    end else begin
                        next_state = PROC;
                    end
                end else begin
                    next_state = IDLE;
                end
            end

            PROC: begin
                if (next_num == 8'd0) begin
                    next_state = DONE;
                end else begin
                    next_state = PROC;
                end
            end

            DONE: begin
                /*
                if (load == 1'b1 && N == 8'd0) begin
                    next_state = DONE;
                end else begin
                    next_state = IDLE;
                end
                */
                next_state = IDLE; // straight from lab (39/40)
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    assign done = (state == DONE) ? 1'b1 : 1'b0;

    assign next_num = (num > 0) ? (num - 1) : 8'd0;

    always_ff @(posedge clk) begin
        if (rst) begin
            num <= 8'd0;
        end else if (load) begin
            num <= N;
        end else begin
            num <= next_num;
        end
    end

    assign out = num;

endmodule
