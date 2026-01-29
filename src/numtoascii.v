`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 03:29:27 PM
// Design Name: 
// Module Name: numtoascii
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


module numtoascii (
    input  wire        clk,
    input  wire [7:0]  num,     
    output reg  [23:0] ascii    
);

    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    always @(posedge clk) begin
        hundreds <= num / 100;
        tens     <= (num % 100) / 10;
        ones     <= num % 10;

        ascii[23:16] <= (hundreds != 0) ? (hundreds + 8'h30) : 8'h20;  //if not 0 8'h30(0) + the number if 0 ascii[23:16] = space
        ascii[15:8 ] <= (hundreds != 0 || tens != 0) ? (tens + 8'h30) : 8'h20; // if hundred =0 and tens = 0 ascii[15:8] = space else same as below
        ascii[7:0  ] <= ones + 8'h30;//ascii[7:0] = ascii(0) + offset
    end
endmodule
