`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/08/2026 12:58:46 PM
// Design Name: 
// Module Name: data_path
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_path #(
    parameter PC_W = 8,
    parameter INS_W = 32,
    parameter RF_ADDRESS = 5,
    parameter DATA_W = 32,
    parameter DM_ADDRESS = 9,
    parameter ALU_CC_W = 4
) (
    input clk,
    input reset,
    input reg_write,
    input [1:0] mem2reg,
    input alu_src,
    input mem_write,
    input mem_read,
    input branch,
    input jump,
    input jump_r,
    input alu_src_a,
    input [ALU_CC_W-1:0] alu_cc,
    output [6:0] opcode,
    output [6:0] funct7,
    output [2:0] funct3,
    output [DATA_W-1:0] alu_result
);

    // Wires
    wire [PC_W-1:0]   pc_out, pc_plus4, pc_next;
    wire [PC_W-1:0]   branch_target;
    wire [INS_W-1:0]  instruction;
    wire [DATA_W-1:0] rg_rd_data1, rg_rd_data2;
    wire [DATA_W-1:0] imm_out;
    wire [DATA_W-1:0] alu_a, alu_b;
    wire [DATA_W-1:0] alu_out;
    wire              zero;
    wire [DATA_W-1:0] dm_read_data;
    wire [DATA_W-1:0] wb_data;
    wire [4:0]        rg_wrt_addr, rg_rd_addr1, rg_rd_addr2;
    wire              take_branch;
    wire              pc_sel_branch;

    // Instruction field slices
    assign opcode      = instruction[6:0];
    assign rg_wrt_addr = instruction[11:7];
    assign funct3      = instruction[14:12];
    assign rg_rd_addr1 = instruction[19:15];
    assign rg_rd_addr2 = instruction[24:20];
    assign funct7      = instruction[31:25];
    assign alu_result  = alu_out;

    // --- PC logic ---
    assign pc_plus4 = pc_out + 4;
    assign branch_target = pc_out + imm_out[PC_W-1:0];
    assign pc_sel_branch = (branch & take_branch) | jump;
    assign pc_next = jump_r        ? alu_out[PC_W-1:0] :
                     pc_sel_branch ? branch_target :
                     pc_plus4;

    flip_flop pc_reg (
        .clk(clk),
        .reset(reset),
        .d(pc_next),
        .q(pc_out)
    );

    // --- Instruction fetch ---
    inst_mem inst_memory (
        .addr(pc_out),
        .instruction(instruction)
    );

    // --- Register file ---
    reg_file rf (
        .clk(clk),
        .reset(reset),
        .rg_wrt_en(reg_write),
        .rg_wrt_addr(rg_wrt_addr),
        .rg_rd_addr1(rg_rd_addr1),
        .rg_rd_addr2(rg_rd_addr2),
        .rg_wrt_data(wb_data),
        .rg_rd_data1(rg_rd_data1),
        .rg_rd_data2(rg_rd_data2)
    );

    // --- Immediate generator ---
    imm_gen #(.INS_W(INS_W), .DATA_W(DATA_W)) imm_generator (
        .InstCode(instruction),
        .imm_out(imm_out)
    );

    // --- ALU input A mux (rs1 or PC for AUIPC) ---
    assign alu_a = alu_src_a ? {{(DATA_W-PC_W){1'b0}}, pc_out} : rg_rd_data1;

    // --- ALU input B mux (rs2 or immediate) ---
    mux_32 alu_src_mux (
        .s(alu_src),
        .d0(rg_rd_data2),
        .d1(imm_out),
        .y(alu_b)
    );

    // --- ALU ---
    ALU #(.DATA_W(DATA_W), .ALU_CC_W(ALU_CC_W)) alu (
        .A(alu_a),
        .B(alu_b),
        .alu_cc(alu_cc),
        .alu_result(alu_out),
        .zero(zero)
    );

    // --- Branch logic ---
    branch_logic branch_eval (
        .rs1(rg_rd_data1),
        .rs2(rg_rd_data2),
        .funct3(funct3),
        .take_branch(take_branch)
    );

    // --- Data memory ---
    data_mem data_memory (
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .addr(alu_out[DM_ADDRESS-1:0]),
        .write_data(rg_rd_data2),
        .read_data(dm_read_data)
    );

    // --- Writeback 4-to-1 mux ---
    mux_32_4to1 wb_mux (
        .s(mem2reg),
        .d0(alu_out),                                  // 00: ALU result
        .d1(dm_read_data),                             // 01: memory data
        .d2({{(DATA_W-PC_W){1'b0}}, pc_plus4}),       // 10: PC+4 (JAL/JALR)
        .d3(imm_out),                                  // 11: immediate (LUI)
        .y(wb_data)
    );

endmodule