`timescale 1ns / 1ps

module instdecoder(
    input  [31:0] inst,
    output [8:0]  jumps,
    output [3:0]  alu_control,
    output        alu_flag1,
    output        alu_flag2,
    output [1:0]  mem_ren,
    output [1:0]  mem_wen,
    output        wb_flag,
    output [4:0]  wb_addr,
    output [1:0]  hi_control,
    output [1:0]  lo_control
    );
    
    wire [31:0] inst_all;
    wire [5:0]  inst_op;
    wire [4:0]  inst_rs;
    wire [4:0]  inst_rt;
    wire [4:0]  inst_rd;
    wire [4:0]  inst_sa;
    wire [5:0]  inst_fun;
    
    assign inst_all = inst[31:0];
    assign inst_op  = inst[31:26];
    assign inst_rs  = inst[25:21];
    assign inst_rt  = inst[20:16];
    assign inst_rd  = inst[15:11];
    assign inst_sa  = inst[10:6];
    assign inst_fun = inst[5:0];
    
    wire code_nop;
    wire code_add;
    wire code_addi;
    wire code_and;
    wire code_andi;
    wire code_beq;
    wire code_bgez;
    wire code_bgtz;
    wire code_blez;
    wire code_bltz;
    wire code_bne;
    wire code_j;
    wire code_jal;
    wire code_jr;
    wire code_lb;
    wire code_lh;
    wire code_lui;
    wire code_lw;
    wire code_mfhi;
    wire code_mflo;
    wire code_mthi;
    wire code_mtlo;
    wire code_mult;
    wire code_nor;
    wire code_or;
    wire code_ori;
    wire code_sb;
    wire code_sh;
    wire code_sll;
    wire code_sllv;
    wire code_slt;
    wire code_slti;
    wire code_sra;
    wire code_srav;
    wire code_srl;
    wire code_srlv;
    wire code_sub;
    wire code_sw;
    wire code_xor;
    wire code_xori;
    
    assign code_nop  = (inst_all == 32'h00000000);
    assign code_add  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100000);
    assign code_addi = (inst_op == 6'b001000);
    assign code_and  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100100);
    assign code_andi = (inst_op == 6'b001100);
    assign code_beq  = (inst_op == 6'b000100);
    assign code_bgez = (inst_op == 6'b000001 & inst_rt == 5'b00001);
    assign code_bgtz = (inst_op == 6'b000111 & inst_rt == 5'b00000);
    assign code_blez = (inst_op == 6'b000110 & inst_rt == 5'b00000);
    assign code_bltz = (inst_op == 6'b000001 & inst_rt == 5'b00000);
    assign code_bne  = (inst_op == 6'b000101);
    assign code_j    = (inst_op == 6'b000010);
    assign code_jal  = (inst_op == 6'b000011);
    assign code_jr   = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b001000);
    assign code_lb   = (inst_op == 6'b100000);
    assign code_lh   = (inst_op == 6'b100001);
    assign code_lui  = (inst_op == 6'b001111);
    assign code_lw   = (inst_op == 6'b100011);
    assign code_mfhi = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010000);
    assign code_mflo = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010010);
    assign code_mthi = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010001);
    assign code_mtlo = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010011);
    assign code_mult = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b011000);
    assign code_nor  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100111);
    assign code_or   = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100101);
    assign code_ori  = (inst_op == 6'b001101);
    assign code_sb   = (inst_op == 6'b101000);
    assign code_sh   = (inst_op == 6'b101001);
    assign code_sll  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fun == 6'b100111);
    assign code_sllv = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b000100);
    assign code_slt  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b101010);
    assign code_slti = (inst_op == 6'b001010);
    assign code_sra  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fun == 6'b000011);
    assign code_srav = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b000111);
    assign code_srl  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fun == 6'b000010);
    assign code_srlv = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b000110);
    assign code_sub  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100010);
    assign code_sw   = (inst_op == 6'b101011);
    assign code_xor  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100110);
    assign code_xori = (inst_op == 6'b001110);
                             
    assign alu_control = (code_add | code_addi | code_lb | code_lh | code_lw | code_sb | code_sh | code_sw) ? 4'd1 :
                         (code_sub)                                                                         ? 4'd2 :
                         (code_slt | code_slti)                                                             ? 4'd3 :
                         (code_and | code_andi)                                                             ? 4'd4 :
                         (code_or  | code_ori)                                                              ? 4'd5 :
                         (code_xor | code_xori)                                                             ? 4'd6 :
                         (code_nor)                                                                         ? 4'd7 :
                         (code_sll | code_sllv)                                                             ? 4'd8 :
                         (code_srl | code_srlv)                                                             ? 4'd9 :
                         (code_sra | code_srav)                                                             ? 4'd10 :
                         (code_lui)                                                                         ? 4'd11 :
                         (code_mult)                                                                        ? 4'd12 : 4'd0;
    
    wire has_imm16;
    wire has_shift;
    wire has_store;
    wire has_branchs;
    
    assign has_imm16 = (code_addi | code_andi | code_lb   | code_lh   | code_beq  | code_bgez | code_bgtz |
                        code_lui  | code_lw   | code_ori  | code_sb   | code_blez | code_bltz | code_bne  |
                        code_sh   | code_sw   | code_slti | code_xori);
                           
    assign has_shift = (code_sll | code_sra | code_srl);
    assign has_store = (code_sb  | code_sh  | code_sw);
    
    assign has_branchs  = (code_beq | code_bgez | code_bgtz | code_blez | code_bltz | code_bne);
    
    assign alu_flag1 = (has_shift) ? 1 : 0;
    assign alu_flag2 = (has_imm16) ? 1 : 0;
    
    assign jumps[0] = code_beq;
    assign jumps[1] = code_bgez;
    assign jumps[2] = code_bgtz;
    assign jumps[3] = code_blez;
    assign jumps[4] = code_bltz;
    assign jumps[5] = code_bne;
    assign jumps[6] = code_j;
    assign jumps[7] = code_jal;
    assign jumps[8] = code_jr;
    
    assign mem_ren = (code_lb) ? 2'b01 :
                     (code_lh) ? 2'b10 :
                     (code_lw) ? 2'b11 : 2'b00;
                          
    assign mem_wen = (code_sb) ? 2'b01 :
                     (code_sh) ? 2'b10 :
                     (code_sw) ? 2'b11 : 2'b00;
                          
    assign wb_flag = (has_branchs | has_store | code_nop | code_mthi | code_mtlo | code_mult | code_j | code_jr) ? 0 : 1;
    
    assign wb_addr = (code_jal)  ? 5'd31 :
                     (has_imm16) ? inst_rt : inst_rd;
    
    assign hi_control = (code_mfhi) ? 2'b01 :
                        (code_mthi) ? 2'b10 :
                        (code_mult) ? 2'b11 : 2'b00;
                        
    assign lo_control = (code_mflo) ? 2'b01 :
                        (code_mtlo) ? 2'b10 :
                        (code_mult) ? 2'b11 : 2'b00;
    
endmodule
