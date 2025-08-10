`timescale 1 ns / 100 ps

module uart_fifo_tb();
    reg         clk;
    reg         resetn;

    reg  [7:0]  in;
    reg         write;
    reg         read;
    wire [7:0]  out;
    wire        empty;
    wire        full;

    uart_fifo #(
        .DEPTH  (3),
        .WIDTH  (8)
    ) uut (
        .clk    (clk),
        .resetn (resetn),
        .in     (in),
        .write  (write),
        .read   (read),
        .out    (out),
        .empty  (empty),
        .full   (full)
    );

    initial begin
        $dumpfile("uart_fifo_tb.vcd");
        $dumpvars(0, uart_fifo_tb);

        #1000000

        $finish;
    end

    initial begin
        clk = 1;
        resetn = 1;

        #8
        resetn = 0;
        #1
        resetn = 1;

        #6
        read = 1;
        #10
        read = 0;

        #30
        in = 8'h87;
        write = 1;
        #10
        write = 0;

        #30
        in = 8'h12;
        write = 1;
        #10
        write = 0;

        #30
        in = 8'hFF;
        write = 1;
        #10
        write = 0;

        #30
        in = 8'hBB;
        write = 1;
        #10
        write = 0;

        #30
        read = 1;
        #10
        read = 0;

        #30
        read = 1;
        #10
        read = 0;

        #30
        read = 1;
        #10
        read = 0;

        #30
        read = 1;
        #10
        read = 0;

        #30
        in = 8'hAA;
        write = 1;
        #10
        write = 0;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
