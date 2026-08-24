`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/16/2026 09:45:00 AM
// Design Name: 
// Module Name: alu
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


module ALU #(
    parameter DATA_W   = 32,
    parameter ALU_CC_W = 4
)(
    input  [DATA_W-1:0]   A,
    input  [DATA_W-1:0]   B,
    input  [ALU_CC_W-1:0] alu_cc,
    output reg [DATA_W-1:0] alu_result,
    output zero
);
    assign zero = (alu_result == 0);

    always @(*) begin
        case (alu_cc)
            4'b0000: alu_result = A & B;                                    // AND
            4'b0001: alu_result = A | B;                                    // OR
            4'b0010: alu_result = A + B;                                    // ADD
            4'b0011: alu_result = A << B[4:0];                              // SLL
            4'b0100: alu_result = A >> B[4:0];                              // SRL
            4'b0101: alu_result = $signed(A) >>> B[4:0];                    // SRA
            4'b0110: alu_result = A - B;                                    // SUB
            4'b0111: alu_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b1000: alu_result = A ^ B;                                    // XOR
            4'b1001: alu_result = (A < B) ? 32'd1 : 32'd0;                 // SLTU
            default: alu_result = 32'b0;
        endcase
    end
endmodule
