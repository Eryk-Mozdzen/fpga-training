#include "ws2812b.h"

#define WS2812B (*((volatile unsigned int *)0x80002000))

void ws2812b_set(unsigned int val) {
    WS2812B = ((1U << 31) | (val & 0x00FFFFFFU));
}

unsigned int ws2812b_get() {
    return WS2812B;
}
