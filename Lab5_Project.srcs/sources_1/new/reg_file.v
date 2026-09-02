`timescale 1ns / 1ps

module reg_file #(
    parameter DATA_W = 32
)(
    input clk,
    input reset,
    input rg_wrt_en,
    input [4:0] rg_wrt_addr,
    input [4:0] rg_rd_addr1,
    input [4:0] rg_rd_addr2,
    input [DATA_W-1:0] rg_wrt_data,
    output [DATA_W-1:0] rg_rd_data1,
    output [DATA_W-1:0] rg_rd_data2
);
    reg [DATA_W-1:0] registers [0:31];

    // x0 is hardwired to zero per RISC-V spec
    assign rg_rd_data1 = (rg_rd_addr1 == 0) ? 0 : registers[rg_rd_addr1];
    assign rg_rd_data2 = (rg_rd_addr2 == 0) ? 0 : registers[rg_rd_addr2];

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 0;
        end else if (rg_wrt_en && rg_wrt_addr != 0) begin
            registers[rg_wrt_addr] <= rg_wrt_data;
        end
    end
endmodule
