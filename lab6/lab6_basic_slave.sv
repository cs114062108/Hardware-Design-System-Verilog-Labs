module lab6_basic_slave(
    input logic clk,
    input logic rst,
    input logic submit_btn,
    input logic [2:0] sw,
    input logic start,
    input logic [1:0] result,
    input logic ACK,

    output logic submit,
    output logic [2:0] num,
    output logic [2:0] led,
    output logic [1:0] state
);

    parameter INIT_STATE = 2'd0;
    parameter GUESS_STATE = 2'd1;
    parameter WAIT_STATE = 2'd2;
    parameter SHOW_STATE = 2'd3;

    logic [1:0] next_state;
    logic [2:0] next_num;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= INIT_STATE;
            num <= 0;
        end else begin
            state <= next_state;
            num <= next_num;
        end
    end

    logic ack_si, ack_s;
    always_ff @(posedge clk) begin
        if (rst) begin
            ack_si <= 1'b0;
            ack_s <= 1'b0;
        end else begin
            ack_si <= ACK;
            ack_s <= ack_si;
        end    
    end


    always_comb begin
        // TODO: set `next_state`
        case (state)
            INIT_STATE: begin
                if (start) begin
                    next_state = GUESS_STATE;
                end else begin
                    next_state = INIT_STATE;
                end
            end

            GUESS_STATE: begin
                if (submit_btn) begin
                    next_state = WAIT_STATE;
                end else begin
                    next_state = GUESS_STATE;
                end
            end

            WAIT_STATE: begin
               if (ack_s) begin
                    next_state = SHOW_STATE;
               end else begin
                    next_state = WAIT_STATE;
               end
            end

            SHOW_STATE: begin
                if (!ack_s) begin
                    if (result == 2'd1) begin
                        next_state = INIT_STATE;
                    end else begin
                        next_state = GUESS_STATE;
                    end
                end else begin
                    next_state = SHOW_STATE;
                end
            end

            default: next_state = INIT_STATE;
        endcase    
    end

    always_comb begin 
        // TODO: set `submit` according to state
        case (state)
            default: begin
                submit = 1'b0;
            end

            WAIT_STATE: begin
                submit = 1'b1;
            end

            SHOW_STATE: begin
                submit = 1'b0;
            end
        endcase
        

    end

    always_comb begin //next_state next_num
        // TODO: set `next_num`
        case(state)
            INIT_STATE: begin
                next_num = 3'd0;
            end
            GUESS_STATE:begin
                next_num = sw;
            end
            WAIT_STATE:begin
                next_num = next_num;
            end
            SHOW_STATE:begin
                next_num = next_num;
            end
            default:begin
                next_num = 3'd0;
            end

        endcase

    end

    // register result
    logic [1:0] result_reg;
    always_ff @(posedge clk) begin
        if (rst) begin
            result_reg <= 2'd0;
        end else if (ack_s) begin
            result_reg <= result;
        end
    end

    always_comb begin
        // TODO: set `led` according to `result`
        case (state)
            INIT_STATE: begin
                led = 3'b0;
            end
            
            GUESS_STATE: begin
                led = 3'b0;
            end
            
            WAIT_STATE: begin
                led = 3'b0;
            end

            SHOW_STATE: begin
                if (result == 2'd0) led = 3'b001;
                else if (result == 2'd1) led = 3'b010;
                else if (result == 2'd2) led =3'b100;
                else led = 3'b000;
            end

            default: begin
                led = 3'd0;
            end

        endcase

    end
endmodule
