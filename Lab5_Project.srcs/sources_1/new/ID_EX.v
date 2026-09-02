`timescale 1ns / 1ps

module ID_EX (
    input             clk,
    input             rst,
    input             flush,
    input      [31:0] PC_in,
    input      [31:0] PCplus4_in,
    input      [31:0] rs1_data_in,
    input      [31:0] rs2_data_in,
    input      [31:0] imm_in,
    input      [4:0]  rs1_in,
    input      [4:0]  rs2_in,
    input      [4:0]  rd_in,
    input      [2:0]  funct3_in,
    input      [6:0]  Funct7_in,
    input             RegWrite_in,
    input      [1:0]  mem2reg_in,
    input             MemRead_in,
    input             MemWrite_in,
    input             Branch_in,
    input             Jump_in,
    input             jump_r_in,
    input             ALUSrc_in,
    input             ALUSrcA_in,
    input      [1:0]  ALUOp_in,

    output reg [31:0] PC_out,
    output reg [31:0] PCplus4_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,
    output reg [2:0]  funct3_out,
    output reg [6:0]  Funct7_out,
    output reg        RegWrite_out,
    output reg [1:0]  mem2reg_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg        Branch_out,
    output reg        Jump_out,
    output reg        jump_r_out,
    output reg        ALUSrc_out,
    output reg        ALUSrcA_out,
    output reg [1:0]  ALUOp_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            PC_out       <= 32'b0;
            PCplus4_out  <= 32'b0;
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out      <= 32'b0;
            rs1_out      <= 5'b0;
            rs2_out      <= 5'b0;
            rd_out       <= 5'b0;
            funct3_out   <= 3'b0;
            Funct7_out   <= 7'b0;
            RegWrite_out <= 1'b0;
            mem2reg_out  <= 2'b0;
            MemRead_out  <= 1'b0;
            MemWrite_out <= 1'b0;
            Branch_out   <= 1'b0;
            Jump_out     <= 1'b0;
            jump_r_out   <= 1'b0;
            ALUSrc_out   <= 1'b0;
            ALUSrcA_out  <= 1'b0;
            ALUOp_out    <= 2'b0;
        end else begin
            PC_out       <= PC_in;
            PCplus4_out  <= PCplus4_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out      <= imm_in;
            rs1_out      <= rs1_in;
            rs2_out      <= rs2_in;
            rd_out       <= rd_in;
            funct3_out   <= funct3_in;
            Funct7_out   <= Funct7_in;
            RegWrite_out <= RegWrite_in;
            mem2reg_out  <= mem2reg_in;
            MemRead_out  <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Branch_out   <= Branch_in;
            Jump_out     <= Jump_in;
            jump_r_out   <= jump_r_in;
            ALUSrc_out   <= ALUSrc_in;
            ALUSrcA_out  <= ALUSrcA_in;
            ALUOp_out    <= ALUOp_in;
        end
    end
endmodule