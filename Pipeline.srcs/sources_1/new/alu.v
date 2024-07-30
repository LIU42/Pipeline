`timescale 1ns / 1ps

module alu(
    input  [3:0]  control,
    input  [31:0] src1,
    input  [31:0] src2,
    output [31:0] result,
    output [31:0] result_hi,
    output [31:0] result_lo
    );
    
    wire [15:0] onehot_control;
    
    decoder4 alu_control_decoder(
        .code_in  (control),
        .code_out (onehot_control)
    );
    
    wire [31:0] adder_operand1;
    wire [31:0] adder_operand2;
    wire        adder_cin;
    wire [31:0] adder_result;
    wire        adder_cout;
    
    adder alu_adder(
        .operand1 (adder_operand1),
        .operand2 (adder_operand2),
        .cin      (adder_cin),
        .result   (adder_result),
        .cout     (adder_cout)
    );
    
    wire [31:0] mul_operand1;
    wire [31:0] mul_operand2;
    wire [31:0] mul_result_hi;
    wire [31:0] mul_result_lo;
    
    multiplier alu_multiplier(
        .operand1  (mul_operand1),
        .operand2  (mul_operand2),
        .result_hi (mul_result_hi),
        .result_lo (mul_result_lo)
    );
    
    wire op_nop;
    wire op_add;
    wire op_sub;
    wire op_slt;
    wire op_and;
    wire op_or;
    wire op_xor;
    wire op_nor;
    wire op_sll;
    wire op_srl;
    wire op_sra;
    wire op_lui;
    wire op_mul;
    
    assign op_nop = onehot_control[0];
    assign op_add = onehot_control[1];
    assign op_sub = onehot_control[2];
    assign op_slt = onehot_control[3];
    assign op_and = onehot_control[4];
    assign op_or  = onehot_control[5];
    assign op_xor = onehot_control[6];
    assign op_nor = onehot_control[7];
    assign op_sll = onehot_control[8];
    assign op_srl = onehot_control[9];
    assign op_sra = onehot_control[10];
    assign op_lui = onehot_control[11];
    assign op_mul = onehot_control[12];
    
    assign adder_operand1 = src1;
    assign adder_operand2 = (op_nop) ? 0 : (op_add) ? src2 : ~src2;
                            
    assign adder_cin = (op_add) ? 0 : 1;
    
    assign mul_operand1 = src1;
    assign mul_operand2 = src2;
    
    wire [31:0] slt_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] nor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    
    assign slt_result[31:1] = 31'h00000000;
    assign slt_result[0]    = (src1[31] & ~src2[31]) | (adder_result[31] & (src1[31] + ~src2[31]));
    
    assign and_result = src1 & src2;
    assign or_result  = src1 | src2;
    assign xor_result = src1 ^ src2;
    assign nor_result = ~or_result;
    
    assign sll_result = src2 << src1[4:0];
    assign srl_result = src2 >> src1[4:0];
    assign sra_result = $signed(src2) >>> src1[4:0];
    
    assign result = (op_nop)          ? src1 :
                    (op_add | op_sub) ? adder_result :
                    (op_slt)          ? slt_result :
                    (op_and)          ? and_result :
                    (op_or)           ? or_result :
                    (op_xor)          ? xor_result :
                    (op_nor)          ? nor_result :
                    (op_sll)          ? sll_result :
                    (op_srl)          ? srl_result :
                    (op_sra)          ? sra_result :
                    (op_lui)          ? {src2[15:0], 16'h0000} : 32'h00000000;
                    
    assign result_hi = (op_mul) ? mul_result_hi : 32'h00000000;
    assign result_lo = (op_mul) ? mul_result_lo : 32'h00000000;
    
endmodule
