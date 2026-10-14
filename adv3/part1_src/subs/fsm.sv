module FSM (
    input  logic clk,
    input  logic rst,
    input  logic set_pulse,
    output logic [1:0] state
);

    localparam INITIAL = 2'b00;
    localparam SET1    = 2'b01;
    localparam SET2    = 2'b10;
    localparam RESULT  = 2'b11;

    logic [1:0] next_state;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= INITIAL;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            INITIAL: begin
                next_state = SET1;
            end

            SET1: begin
                if (set_pulse) begin
                    next_state = SET2;
                end else begin
                    next_state = SET1;
                end
            end

            SET2: begin
                if (set_pulse) begin
                    next_state = RESULT;
                end else begin
                    next_state = SET2;
                end
            end

            RESULT: begin
                if (set_pulse) begin
                    next_state = SET1;
                end else begin
                    next_state = RESULT;
                end
            end

            default: begin
                next_state = INITIAL;
            end
        endcase
    end

endmodule