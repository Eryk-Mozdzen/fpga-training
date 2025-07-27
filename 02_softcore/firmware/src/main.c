#include "gpio.h"
#include "uart.h"
#include "ws2812b.h"

#define MEMSIZE 512

unsigned int mem[MEMSIZE];
unsigned int test_vals[] = {
    0, 0xffffffff, 0xaaaaaaaa, 0x55555555, 0xdeadbeef,
};

static unsigned int mem_test() {
    unsigned int i, test, errors;
    unsigned int val_read;

    errors = 0;
    for(test = 0; test < sizeof(test_vals) / sizeof(test_vals[0]); test++) {

        for(i = 0; i < MEMSIZE; i++)
            mem[i] = test_vals[test];

        for(i = 0; i < MEMSIZE; i++) {
            val_read = mem[i];
            if(val_read != test_vals[test])
                errors += 1;
        }
    }

    for(i = 0; i < MEMSIZE; i++)
        mem[i] = i + (i << 17);

    for(i = 0; i < MEMSIZE; i++) {
        val_read = mem[i];
        if(val_read != i + (i << 17))
            errors += 1;
    }

    return (errors);
}

static inline unsigned int readtime() {
    unsigned int val;
    asm volatile("rdtime %0" : "=r"(val));
    return val;
}

static void endian_test() {
    volatile unsigned int test_loc = 0;
    volatile unsigned int *addr = &test_loc;
    volatile unsigned char *cp0, *cp3;
    char byte0, byte3;
    unsigned int i, ok;

    cp0 = (volatile unsigned char *)addr;
    cp3 = cp0 + 3;
    *addr = 0x44332211;
    byte0 = *cp0;
    byte3 = *cp3;
    *cp3 = 0xab;
    i = *addr;

    ok = (byte0 == 0x11) && (byte3 == 0x44) && (i == 0xab332211);
    uart_puts("\r\nEndian test: at ");
    uart_print_hex((unsigned int)addr);
    uart_puts(", byte0: ");
    uart_print_hex((unsigned int)byte0);
    uart_puts(", byte3: ");
    uart_print_hex((unsigned int)byte3);
    uart_puts(",\r\n     word: ");
    uart_print_hex(i);
    if(ok)
        uart_puts(" [PASSED]\r\n");
    else
        uart_puts(" [FAILED]\r\n");
}

static void la_wtest() {
    unsigned int v;
    volatile unsigned int *ip = (volatile unsigned int *)&v;
    volatile unsigned short *sp = (volatile unsigned short *)&v;
    volatile unsigned char *cp = (volatile unsigned char *)&v;

    *ip = 0x03020100; // addr 0x00

    *sp = 0x0302;       // addr 0x00
    *(sp + 1) = 0x0100; // addr 0x02

    *cp = 0x03;       // addr 0x00
    *(cp + 1) = 0x02; // addr 0x01
    *(cp + 2) = 0x01; // addr 0x02
    *(cp + 3) = 0x00; // addr 0x03
}

static void la_rtest() {
    unsigned int v;
    volatile unsigned int *ip = (volatile unsigned int *)&v;
    volatile unsigned short *sp = (volatile unsigned short *)&v;
    volatile unsigned char *cp = (volatile unsigned char *)&v;

    *ip = 0x03020100; // addr 0x00

    *ip; // addr 0x00

    *sp;       // addr 0x00
    *(sp + 1); // addr 0x02

    *cp;       // addr 0x00
    *(cp + 1); // addr 0x01
    *(cp + 2); // addr 0x02
    *(cp + 3); // addr 0x03
}

int main() {
    unsigned char v, ch;

    gpio_set(6);
    la_wtest();
    la_rtest();

    uart_set_div(CLK_FREQ / 115200.0 + 0.5);

    uart_puts("\r\nStarting, CLK_FREQ: 0x");
    uart_print_hex(CLK_FREQ);
    uart_puts("\r\n\r\n");

    while(1) {
        uart_puts("Enter command:\r\n");
        uart_puts("   e: endian test\r\n");
        uart_puts("   g: read LED value\r\n");
        uart_puts("   i: increment LED value\r\n");
        uart_puts("   l: set RGB LED\r\n");
        uart_puts("   m: memory test\r\n");
        uart_puts("   r: read clock\r\n");
        ch = uart_getchar();
        switch(ch) {
            case 'e':
                endian_test();
                break;
            case 'g':
                v = gpio_get();
                uart_puts("LED = ");
                uart_print_hex(v);
                uart_puts("\r\n");
                break;
            case 'i':
                v = gpio_get();
                gpio_set(v + 1);
                break;
            case 'l':
                uart_puts(" enter 6 hex digits: ");
                ws2812b_set(uart_get_hex());
                uart_puts("\r\n");
                break;
            case 'm':
                if(mem_test())
                    uart_puts("memory test FAILED.\r\n");
                else
                    uart_puts("memory test PASSED.\r\n");
                break;
            case 'r':
                uart_puts("time is ");
                uart_print_hex(readtime());
                uart_puts("\r\n");
                break;
            default:
                uart_puts("  Try again...\r\n");
                break;
        }
    }

    return 0;
}
