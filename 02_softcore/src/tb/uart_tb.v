`timescale 1 ns / 100 ps

module uart_tb();
    reg         clk;
    reg         resetn;

    reg         mem_valid;
    reg [31:0]  mem_addr;
    reg [3:0]   mem_wstrb;
    reg [31:0]  mem_wdata;
    wire [31:0] mem_rdata;
    wire        mem_ready;
    wire        tx;
    wire        rx;

    assign rx = tx;

    uart #(
        .ADDR           (32'h0000_0000),
        .CLK_FREQ       (100e6),
        .BAUDRATE       (115200),
        .DATA_BITS      (8),
        .STOP_BITS      (1)
    ) uut (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (mem_rdata),
        .mem_ready      (mem_ready),
        .tx             (tx),
        .rx             (rx)
    );

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

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

        #4
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_00CE;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #30
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_0023;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #100000
        mem_wstrb   = 4'b0000;
        mem_addr    = 32'h0000_0008;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #500000
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_0001;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #30
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_0002;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #30
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_0003;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #30
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_0004;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;

        #30
        mem_wstrb   = 4'b1111;
        mem_wdata   = 32'h0000_0005;
        mem_addr    = 32'h0000_0004;
        mem_valid   = 1;
        #10
        mem_valid   = 0;
    end

    always begin
        #5
        clk = ~clk;
    end

endmodule
