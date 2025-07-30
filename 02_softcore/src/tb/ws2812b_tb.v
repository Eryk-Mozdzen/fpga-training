
`timescale 1 ns / 100 ps

module ws2812b_tb();

    reg         clk = 1;
    reg         rst = 1;
    reg [10:0]  addr = 0;
    reg [3:0]   wstrb = 0;
    reg [31:0]  wdata = 0;
    wire [31:0] rdata = 0;
    wire        ready;
    wire        din;

    ws2812b #(
        .CASCADE_LENGTH (1),
        .CLK_FREQ       (100e6)
    ) uut(
        .clk            (clk),
        .reset_n        (reset_n),
        .sel            (ws2812b_sel),
        .addrxd         (addr),
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
        #8
        rst = 0;
        #1
        rst = 1;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
