module top (
    input wire          clk,
    input wire          reset_button,
    input wire          uart_rx,
    output wire         uart_tx,
    output wire         ws2812b_din,
    output wire [5:0]   leds
);

    wire        resetn;
    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire [3:0]  mem_wstrb;
    wire        mem_ready;
    wire        mem_inst;
    wire        gpio_sel;
    wire [31:0] gpio_rdata;
    wire        gpio_ready;
    wire        sram_sel;
    wire [31:0] sram_rdata;
    wire        sram_ready;
    wire        uart_sel;
    wire [31:0] uart_rdata;
    wire        uart_ready;
    wire        ws2812b_sel;
    wire [31:0] ws2812b_rdata;
    wire        ws2812b_ready;

    assign sram_sel     = mem_valid && (mem_addr >= 32'h0000_0000) && (mem_addr <= 32'h0000_FFFF);
    assign gpio_sel     = mem_valid && (mem_addr >= 32'h8000_0000) && (mem_addr <= 32'h8000_0003);
    assign uart_sel     = mem_valid && (mem_addr >= 32'h8000_0008) && (mem_addr <= 32'h8000_000F);
    assign ws2812b_sel  = mem_valid && (mem_addr >= 32'h8002_0000) && (mem_addr <= 32'h8002_FFFF);

    assign mem_ready = mem_valid & (sram_ready | gpio_ready | uart_ready | ws2812b_ready);

    assign mem_rdata =
        sram_sel    ? sram_rdata :
        gpio_sel    ? gpio_rdata :
        uart_sel    ? uart_rdata :
        ws2812b_sel ? ws2812b_rdata : 32'h0;

    assign leds = ~gpio_rdata[5:0];

    reset_ctrl reset_controller (
        .clk            (clk),
        .reset_button   (reset_button),
        .resetn         (resetn)
    );

    uart_wrap uart0 (
        .clk            (clk),
        .resetn         (resetn),
        .uart_sel       (uart_sel),
        .addr           (mem_addr[3:0]),
        .uart_wstrb     (mem_wstrb),
        .uart_di        (mem_wdata),
        .uart_do        (uart_rdata),
        .uart_ready     (uart_ready),
        .uart_tx        (uart_tx),
        .uart_rx        (uart_rx)
    );

    ws2812b #(
        .CLK_FREQ       (27e6)
    ) ws2812b0 (
        .clk            (clk),
        .resetn         (resetn),
        .sel            (ws2812b_sel),
        .addr           (mem_addr[15:0]),
        .wstrb          (mem_wstrb),
        .wdata          (mem_wdata),
        .rdata          (ws2812b_rdata),
        .ready          (ws2812b_ready),
        .din            (ws2812b_din)
    );

    gpio gpio0 (
        .clk            (clk),
        .resetn         (resetn),
        .sel            (gpio_sel),
        .addr           (mem_addr[15:0]),
        .wstrb          (mem_wstrb),
        .wdata          (mem_wdata),
        .rdata          (gpio_rdata),
        .ready          (gpio_ready)
    );

    sram #(
        .BYTES          (65536),
        .FILE           ("../firmware/build/mem_init.ini")
    ) sram0 (
        .clk            (clk),
        .resetn         (resetn),
        .sel            (sram_sel),
        .addr           (mem_addr),
        .wstrb          (mem_wstrb),
        .wdata          (mem_wdata),
        .rdata          (sram_rdata),
        .ready          (sram_ready)
    );

    picorv32 #(
        .STACKADDR          (32'h0000_FFF0),
        .PROGADDR_RESET     (32'h0000_0000),
        .PROGADDR_IRQ       (32'h0000_0000),
        .BARREL_SHIFTER     (0),
        .COMPRESSED_ISA     (0),
        .ENABLE_MUL         (0),
        .ENABLE_DIV         (0),
        .ENABLE_FAST_MUL    (0),
        .ENABLE_IRQ         (1),
        .ENABLE_IRQ_QREGS   (0)
    ) cpu0 (
        .clk            (clk),
        .resetn         (resetn),
        .mem_valid      (mem_valid),
        .mem_instr      (mem_instr),
        .mem_addr       (mem_addr),
        .mem_wstrb      (mem_wstrb),
        .mem_wdata      (mem_wdata),
        .mem_rdata      (mem_rdata),
        .mem_ready      (mem_ready),
        .irq            ('b0)
    );

endmodule
