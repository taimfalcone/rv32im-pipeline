`timescale 1ns / 1ps

module forwarding_unit (
    input      [4:0] id_ex_rs1,
    input      [4:0] id_ex_rs2,
    input      [4:0] ex_mem_rd,
    input            ex_mem_regwrite,
    input      [4:0] mem_wb_rd,
    input            mem_wb_regwrite,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    // Mux encoding:
    //   2'b00 = no forward, use id_ex_rs*_data (from register file)
    //   2'b01 = forward from MEM/WB (wb_data)
    //   2'b10 = forward from EX/MEM (pre-computed writeback value)
    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX/MEM has priority (newer value wins if both stages match)
        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1))
            forwardA = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1))
            forwardA = 2'b01;

        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2))
            forwardB = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2))
            forwardB = 2'b01;
    end
endmodule
