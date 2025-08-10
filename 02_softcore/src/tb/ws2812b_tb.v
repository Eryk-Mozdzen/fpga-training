`timescale 1 ns / 100 ps

module ws2812b_tb();

    reg         clk;
    reg         resetn;
    reg         mem_valid;
    reg [31:0]  mem_addr;
    reg [3:0]   mem_wstrb;
    reg [31:0]  mem_wdata;
    wire [31:0] mem_rdata;
    wire        mem_ready;
    wire        din;

    ws2812b #(
        .ADDR           (32'h0000_0000),
        .CLK_FREQ       (100e6)
    ) uut (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (mem_rdata),
        .mem_ready      (mem_ready),
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
        resetn = 1;

        #8
        resetn = 0;
        #1
        resetn = 1;
        #6

        #4
        mem_wstrb   = 4'b0111;
        mem_wdata   = 32'h0080_FFCE;
        mem_addr    = 32'h0000_0000;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #400000

        mem_wstrb   = 4'b0111;
        mem_wdata   = 32'h00FF_FFFF;
        mem_addr    = 32'h0000_0000;
        mem_valid   = 1;
        #10
        mem_valid   = 0;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
