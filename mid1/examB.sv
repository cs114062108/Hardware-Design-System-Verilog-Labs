// Student ID Name // FIXME: Fill in your student ID and name here. EX: 111000111 David Wang

module FIFO (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] data_in,
    input  logic       push_data,
    input  logic       pop_data,
    output logic [7:0] data_out,
    output logic       full,
    output logic       empty
);
    //NOTE:
    // Only the module name and I/O ports are fixed. 
    // You may modify, remove, or add any internal signals, registers, pointers, counters, or memory declarations as necessary.
    
    localparam int FIFO_DEPTH = 12;

    // FIFO storage
    logic [7:0] fifo_data [0:FIFO_DEPTH-1];

    // Input registers
    logic [7:0] data_in_reg;
    logic       push_data_reg;
    logic       pop_data_reg;

    // FIFO control
    logic [3:0] read_pointer;
    logic [3:0] write_pointer;
    logic [3:0] data_count;

    // Dataflow control signal
    logic valid_push;
    logic valid_pop;

    assign valid_push = push_data_reg && !full;
    assign valid_pop  = pop_data_reg  && !empty;

    // TODO:
    // 1. Register input signals.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_reg <= 8'd0;
            push_data_reg <= 1'b0;
            pop_data_reg <= 1'b0;

            data_out <= 8'd0;

            read_pointer <= 4'd0;
            write_pointer <= 4'd0;
            data_count <= 4'd0;

            for (int i = 0; i < FIFO_DEPTH; i++) begin
                fifo_data[i] <= 8'd0;
            end
        end else begin
            data_in_reg <= data_in;
            push_data_reg <= push_data;
            pop_data_reg <= pop_data;

            // 2. Implement push and pop operations.
            // 3. Wrap pointers from 11 back to 0.
            // 4. Update data_count.
            if (valid_push) begin
                fifo_data[write_pointer] <= data_in_reg;
                write_pointer <= (write_pointer < 4'd11) ? (write_pointer + 4'd1) : 4'd0;
                data_count <= data_count + 4'd1;
            end
            if (valid_pop) begin
                data_count <= fifo_data[read_pointer];
                read_pointer <= (read_pointer > 4'd0) ? (read_pointer - 4'd1) : 4'd11;
                data_count <= data_count + 4'd1;
            end
        end
    end

    // 5. Register data_out, full, and empty.
    always_comb begin
        full = data_count == FIFO_DEPTH;
        empty = data_count == 4'd0; 
    end

endmodule