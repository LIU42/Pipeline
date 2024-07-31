`timescale 1ns / 1ps

module cpu(
    input         clk,
    input         rst,
    input  [4:0]  reg_taddr1,
    input  [4:0]  reg_taddr2,
    input  [11:0] mem_taddr,
    output [31:0] reg_tdata1,
    output [31:0] reg_tdata2,
    output [31:0] mem_tdata,
    output [31:0] cur_pc,
    output [31:0] cur_ir,
    output [31:0] cur_hi,
    output [31:0] cur_lo
    );
    
    wire [31:0] inst_addr;
    wire [31:0] inst_data;
    
    instrom cpu_instrom(
        .a   (inst_addr[11:2]),
        .spo (inst_data[31:0])
    );
    
    wire [31:0] id_inst;
    wire [8:0]  id_jumps;
    wire [3:0]  id_alu_control;
    wire        id_alu_flag1;
    wire        id_alu_flag2;
    wire [1:0]  id_mem_ren;
    wire [1:0]  id_mem_wen;
    wire        id_wb_flag;
    wire [4:0]  id_wb_addr;
    wire [1:0]  id_hi_control;
    wire [1:0]  id_lo_control;
    
    controller cpu_controller(
        .inst        (id_inst),
        .jumps       (id_jumps),
        .alu_control (id_alu_control),
        .alu_flag1   (id_alu_flag1),
        .alu_flag2   (id_alu_flag2),
        .mem_ren     (id_mem_ren),
        .mem_wen     (id_mem_wen),
        .wb_flag     (id_wb_flag),
        .wb_addr     (id_wb_addr),
        .hi_control  (id_hi_control),
        .lo_control  (id_lo_control)
    );
    
    wire [3:0]  alu_control;
    wire [31:0] alu_src1;
    wire [31:0] alu_src2;
    wire [31:0] alu_result;
    wire [31:0] alu_result_hi;
    wire [31:0] alu_result_lo;
    
    alu cpu_alu(
        .control   (alu_control),
        .src1      (alu_src1),
        .src2      (alu_src2),
        .result    (alu_result),
        .result_hi (alu_result_hi),
        .result_lo (alu_result_lo)
    );

    wire        reg_wen;
    wire [4:0]  reg_raddr1;
    wire [4:0]  reg_raddr2;
    wire [4:0]  reg_waddr;
    wire [31:0] reg_rdata1;
    wire [31:0] reg_rdata2;
    wire [31:0] reg_wdata;
    
    regfile cpu_regfile(
        .clk    (clk),
        .wen    (reg_wen),
        .raddr1 (reg_raddr1),
        .raddr2 (reg_raddr2),
        .waddr  (reg_waddr),
        .taddr1 (reg_taddr1),
        .taddr2 (reg_taddr2),
        .rdata1 (reg_rdata1),
        .rdata2 (reg_rdata2),
        .wdata  (reg_wdata),
        .tdata1 (reg_tdata1),
        .tdata2 (reg_tdata2)
    );
    
    wire [1:0]  mem_ren;
    wire [1:0]  mem_wen;
    wire [11:0] mem_addr;
    wire        mem_rerr;
    wire        mem_werr;
    wire [31:0] mem_rdata;
    wire [31:0] mem_wdata;
    
    dataram cpu_dataram(
        .clk   (clk),
        .ren   (mem_ren),
        .wen   (mem_wen),
        .addr  (mem_addr),
        .taddr (mem_taddr),
        .rerr  (mem_rerr),
        .werr  (mem_werr),
        .rdata (mem_rdata),
        .wdata (mem_wdata),
        .tdata (mem_tdata)
    );
    
    reg [31:0] pc;
    reg [31:0] ir;
    reg [31:0] hi;
    reg [31:0] lo;
    
    reg [1:0] hi_control_reg;
    reg [1:0] lo_control_reg;
    
    reg [13:0] alu_control_reg;
    reg [31:0] alu_src1_reg;
    reg [31:0] alu_src2_reg;
    reg [31:0] alu_src3_reg;
    
    reg [9:0]  mem_control_reg;
    reg [31:0] mem_addr_reg;
    reg [31:0] mem_wdata_reg;
    
    reg [6:0]  wb_control_reg;
    reg [31:0] wb_data_reg;
    
    reg [4:0] dest_reg1;
    reg [4:0] dest_reg2;
    
    assign cur_pc = pc;
    assign cur_ir = ir;
    assign cur_hi = hi;
    assign cur_lo = lo;
    
    wire        jump_flag;
    wire [31:0] sequ_pc;
    wire [31:0] jump_pc;
    wire [31:0] next_pc;
 
    assign inst_addr = pc;
    
    assign sequ_pc = pc + 4;
    assign next_pc = (jump_flag) ? jump_pc : sequ_pc;
    
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h00000000;
            ir <= 32'h00000000;
        end
        else begin
            pc <= next_pc;
            ir <= inst_data;
        end
    end

    assign id_inst = ir;
    
    wire [15:0] inst_imm16;
    wire [25:0] inst_imm26;
    
    assign inst_imm16 = id_inst[15:0];
    assign inst_imm26 = id_inst[25:0];
    
    wire [4:0] rs_addr;
    wire [4:0] rt_addr;
    
    assign rs_addr = id_inst[25:21];
    assign rt_addr = id_inst[20:16];
    
    wire jump_beq;
    wire jump_bgez;
    wire jump_bgtz;
    wire jump_blez;
    wire jump_bltz;
    wire jump_bne;
    wire jump_j;
    wire jump_jal;
    wire jump_jr;
    wire jump_branchs;
    
    assign jump_beq  = id_jumps[0];
    assign jump_bgez = id_jumps[1];
    assign jump_bgtz = id_jumps[2];
    assign jump_blez = id_jumps[3];
    assign jump_bltz = id_jumps[4];
    assign jump_bne  = id_jumps[5];
    assign jump_j    = id_jumps[6];
    assign jump_jal  = id_jumps[7];
    assign jump_jr   = id_jumps[8];
    
    assign jump_branchs = (jump_beq | jump_bgez | jump_bgtz | jump_blez | jump_bltz | jump_bne);
    
    wire [31:0] alu_sideway;
    wire [31:0] mem_sideway;
    
    wire id_rs_used;
    wire id_rt_used;
    
    assign id_rs_used = (id_alu_flag1 == 1'b0 | jump_jr  | jump_branchs);
    assign id_rt_used = (id_alu_flag2 == 1'b0 | jump_beq | jump_bne);
          
    wire id_rs_conflict1;
    wire id_rt_conflict1;
    wire id_rs_conflict2;
    wire id_rt_conflict2;
    
    assign id_rs_conflict1 = (id_rs_used & rs_addr != 5'b00000 & rs_addr == dest_reg1);
    assign id_rt_conflict1 = (id_rt_used & rt_addr != 5'b00000 & rt_addr == dest_reg1);
    assign id_rs_conflict2 = (id_rs_used & rs_addr != 5'b00000 & rs_addr == dest_reg2);
    assign id_rt_conflict2 = (id_rt_used & rt_addr != 5'b00000 & rt_addr == dest_reg2);
                          
    wire [4:0] id_dest;
                             
    assign id_dest = (id_wb_flag) ? id_wb_addr : 5'b00000;
    
    wire [31:0] rs_data;
    wire [31:0] rt_data;
    wire [31:0] sa_data;
    
    assign reg_raddr1 = rs_addr;
    assign reg_raddr2 = rt_addr;
    
    assign rs_data = (id_rs_conflict2) ? alu_sideway :
                     (id_rs_conflict1) ? mem_sideway : reg_rdata1;
    assign rt_data = (id_rt_conflict2) ? alu_sideway :
                     (id_rt_conflict1) ? mem_sideway : reg_rdata2;
    assign sa_data = {27'h0000000, id_inst[10:6]};
    
    wire is_eq;
    wire is_ltz;
    wire is_gtz;
    
    assign is_eq  = (rs_data == rt_data);
    assign is_ltz = (rs_data < 0);
    assign is_gtz = (rs_data > 0);
  
    assign jump_flag = (jump_j)              |
                       (jump_jal)            |
                       (jump_jr)             |
                       (jump_beq  &  is_eq)  |
                       (jump_bgez & !is_ltz) |
                       (jump_bgtz &  is_gtz) |
                       (jump_blez & !is_gtz) |
                       (jump_bltz &  is_ltz) |
                       (jump_bne  & !is_eq);
                      
    wire [31:0] ext_addr16;
    wire [31:0] ext_addr26;
    
    assign ext_addr16[31:18] = (inst_imm16[15] == 0) ? 14'h0000 : 14'hFFFF;
    assign ext_addr26[31:28] = pc[31:28];
    
    assign ext_addr16[17:0] = {inst_imm16[15:0], 2'b00};
    assign ext_addr26[27:0] = {inst_imm26[25:0], 2'b00};
                      
    assign jump_pc = (jump_jr)           ? rs_data :
                     (jump_j | jump_jal) ? ext_addr26 :
                     (jump_branchs)      ? ext_addr16 + pc : 32'h00000000;
                    
    wire [31:0] ext_imm16;
    
    assign ext_imm16 = {((inst_imm16[15] == 0) ? 16'h0000 : 16'hFFFF), inst_imm16[15:0]};
    
    wire [31:0] id_operand1;
    wire [31:0] id_operand2;
    
    assign id_operand1 = (jump_jal)               ? sequ_pc :
                         (id_hi_control == 2'b01) ? hi :
                         (id_lo_control == 2'b01) ? lo :
                         (id_alu_flag1 == 1'b1)   ? sa_data : rs_data;
                         
    assign id_operand2 = (id_alu_flag2 == 1'b1) ? ext_imm16 : rt_data;
                      
    wire [3:0] mem_control;
    wire [5:0] wb_control;
    
    assign mem_control[1:0] = id_mem_ren;
    assign mem_control[3:2] = id_mem_wen;
    
    assign wb_control[0]   = id_wb_flag;
    assign wb_control[5:1] = id_wb_addr;

    always @(posedge clk) begin
        if (rst) begin
            dest_reg1 <= 5'b00000;
            dest_reg2 <= 5'b00000;
        end
        else begin
            dest_reg2 <= id_dest;
            dest_reg1 <= dest_reg2;
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            hi_control_reg <= 2'b00;
            lo_control_reg <= 2'b00;
            
            alu_control_reg <= 14'h00000000;
            alu_src1_reg    <= 32'h00000000;
            alu_src2_reg    <= 32'h00000000;
            alu_src3_reg    <= 32'h00000000;
        end
        else begin
            hi_control_reg <= id_hi_control;
            lo_control_reg <= id_lo_control;
            
            alu_control_reg <= {wb_control[5:0], mem_control[3:0], id_alu_control[3:0]};
            alu_src1_reg    <= id_operand1;
            alu_src2_reg    <= id_operand2;
            alu_src3_reg    <= rt_data;
        end
    end
    
    assign alu_control = alu_control_reg;
    assign alu_src1    = alu_src1_reg;
    assign alu_src2    = alu_src2_reg;
    assign alu_sideway = alu_result;
    
    always @(negedge clk) begin
        case (hi_control_reg)
            2'b10: hi <= alu_result;
            2'b11: hi <= alu_result_hi;
        endcase
        case (lo_control_reg)
            2'b10: lo <= alu_result;
            2'b11: lo <= alu_result_lo;
        endcase
    end
    
    always @(posedge clk) begin
        if (rst) begin
            mem_control_reg <= 10'h00000000;
            mem_addr_reg    <= 32'h00000000;
            mem_wdata_reg   <= 32'h00000000;
        end
        else begin
            mem_control_reg <= alu_control_reg[13:4];
            mem_addr_reg    <= alu_result;
            mem_wdata_reg   <= alu_src3_reg;
        end
    end
    
    assign mem_ren = mem_control_reg[1:0];
    assign mem_wen = mem_control_reg[3:2];
    
    assign mem_addr  = mem_addr_reg[11:0];
    assign mem_wdata = mem_wdata_reg;
    
    wire [31:0] mem_result;
    
    assign mem_result  = (mem_ren == 2'b00) ? mem_addr_reg : mem_rdata;
    assign mem_sideway = mem_result;
    
    always @(posedge clk) begin
        if (rst) begin
            wb_control_reg <=  6'd00000000;
            wb_data_reg    <= 32'h00000000;
        end
        else begin
            wb_control_reg <= mem_control_reg[9:4];
            wb_data_reg    <= mem_result;
        end
    end
    
    assign reg_wen   = wb_control_reg[0];
    assign reg_waddr = wb_control_reg[5:1];
    assign reg_wdata = wb_data_reg;
    
endmodule
