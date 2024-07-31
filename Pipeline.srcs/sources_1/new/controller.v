`timescale 1ns / 1ps

module controller(
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
    
    wire c_nop;
    wire c_add;
    wire c_addi;
    wire c_and;
    wire c_andi;
    wire c_beq;
    wire c_bgez;
    wire c_bgtz;
    wire c_blez;
    wire c_bltz;
    wire c_bne;
    wire c_j;
    wire c_jal;
    wire c_jr;
    wire c_lb;
    wire c_lh;
    wire c_lui;
    wire c_lw;
    wire c_mfhi;
    wire c_mflo;
    wire c_mthi;
    wire c_mtlo;
    wire c_mult;
    wire c_nor;
    wire c_or;
    wire c_ori;
    wire c_sb;
    wire c_sh;
    wire c_sll;
    wire c_sllv;
    wire c_slt;
    wire c_slti;
    wire c_sra;
    wire c_srav;
    wire c_srl;
    wire c_srlv;
    wire c_sub;
    wire c_sw;
    wire c_xor;
    wire c_xori;
    
    assign c_nop  = (inst_all == 32'h00000000);
    assign c_add  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100000);
    assign c_addi = (inst_op == 6'b001000);
    assign c_and  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100100);
    assign c_andi = (inst_op == 6'b001100);
    assign c_beq  = (inst_op == 6'b000100);
    assign c_bgez = (inst_op == 6'b000001 & inst_rt == 5'b00001);
    assign c_bgtz = (inst_op == 6'b000111 & inst_rt == 5'b00000);
    assign c_blez = (inst_op == 6'b000110 & inst_rt == 5'b00000);
    assign c_bltz = (inst_op == 6'b000001 & inst_rt == 5'b00000);
    assign c_bne  = (inst_op == 6'b000101);
    assign c_j    = (inst_op == 6'b000010);
    assign c_jal  = (inst_op == 6'b000011);
    assign c_jr   = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b001000);
    assign c_lb   = (inst_op == 6'b100000);
    assign c_lh   = (inst_op == 6'b100001);
    assign c_lui  = (inst_op == 6'b001111);
    assign c_lw   = (inst_op == 6'b100011);
    assign c_mfhi = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010000);
    assign c_mflo = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010010);
    assign c_mthi = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010001);
    assign c_mtlo = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b010011);
    assign c_mult = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b011000);
    assign c_nor  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100111);
    assign c_or   = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100101);
    assign c_ori  = (inst_op == 6'b001101);
    assign c_sb   = (inst_op == 6'b101000);
    assign c_sh   = (inst_op == 6'b101001);
    assign c_sll  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fun == 6'b100111);
    assign c_sllv = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b000100);
    assign c_slt  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b101010);
    assign c_slti = (inst_op == 6'b001010);
    assign c_sra  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fun == 6'b000011);
    assign c_srav = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b000111);
    assign c_srl  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fun == 6'b000010);
    assign c_srlv = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b000110);
    assign c_sub  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100010);
    assign c_sw   = (inst_op == 6'b101011);
    assign c_xor  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fun == 6'b100110);
    assign c_xori = (inst_op == 6'b001110);
                             
    assign alu_control = (c_add | c_addi | c_lb | c_lh | c_lw | c_sb | c_sh | c_sw) ? 4'd1 :
                         (c_sub)                                                    ? 4'd2 :
                         (c_slt | c_slti)                                           ? 4'd3 :
                         (c_and | c_andi)                                           ? 4'd4 :
                         (c_or  | c_ori)                                            ? 4'd5 :
                         (c_xor | c_xori)                                           ? 4'd6 :
                         (c_nor)                                                    ? 4'd7 :
                         (c_sll | c_sllv)                                           ? 4'd8 :
                         (c_srl | c_srlv)                                           ? 4'd9 :
                         (c_sra | c_srav)                                           ? 4'd10 :
                         (c_lui)                                                    ? 4'd11 :
                         (c_mult)                                                   ? 4'd12 : 4'd0;
    
    wire has_imm16;
    wire has_shift;
    wire has_store;
    wire has_branchs;
    
    assign has_imm16 = (c_addi | c_andi | c_lb   | c_lh   | c_beq  | c_bgez | c_bgtz |
                        c_lui  | c_lw   | c_ori  | c_sb   | c_blez | c_bltz | c_bne  |
                        c_sh   | c_sw   | c_slti | c_xori);
                           
    assign has_shift = (c_sll | c_sra | c_srl);
    assign has_store = (c_sb  | c_sh  | c_sw);
    
    assign has_branchs  = (c_beq | c_bgez | c_bgtz | c_blez | c_bltz | c_bne);
    
    assign alu_flag1 = (has_shift) ? 1 : 0;
    assign alu_flag2 = (has_imm16) ? 1 : 0;
    
    assign jumps[0] = c_beq;
    assign jumps[1] = c_bgez;
    assign jumps[2] = c_bgtz;
    assign jumps[3] = c_blez;
    assign jumps[4] = c_bltz;
    assign jumps[5] = c_bne;
    assign jumps[6] = c_j;
    assign jumps[7] = c_jal;
    assign jumps[8] = c_jr;
    
    assign mem_ren = (c_lb) ? 2'b01 :
                     (c_lh) ? 2'b10 :
                     (c_lw) ? 2'b11 : 2'b00;
                          
    assign mem_wen = (c_sb) ? 2'b01 :
                     (c_sh) ? 2'b10 :
                     (c_sw) ? 2'b11 : 2'b00;
                          
    assign wb_flag = (has_branchs | has_store | c_nop | c_mthi | c_mtlo | c_mult | c_j | c_jr) ? 0 : 1;
    
    assign wb_addr = (c_jal)     ? 5'd31 :
                     (has_imm16) ? inst_rt : inst_rd;
    
    assign hi_control = (c_mfhi) ? 2'b01 :
                        (c_mthi) ? 2'b10 :
                        (c_mult) ? 2'b11 : 2'b00;
                        
    assign lo_control = (c_mflo) ? 2'b01 :
                        (c_mtlo) ? 2'b10 :
                        (c_mult) ? 2'b11 : 2'b00;
    
endmodule
