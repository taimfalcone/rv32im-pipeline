`timescale 1ns / 1ps

module imm_gen #(
    parameter INS_W  = 32,
    parameter DATA_W = 32
)(
    input  [INS_W-1:0]  InstCode,
    output reg [DATA_W-1:0] imm_out
);
    always @(*) begin
        case (InstCode[6:0])
            7'b0000011: // I-type (load)
                imm_out = {{20{InstCode[31]}}, InstCode[31:20]};
            7'b0010011: // I-type (ALU immediate)
                imm_out = {{20{InstCode[31]}}, InstCode[31:20]};
            7'b1100111: // I-type (JALR)
                imm_out = {{20{InstCode[31]}}, InstCode[31:20]};
            7'b0100011: // S-type (store)
                imm_out = {{20{InstCode[31]}}, InstCode[31:25], InstCode[11:7]};
            7'b1100011: // B-type (branches)
                imm_out = {{19{InstCode[31]}}, InstCode[31], InstCode[7],
                            InstCode[30:25], InstCode[11:8], 1'b0};
            7'b0110111: // U-type (LUI)
                imm_out = {InstCode[31:12], 12'b0};
            7'b0010111: // U-type (AUIPC)
                imm_out = {InstCode[31:12], 12'b0};
            7'b1101111: // J-type (JAL)
                imm_out = {{11{InstCode[31]}}, InstCode[31], InstCode[19:12],
                            InstCode[20], InstCode[30:21], 1'b0};
            default:
                imm_out = 32'b0;
        endcase
    end
endmodule