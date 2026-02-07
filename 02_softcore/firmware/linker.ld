ENTRY(_start)

MEMORY {
    RAM   (rwx) : ORIGIN = 0x10000000, LENGTH = 60K
    STACK (rw)  : ORIGIN = 0x1000F000, LENGTH = 4K
}

SECTIONS {
    .text : {
        *(.init)
        *(.text*)
        *(.rodata*)
        *(.srodata*)
    } > RAM

    .data : ALIGN(4) {
        /* __data_start = .; */
        *(.data*)
        /* __data_end = .; */
    } > RAM

    .bss : ALIGN(4) {
        __bss_start = .;
        *(.sbss*)
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } > RAM

    _end = .;

    /* __data_load = LOADADDR(.data); */
    __stack_top = ORIGIN(STACK) + LENGTH(STACK);
}
