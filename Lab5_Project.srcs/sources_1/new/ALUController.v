`timescale 1ns / 1ps

module ALUController (
    input  [1:0] ALUOp,
    input  [6:0] Funct7,
    input  [2:0] Funct3,
    output reg [3:0] Operation
);
    always @(*) begin
        case (ALUOp)
            2'b00: begin // I-type ALU
                case (Funct3)
                    3'b000: Operation = 4'b0010; // ADDI
                    3'b010: Operation = 4'b0111; // SLTI
                    3'b011: Operation = 4'b1001; // SLTIU
                    3'b100: Operation = 4'b1000; // XORI
                    3'b110: Operation = 4'b0001; // ORI
                    3'b111: Operation = 4'b0000; // ANDI
                    3'b001: Operation = 4'b0011; // SLLI
                    3'b101: Operation = (Funct7[5]) ? 4'b0101 : 4'b0100; // SRAI : SRLI
                    default: Operation = 4'b0010;
                endcase
            end
            2'b01: begin // Load/Store (address calc = ADD)
                Operation = 4'b0010;
            end
            2'b10: begin // R-type
                case (Funct3)
                    3'b000: Operation = (Funct7[5]) ? 4'b0110 : 4'b0010; // SUB : ADD
                    3'b001: Operation = 4'b0011; // SLL
                    3'b010: Operation = 4'b0111; // SLT
                    3'b011: Operation = 4'b1001; // SLTU
                    3'b100: Operation = 4'b1000; // XOR
                    3'b101: Operation = (Funct7[5]) ? 4'b0101 : 4'b0100; // SRA : SRL
                    3'b110: Operation = 4'b0001; // OR
                    3'b111: Operation = 4'b0000; // AND
                    default: Operation = 4'b0010;
                endcase
            end
            default: Operation = 4'b0010;
        endcase
    end
endmodule
