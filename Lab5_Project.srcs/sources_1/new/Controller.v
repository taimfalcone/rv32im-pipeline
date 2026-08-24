`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/08/2026 01:04:36 PM
// Design Name: 
// Module Name: Controller
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


module Controller (
    input  [6:0] Opcode,
    output reg       ALUSrc,
    output reg [1:0] MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Jump,
    output reg       JumpR,
    output reg       ALUSrcA,
    output reg [1:0] ALUOp
);
    always @(*) begin
        // Defaults - all zeros
        ALUSrc   = 1'b0;
        MemtoReg = 2'b00;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        JumpR    = 1'b0;
        ALUSrcA  = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, SLT, etc.)
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            7'b0010011: begin // I-type ALU (ADDI, ANDI, ORI, SLTI, etc.)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            7'b0000011: begin // Load (LW)
                ALUSrc   = 1'b1;
                MemtoReg = 2'b01;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b01;
            end
            7'b0100011: begin // Store (SW)
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b01;
            end
            7'b1100011: begin // B-type (BEQ, BNE, BLT, BGE, etc.)
                Branch   = 1'b1;
            end
            7'b1101111: begin // JAL
                Jump     = 1'b1;
                RegWrite = 1'b1;
                MemtoReg = 2'b10;  // write PC+4 to rd
            end
            7'b1100111: begin // JALR
                ALUSrc   = 1'b1;
                JumpR    = 1'b1;
                RegWrite = 1'b1;
                MemtoReg = 2'b10;  // write PC+4 to rd
                ALUOp    = 2'b01;  // ALU does ADD (rs1 + imm = target)
            end
            7'b0110111: begin // LUI
                RegWrite = 1'b1;
                MemtoReg = 2'b11;  // write immediate to rd
            end
            7'b0010111: begin // AUIPC
                ALUSrc   = 1'b1;
                ALUSrcA  = 1'b1;   // ALU input A = PC
                RegWrite = 1'b1;
                ALUOp    = 2'b01;  // ALU does ADD (PC + imm)
            end
            default: begin
                // all zeros from defaults above
            end
        endcase
    end
endmodule