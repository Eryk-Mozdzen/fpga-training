
#define GPIO0        (*((volatile unsigned int *)0x80000000U))
#define UART0_STATUS (*((volatile unsigned int *)0x80010000U))
#define UART0_TX     (*((volatile unsigned int *)0x80010004U))
#define UART0_RX     (*((volatile unsigned int *)0x80010008U))
#define WS2812B0     (*((volatile unsigned int *)0x80020000U))

#define UART_STATUS_TX_READY (1U << 0U)
#define UART_STATUS_RX_READY (1U << 1U)

static inline unsigned int timer(void) {
    unsigned int val;
    asm volatile("rdtime %0" : "=r"(val));
    return val;
}

static void print_str(char *str) {
    while(*str) {
        while(!(UART0_STATUS & UART_STATUS_TX_READY)) {
        }
        UART0_TX = *str;
        str++;
    }
}

static void print_hex(unsigned int val) {
    const char *digits = "0123456789ABCDEF";

    for(int i = 0; i < 8; i++) {
        const int ch = (val & 0xF0000000U) >> 28U;
        while(!(UART0_STATUS & UART_STATUS_TX_READY)) {
        }
        UART0_TX = digits[ch];
        val = val << 4;
    }
}

int main(void) {
    GPIO0 = 0;

    print_str("\r\nStarting\n\r");

    print_str("Enter command:\r\n");
    print_str("   g: read LED value\r\n");
    print_str("   i: increment LED value\r\n");
    print_str("   k: read RGB LED\r\n");
    print_str("   r: read clock\r\n");

    unsigned int rgb_time = 0;
    unsigned int rgb_counter = 0;
    unsigned int rgb_state = 0;

    while(1) {
        if((timer() - rgb_time) >= 100000U) {
            rgb_time = timer();

            switch(rgb_state) {
                case 0: {
                    WS2812B0 = 0xFF0000U | (rgb_counter << 8U);
                } break;
                case 1: {
                    WS2812B0 = 0x00FF00U | ((0xFFU - rgb_counter) << 16U);
                } break;
                case 2: {
                    WS2812B0 = 0x00FF00U | (rgb_counter << 0U);
                } break;
                case 3: {
                    WS2812B0 = 0x0000FFU | ((0xFFU - rgb_counter) << 8U);
                } break;
                case 4: {
                    WS2812B0 = 0x0000FFU | (rgb_counter << 16U);
                } break;
                case 5: {
                    WS2812B0 = 0xFF0000U | ((0xFFU - rgb_counter) << 0U);
                } break;
            }

            rgb_counter++;

            if(rgb_counter == 0xFFU) {
                rgb_state++;
                if(rgb_state > 5) {
                    rgb_state = 0;
                }
                rgb_counter = 0U;
            }
        }

        if(UART0_STATUS & UART_STATUS_RX_READY) {
            const char ch = UART0_RX;

            switch(ch) {
                case 'g': {
                    print_str("LED = ");
                    print_hex(GPIO0);
                    print_str("\r\n");
                } break;
                case 'i': {
                    GPIO0++;
                } break;
                case 'k': {
                    print_str("RGB LED = ");
                    print_hex(WS2812B0);
                    print_str("\r\n");
                } break;
                case 'r': {
                    print_str("time is ");
                    print_hex(timer());
                    print_str("\r\n");
                } break;
                default: {
                    print_str("  Try again...\r\n");
                } break;
            }

            print_str("Enter command:\r\n");
            print_str("   g: read LED value\r\n");
            print_str("   i: increment LED value\r\n");
            print_str("   k: read RGB LED\r\n");
            print_str("   r: read clock\r\n");
        }
    }

    return 0;
}
