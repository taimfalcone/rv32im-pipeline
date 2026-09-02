`timescale 1ns / 1ps

module data_path #(
    parameter PC_W = 8,
    parameter INS_W = 32,
    parameter RF_ADDRESS = 5,
    parameter DATA_W = 32,
    parameter DM_ADDRESS = 9,
    parameter ALU_CC_W = 4
) (
    input                    clk,
    input                    reset,
    input                    reg_write,
    input      [1:0]         mem2reg,
    input                    alu_src,
    input                    mem_write,
    input                    mem_read,
    input                    branch,
    input                    jump,
    input                    jump_r,
    input                    alu_src_a,
    input      [1:0]         aluop,
    output     [6:0]         opcode,
    output     [DATA_W-1:0]  alu_result
);

    // Cross-stage wires (forward-declared for pc_next and forwarding)
    wire [PC_W-1:0]   branch_target_ex;
    wire [PC_W-1:0]   jumpr_target_ex;
    wire              pc_redirect_ex;
    wire              jump_r_ex;
    wire              mem_wb_regwrite;
    wire [4:0]        mem_wb_rd;
    wire [DATA_W-1:0] wb_data;
    wire              ex_mem_regwrite;
    wire [4:0]        ex_mem_rd;
    wire [DATA_W-1:0] ex_mem_forward_value;
    
    //                         New additions
    wire [4:0]        id_ex_rd;
    wire              id_ex_memread;
    wire              flush_on_branch;
    
    //                        IF STAGE
    wire [PC_W-1:0]  pc_out, pc_next, pc_plus4_if;
    wire [INS_W-1:0] instruction_if;

    assign pc_next = jump_r_ex      ? jumpr_target_ex :
                     pc_redirect_ex ? branch_target_ex :
                                      pc_plus4_if;

        // Stall PC by feeding it its own value when stall_pipeline is high
    wire [PC_W-1:0] pc_input = stall_pipeline ? pc_out : pc_next;
    flip_flop pc_reg (
        .clk(clk), .reset(reset), .d(pc_input), .q(pc_out)
    );

    assign pc_plus4_if = pc_out + 4;

    inst_mem inst_memory (
        .addr(pc_out),
        .instruction(instruction_if)
    );

    wire [31:0] if_id_instruction, if_id_pc, if_id_pcplus4;
    IF_ID if_id (
        .clk(clk), .rst(reset), .stall(stall_pipeline), .flush(flush_on_branch),
        .instruction_in(instruction_if),
        .PC_in     ({{(32-PC_W){1'b0}}, pc_out}),
        .PCplus4_in({{(32-PC_W){1'b0}}, pc_plus4_if}),
        .instruction_out(if_id_instruction),
        .PC_out(if_id_pc),
        .PCplus4_out(if_id_pcplus4)
    );


    //                        ID STAGE
    assign opcode = if_id_instruction[6:0];

    wire [4:0] rd_id     = if_id_instruction[11:7];
    wire [2:0] funct3_id = if_id_instruction[14:12];
    wire [4:0] rs1_id    = if_id_instruction[19:15];
    wire [4:0] rs2_id    = if_id_instruction[24:20];
    wire [6:0] funct7_id = if_id_instruction[31:25];

    wire [DATA_W-1:0] rf_rs1_data, rf_rs2_data;
    reg_file rf (
        .clk(clk), .reset(reset),
        .rg_wrt_en(mem_wb_regwrite),
        .rg_wrt_addr(mem_wb_rd),
        .rg_rd_addr1(rs1_id), .rg_rd_addr2(rs2_id),
        .rg_wrt_data(wb_data),
        .rg_rd_data1(rf_rs1_data), .rg_rd_data2(rf_rs2_data)
    );

    wire [DATA_W-1:0] rs1_data_id =
        (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == rs1_id))
        ? wb_data : rf_rs1_data;
    wire [DATA_W-1:0] rs2_data_id =
        (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == rs2_id))
        ? wb_data : rf_rs2_data;

        wire [DATA_W-1:0] imm_id;
    imm_gen #(.INS_W(INS_W), .DATA_W(DATA_W)) imm_generator (
        .InstCode(if_id_instruction),
        .imm_out(imm_id)
    );
    
        // Hazard detection - detects load-use, stalls PC and IF/ID for 1 cycle
    wire stall_pipeline;
    hazard_detection hazard_unit (
        .if_id_rs1(rs1_id),
        .if_id_rs2(rs2_id),
        .id_ex_rd(id_ex_rd),
        .id_ex_memread(id_ex_memread),
        .stall(stall_pipeline)
    );

    wire [31:0]       id_ex_pc, id_ex_pcplus4;
    wire [DATA_W-1:0] id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    wire [4:0]        id_ex_rs1, id_ex_rs2;
    wire [2:0]        id_ex_funct3;
    wire [6:0]        id_ex_funct7;
    wire              id_ex_regwrite, id_ex_memread;
    wire [1:0]        id_ex_mem2reg, id_ex_aluop;
    wire              id_ex_branch, id_ex_jump, id_ex_jump_r;
    wire              id_ex_alusrc, id_ex_alusrca;

    ID_EX id_ex (
        .clk(clk), .rst(reset), .flush(stall_pipeline | flush_on_branch),
        .PC_in(if_id_pc), .PCplus4_in(if_id_pcplus4),
        .rs1_data_in(rs1_data_id), .rs2_data_in(rs2_data_id),
        .imm_in(imm_id),
        .rs1_in(rs1_id), .rs2_in(rs2_id), .rd_in(rd_id),
        .funct3_in(funct3_id), .Funct7_in(funct7_id),
        .RegWrite_in(reg_write), .mem2reg_in(mem2reg),
        .MemRead_in(mem_read), .MemWrite_in(mem_write),
        .Branch_in(branch), .Jump_in(jump), .jump_r_in(jump_r),
        .ALUSrc_in(alu_src), .ALUSrcA_in(alu_src_a), .ALUOp_in(aluop),
        .PC_out(id_ex_pc), .PCplus4_out(id_ex_pcplus4),
        .rs1_data_out(id_ex_rs1_data), .rs2_data_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1), .rs2_out(id_ex_rs2), .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3), .Funct7_out(id_ex_funct7),
        .RegWrite_out(id_ex_regwrite), .mem2reg_out(id_ex_mem2reg),
        .MemRead_out(id_ex_memread), .MemWrite_out(id_ex_memwrite),
        .Branch_out(id_ex_branch), .Jump_out(id_ex_jump), .jump_r_out(id_ex_jump_r),
        .ALUSrc_out(id_ex_alusrc), .ALUSrcA_out(id_ex_alusrca),
        .ALUOp_out(id_ex_aluop)
    );

    //                        EX STAGE
    wire [1:0] forwardA, forwardB;
    forwarding_unit fwd_unit (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_regwrite(ex_mem_regwrite),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_regwrite(mem_wb_regwrite),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    // 3-to-1 forwarding muxes on rs1 and rs2 (BEFORE AUIPC and ALUSrc muxes)
    wire [DATA_W-1:0] rs1_forwarded_ex =
        (forwardA == 2'b10) ? ex_mem_forward_value :
        (forwardA == 2'b01) ? wb_data :
                              id_ex_rs1_data;

    wire [DATA_W-1:0] rs2_forwarded_ex =
        (forwardB == 2'b10) ? ex_mem_forward_value :
        (forwardB == 2'b01) ? wb_data :
                              id_ex_rs2_data;

    // AUIPC mux on A (PC vs forwarded rs1)
    wire [DATA_W-1:0] alu_a_ex = id_ex_alusrca ? id_ex_pc : rs1_forwarded_ex;

    // ALUSrc mux on B (imm vs forwarded rs2)
    wire [DATA_W-1:0] alu_b_ex;
    mux_32 alu_src_mux (
        .s (id_ex_alusrc),
        .d0(rs2_forwarded_ex),
        .d1(id_ex_imm),
        .y (alu_b_ex)
    );

    wire [ALU_CC_W-1:0] alu_cc_ex;
    ALUController ex_alu_ctrl (
        .ALUOp(id_ex_aluop), .Funct7(id_ex_funct7),
        .Funct3(id_ex_funct3), .Operation(alu_cc_ex)
    );

    wire [DATA_W-1:0] alu_out_ex;
    wire              zero_ex;
    ALU #(.DATA_W(DATA_W), .ALU_CC_W(ALU_CC_W)) alu (
        .A(alu_a_ex), .B(alu_b_ex),
        .alu_cc(alu_cc_ex),
        .alu_result(alu_out_ex), .zero(zero_ex)
    );

    assign alu_result = alu_out_ex;

    // Branch logic uses FORWARDED values
    wire take_branch_ex;
    branch_logic branch_eval (
        .rs1(rs1_forwarded_ex),
        .rs2(rs2_forwarded_ex),
        .funct3(id_ex_funct3),
        .take_branch(take_branch_ex)
    );

    assign branch_target_ex = id_ex_pc[PC_W-1:0] + id_ex_imm[PC_W-1:0];
    assign jumpr_target_ex  = alu_out_ex[PC_W-1:0];
    assign pc_redirect_ex   = (id_ex_branch & take_branch_ex) | id_ex_jump;
    assign jump_r_ex        = id_ex_jump_r;
    assign flush_on_branch = pc_redirect_ex | jump_r_ex;

    // ---------- EX/MEM ----------
    // NOTE: rs2_data_in uses FORWARDED value so stores get correct data
    wire [DATA_W-1:0] ex_mem_alu, ex_mem_rs2, ex_mem_pcplus4, ex_mem_imm;
    wire [2:0]        ex_mem_funct3;
    wire              ex_mem_memread, ex_mem_memwrite;
    wire [1:0]        ex_mem_mem2reg;

    EX_MEM ex_mem (
        .clk(clk), .rst(reset),
        .ALU_result_in(alu_out_ex),
        .rs2_data_in(rs2_forwarded_ex),
        .PCplus4_in(id_ex_pcplus4),
        .imm_in(id_ex_imm),
        .rd_in(id_ex_rd),
        .funct3_in(id_ex_funct3),
        .RegWrite_in(id_ex_regwrite), .mem2reg_in(id_ex_mem2reg),
        .MemRead_in(id_ex_memread), .MemWrite_in(id_ex_memwrite),
        .ALU_result_out(ex_mem_alu),
        .rs2_data_out(ex_mem_rs2),
        .PCplus4_out(ex_mem_pcplus4),
        .imm_out(ex_mem_imm),
        .rd_out(ex_mem_rd),
        .funct3_out(ex_mem_funct3),
        .RegWrite_out(ex_mem_regwrite), .mem2reg_out(ex_mem_mem2reg),
        .MemRead_out(ex_mem_memread), .MemWrite_out(ex_mem_memwrite)
    );

    // Pre-compute what EX/MEM's writeback value WILL be, for forwarding.
    // Handles JAL/JALR (PC+4) and LUI (imm) correctly, not just ALU results.
    // Load data (mem2reg=01) isn't ready yet - Phase 3 stalls for that case.
    assign ex_mem_forward_value =
        (ex_mem_mem2reg == 2'b10) ? ex_mem_pcplus4 :
        (ex_mem_mem2reg == 2'b11) ? ex_mem_imm     :
                                    ex_mem_alu;

    //                       MEM STAGE
    wire [DATA_W-1:0] dm_read_data_mem;
    data_mem data_memory (
        .MemRead(ex_mem_memread), .MemWrite(ex_mem_memwrite),
        .addr(ex_mem_alu[DM_ADDRESS-1:0]),
        .write_data(ex_mem_rs2),
        .read_data(dm_read_data_mem)
    );

    wire [DATA_W-1:0] mem_wb_alu, mem_wb_memdata, mem_wb_pcplus4, mem_wb_imm;
    wire [1:0]        mem_wb_mem2reg;

    MEM_WB mem_wb (
        .clk(clk), .rst(reset),
        .ALU_result_in(ex_mem_alu),
        .mem_read_data_in(dm_read_data_mem),
        .PCplus4_in(ex_mem_pcplus4),
        .imm_in(ex_mem_imm),
        .rd_in(ex_mem_rd),
        .RegWrite_in(ex_mem_regwrite),
        .mem2reg_in(ex_mem_mem2reg),
        .ALU_result_out(mem_wb_alu),
        .mem_read_data_out(mem_wb_memdata),
        .PCplus4_out(mem_wb_pcplus4),
        .imm_out(mem_wb_imm),
        .rd_out(mem_wb_rd),
        .RegWrite_out(mem_wb_regwrite),
        .mem2reg_out(mem_wb_mem2reg)
    );

    //                       WB STAGE
    mux_32_4to1 wb_mux (
        .s (mem_wb_mem2reg),
        .d0(mem_wb_alu),
        .d1(mem_wb_memdata),
        .d2(mem_wb_pcplus4),
        .d3(mem_wb_imm),
        .y (wb_data)
    );

endmodule