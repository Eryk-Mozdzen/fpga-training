ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS {
    .text : {
        *(.init)
        *(.text*)
        *(.rodata*)
        *(.srodata*)
    } > RAM

    .data : {
        *(.data*)
    } > RAM

    .bss : {
        *(.sbss*)
        *(.bss*)
        *(COMMON)
    } > RAM

    _end = .;
}
