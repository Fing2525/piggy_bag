`timescale 1ns / 1ps

module tt_um_piggy_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena
);


    // ------------------------------------------------------------
    // Required: drive ALL outputs
    // ------------------------------------------------------------
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // ------------------------------------------------------------
    // Silence unused input warning
    // ------------------------------------------------------------
    wire _unused_ena = ena;
    wire _unused_uio = |uio_in;
    // ------------------------------------------------------------

    // ------------------------------------------------------------
    // Input mapping (from Tiny Tapeout pins)
    // ------------------------------------------------------------
    wire Input_0 = ui_in[2];
    wire Input_1 = ui_in[3];
    wire Input_2 = ui_in[4];
    wire Input_3 = ui_in[5];
    wire LCD_0   = ui_in[6];

    // active-low reset
    wire reset = rst_n;

    // ------------------------------------------------------------
    // Internal wires
    // ------------------------------------------------------------
    wire [7:0] amount0, amount1, amount2, amount3;
    wire change0, change1, change2, change3;

    wire deb0, deb1, deb2, deb3, deb4;
    wire edge_out;

    wire [23:0] ascii0, ascii1, ascii2, ascii3;

    wire or4_out;
    wire start_sending;

    wire o_Tx_Active;
    wire o_Tx_Done;
    wire o_Tx_Serial;

    // ------------------------------------------------------------
    // Debouncers
    // ------------------------------------------------------------
    debouncer u_deb0 (.clk(clk), .Input(LCD_0),  .Output(deb0));
    debouncer u_deb1 (.clk(clk), .Input(Input_0), .Output(deb1));
    debouncer u_deb2 (.clk(clk), .Input(Input_1), .Output(deb2));
    debouncer u_deb3 (.clk(clk), .Input(Input_2), .Output(deb3));
    debouncer u_deb4 (.clk(clk), .Input(Input_3), .Output(deb4));

    // ------------------------------------------------------------
    // Counters
    // ------------------------------------------------------------
    Counter8bit u_cnt0 (.clk(clk), .reset(reset), .coin(deb0), .amount(amount0), .change(change0));
    Counter8bit u_cnt1 (.clk(clk), .reset(reset), .coin(deb1), .amount(amount1), .change(change1));
    Counter8bit u_cnt2 (.clk(clk), .reset(reset), .coin(deb2), .amount(amount2), .change(change2));
    Counter8bit u_cnt3 (.clk(clk), .reset(reset), .coin(deb3), .amount(amount3), .change(change3));

    // ------------------------------------------------------------
    // Edge detector
    // ------------------------------------------------------------
    edge_detector u_edge (
        .clk(clk),
        .rst(reset),
        .Input(deb4),
        .Output(edge_out)
    );

    // ------------------------------------------------------------
    // Num to ASCII
    // ------------------------------------------------------------
    numtoascii u_n2a0 (.clk(clk), .num(amount0), .ascii(ascii0));
    numtoascii u_n2a1 (.clk(clk), .num(amount1), .ascii(ascii1));
    numtoascii u_n2a2 (.clk(clk), .num(amount2), .ascii(ascii2));
    numtoascii u_n2a3 (.clk(clk), .num(amount3), .ascii(ascii3));

    // ------------------------------------------------------------
    // OR logic
    // ------------------------------------------------------------
    orgate_4input u_or4 (
        .input1(change0),
        .input2(change1),
        .input3(change2),
        .input4(change3),
        .output1(or4_out)
    );

    orgate_2input u_or2 (
        .input1(edge_out),
        .input2(or4_out),
        .output1(start_sending)
    );

    // ------------------------------------------------------------
    // UART TX FSM
    // ------------------------------------------------------------
    uart_tx_fsm u_uart (
        .clk(clk),
        .rst(reset),
        .start_sending(start_sending),

        .tenbaht (ascii0),
        .fivebaht(ascii1),
        .twobaht (ascii2),
        .onebaht (ascii3),

        .o_Tx_Active (o_Tx_Active),
        .o_Tx_Done   (o_Tx_Done),
        .o_Tx_Serial (o_Tx_Serial)
    );

    // ------------------------------------------------------------
    // Output mapping (to Tiny Tapeout pins)
    // ------------------------------------------------------------
    assign uo_out[0] = o_Tx_Active;
    assign uo_out[1] = o_Tx_Done;
    assign uo_out[2] = o_Tx_Serial;
    assign uo_out[7:3] = 5'b0;

endmodule
