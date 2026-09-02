`timescale 1ns / 1ps

module processor (
    input  clk, reset,
    output [31:0] Result
);
    wire [6:0] opcode;
    wire [1:0] ALUOp;
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
        .aluop     (ALUOp),
        .opcode    (opcode),
        .alu_result(Result)
    );
endmodule
