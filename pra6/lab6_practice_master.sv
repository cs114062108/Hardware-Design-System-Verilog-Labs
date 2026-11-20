`timescale 1ns/1ps

module lab6_practice_master (
	input  logic clk,
	input  logic rst,
	input  logic request_btn,
	input  logic [3:0] sw, // switches
	input  logic ACK,
	output logic Request,
	output logic [3:0] Data, // data to the slave
	output logic [3:0] led
);
	
	// add your design here

	// ---------------------------------------
	// FSM (Synchronous Reset)
	// ---------------------------------------
	localparam S_Init = 2'b00;
	localparam S_Req  = 2'b01;
	localparam S_Ack  = 2'b10;

	logic [1:0] state, next_state;

	always_ff @(posedge clk) begin
		if (rst) begin	// sync reset
			state <= S_Init;
		end else begin
			state <= next_state;
		end
	end

	// ---------------------------------------
	// Process
	// ---------------------------------------
	always_comb begin
		case (state)
			S_Req: begin
				Request = 1'b1;
				Data = sw;
				led = 4'd0;
			end

			S_Ack: begin
				Request = 1'b0;
				Data = 4'd0;
				led = 4'b1111;
			end

			default: begin
				Request = 1'b0;
				Data = 4'd0;
				led = 4'd0;
			end
		endcase
	end

	// ---------------------------------------
	// FSM Next State Logic
	// ---------------------------------------
	always_comb begin
		case (state)
			S_Init: begin
				if (request_btn) begin
					next_state = S_Req;
				end else begin
					next_state = S_Init;
				end
			end

			S_Req: begin
				if (ACK) begin
					next_state = S_Ack;
				end else begin
					next_state = S_Req;
				end
			end

			S_Ack: begin
				if (!ACK) begin
					next_state = S_Init;
				end else begin
					next_state = S_Ack;
				end
			end

			default: begin	// latch prevent
				next_state = S_Init;
			end
		endcase
	end

	// ---------------------------------------
	// LED
	// ---------------------------------------
	

endmodule
