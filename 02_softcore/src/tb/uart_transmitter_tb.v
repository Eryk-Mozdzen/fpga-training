`timescale 1 ns / 100 ps

module uart_transmitter_tb();
    reg         clk;
    reg         resetn;

    reg  [7:0]  data;
    reg         data_valid;
    wire        data_req;
    wire        tx;

    uart_transmitter #(
        .DATA_BITS      (8),
        .STOP_DURATION  (15),
        .BIT_DURATION   (10)
    ) uut (
        .clk        (clk),
        .resetn     (resetn),
        .data       (data),
        .data_valid (data_valid),
        .data_req   (data_req),
        .tx         (tx)
    );

    initial begin
        $dumpfile("uart_transmitter_tb.vcd");
        $dumpvars(0, uart_transmitter_tb);

        #1000000

        $finish;
    end

    initial begin
        clk = 1;
        resetn = 1;
        data_valid = 0;

        #8
        resetn = 0;
        #1
        resetn = 1;

        #20
        data = 8'h27;
        data_valid = 1;
        #10
        data_valid = 0;
        data = 8'h00;

        #100
        data = 8'h88;
        data_valid = 1;
        #10
        data_valid = 0;
        data = 8'h00;

        #1000
        data = 8'h88;
        data_valid = 1;
        #10
        data_valid = 0;
        data = 8'h00;

        #500
        data = 8'hC1;
        data_valid = 1;
        #600
        data_valid = 0;
        data = 8'h00;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
