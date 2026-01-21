// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of clk)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// 125000000)/(115200) ≈ 1085
  
module uart_tx_phy
  #(parameter CLKS_PER_BIT = 1085)
  (
   input  wire [0:0] clk,
   input  wire [0:0] rst,
   input  wire [0:0] i_Tx_Start,
   input  wire [7:0] i_Tx_Byte,
   output wire       o_Tx_Active,
   output wire       o_Tx_Serial,
   output wire       o_Tx_Done
   );
  
  localparam FSM_IDLE         = 3'b000;
  localparam FSM_TX_START_BIT = 3'b001;
  localparam FSM_TX_DATA_BITS = 3'b010;
  localparam FSM_TX_STOP_BIT  = 3'b011;
  localparam FSM_CLEANUP      = 3'b100;
   
  reg [2:0]    state;
  reg [31:0]   clk_count;
  reg [2:0]    bit_index;
  reg [7:0]    tx_data;
  reg          tx_active_reg;
  reg          tx_serial_reg;
  reg          tx_done_reg;
     
	always @(posedge clk) begin
		if(rst) begin
			state     	  <= FSM_IDLE;
			clk_count 	  <= 0;
			bit_index 	  <= 0;
			tx_data   	  <= 0;
			tx_done_reg   <= 0;
			tx_active_reg <= 0;
			tx_serial_reg <= 0;
		end
		else begin
			if(state == FSM_IDLE) begin
				tx_serial_reg <= 1'b1;         // Drive Line High for Idle
				tx_done_reg   <= 1'b0;
				clk_count 	  <= 0;
				bit_index     <= 0;
				 
				if (i_Tx_Start == 1'b1) begin
					tx_active_reg <= 1'b1;
					tx_data       <= i_Tx_Byte;
					state         <= FSM_TX_START_BIT;
				end
				else begin
					state <= FSM_IDLE;
				end
			end // case: FSM_IDLE
			 
			 
			// Send out Start Bit. Start bit = 0
			else if(state == FSM_TX_START_BIT) begin
				tx_serial_reg <= 1'b0;
				 
				// Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
				if (clk_count < CLKS_PER_BIT-1) begin
					clk_count <= clk_count + 1;
					state     <= FSM_TX_START_BIT;
				end
				else begin
					clk_count <= 0;
					state     <= FSM_TX_DATA_BITS;
				end
			end // case: FSM_TX_START_BIT
			 
			 
			// Wait CLKS_PER_BIT-1 clock cycles for data bits to finish
			else if(state == FSM_TX_DATA_BITS) begin
				tx_serial_reg <= tx_data[bit_index];
				 
				if (clk_count < CLKS_PER_BIT-1)
				  begin
					clk_count <= clk_count + 1;
					state     <= FSM_TX_DATA_BITS;
				  end
				else
				  begin
					clk_count <= 0;
					 
					// Check if we have sent out all bits
					if (bit_index < 7)
					  begin
						bit_index <= bit_index + 1;
						state   <= FSM_TX_DATA_BITS;
					  end
					else
					  begin
						bit_index <= 0;
						state   <= FSM_TX_STOP_BIT;
					  end
				  end
			  end // case: FSM_TX_DATA_BITS
			 
			 
			// Send out Stop bit.  Stop bit = 1
			else if(state == FSM_TX_STOP_BIT) begin
				tx_serial_reg <= 1'b1;
				
				// Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
				if (clk_count < CLKS_PER_BIT-1) begin
					clk_count <= clk_count + 1;
					state     <= FSM_TX_STOP_BIT;
				end
				else begin
					tx_done_reg   <= 1'b1;
					clk_count     <= 0;
					state         <= FSM_CLEANUP;
					tx_active_reg <= 1'b0;
				end
			end // case: FSM_TX_STOP_BIT
			 
			 
			// Stay here 1 clock
			else if(state == FSM_CLEANUP) begin
				tx_done_reg <= 1'b1;
				state       <= FSM_IDLE;
			end
		end
	end
 
  assign o_Tx_Active = tx_active_reg;
  assign o_Tx_Serial = tx_serial_reg;
  assign o_Tx_Done   = tx_done_reg;
   
endmodule