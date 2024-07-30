`timescale 1ns / 1ps

module decoder4(
    input  [3:0]  code_in,
    output [15:0] code_out
    );
    
    assign code_out = (code_in == 4'h0) ? 16'h0001 :
                      (code_in == 4'h1) ? 16'h0002 :
                      (code_in == 4'h2) ? 16'h0004 :
                      (code_in == 4'h3) ? 16'h0008 :
                      (code_in == 4'h4) ? 16'h0010 :
                      (code_in == 4'h5) ? 16'h0020 :
                      (code_in == 4'h6) ? 16'h0040 :
                      (code_in == 4'h7) ? 16'h0080 :
                      (code_in == 4'h8) ? 16'h0100 :
                      (code_in == 4'h9) ? 16'h0200 :
                      (code_in == 4'hA) ? 16'h0400 :
                      (code_in == 4'hB) ? 16'h0800 :
                      (code_in == 4'hC) ? 16'h1000 :
                      (code_in == 4'hD) ? 16'h2000 :
                      (code_in == 4'hE) ? 16'h4000 :
                      (code_in == 4'hF) ? 16'h8000 : 16'h0000;
    
endmodule
