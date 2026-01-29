`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2026 04:48:10 PM
// Design Name: 
// Module Name: orgate_4input
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


module orgate_4input(
    input   input1,
    input   input2,
    input   input3,
    input   input4,
    input   reset,
    input   clk,
    output  reg output1
    );
    
    
    always@(posedge clk) begin
        if(reset)begin
            output1 <= 0;
        end
        else begin
            output1 <= input1 | input2 | input3 | input4;
        
        end
    end
endmodule
