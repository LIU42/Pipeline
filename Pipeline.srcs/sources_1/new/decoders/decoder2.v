`timescale 1ns / 1ps

module decoder2(
    input  [1:0] cin,
    output [3:0] cout
    );
    
    assign cout = (cin == 2'b00) ? 4'b0001 :
                  (cin == 2'b01) ? 4'b0010 :
                  (cin == 2'b10) ? 4'b0100 :
                  (cin == 2'b11) ? 4'b1000 : 4'b0000;
    
endmodule
