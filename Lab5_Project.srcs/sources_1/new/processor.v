`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 03:55:18 PM
// Design Name: 
// Module Name: processor
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


module processor (
    input clk, reset,
    output [31:0] Result
);
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [1:0] ALUOp;
    wire [3:0] ALU_CC;
    wire       ALUSrc;
    wire [1:0] MemtoReg;
    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       Branch;
    wire       Jump;
    wire       JumpR;
    wire       ALUSrcA;

    Controller u_controller (
        .Opcode   (opcode),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .RegWrite (RegWrite),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .Branch   (Branch),
        .Jump     (Jump),
        .JumpR    (JumpR),
        .ALUSrcA  (ALUSrcA),
        .ALUOp    (ALUOp)
    );

    ALUController u_alu_controller (
        .ALUOp     (ALUOp),
        .Funct7    (funct7),
        .Funct3    (funct3),
        .Operation (ALU_CC)
    );

    data_path u_data_path (
        .clk       (clk),
        .reset     (reset),
        .alu_src   (ALUSrc),
        .mem2reg   (MemtoReg),
        .reg_write (RegWrite),
        .mem_read  (MemRead),
        .mem_write (MemWrite),
        .branch    (Branch),
        .jump      (Jump),
        .jump_r    (JumpR),
        .alu_src_a (ALUSrcA),
        .alu_cc    (ALU_CC),
        .opcode    (opcode),
        .funct3    (funct3),
        .funct7    (funct7),
        .alu_result(Result)
    );
endmodule
