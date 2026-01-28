`timescale 1ns / 1ps

module tt_um_piggy_top(
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena
);

    // Required by Tiny Tapeout
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused_ena = ena;
    wire _unused_uio = |uio_in;

    wire deb_out;
    wire amount0;
    wire change0;

    debouncer u_deb (
        .clk   (clk),
        .rst_n (rst_n),
        .Input (ui_in[2]),
        .Output(deb_out)
    );

    Counter8bit u_cnt0 (.clk(clk), .reset(rst_n), .coin(deb_out), .amount(amount0), .change(change0));

    assign uo_out[0] = deb_out;
    assign uo_out[7:1] = 7'b0;

endmodule
