`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2026 05:29:22 PM
// Design Name: 
// Module Name: orgate_2input
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


module orgate_2input(
    input   input1,
    input   input2,
    output  output1
    );
    
    assign output1 = input1 | input2;
    
endmodule
