`timescale 1ns / 1ps

module tb_processor();
    reg clk, rst;
    wire [31:0] tb_Result;
    integer pass = 0;
    integer fail = 0;

    processor processor_inst(
        .clk    (clk),
        .reset  (rst),
        .Result (tb_Result)
    );

    // 20 ns clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Reset held for 2 cycles
    initial begin
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
    end

    // Check a register against expected value, tally pass/fail
    task check_reg;
        input [4:0]  reg_num;
        input [31:0] expected;
        input [255:0] label;
        begin
            if (processor_inst.u_data_path.rf.registers[reg_num] === expected) begin
                $display("PASS  x%0d = 0x%08x  [%0s]", reg_num, expected, label);
                pass = pass + 1;
            end else begin
                $display("FAIL  x%0d = 0x%08x  expected 0x%08x  [%0s]",
                         reg_num, processor_inst.u_data_path.rf.registers[reg_num],
                         expected, label);
                fail = fail + 1;
            end
        end
    endtask

    // Main sequence
    initial begin
        @(negedge rst);
        repeat (40) @(posedge clk);  // give the pipeline time to drain

        $display("");
        $display("=====================================================");
        $display("  Pipelined RV32I processor - register file check    ");
        $display("=====================================================");

        check_reg(1,  32'h00000005, "ADDI");
        check_reg(2,  32'h0000000A, "ADDI");
        check_reg(3,  32'h0000000F, "ADD  with EX/MEM forwarding");
        check_reg(4,  32'h0000000A, "SUB  with EX/MEM forwarding");
        check_reg(5,  32'h00000000, "AND");
        check_reg(6,  32'h0000000F, "LW");
        check_reg(7,  32'h0000001E, "ADD  after load-use stall");
        check_reg(8,  32'h0000002A, "BEQ  taken (flush verified)");
        check_reg(9,  32'h00000021, "BEQ  taken (2nd branch)");
        check_reg(10, 32'h00000055, "JAL  target reached");
        check_reg(11, 32'h00000048, "JAL  link (PC+4)");
        check_reg(13, 32'h12345678, "LUI + ADDI");
        check_reg(14, 32'h00000058, "AUIPC");

        $display("=====================================================");
        $display("  Results: %0d passed, %0d failed  (of %0d checks)",
                 pass, fail, pass + fail);
        $display("=====================================================");
        $finish;
    end

    // Safety timeout
    initial begin
        #2000;
        $display("TIMEOUT - simulation ran too long");
        $finish;
    end
endmodule