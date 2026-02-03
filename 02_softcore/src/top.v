module top (
    input wire          clk_oscillator,
    input wire          reset_button,
    input wire          uart_rx,
    output wire         uart_tx,
    output wire         ws2812b_din,
    output wire [5:0]   leds,

    /*output              O_sdram_clk,
    output              O_sdram_cke,
    output              O_sdram_cs_n,   // chip select
    output              O_sdram_cas_n,  // columns address select
    output              O_sdram_ras_n,  // row address select
    output              O_sdram_wen_n,  // write enable
    inout [31:0]        IO_sdram_dq,    // 32 bit bidirectional data bus
    output [10:0]       O_sdram_addr,   // 11 bit multiplexed address bus
    output [1:0]        O_sdram_ba,     // two banks
    output [3:0]        O_sdram_dqm*/     // 32/4
);

    wire        clk;
    wire        clk_sdram;
    wire        resetn;
    wire [31:0] io;

    wire        pll0_gnd;
    wire        pll0_lock;
    wire        pll0_reset;
    wire        pll0_clkoutd;
    wire        pll0_clkoutd3;

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

    assign pll0_gnd = 0;
    assign leds = ~io[5:0];
    assign mem_ready = sram0_ready | gpio0_ready | uart0_ready | ws2812b0_ready;
    assign mem_rdata =
        sram0_ready     ? sram0_rdata :
        gpio0_ready     ? gpio0_rdata :
        uart0_ready     ? uart0_rdata :
        ws2812b0_ready  ? ws2812b0_rdata :
        32'h0;

    rPLL #(
        .IDIV_SEL           (6),
        .FBDIV_SEL          (12),
        .ODIV_SEL           (16),
        .FCLKIN             ("27"),
        .DYN_IDIV_SEL       ("false"),
        .DYN_FBDIV_SEL      ("false"),
        .DYN_ODIV_SEL       ("false"),
        .PSDA_SEL           ("1010"),
        .DYN_DA_EN          ("false"),
        .DUTYDA_SEL         ("1000"),
        .CLKOUT_FT_DIR      (1),
        .CLKOUTP_FT_DIR     (1),
        .CLKOUT_DLY_STEP    (0),
        .CLKOUTP_DLY_STEP   (0),
        .CLKFB_SEL          ("internal"),
        .CLKOUT_BYPASS      ("false"),
        .CLKOUTP_BYPASS     ("false"),
        .CLKOUTD_BYPASS     ("false"),
        .DYN_SDIV_SEL       (2),
        .CLKOUTD_SRC        ("CLKOUT"),
        .CLKOUTD3_SRC       ("CLKOUT"),
        .DEVICE             ("GW2A-18C")
    ) pll0 (
        .CLKIN          (clk_oscillator),
        .CLKOUT         (clk),
        .CLKOUTP        (clk_sdram),
        .CLKOUTD        (pll0_clkoutd),
        .CLKOUTD3       (pll0_clkoutd3),
        .RESET          (pll0_reset),
        .LOCK           (pll0_lock),
        .RESET_P        (pll0_gnd),
        .CLKFB          (pll0_gnd),
        .FBDSEL         ({pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd}),
        .IDSEL          ({pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd}),
        .ODSEL          ({pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd}),
        .PSDA           ({pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd}),
        .DUTYDA         ({pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd}),
        .FDLY           ({pll0_gnd, pll0_gnd, pll0_gnd, pll0_gnd})
    );

    reset_ctrl reset_controller (
        .clk            (clk),
        .reset_button   (reset_button),
        .resetn         (resetn)
    );

    picorv32 #(
        .STACKADDR          (32'h1000_FFF0),
        .PROGADDR_RESET     (32'h1000_0000),
        .PROGADDR_IRQ       (32'h1000_0000),
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

    /*sdram #(
        .FREQ           (27e6)
    ) sdram0 (
        .clk            (clk),
        .clk_sdram      (clk_sdram),
        .resetn         (sys_resetn && start),
        .addr           (addr),
        .rd             (rd),
        .wr             (wr),
        .refresh        (refresh),
        .din            (din),
        .dout           (dout),
        .data_ready     (data_ready),
        .busy           (busy),
        .SDRAM_DQ       (IO_sdram_dq),      // 32 bit bidirectional data bus
        .SDRAM_A        (O_sdram_addr),     // 11 bit multiplexed address bus
        .SDRAM_BA       (O_sdram_ba),       // 4 banks
        .SDRAM_nCS      (O_sdram_cs_n),     // a single chip select
        .SDRAM_nWE      (O_sdram_wen_n),    // write enable
        .SDRAM_nRAS     (O_sdram_ras_n),    // row address select
        .SDRAM_nCAS     (O_sdram_cas_n),    // columns address select
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
        .CLK_FREQ       (50e6),
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
        .CLK_FREQ       (50e6)
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
