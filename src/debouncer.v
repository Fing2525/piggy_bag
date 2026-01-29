`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 12:22:26 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer #(
    parameter DELAY = 400_000
   )(
    input wire  Input,
    input wire  clk,
    input wire  rst_n,
    output  reg Output = 0

    );
    localparam COUNTER_BITS = $clog2(DELAY);
    reg [COUNTER_BITS:0] counter = 0;
    
    always@(posedge clk) begin
        if(rst_n)begin

            counter <= 0;
            Output <= 0;

        end
        else if(Input!=Output )begin
            if(counter < (DELAY-2))counter <= counter + 1'b1;
            if(counter >= (DELAY-2))begin
                Output <= Input;
                counter <= 0;
            end
         end
         
         if (Input == Output) counter <= 0;
        end
    
    
endmodule
