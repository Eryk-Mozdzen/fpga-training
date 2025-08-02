cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE "toolchain.cmake")

project(firmware)

enable_language(ASM C)

set(TARGET ${CMAKE_PROJECT_NAME}.elf)

add_executable(${TARGET}
    "src/startup.s"
    "src/main.c"
    "src/gpio.c"
    "src/uart.c"
    "src/ws2812b.c"
)

target_include_directories(${TARGET} PRIVATE
    "include"
)

target_compile_definitions(${TARGET} PRIVATE
    CLK_FREQ=27000000
)

target_compile_options(${TARGET} PRIVATE
	$<$<COMPILE_LANGUAGE:ASM>:
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
    COMMAND ${CMAKE_SIZE} ${TARGET}
    COMMAND rm -f ${CMAKE_SOURCE_DIR}/../src/mem_init.ini
    COMMAND gcc ${CMAKE_SOURCE_DIR}/conv_to_init.c -o ${CMAKE_SOURCE_DIR}/build/conv_to_init
    COMMAND ${CMAKE_SOURCE_DIR}/build/conv_to_init ${CMAKE_PROJECT_NAME}.bin
)
