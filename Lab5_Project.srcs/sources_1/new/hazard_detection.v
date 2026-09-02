`timescale 1ns / 1ps

module hazard_detection (
    input      [4:0] if_id_rs1,
    input      [4:0] if_id_rs2,
    input      [4:0] id_ex_rd,
    input            id_ex_memread,
    output reg       stall
);
    // Load-use hazard: the instruction currently in EX is a load,
    // and the instruction currently in ID reads that load's destination.
    // Stall for one cycle to let the load reach MEM before the dependent
    // instruction enters EX. MEM/WB → EX forwarding then delivers the value.
    always @(*) begin
        if (id_ex_memread &&
            (id_ex_rd != 5'b0) &&
            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)))
            stall = 1'b1;
        else
            stall = 1'b0;
    end
endmodule
