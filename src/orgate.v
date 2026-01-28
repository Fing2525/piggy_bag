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
    input   clk,
    input   reset,
    output reg output1
    );
    
    always@(posedge clk) begin
        if(reset)begin
            output1 <= 0;
        end
        else begin
            output1 <= input1 | input2;
        
        end
    end
    
endmodule
