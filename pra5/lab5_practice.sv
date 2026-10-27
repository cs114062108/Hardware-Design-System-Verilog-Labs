// lab5_practice.sv
module lab5_practice (
    input logic clk,
    input logic rst,

    // write port
    input logic we,
    input logic [6:0] w_addr,
    input logic [3:0] din,

    // read port
    input logic re,
    input logic [6:0] r_addr,
    output logic [3:0] dout,

    // Status output
    output logic [3:0] cnt_valid
);

// Add your design here.
// You may change the data types of the I/O signals.

endmodule