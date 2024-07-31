`timescale 1ns / 1ps

module multiplier(
    input  [31:0] operand1,
    input  [31:0] operand2,
    output [31:0] result_hi,
    output [31:0] result_lo
    );
    
    wire [63:0] product;
    
    assign product = $signed(operand1) * $signed(operand2);
    
    assign result_hi = product[63:32];
    assign result_lo = product[31:0];
    
endmodule
