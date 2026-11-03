// lab5_basic.sv
module lab5_basic(
	input  logic clk,
	input  logic rst,
	input  logic we,
	input  logic re,
    input  logic [7:0] din,
    output logic found
);
	
	// add your design here
	logic [5:0] data;
	logic [1:0] addr;

	assign data = din[7:2];
	assign addr = din[1:0];

	// slot1
	logic [5:0] memory1 [3:0];
	logic [3:0] valid1;

	// slot2
	logic [5:0] memory2 [3:0];
	logic [3:0] valid2;

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (int i = 0; i < 4; i++) begin
				memory1[i] <= 6'd0;
				valid1[i] <= 1'b0;
				memory2[i] <= 6'd0;
				valid2[i] <= 1'b0;
			end
			found <= 1'b0;
		end else begin
			if (we) begin
				if (!valid1[addr] && !(valid2[addr] && memory2[addr] == data)) begin
					memory1[addr] <= data;
					valid1[addr] <= 1'b1;
				end else if (!valid2[addr] && !(valid1[addr] && memory1[addr] == data)) begin
					memory2[addr] <= data;
					valid2[addr] <= 1'b1;
				end
			end

			if (re) begin
				if (valid1[addr] && memory1[addr] == data) begin
					found <= 1'b1;
				end else if (valid2[addr] && memory2[addr] == data) begin
					found <= 1'b1;
				end else begin
					found <= 1'b0;
				end
			end
		end
	end

endmodule

