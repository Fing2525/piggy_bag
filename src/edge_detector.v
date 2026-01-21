`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2026 03:18:31 PM
// Design Name: 
// Module Name: edge_detector
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


module edge_detector(
       input wire   Input,
       input wire   clk,
       input wire   rst,
       output reg  Output = 1'b0
    );
    reg signal;
    reg state;
    
    localparam WAIT      = 1'd0;
    localparam FINISH  = 1'd1;

    
    always @(posedge clk) begin
        
        if (rst) begin
            signal <= 1'b0;
            Output <= 1'b0;
            state <= WAIT;
            
          end
            else begin
                case (state)
                    WAIT: begin
                        if(Input)begin
                            Output <= 1'b1;
                            state <= FINISH;
                            end
                    end
                    FINISH:begin
                           Output <= 1'b0;
                           if(Input == 1'b0)begin
                                 state<= WAIT;
                           end
                    end      
            
                endcase
            end
        end
    
endmodule
