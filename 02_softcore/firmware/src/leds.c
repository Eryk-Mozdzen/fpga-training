#include "leds.h"

#define LEDS ((volatile unsigned char *)0x80000000)

void leds_set(unsigned char val) {
    *LEDS = val;
}

unsigned char leds_get(void) {
    return *LEDS;
}
