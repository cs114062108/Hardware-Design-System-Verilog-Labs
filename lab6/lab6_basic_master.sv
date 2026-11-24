module lab6_basic_master (
	input logic clk,
	input logic rst,
	input logic start_btn,
	input logic [2:0] sw, // switches
	input logic submit,
    input logic [2:0] num,

	output logic start,
	output logic [1:0] result,
    output logic ACK,
	output logic [2:0] led,
    output logic [1:0] state
);

    logic [1:0] next_state;
    localparam INIT_STATE = 2'b00;
    localparam GAME_STATE = 2'b01;
    localparam LOSE_STATE = 2'b10;
    localparam WIN_STATE = 2'b11;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= INIT_STATE;
        end else begin
            state <= next_state;
        end
    end

    logic ack_rst;
    logic ack_enable;
    logic ack_done;

    assign ack_enable = (state == LOSE_STATE || state == WIN_STATE);
    assign ack_rst = rst || !ack_enable;

    timer #(
        .COUNT(200_000_000)
    ) two_second_timer (
        .clk(clk),
        .rst(ack_rst),
        .enable(ack_enable),
        .tick(ack_done)
    );

    // Synchronizer (submit)
    logic submit_si, submit_s;
    always_ff @(posedge clk) begin
        submit_si <= submit;
        submit_s  <= submit_si;
    end

    // num register
    logic [2:0] num_reg;
    always_ff @(posedge clk) begin
        if (rst) begin
            num_reg <= 3'd0;
        end else begin
            num_reg <= num;
        end
    end

    logic [2:0] answer;
    always_ff @(posedge clk) begin
        // TODO: set `answer`
        if (rst) begin
            answer <= 3'd0;
        end else if (state == INIT_STATE && start_btn) begin
            answer <= sw;
        end
    end

    localparam LSR = 2'd0;
    localparam EQU = 2'd1;
    localparam GTR = 2'd2;

    localparam NOTHING = 3'b11;

    always_ff @(posedge clk) begin
        // TODO: encode the relation of `num` and `answer` to `result`
        if (rst || state == INIT_STATE) begin
            result <= NOTHING;
        end else if (state == GAME_STATE) begin
            if (num == answer) begin
                result <= EQU;
            end else if (num < answer) begin
                result <= LSR;
            end else begin
                result <= GTR;
            end
        end
    end

    always_comb begin
        next_state = state;

        // TODO: set `next_state`
        case (state)
            INIT_STATE: begin
               if (start_btn) begin
                    next_state = GAME_STATE;
               end else begin
                    next_state = INIT_STATE;
               end
            end

            GAME_STATE: begin
                if (submit_s) begin
                    if (result == EQU) begin
                        next_state = WIN_STATE;
                    end else begin
                        next_state = LOSE_STATE;
                    end
                end else begin
                    next_state = GAME_STATE;
                end
            end

            LOSE_STATE: begin
                if (ack_done) begin     // ack done
                    next_state = GAME_STATE;
                end else begin
                    next_state = LOSE_STATE;
                end
            end

            WIN_STATE: begin
                if (ack_done) begin     // only timer done, no ack
                    next_state = INIT_STATE;
                end else begin
                    next_state = WIN_STATE;
                end
            end

            default: next_state = INIT_STATE;
        endcase
    end

    always_comb begin
        // TODO: set `ACK` according to state
        case (state)
            LOSE_STATE: ACK = 1'b1;
            default: ACK = 1'b0;
        endcase
    end

    always_comb begin
        // TODO: set `led`
        case (state)
            INIT_STATE: led = 3'd0;
            GAME_STATE: led = answer;
            LOSE_STATE: led = answer;
            WIN_STATE:  led = answer;
            default: led = 3'd0;
        endcase
    end

    always_comb begin
        // TODO: set `start` according to state
        case (state)
            INIT_STATE: start = 1'b0;
            GAME_STATE: start = 1'b1;
            LOSE_STATE: start = 1'b0;
            WIN_STATE:  start = 1'b0;
            default: start = 1'b0;
        endcase
    end

endmodule

module timer #(
    parameter integer COUNT = 100_000_000
)(
    input logic clk,
    input logic rst,
    input logic enable,
    output logic tick
);

    logic [31:0] num;
    logic [31:0] next_num;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            num <= 32'd0;
        end else begin
            num <= next_num;
        end
    end

    assign next_num = (enable == 1'b0) ? 32'd0 :
                      (num == COUNT - 1) ? 32'd0 :
                      num + 1'b1;
    assign tick = enable && (num == COUNT - 1);
endmodule
