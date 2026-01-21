module uart_rom (
    input  wire [32-1:0]  addr,   // address (0-12)
    input  wire [23:0]    onebaht,
    input  wire [23:0]    twobaht,
    input  wire [23:0]    fivebaht,
    input  wire [23:0]    tenbaht,
    output reg  [7:0]     data
);

always @(*) begin
    case (addr)
        32'd0:  data = 8'h31; // '1'
        32'd1:  data = 8'h30; // '0'
        32'd2:  data = 8'h62; // 'b'
        32'd3:  data = 8'h61; // 'a'
        32'd4:  data = 8'h68; // 'h'
        32'd5:  data = 8'h74; // 't'
        32'd6:  data = 8'h20; // ' '
        
        32'd7:  data = tenbaht[23:16]; // hundreds ascii for amount of ten baht
        32'd8:  data = tenbaht[15:8]; // tens ascii for amount of ten baht
        32'd9:  data = tenbaht[7:0]; // ones ascii for amount of ten baht
        32'd10: data = 8'h20; // ' '
        
        32'd11: data = 8'h35; // '5'
        32'd12: data = 8'h62; // 'b'
        32'd13: data = 8'h61; // 'a'
        32'd14: data = 8'h68; // 'h'
        32'd15: data = 8'h74; // 't'
        32'd16: data = 8'h20; // ' '
        
        32'd17: data = fivebaht[23:16]; // '0'
        32'd18: data = fivebaht[15:8]; // '0'
        32'd19: data = fivebaht[7:0]; // '0'
        32'd20: data = 8'h20; // ' '
        
        32'd21: data = 8'h32; // '2'
        32'd22: data = 8'h62; // 'b'
        32'd23: data = 8'h61; // 'a'
        32'd24: data = 8'h68; // 'h'
        32'd25: data = 8'h74; // 't'
        32'd26: data = 8'h20; // ' '
        
        32'd27: data = twobaht[23:16]; // '0'
        32'd28: data = twobaht[15:8]; // '0'
        32'd29: data = twobaht[7:0]; // '0'
        32'd30: data = 8'h20; // ' '
        
        32'd31: data = 8'h31; // '1'
        32'd32: data = 8'h62; // 'b'
        32'd33: data = 8'h61; // 'a'
        32'd34: data = 8'h68; // 'h'
        32'd35: data = 8'h74; // 't'
        32'd36: data = 8'h20; // ' '
        
        32'd37: data = onebaht[23:16]; // '0'
        32'd38: data = onebaht[15:8]; // '0'
        32'd39: data = onebaht[7:0]; // '0'
        
        32'd40: data = 8'h0A; //\n
        32'd41: data = 8'h0D; // \r
        
        default: data = 8'h00;
        
    endcase
end

endmodule
