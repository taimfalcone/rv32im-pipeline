`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/08/2026 01:01:47 PM
// Design Name: 
// Module Name: data_mem
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
// 
//////////////////////////////////////////////////////////////////////////////////


module data_mem(MemRead, MemWrite, addr, write_data, read_data);

    input MemRead;
    input MemWrite;
    input [8:0] addr;
    input [31:0] write_data;
    output reg [31:0] read_data;
    
    reg [31:0] memory [127:0];
    
    always @(*) begin
        if(MemWrite)
            memory[addr[8:2]] = write_data;
            
         if(MemRead)
            read_data = memory[addr[8:2]];
         else
            read_data = 32'h00000000;
      end

endmodule