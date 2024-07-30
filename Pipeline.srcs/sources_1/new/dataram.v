`timescale 1ns / 1ps

module dataram(
    input         clk,
    input  [1:0]  ren,
    input  [1:0]  wen,
    input  [11:0] addr,
    input  [11:0] taddr,
    input  [31:0] wdata,
    output        rerr,
    output        werr,
    output [31:0] rdata,
    output [31:0] tdata
    );
    
    wire [3:0] d_ren;
    wire [3:0] d_wen;
    
    decoder2 ren_decoder(
        .code_in  (ren),
        .code_out (d_ren)
    );
    
    decoder2 wen_decoder(
        .code_in  (wen),
        .code_out (d_wen)
    );
    
    wire [9:0] addr_hi;
    wire [1:0] addr_lo;
    
    assign addr_hi = addr[11:2];
    assign addr_lo = addr[1:0];
    
    wire [9:0] taddr_hi;
    wire [9:0] taddr_lo;
    
    assign taddr_hi = taddr[11:2];
    assign taddr_lo = taddr[1:0];
    
    wire mem0_wen;
    wire mem1_wen;
    wire mem2_wen;
    wire mem3_wen;
    
    wire [7:0] mem0_wdata;
    wire [7:0] mem1_wdata;
    wire [7:0] mem2_wdata;
    wire [7:0] mem3_wdata;
    
    wire [7:0] mem0_rdata;
    wire [7:0] mem1_rdata;
    wire [7:0] mem2_rdata;
    wire [7:0] mem3_rdata;
    
    wire [7:0] mem0_tdata;
    wire [7:0] mem1_tdata;
    wire [7:0] mem2_tdata;
    wire [7:0] mem3_tdata;

    dataram8 mem0(
        .clk  (~clk),
        .we   (mem0_wen),
        .a    (addr_hi),
        .dpra (taddr_hi),
        .d    (mem0_wdata),
        .spo  (mem0_rdata),
        .dpo  (mem0_tdata)
    );
    
    dataram8 mem1(
        .clk  (~clk),
        .we   (mem1_wen),
        .a    (addr_hi),
        .dpra (taddr_hi),
        .d    (mem1_wdata),
        .spo  (mem1_rdata),
        .dpo  (mem1_tdata)
    );
    
    dataram8 mem2(
        .clk  (~clk),
        .we   (mem2_wen),
        .a    (addr_hi),
        .dpra (taddr_hi),
        .d    (mem2_wdata),
        .spo  (mem2_rdata),
        .dpo  (mem2_tdata)
    );
    
    dataram8 mem3(
        .clk  (~clk),
        .we   (mem3_wen),
        .a    (addr_hi),
        .dpra (taddr_hi),
        .d    (mem3_wdata),
        .spo  (mem3_rdata),
        .dpo  (mem3_tdata)
    );
    
    wire rword;
    wire rhalf;
    wire rbyte;
    wire wword;
    wire whalf;
    wire wbyte;
    
    assign rword = d_ren[3];
    assign rhalf = d_ren[2];
    assign rbyte = d_ren[1];
    assign wword = d_wen[3];
    assign whalf = d_wen[2];
    assign wbyte = d_wen[1];
    
    assign rerr = (rword & (addr_lo[0] | addr_lo[1])) | (rhalf & addr_lo[0]);
    assign werr = (wword & (addr_lo[0] | addr_lo[1])) | (whalf & addr_lo[0]);
    
    assign mem0_wen = (!werr & (wword)                    |
                               (whalf & addr_lo == 2'b00) |
                               (wbyte & addr_lo == 2'b00));                            
    assign mem1_wen = (!werr & (wword)                    |
                               (whalf & addr_lo == 2'b00) |
                               (wbyte & addr_lo == 2'b01));                         
    assign mem2_wen = (!werr & (wword)                    |
                               (whalf & addr_lo == 2'b10) |
                               (wbyte & addr_lo == 2'b10));                        
    assign mem3_wen = (!werr & (wword)                    |
                               (whalf & addr_lo == 2'b10) |
                               (wbyte & addr_lo == 2'b11));
                               
    assign mem0_wdata = wdata[7:0];      
    assign mem1_wdata = (wbyte) ? wdata[7:0] : wdata[15:8];
    assign mem2_wdata = (whalf) ? wdata[7:0] :
                        (wbyte) ? wdata[7:0] : wdata[23:16];                     
    assign mem3_wdata = (whalf) ? wdata[15:8] :
                        (wbyte) ? wdata[7:0] : wdata[31:24];
    
    assign rdata[31:24] = (rword) ? mem3_rdata : 8'h00;
    assign rdata[23:16] = (rword) ? mem2_rdata : 8'h00;
    assign rdata[15:8]  = (rword) ? mem1_rdata :
                          (rhalf) ? ((addr_lo == 2'b00) ? mem1_rdata :
                                     (addr_lo == 2'b10) ? mem3_rdata : 8'h00) : 8'h00;
    assign rdata[7:0]   = (rword) ? mem0_rdata :
                          (rhalf) ? ((addr_lo == 2'b00) ? mem0_rdata :
                                     (addr_lo == 2'b10) ? mem2_rdata : 8'h00) :
                          (rbyte) ? ((addr_lo == 2'b00) ? mem0_rdata :
                                     (addr_lo == 2'b01) ? mem1_rdata :
                                     (addr_lo == 2'b10) ? mem2_rdata :
                                     (addr_lo == 2'b11) ? mem3_rdata : 8'h00) : 8'h00;
                                     
    assign tdata = {mem3_tdata[7:0], mem2_tdata[7:0], mem1_tdata[7:0], mem0_tdata[7:0]};
    
endmodule
