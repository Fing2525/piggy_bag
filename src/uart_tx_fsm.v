module uart_tx_fsm (
    input  wire clk,
    input  wire rst,
    input  wire start_sending,
    input  wire [23:0]    onebaht,
    input  wire [23:0]    twobaht,
    input  wire [23:0]    fivebaht,
    input  wire [23:0]    tenbaht,

    // UART TX interface
    output wire o_Tx_Active,
    output wire o_Tx_Serial,
    output wire o_Tx_Done
);

    localparam MSG_LEN = 42;

    // FSM states
    localparam IDLE      = 2'd0;
    localparam START_TX  = 2'd1;
    localparam WAIT_DONE = 2'd2;
    localparam FINISHED  = 2'd3;

    reg [1:0]    state;
    reg [32-1:0] rom_addr;
    reg          tx_start;

    wire [7:0]   rom_data;
    wire         tx_done;
    wire         tx_serial;
    wire         tx_active;

    // ROM
    uart_rom rom (
        .addr(rom_addr),
        .tenbaht(tenbaht),
        .fivebaht(fivebaht),
        .twobaht(twobaht),
        .onebaht(onebaht),
        .data(rom_data)
    );

    // UART TX
    uart_tx_phy #(
        .CLKS_PER_BIT(1085)   // adjust to your clock
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .i_Tx_Start(tx_start),
        .i_Tx_Byte(rom_data),
        .o_Tx_Active(tx_active),
        .o_Tx_Serial(tx_serial),
        .o_Tx_Done(tx_done)
    );

    // Controller FSM
    always @(posedge clk) begin
    if (rst) begin
            state     <= IDLE;
            rom_addr  <= 0;
            tx_start  <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start_sending) begin
                        rom_addr <= 0;
                        state    <= START_TX;
                    end
                end
    
                START_TX: begin
                    // IMPORTANT: only start when UART is idle
                    if (!tx_active) begin
                        tx_start <= 1'b1;   // 1-cycle pulse
                        state    <= WAIT_DONE;
                    end
                end
    
                WAIT_DONE: begin
                    if (tx_done) begin
                        if (rom_addr == MSG_LEN-1) begin
                            state <= FINISHED;
                        end
                        else begin
                            rom_addr <= rom_addr + 1;
                            state    <= START_TX;
                        end
                    end
                end
    
                FINISHED: begin
                    state     <= IDLE;
                    rom_addr  <= 0;
                    tx_start  <= 0;
                end
            endcase
        end
    end

assign o_Tx_Active = tx_active;
assign o_Tx_Serial = tx_serial;
assign o_Tx_Done   = tx_done;

endmodule