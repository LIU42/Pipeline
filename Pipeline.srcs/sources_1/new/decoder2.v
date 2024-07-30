`timescale 1ns / 1ps

module decoder2(
    input  [1:0] code_in,
    output [3:0] code_out
    );
    
    assign code_out = (code_in == 2'b00) ? 4'b0001 :
                      (code_in == 2'b01) ? 4'b0010 :
                      (code_in == 2'b10) ? 4'b0100 :
                      (code_in == 2'b11) ? 4'b1000 : 4'b0000;
    
endmodule
