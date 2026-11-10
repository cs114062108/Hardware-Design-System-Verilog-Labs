// 114062108 杜時羽 // FIXME: Fill in your student ID and name here. EX: 111000111 David Wang

module fir_filter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        data_in_enable,
    input  logic [7:0]  data_in, 
    input  logic [7:0]  weight_0, 
    input  logic [7:0]  weight_1, 
    input  logic [7:0]  weight_2,  
    input  logic [7:0]  weight_3, 
    input  logic [7:0]  weight_4,
    output logic [18:0] y
);

    // TODO: In this module, you should implement the FIR filter
    logic [7:0] din;
    always_comb begin
        if (data_in_enable) begin
            din = data_in;
        end else begin
            din = 8'd0;
        end
    end

    logic [7:0] regs [0:3];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 4; i++) begin
                regs[i] <= 8'd0;
            end
        end else begin
            for (int i = 0; i < 4; i++) begin
                if (i == 0) begin
                    regs[i] <= din;
                end else begin
                    regs[i] <= regs[i-1];
                end
            end
        end
    end
    
    logic [15:0] wmult [0:4];
    logic [18:0] sum;

    always_comb begin
        wmult[0] = weight_0 * din;
        wmult[1] = weight_1 * regs[0];
        wmult[2] = weight_2 * regs[1];
        wmult[3] = weight_3 * regs[2];
        wmult[4] = weight_4 * regs[3];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= 19'd0;
            sum <= 19'd0;
        end else begin
            sum <= wmult[0] + wmult[1] + wmult[2] + wmult[3] + wmult[4];
            y <= sum;
        end
    end

endmodule