#include "uart.h"

#define UART0_STATUS (*((volatile unsigned int *)0x80010000U))
#define UART0_TX     (*((volatile unsigned int *)0x80010004U))
#define UART0_RX     (*((volatile unsigned int *)0x80010008U))

#define UART_STATUS_TX_EMPTY (1U << 0U)
#define UART_STATUS_TX_FULL  (1U << 1U)
#define UART_STATUS_RX_EMPTY (1U << 2U)
#define UART_STATUS_RX_FULL  (1U << 3U)

char uart_getc() {
    // while(UART0_STATUS & UART_STATUS_RX_EMPTY) {}
    // return UART0_RX;
    return 'i';
}

unsigned int uart_geth() {
    unsigned int v = 0;

    while(1) {
        // while(UART0_STATUS & UART_STATUS_RX_EMPTY) {}
        // const char ch = UART0_RX;
        const char ch = 'i';

        if((ch >= '0') && (ch <= '9')) {
            v = 16 * v + (ch - '0');
            uart_putc(ch);
        } else if((ch >= 'a') && (ch <= 'f')) {
            v = 16 * v + (ch - 'a' + 10);
            uart_putc(ch);
        } else if((ch >= 'A') && (ch <= 'F')) {
            v = 16 * v + (ch - 'A' + 10);
            uart_putc(ch);
        } else {
            break;
        }
    }

    return v;
}

void uart_putc(char ch) {
    while(UART0_STATUS & UART_STATUS_TX_FULL) {
    }
    UART0_TX = ch;
}

void uart_puts(char *str) {
    while(*str) {
        while(UART0_STATUS & UART_STATUS_TX_FULL) {
        }
        UART0_TX = *str;
        str++;
    }
}

void uart_puth(unsigned int val) {
    const char *digits = "0123456789ABCDEF";

    for(int i = 0; i < 8; i++) {
        const int ch = (val & 0xF0000000U) >> 28U;
        while(UART0_STATUS & UART_STATUS_TX_FULL) {
        }
        UART0_TX = digits[ch];
        val = val << 4;
    }
}
