cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE "toolchain.cmake")

project(firmware)

enable_language(ASM C)

set(TARGET ${CMAKE_PROJECT_NAME}.elf)

add_executable(${TARGET}
    "src/startup.s"
    "src/main.c"
)

target_compile_options(${TARGET} PRIVATE
	$<$<COMPILE_LANGUAGE:ASM>:
        -march=rv32i2p0
        -mabi=ilp32
	>

	$<$<COMPILE_LANGUAGE:C>:
		-Os
		-Wall
        -Wextra
        -Wpedantic

        -nostartfiles
        -nostdlib
        -static

        -march=rv32i2p0
        -mabi=ilp32
	>
)

target_link_options(${TARGET} PRIVATE
	-T ${CMAKE_SOURCE_DIR}/linker.ld

    -nostartfiles
    -nostdlib
    -static

    -march=rv32i2p0
    -mabi=ilp32
)

add_custom_command(TARGET ${TARGET} POST_BUILD
	COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET} ${CMAKE_PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJDUMP} -d -j .text ${TARGET} > ${CMAKE_PROJECT_NAME}.dump
    COMMAND ${CMAKE_SIZE} ${TARGET}
    COMMAND python3 ${CMAKE_SOURCE_DIR}/convert.py ${CMAKE_PROJECT_NAME}.bin
)
