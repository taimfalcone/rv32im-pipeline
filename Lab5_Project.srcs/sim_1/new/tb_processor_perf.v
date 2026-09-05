`timescale 1ns / 1ps

module tb_processor_perf();
    reg clk, rst;
    wire [31:0] tb_Result;

    // Steady-state cycle counter
    reg counting = 0;
    integer cycles_ss = 0;
    reg first_retire_seen = 0;
    integer last_retire_cycle = 0;
    integer instructions_retired = 0;

    processor processor_inst(
        .clk    (clk),
        .reset  (rst),
        .Result (tb_Result)
    );

    // Peek at what MEM/WB is about to write. If RegWrite=1 and rd!=0, an
    // instruction is retiring this cycle.
    wire retire_this_cycle =
        processor_inst.u_data_path.mem_wb_regwrite &&
        (processor_inst.u_data_path.mem_wb_rd != 5'b0);

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
    end

    // Count cycles only between first and last retire (steady state)
    always @(posedge clk) begin
        if (!rst) begin
            if (retire_this_cycle) begin
                if (!first_retire_seen) begin
                    first_retire_seen <= 1;
                    counting          <= 1;
                    cycles_ss         <= 1;
                    instructions_retired <= 1;
                end else begin
                    instructions_retired <= instructions_retired + 1;
                    cycles_ss <= cycles_ss + 1;
                end
                last_retire_cycle <= cycles_ss;
            end else if (counting) begin
                cycles_ss <= cycles_ss + 1;
            end
        end
    end

    initial begin
        @(negedge rst);
        repeat (100) @(posedge clk);   // long enough for the whole program

        $display("");
        $display("=====================================================");
        $display("  Pipelined RV32I processor - performance metrics    ");
        $display("=====================================================");
        $display("  Program: mixed ALU/mem/branch, 70 retired instrs");
        $display("");
        $display("  Instructions retired:   %0d", instructions_retired);
        $display("  Steady-state cycles:    %0d", last_retire_cycle);
        $display("  CPI (steady state):     %0f", last_retire_cycle * 1.0 / instructions_retired);
        $display("=====================================================");
        $finish;
    end

    initial begin #3000; $finish; end
endmodule