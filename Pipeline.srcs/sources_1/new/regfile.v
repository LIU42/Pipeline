`timescale 1ns / 1ps

module regfile(
    input         clk,
    input         wen,
    input  [4:0]  raddr1,
    input  [4:0]  raddr2,
    input  [4:0]  waddr,
    input  [4:0]  taddr1,
    input  [4:0]  taddr2,
    input  [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2,
    output [31:0] tdata1,
    output [31:0] tdata2
    );
    
    reg [31:0] regs[31:0];
    
    always @(negedge clk) begin
        if (wen) begin
            regs[waddr] <= wdata;
        end
    end
    
    assign rdata1 = (raddr1 == 5'b00000) ? 32'h00000000 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b00000) ? 32'h00000000 : regs[raddr2];
    assign tdata1 = (taddr1 == 5'b00000) ? 32'h00000000 : regs[taddr1];
    assign tdata2 = (taddr2 == 5'b00000) ? 32'h00000000 : regs[taddr2];

endmodule
