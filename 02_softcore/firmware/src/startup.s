.text

.global _start

_start:
    la sp, __stack_top

#copy_data:
#    la t0, __data_start
#    la t1, __data_end
#    la t2, __data_load
#copy_data_loop:
#    beq t0, t1, zero_bss
#    lw t3, 0(t2)
#    sw t3, 0(t0)
#    addi t0, t0, 4
#    addi t2, t2, 4
#    j copy_data_loop

zero_bss:
    la t0, __bss_start
    la t1, __bss_end
zero_bss_loop:
    beq t0, t1, main_function
    sw  zero, 0(t0)
    addi t0, t0, 4
    j zero_bss_loop

main_function:
    call main
    j main_function
