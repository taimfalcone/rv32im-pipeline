`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 04:49:54 PM
// Design Name: 
// Module Name: tb_processor
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
//////////////////////////////////////////////////////////////////////////////////

module tb_processor();
    reg clk, rst;
    wire [31:0] tb_Result;

    processor processor_inst(
        .clk    (clk),
        .reset  (rst),
        .Result (tb_Result)
    );

    integer point = 0;

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
    end

    initial begin
        @(negedge rst);
        @(posedge clk);

        // ===== EXISTING TESTS (20 checks) =====
        @(negedge clk); if (tb_Result == 32'h00000000) point = point + 1;
        else $display("Oh no! AND  expected 0x00000000, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000001) point = point + 1;
        else $display("Oh no! ADDI expected 0x00000001, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000002) point = point + 1;
        else $display("Oh no! ADDI expected 0x00000002, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000004) point = point + 1;
        else $display("Oh no! ADDI expected 0x00000004, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000005) point = point + 1;
        else $display("Oh no! ADDI expected 0x00000005, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000007) point = point + 1;
        else $display("Oh no! ADDI expected 0x00000007, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000008) point = point + 1;
        else $display("Oh no! ADDI expected 0x00000008, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h0000000b) point = point + 1;
        else $display("Oh no! ADDI expected 0x0000000b, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000003) point = point + 1;
        else $display("Oh no! ADD  expected 0x00000003, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'hfffffffe) point = point + 1;
        else $display("Oh no! SUB  expected 0xfffffffe, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000000) point = point + 1;
        else $display("Oh no! AND  expected 0x00000000, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000005) point = point + 1;
        else $display("Oh no! OR   expected 0x00000005, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000001) point = point + 1;
        else $display("Oh no! SLT  expected 0x00000001, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000003) point = point + 1;
        else $display("Oh no! XOR  expected 0x00000003, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h000004D2) point = point + 1;
        else $display("Oh no! ANDI expected 0x000004D2, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'hfffff8d7) point = point + 1;
        else $display("Oh no! ORI  expected 0xfffff8d7, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000001) point = point + 1;
        else $display("Oh no! SLTI expected 0x00000001, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h000004d1) point = point + 1;
        else $display("Oh no! XORI expected 0x000004d1, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000030) point = point + 1;
        else $display("Oh no! SW   expected 0x00000030, got 32'h%08x", tb_Result);

        @(negedge clk); if (tb_Result == 32'h00000030) point = point + 1;
        else $display("Oh no! LW   expected 0x00000030, got 32'h%08x", tb_Result);

        // ===== NEW TESTS: branches, jumps, LUI, AUIPC =====

                // ===== NEW TESTS with debug =====

        @(negedge clk); $display("[t=%0t] skip (BEQ) tb_Result=0x%08x", $time, tb_Result);

        @(negedge clk); $display("[t=%0t] BEQ-target tb_Result=0x%08x", $time, tb_Result);
        if (tb_Result == 32'h0000002A) point = point + 1;
        else $display("Oh no! BEQ-target expected 0x0000002A, got 32'h%08x", tb_Result);

        @(negedge clk); $display("[t=%0t] skip (BNE) tb_Result=0x%08x", $time, tb_Result);

        @(negedge clk); $display("[t=%0t] BNE-fallthrough tb_Result=0x%08x", $time, tb_Result);
        if (tb_Result == 32'h00000037) point = point + 1;
        else $display("Oh no! BNE-fallthrough expected 0x00000037, got 32'h%08x", tb_Result);

        @(negedge clk); $display("[t=%0t] skip (JAL) tb_Result=0x%08x", $time, tb_Result);

        @(negedge clk); $display("[t=%0t] JAL-target tb_Result=0x%08x", $time, tb_Result);
        if (tb_Result == 32'h00000021) point = point + 1;
        else $display("Oh no! JAL-target expected 0x00000021, got 32'h%08x", tb_Result);

        @(negedge clk); $display("[t=%0t] skip (LUI) tb_Result=0x%08x", $time, tb_Result);

        @(negedge clk); $display("[t=%0t] LUI+ADDI tb_Result=0x%08x", $time, tb_Result);
        if (tb_Result == 32'h12345678) point = point + 1;
        else $display("Oh no! LUI+ADDI expected 0x12345678, got 32'h%08x", tb_Result);

        @(negedge clk); $display("[t=%0t] AUIPC tb_Result=0x%08x", $time, tb_Result);
        if (tb_Result == 32'h0000007C) point = point + 1;
        else $display("Oh no! AUIPC expected 0x0000007C, got 32'h%08x", tb_Result);
        
                // ===== ADDITIONAL BRANCH/JUMP TESTS =====

        // BLT executes - ALU output meaningless
        @(negedge clk);

        // BLT target: memory[34] ADDI → 0x2C (44)
        @(negedge clk); if (tb_Result == 32'h0000002C) point = point + 1;
        else $display("Oh no! BLT-target expected 0x0000002C, got 32'h%08x", tb_Result);

        // BGE executes - ALU output meaningless
        @(negedge clk);

        // BGE target: memory[37] ADDI → 0x37 (55)
        @(negedge clk); if (tb_Result == 32'h00000037) point = point + 1;
        else $display("Oh no! BGE-target expected 0x00000037, got 32'h%08x", tb_Result);

        // BLTU executes - ALU output meaningless
        @(negedge clk);

        // BLTU target: memory[40] ADDI → 0x42 (66)
        @(negedge clk); if (tb_Result == 32'h00000042) point = point + 1;
        else $display("Oh no! BLTU-target expected 0x00000042, got 32'h%08x", tb_Result);

        // BGEU executes - ALU output meaningless
        @(negedge clk);

        // BGEU target: memory[43] ADDI → 0x4D (77)
        @(negedge clk); if (tb_Result == 32'h0000004D) point = point + 1;
        else $display("Oh no! BGEU-target expected 0x0000004D, got 32'h%08x", tb_Result);

        // ADDI x28, x0, 176 - executes normally, sets up JALR target
        // ALU result = 176 = 0xB0
        @(negedge clk); if (tb_Result == 32'h000000B0) point = point + 1;
        else $display("Oh no! ADDI-setup expected 0x000000B0, got 32'h%08x", tb_Result);

        // JALR executes - ALU output IS meaningful (it's the jump target)
        // ALU computes x28 + 12 = 0xBC. That IS tb_Result.
        @(negedge clk); if (tb_Result == 32'h000000BC) point = point + 1;
        else $display("Oh no! JALR-target-calc expected 0x000000BC, got 32'h%08x", tb_Result);

        // JALR lands at memory[47]: ADDI → 0x58 (88)
        @(negedge clk); if (tb_Result == 32'h00000058) point = point + 1;
        else $display("Oh no! JALR-landed expected 0x00000058, got 32'h%08x", tb_Result);

        // ===== RESULTS =====
        $display("Score: %0d / %0d", 4 * point, 4 * 32);
        $finish;
    end

    initial begin #2000; $finish; end
endmodule
