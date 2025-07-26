#include "ws2812b.h"

#define WS2812B_VAL ((volatile unsigned int *)0x80000020)

void ws2812b_set(unsigned int val) {
    *WS2812B_VAL = val;
}
