`timescale 1ns / 1ps

module decoder4(
    input  [3:0]  cin,
    output [15:0] cout
    );
    
    assign cout = (cin == 4'h0) ? 16'h0001 :
                  (cin == 4'h1) ? 16'h0002 :
                  (cin == 4'h2) ? 16'h0004 :
                  (cin == 4'h3) ? 16'h0008 :
                  (cin == 4'h4) ? 16'h0010 :
                  (cin == 4'h5) ? 16'h0020 :
                  (cin == 4'h6) ? 16'h0040 :
                  (cin == 4'h7) ? 16'h0080 :
                  (cin == 4'h8) ? 16'h0100 :
                  (cin == 4'h9) ? 16'h0200 :
                  (cin == 4'hA) ? 16'h0400 :
                  (cin == 4'hB) ? 16'h0800 :
                  (cin == 4'hC) ? 16'h1000 :
                  (cin == 4'hD) ? 16'h2000 :
                  (cin == 4'hE) ? 16'h4000 :
                  (cin == 4'hF) ? 16'h8000 : 16'h0000;
    
endmodule
