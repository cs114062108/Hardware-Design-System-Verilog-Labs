// You can change anything in the template, except the module I/O of lab4_basic.
enum logic [1:0] {
    IDLE,
    PLAY,
    FINAL
} state_t;

// parameter IDLE = 2'd0;
// parameter PLAY = 2'd1;
// parameter FINAL = 2'd2;

module lab4_basic (
    input logic clk,
    input logic rst,
    input logic btnL,
    input logic btnR,
    input logic btnD,
    input logic btnU,
    output logic [15:0] LED
);
    
    
endmodule
