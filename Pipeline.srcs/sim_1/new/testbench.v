`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg rst;
    
    reg [4:0]  tb_reg_addr1;
    reg [4:0]  tb_reg_addr2;
    reg [11:0] tb_mem_addr;
    
    wire [31:0] tb_reg_data1;
    wire [31:0] tb_reg_data2;
    wire [31:0] tb_mem_data;
    
    wire [31:0] tb_pc;
    wire [31:0] tb_ir;
    wire [31:0] tb_hi;
    wire [31:0] tb_lo;
    
    cpu test_cpu(
        .clk        (clk),
        .rst        (rst),
        .reg_taddr1 (tb_reg_addr1),
        .reg_taddr2 (tb_reg_addr2),
        .mem_taddr  (tb_mem_addr),
        .reg_tdata1 (tb_reg_data1),
        .reg_tdata2 (tb_reg_data2),
        .mem_tdata  (tb_mem_data),
        .cur_pc     (tb_pc),
        .cur_ir     (tb_ir),
        .cur_hi     (tb_hi),
        .cur_lo     (tb_lo)
    );

    initial begin
        tb_reg_addr1 = 5'd5;
        tb_reg_addr2 = 5'd6;
        tb_mem_addr  = 12'h000;
    end
    
    initial begin
        clk = 1'b1;
        rst = 1'b1;
        #10
        rst = 1'b0;
    end

    initial begin    
        #2950
        tb_reg_addr1 = 5'd11;
        tb_reg_addr2 = 5'd11;
        tb_mem_addr  = 12'h000;
        #10
        tb_reg_addr1 = 5'd12;
        tb_reg_addr2 = 5'd12;
        tb_mem_addr  = 12'h004;
        #10
        tb_reg_addr1 = 5'd13;
        tb_reg_addr2 = 5'd13;
        tb_mem_addr  = 12'h008;
        #10
        tb_reg_addr1 = 5'd14;
        tb_reg_addr2 = 5'd14;
        tb_mem_addr  = 12'h00C;
        #10
        tb_reg_addr1 = 5'd15;
        tb_reg_addr2 = 5'd15;
        tb_mem_addr  = 12'h010;
    end
    
    always #5 clk = ~clk;

endmodule
