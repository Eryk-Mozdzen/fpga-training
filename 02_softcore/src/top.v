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
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire        mem_ready;

    wire [31:0] sram0_rdata;
    wire        sram0_ready;
    wire [31:0] gpio0_rdata;
    wire        gpio0_ready;
    wire [31:0] uart0_rdata;
    wire        uart0_ready;
    wire [31:0] ws2812b0_rdata;
    wire        ws2812b0_ready;

    assign leds = ~gpio0_rdata[5:0];
    assign mem_ready = sram0_ready | gpio0_ready | uart0_ready | ws2812b0_ready;
    assign mem_rdata =
        sram0_ready     ? sram0_rdata :
        gpio0_ready     ? gpio0_rdata :
        uart0_ready     ? uart0_rdata :
        ws2812b0_ready  ? ws2812b0_rdata :
        32'h0;

    reset_ctrl reset_controller (
        .clk            (clk),
        .reset_button   (reset_button),
        .resetn         (resetn)
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
        .irq            (0)
    );

    sram #(
        .ADDR           (32'h0000_0000),
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
        .mem_ready      (gpio0_ready)
    );

    uart #(
        .ADDR           (32'h8001_0000),
        .CLK_FREQ       (27e6),
        .BAUDRATE       (115200),
        .DATA_BITS      (8),
        .STOP_BITS      (1),
        .TX_FIFO        (64),
        .RX_FIFO        (64)
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
