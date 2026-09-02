`timescale 1ns / 1ps

module EX_MEM (
    input             clk,
    input             rst,
    input      [31:0] ALU_result_in,
    input      [31:0] rs2_data_in,
    input      [31:0] PCplus4_in,
    input      [31:0] imm_in,
    input      [4:0]  rd_in,
    input      [2:0]  funct3_in,
    input             RegWrite_in,
    input      [1:0]  mem2reg_in,
    input             MemRead_in,
    input             MemWrite_in,

    output reg [31:0] ALU_result_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] PCplus4_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rd_out,
    output reg [2:0]  funct3_out,
    output reg        RegWrite_out,
    output reg [1:0]  mem2reg_out,
    output reg        MemRead_out,
    output reg        MemWrite_out
);
    always @(posedge clk) begin
        if (rst) begin
            ALU_result_out <= 32'b0;
            rs2_data_out   <= 32'b0;
            PCplus4_out    <= 32'b0;
            imm_out        <= 32'b0;
            rd_out         <= 5'b0;
            funct3_out     <= 3'b0;
            RegWrite_out   <= 1'b0;
            mem2reg_out    <= 2'b0;
            MemRead_out    <= 1'b0;
            MemWrite_out   <= 1'b0;
        end else begin
            ALU_result_out <= ALU_result_in;
            rs2_data_out   <= rs2_data_in;
            PCplus4_out    <= PCplus4_in;
            imm_out        <= imm_in;
            rd_out         <= rd_in;
            funct3_out     <= funct3_in;
            RegWrite_out   <= RegWrite_in;
            mem2reg_out    <= mem2reg_in;
            MemRead_out    <= MemRead_in;
            MemWrite_out   <= MemWrite_in;
        end
    end
endmodule
