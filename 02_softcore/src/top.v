module top (
    input wire          clk_oscillator,
    input wire          reset_button,
    input wire          uart_rx,
    output wire         uart_tx,
    output wire         ws2812b_din,
    output wire [5:0]   leds/*,

    output              O_sdram_clk,
    output              O_sdram_cke,
    output              O_sdram_cs_n,
    output              O_sdram_cas_n,
    output              O_sdram_ras_n,
    output              O_sdram_wen_n,
    inout [31:0]        IO_sdram_dq,
    output [10:0]       O_sdram_addr,
    output [1:0]        O_sdram_ba,
    output [3:0]        O_sdram_dqm*/
);

    wire        clk;
    wire        clkp;
    wire        resetn;
    wire [31:0] io;

    wire [31:0] mem_addr;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;

    wire [31:0] sram0_rdata;
    wire        sram0_ready;
    wire [31:0] gpio0_rdata;
    wire        gpio0_ready;
    wire [31:0] uart0_rdata;
    wire        uart0_ready;
    wire [31:0] ws2812b0_rdata;
    wire        ws2812b0_ready;

    assign leds = ~io[5:0];
    assign mem_ready = sram0_ready | gpio0_ready | uart0_ready | ws2812b0_ready;
    assign mem_rdata =
        sram0_ready     ? sram0_rdata :
        gpio0_ready     ? gpio0_rdata :
        uart0_ready     ? uart0_rdata :
        ws2812b0_ready  ? ws2812b0_rdata :
        32'h0;

    pll pll0 (
        .clk_in         (clk_oscillator),
        .clk_out        (clk),
        .clk_outp       (clkp)
    );

    reset reset0 (
        .clk            (clk),
        .button         (reset_button),
        .resetn         (resetn)
    );

    picorv32 #(
        .PROGADDR_RESET (32'h1000_0000)
    ) cpu0 (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_instr      (mem_instr),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (mem_rdata),
        .mem_ready      (mem_ready)
    );

    /*sdram #(
        .FREQ           (27e6)
    ) sdram0 (
        .clk            (clk),
        .clk_sdram      (clkp),
        .resetn         (sys_resetn && start),
        .addr           (addr),
        .rd             (rd),
        .wr             (wr),
        .refresh        (refresh),
        .din            (din),
        .dout           (dout),
        .data_ready     (data_ready),
        .busy           (busy),
        .SDRAM_DQ       (IO_sdram_dq),
        .SDRAM_A        (O_sdram_addr),
        .SDRAM_BA       (O_sdram_ba),
        .SDRAM_nCS      (O_sdram_cs_n),
        .SDRAM_nWE      (O_sdram_wen_n),
        .SDRAM_nRAS     (O_sdram_ras_n),
        .SDRAM_nCAS     (O_sdram_cas_n),
        .SDRAM_CLK      (O_sdram_clk),
        .SDRAM_CKE      (O_sdram_cke),
        .SDRAM_DQM      (O_sdram_dqm)
    );*/

    sram #(
        .ADDR           (32'h1000_0000),
        .FILE           ("firmware/build/memory.ini")
    ) sram0 (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (sram0_rdata),
        .mem_ready      (sram0_ready)
    );

    gpio #(
        .ADDR           (32'h8000_0000)
    ) gpio0 (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (gpio0_rdata),
        .mem_ready      (gpio0_ready),
        .io             (io)
    );

    uart #(
        .ADDR           (32'h8001_0000),
        .CLK_FREQ       (27e6),
        .BAUDRATE       (115200),
        .DATA_BITS      (8),
        .STOP_BITS      (1)
    ) uart0 (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (uart0_rdata),
        .mem_ready      (uart0_ready),
        .tx             (uart_tx),
        .rx             (uart_rx)
    );

    ws2812b #(
        .ADDR           (32'h8002_0000),
        .CLK_FREQ       (27e6)
    ) ws2812b0 (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (ws2812b0_rdata),
        .mem_ready      (ws2812b0_ready),
        .din            (ws2812b_din)
    );

endmodule
