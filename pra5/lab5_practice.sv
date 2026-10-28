// lab5_practice.sv
module lab5_practice (
    input  logic clk,
    input  logic rst,

    // write port
    input  logic we,
    input  logic [6:0] w_addr,
    input  logic [3:0] din,

    // read port
    input  logic re,
    input  logic [6:0] r_addr,
    output logic [3:0] dout,

    // Status output
    output logic [3:0] cnt_valid
);

    // Add your design here.
    // You may change the data types of the I/O signals.
    logic [3:0] memory [0:7];
    logic valid [0:7];

    logic [2:0] mapped_addr;
    logic [2:0] mapped_w_addr;
    logic [2:0] mapped_r_addr;
    
    function automatic logic [2:0] calc_map_addr(input logic [6:0] addr);
        calc_map_addr = addr[2:0] ^ addr[6:4] ^ addr[3:1];
    endfunction

    always_comb begin
        mapped_w_addr = calc_map_addr(w_addr);
        mapped_r_addr = calc_map_addr(r_addr);
    end

    always_comb begin
        if (re) begin
            dout = memory[mapped_r_addr];
        end else begin
            dout = 4'd0;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 8; i++) begin
                memory[i] <= 4'd0;
                valid[i] <= 1'b0;
            end
            cnt_valid <= 4'd0;
            dout <= 4'd0;
        end else begin
            if (we) begin
                memory[mapped_w_addr] <= din;
                if (!valid[mapped_w_addr]) begin
                    cnt_valid <= cnt_valid + 4'd1;
                    valid[mapped_w_addr] <= 1'b1;
                end
            end
        end
    end

endmodule