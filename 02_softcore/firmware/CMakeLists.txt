cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE "toolchain.cmake")

project(firmware)

enable_language(ASM C)

set(TARGET ${CMAKE_PROJECT_NAME}.elf)

add_executable(${TARGET}
    "src/startup.s"
    "src/main.c"
    "src/leds.c"
    "src/uart.c"
    "src/ws2812b.c"
)

target_include_directories(${TARGET} PRIVATE
    "include"
)

target_compile_definitions(${TARGET} PRIVATE
    SRAM_ADDR_WIDTH=12
    CLK_FREQ=27000000
)

target_compile_options(${TARGET} PRIVATE
	$<$<COMPILE_LANGUAGE:ASM>:
        --defsym SRAM_ADDR_WIDTH=12

        -march=rv32i2p0
        -mabi=ilp32
	>

	$<$<COMPILE_LANGUAGE:C>:
		-O1
		-Wall
        -Wextra
        -Wpedantic

        -mno-save-restore
        -nostartfiles
        -nostdlib
        -static

        -march=rv32i2p0
        -mabi=ilp32
	>
)

target_link_options(${TARGET} PRIVATE
	-T ${CMAKE_SOURCE_DIR}/linker.ld

	-mno-save-restore
    -nostartfiles
    -nostdlib
    -static

    -march=rv32i2p0
    -mabi=ilp32
)

add_custom_command(TARGET ${TARGET} POST_BUILD
	COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET} ${CMAKE_PROJECT_NAME}.bin
    COMMAND rm -f ${CMAKE_SOURCE_DIR}/../src/mem_init[0-3].ini ../src/sys_parameters.v
    COMMAND gcc ${CMAKE_SOURCE_DIR}/conv_to_init.c -o ${CMAKE_SOURCE_DIR}/build/conv_to_init
    COMMAND ${CMAKE_SOURCE_DIR}/build/conv_to_init 27000000 12 ${CMAKE_PROJECT_NAME}.bin
)
