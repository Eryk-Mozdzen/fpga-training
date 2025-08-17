`timescale 1 ns / 100 ps

module top_tb();
    reg         clk;
    reg         reset_button;
    reg         uart_rx;
    wire        uart_tx;
    wire        ws2812b_din;
    wire [5:0]  leds;

    top uut (
        .clk            (clk),
        .reset_button   (reset_button),
        .uart_rx        (uart_rx),
        .uart_tx        (uart_tx),
        .ws2812b_din    (ws2812b_din),
        .leds           (leds)
    );

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        #1000000

        $finish;
    end

    initial begin
        clk = 1;
        reset_button = 0;
        #10
        reset_button = 1;
        #100
        reset_button = 0;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
