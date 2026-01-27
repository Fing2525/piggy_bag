`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/

module tb;

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

 
    // ----------------------------------
    // DUT signals
    // ----------------------------------
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        clk;
    reg        rst_n;
    reg        ena;

    // ----------------------------------
    // Instantiate DUT
    // ----------------------------------
    tt_um_piggy_top dut (
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe),
        .clk    (clk),
        .rst_n  (rst_n),
        .ena    (ena)
    );

    // ----------------------------------
    // Clock: 100 MHz
    // ----------------------------------
    always #5 clk = ~clk;

    // ----------------------------------
    // Debounce timing parameters
    // ----------------------------------
    localparam integer CLK_PERIOD_NS   = 10;
    localparam integer DEBOUNCE_CYCLES  = 400_000;
    localparam integer DEBOUNCE_TIME_NS = CLK_PERIOD_NS * DEBOUNCE_CYCLES;

    // ----------------------------------
    // Task: press a button correctly
    // ----------------------------------
    task press_button(input integer bit_index);
    begin
        ui_in[bit_index] = 1'b1;
        #(DEBOUNCE_TIME_NS + 1000);  // hold long enough
        ui_in[bit_index] = 1'b0;
        #(DEBOUNCE_TIME_NS + 1000);
    end
    endtask

    // ----------------------------------
    // Test sequence
    // ----------------------------------
    initial begin
        // Init
        clk    = 0;
        rst_n  = 1;
        ena    = 1;
        ui_in  = 0;
        uio_in = 0;

        // Reset
        #100;
        rst_n = 0;

        // ----------------------------------
        // Insert coins
        // ----------------------------------
        ui_in[6] = 0;
        $display("Insert 10 baht");
        press_button(6);   // LCD_0 → deb0

        $display("Insert 5 baht");
        press_button(2);   // Input_0

        $display("Insert 2 baht");
        press_button(3);   // Input_1

        $display("Insert 1 baht");
        press_button(4);   // Input_2

        // ----------------------------------
        // Trigger edge detector (send UART)
        // ----------------------------------
        $display("Trigger send");
        press_button(5);   // Input_3 (edge detector)

        // ----------------------------------
        // Wait for UART to finish
        // ----------------------------------
        #5_000_000;

        $display("Simulation done");
        $finish;
    end

endmodule
