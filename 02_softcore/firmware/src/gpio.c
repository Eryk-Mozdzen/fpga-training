#include "gpio.h"

#define GPIO (*((volatile unsigned char *)0x80000000))

void gpio_set(unsigned char val) {
    GPIO = val;
}

unsigned char gpio_get(void) {
    return GPIO;
}
