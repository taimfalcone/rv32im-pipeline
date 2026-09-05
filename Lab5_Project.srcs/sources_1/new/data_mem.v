`timescale 1ns / 1ps
module data_mem(clk, MemRead, MemWrite, addr, write_data, read_data);
    input             clk;
    input             MemRead;
    input             MemWrite;
    input      [8:0]  addr;
    input      [31:0] write_data;
    output     [31:0] read_data;

    reg [31:0] memory [127:0];

    // Write on FALLING edge - completes half a cycle before the next rising
    // edge, so downstream flops capturing on posedge see stable data
    always @(negedge clk) begin
        if (MemWrite)
            memory[addr[8:2]] <= write_data;
    end

    assign read_data = MemRead ? memory[addr[8:2]] : 32'h00000000;

endmodule