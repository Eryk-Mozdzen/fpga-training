#include "ws2812b.h"

#define WS2812B (*((volatile unsigned int *)0x80020000))

void ws2812b_set(unsigned int val) {
    WS2812B = val;
}

unsigned int ws2812b_get() {
    return WS2812B;
}
