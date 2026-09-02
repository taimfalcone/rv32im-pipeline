`timescale 1ns / 1ps

module MEM_WB (
    input             clk,
    input             rst,
    input      [31:0] ALU_result_in,
    input      [31:0] mem_read_data_in,
    input      [31:0] PCplus4_in,
    input      [31:0] imm_in,
    input      [4:0]  rd_in,
    input             RegWrite_in,
    input      [1:0]  mem2reg_in,

    output reg [31:0] ALU_result_out,
    output reg [31:0] mem_read_data_out,
    output reg [31:0] PCplus4_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rd_out,
    output reg        RegWrite_out,
    output reg [1:0]  mem2reg_out
);
    always @(posedge clk) begin
        if (rst) begin
            ALU_result_out    <= 32'b0;
            mem_read_data_out <= 32'b0;
            PCplus4_out       <= 32'b0;
            imm_out           <= 32'b0;
            rd_out            <= 5'b0;
            RegWrite_out      <= 1'b0;
            mem2reg_out       <= 2'b0;
        end else begin
            ALU_result_out    <= ALU_result_in;
            mem_read_data_out <= mem_read_data_in;
            PCplus4_out       <= PCplus4_in;
            imm_out           <= imm_in;
            rd_out            <= rd_in;
            RegWrite_out      <= RegWrite_in;
            mem2reg_out       <= mem2reg_in;
        end
    end
endmodule
