`timescale 1ns / 1ps

module IF_ID (
    input         clk,
    input         rst,
    input         stall,
    input         flush,
    input  [31:0] instruction_in,
    input  [31:0] PC_in,
    input  [31:0] PCplus4_in,
    output reg [31:0] instruction_out,
    output reg [31:0] PC_out,
    output reg [31:0] PCplus4_out
    );

    always @(posedge clk) begin
        if (rst || flush) begin
            instruction_out <= 32'h00000013; // canonical NOP: addi x0,x0,0
            PC_out          <= 32'b0;
            PCplus4_out     <= 32'b0;
        end else if (!stall) begin
            instruction_out <= instruction_in;
            PC_out          <= PC_in;
            PCplus4_out     <= PCplus4_in;
        end
    end
endmodule
