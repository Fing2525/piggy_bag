`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 11:57:31 AM
// Design Name: 
// Module Name: Counter8bit
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


module Counter8bit(
    input           coin,
    input           clk,
    input           reset,
    output          change,
    output  [7:0]   amount
    );
    reg     [7:0]   count = 8'b0;
    reg             signal =1'b0;
    reg             changing;
    reg             state;
    
    assign amount = count;
    assign change = changing;
    
    localparam WAIT = 1'b0;
    localparam FINISH = 1'b1;

    
always @(posedge clk) begin
    if (reset) begin
        count <= 8'd0;
        state <= WAIT;
    end 
    else begin
        case(state)
            WAIT:begin
                if(coin)begin
                    count<=count+1'b1;
                    changing <= 1'b1;
                    state <= FINISH;
                 end
              end
           FINISH:begin
            changing <= 1'b0;
                if(coin==1'b0)begin
                    state <= WAIT;
                end
           end
         endcase 
    end
    
    
    
    
    
    
//     else if (coin) begin
//        signal <= 1'b1;
//    end else if(signal != coin)begin
//        count <= count+1'b1;
//        changing <= 1'b1;
//        signal <= 1'b0;
//    end
end   
    
endmodule
