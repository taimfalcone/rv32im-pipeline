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

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
    end

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

    initial begin
        @(negedge rst);
        repeat (80) @(posedge clk);

        $display("");
        $display("=====================================================");
        $display("  Pipelined RV32I processor - functional regression  ");
        $display("=====================================================");

        check_reg(1,  32'h00000001, "SUB result");
        check_reg(2,  32'h00000002, "AND result");
        check_reg(3,  32'h00000003, "OR result");
        check_reg(4,  32'h00000007, "XOR result");
        check_reg(5,  32'h0000000C, "SLT chain result");
        check_reg(7,  32'h0000001B, "LW result (forwarding into store)");
        check_reg(8,  32'h00000004, "LW result");
        check_reg(9,  32'h00000007, "ADD after load-use (stall verified)");
        check_reg(10, 32'h0000000E, "ADD cascade");
        check_reg(11, 32'h0000001C, "ADD cascade");
        check_reg(12, 32'h00000038, "ADD cascade");
        check_reg(13, 32'h00000070, "ADD cascade");
        check_reg(14, 32'h000000E0, "ADD cascade");
        check_reg(15, 32'h000001C0, "ADD cascade");
        check_reg(16, 32'h00000380, "ADD cascade");
        check_reg(17, 32'h00000700, "ADD cascade");
        check_reg(18, 32'h00000E00, "ADD cascade");
        check_reg(19, 32'h00000E01, "ADD post-branch (flush verified)");
        check_reg(20, 32'h00000E01, "ADD post-branch");
        check_reg(21, 32'h00000E04, "ADD post-branch");
        check_reg(22, 32'h00000E08, "ADD post-branch");
        check_reg(23, 32'h00000E08, "ADD post-branch");
        check_reg(28, 32'h00000E30, "ADD final chain result");

        $display("=====================================================");
        $display("  Results: %0d passed, %0d failed  (of %0d checks)",
                 pass, fail, pass + fail);
        $display("=====================================================");
        $finish;
    end

    initial begin #2500; $finish; end
endmodule