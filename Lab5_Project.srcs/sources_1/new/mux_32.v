`timescale 1ns / 1ps

module mux_32(input s, input [31:0] d0, input [31:0] d1, input [31:0] y);

    assign y = s ? d1 : d0;

endmodule
