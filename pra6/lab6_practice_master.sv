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
	//localparam Init = 2'b00;
	//localparam Req  = 2'b01;
	//localparam Ack  = 2'b10;
	typedef enum logic [1:0] {Init, Req, Ack} state_t;

	state_t state, next_state;

	always_ff @(posedge clk) begin
		if (rst) begin	// sync reset
			state <= Init;
		end else begin
			state <= next_state;
		end
	end

	// ---------------------------------------
	// Process & LED
	// ---------------------------------------
	logic [3:0] data_reg;
	always_ff @(posedge clk) begin
		if (rst) begin
			data_reg <= 4'd0;
		end else if (state == Init && request_btn) begin
			data_reg <= sw;
		end
	end

	always_comb begin
		case (state)
			Req: begin
				Request = 1'b1;
				Data = sw;
				led = 4'd0;
			end

			Ack: begin
				Request = 1'b0;
				Data = 4'd0;
				led = data_reg;
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
			Init: begin
				if (request_btn) begin
					next_state = Req;
				end else begin
					next_state = Init;
				end
			end

			Req: begin
				if (ACK) begin
					next_state = Ack;
				end else begin
					next_state = Req;
				end
			end

			Ack: begin
				if (!ACK) begin
					next_state = Init;
				end else begin
					next_state = Ack;
				end
			end

			default: begin	// latch prevent
				next_state = Init;
			end
		endcase
	end

endmodule
