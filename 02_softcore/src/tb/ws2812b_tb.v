
`timescale 1 ns / 100 ps

module ws2812b_tb();

    reg         clk;
    reg         rst;
    reg         sel;
    reg [10:0]  addr;
    reg [3:0]   wstrb;
    reg [31:0]  wdata;
    wire [31:0] rdata;
    wire        ready;
    wire        din;

    ws2812b #(
        .CLK_FREQ       (100e6)
    ) uut(
        .clk            (clk),
        .reset_n        (rst),
        .sel            (sel),
        .addr           (addr),
        .wstrb          (wstrb),
        .wdata          (wdata),
        .rdata          (rdata),
        .ready          (ready),
        .din            (din)
    );

    initial begin
        $dumpfile("ws2812b_tb.vcd");
        $dumpvars(0, ws2812b_tb);

        #1000000

        $finish;
    end

    initial begin
        clk = 1;
        rst = 1;
        sel = 0;

        #8
        rst = 0;
        #1
        rst = 1;
        #6

        sel = 1;
        addr = 11'h0;
        wstrb = 4'b1111;
        wdata = 32'h80CF8002;

        #100

        sel = 0;

        #400000

        sel = 1;
        addr = 11'h0;
        wstrb = 4'b0000;
        wdata = 24'hFFFFFF;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
