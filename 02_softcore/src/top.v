module top(
        input wire          clk,
        input wire          reset_button,
        input wire          uart_rx,
        output wire         uart_tx,
        output wire         ws2812b_din,
        output wire [5:0]   leds
    );

    `include "sys_parameters.v"

    parameter        MEMBYTES = 4*(1 << SRAM_ADDR_WIDTH);
    parameter [31:0] STACKADDR = (MEMBYTES);
    parameter [31:0] PROGADDR_RESET = 32'h0000_0000;
    parameter [31:0] PROGADDR_IRQ = 32'h0000_0000;

    wire        reset_n;
    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire [3:0]  mem_wstrb;
    wire        mem_ready;
    wire        mem_inst;
    wire        gpio_sel;
    wire        gpio_ready;
    wire [31:0] gpio_data_o;
    wire        sram_sel;
    wire        sram_ready;
    wire [31:0] sram_data_o;
    wire        uart_sel;
    wire [31:0] uart_data_o;
    wire        uart_ready;
    wire        ws2812b_sel;
    wire [31:0] ws2812b_data_o;
    wire        ws2812b_ready;

    //    SRAM 0x00000000 - 0x00003FFF
    //    GPIO 0x80000000 - 0x80000003
    //    UART 0x80000008 - 0x8000000F
    // WS2812B 0x80001000 - 0x800017FF
    assign sram_sel     = mem_valid && (mem_addr < MEMBYTES);
    assign gpio_sel     = mem_valid && (mem_addr >= 32'h80000000) && (mem_addr <= 32'h80000003);
    assign uart_sel     = mem_valid && (mem_addr >= 32'h80000008) && (mem_addr <= 32'h8000000F);
    assign ws2812b_sel  = mem_valid && (mem_addr >= 32'h80001000) && (mem_addr <= 32'h800017FF);

    assign mem_ready = mem_valid & (sram_ready | gpio_ready | uart_ready | ws2812b_ready);

    assign mem_rdata =
        sram_sel    ? sram_data_o :
        gpio_sel    ? gpio_data_o :
        uart_sel    ? uart_data_o :
        ws2812b_sel ? ws2812b_data_o : 32'h0;

    assign leds = ~gpio_data_o[5:0];

    reset_ctrl reset_controller(
        .clk            (clk),
        .reset_button   (reset_button),
        .reset_n        (reset_n)
    );

    uart_wrap uart0(
        .clk(clk),
        .reset_n        (reset_n),
        .uart_tx        (uart_tx),
        .uart_rx        (uart_rx),
        .uart_sel       (uart_sel),
        .addr           (mem_addr[3:0]),
        .uart_wstrb     (mem_wstrb),
        .uart_di        (mem_wdata),
        .uart_do        (uart_data_o),
        .uart_ready     (uart_ready)
    );

    ws2812b #(
        .MAX_CASCADE_LENGTH (1)
    ) ws2812b0(
        .clk            (clk),
        .reset_n        (reset_n),
        .sel            (ws2812b_sel),
        .addrxd         (mem_addr[10:0]), // why 'addr' not work here ???
        .wstrb          (mem_wstrb),
        .wdata          (mem_wdata),
        .rdata          (ws2812b_data_o),
        .ready          (ws2812b_ready),
        .din            (ws2812b_din)
    );

    gpio #(
        .WIDTH          (6)
    ) gpio0(
        .clk            (clk),
        .reset_n        (reset_n),
        .sel            (gpio_sel),
        .wdata          (mem_wdata[5:0]),
        .wstrb          (mem_wstrb[0]),
        .ready          (gpio_ready),
        .rdata          (gpio_data_o)
    );

    sram #(
        .SRAM_ADDR_WIDTH    (SRAM_ADDR_WIDTH)
    ) sram0(
        .clk            (clk),
        .reset_n        (reset_n),
        .sram_sel       (sram_sel),
        .wstrb          (mem_wstrb),
        .addr           (mem_addr[SRAM_ADDR_WIDTH + 1:0]),
        .sram_data_i    (mem_wdata),
        .sram_ready     (sram_ready),
        .sram_data_o    (sram_data_o)
    );

    picorv32 #(
        .STACKADDR          (STACKADDR),
        .PROGADDR_RESET     (PROGADDR_RESET),
        .PROGADDR_IRQ       (PROGADDR_IRQ),
        .BARREL_SHIFTER     (0),
        .COMPRESSED_ISA     (0),
        .ENABLE_MUL         (0),
        .ENABLE_DIV         (0),
        .ENABLE_FAST_MUL    (0),
        .ENABLE_IRQ         (1),
        .ENABLE_IRQ_QREGS   (0)
    ) cpu0(
        .clk            (clk),
        .resetn         (reset_n),
        .mem_valid      (mem_valid),
        .mem_instr      (mem_instr),
        .mem_ready      (mem_ready),
        .mem_addr       (mem_addr),
        .mem_wdata      (mem_wdata),
        .mem_wstrb      (mem_wstrb),
        .mem_rdata      (mem_rdata),
        .irq            ('b0)
    );

endmodule
